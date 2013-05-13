#
# Copyright 2013 Timo Benk
# 
# This file is part of nrun.
# 
# nrun is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# nrun is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with nrun.  If not, see <http://www.gnu.org/licenses/>.
#
# Program: Worker.pm
# Author:  Timo Benk <benk@b1-systems.de>
# Date:    Mon May 13 18:54:32 2013 +0200
# Ident:   beeacd63b3b9e6fe986adc9c52feb80ebaf984d8
# Branch:  <REFNAMES>
#
# Changelog:--reverse --grep '^tags.*relevant':-1:%an : %ai : %s
# 
# Timo Benk : 2013-04-28 17:27:31 +0200 : initial checkin
# Timo Benk : 2013-04-29 18:53:21 +0200 : introducing ncopy
# Timo Benk : 2013-05-03 13:52:25 +0200 : no output was returned on timeout
# Timo Benk : 2013-05-03 19:16:11 +0200 : no output was returned on SIGINT
# Timo Benk : 2013-05-08 10:05:39 +0200 : better signal handling implemented
# Timo Benk : 2013-05-08 13:46:36 +0200 : skip empty output when signaled USR1/USR2
# Timo Benk : 2013-05-09 07:31:52 +0200 : fix race condition in semaphore cleanup code
#

package NRun::Worker;

use strict;
use warnings;

use File::Basename;
use NRun::Semaphore;

my $semaphore;
my $workers = {};

###
# module specification
our $MODINFO = {

  'MODE' => "",
  'DESC' => "",
};

###
# return all available worker modules
sub workers {

    return $workers;
}

###
# dynamically load all available login modules
#
# $_cfg - option hash given to the submodules on creation
# $_sem - semaphore object 
sub init {

    my $_cfg = shift;
    my $_sem = shift;

    $semaphore = $_sem;

    my $basedir = dirname($INC{"NRun/Worker.pm"}) . "/Workers";

    opendir(DIR, $basedir) or die("$basedir: $!");
    while (my $module = readdir(DIR)) {

        if ($module =~ /\.pm$/i) {

            require "$basedir/$module";

            $module =~ s/\.pm$//i;

            my $object = $module->new($_cfg);
            $workers->{$object->mode()} = $object;
        }
    }
    close DIR;
}

###
# execute $_cmd. will die on SIGALRM.
#
# $_cmd -  the command to be executed
# <- (
#      $ret - the return code
#      $out - command output (joined stderr and stdout)
#    )
sub _ {

    my $_cmd = shift;

    my $pid = -128;
    my @out;

    local $SIG{USR1} = sub {

        $semaphore->lock();
        print STDERR "[$$]: ($pid) $_cmd\n";
        print STDERR "[$$]: " . join("[$$]: ", @out) if (scalar(@out));
        $semaphore->unlock();
    };

    local $SIG{USR2} = sub {

        $semaphore->lock();

        if (not open(LOG, ">>trace.txt")) {

            print STDERR "trace.txt: $!\n";
            return;
        }

        print LOG "[$$]: ($pid) $_cmd\n";
        print LOG "[$$]: " . join("[$$]: ", @out) if (scalar(@out));

        close(LOG);

        $semaphore->unlock();
    };

    local $SIG{INT} = sub {

        kill(9, $pid);
        push(@out, "SIGINT received\n");
        die join("", @out);
    };

    local $SIG{ALRM} = sub {

        kill(9, $pid);
        push(@out, "SIGALRM received (timeout)\n");
        die join("", @out);
    };

    local $SIG{TERM} = sub {

        kill(9, $pid);
        push(@out, "SIGTERM received\n");
        die join("", @out);
    };

    $pid = open(CMD, "$_cmd 2>&1 2>&1|") or die "$_cmd: $!\n"; 
    while (my $line = <CMD>) {
    
       push(@out, $line);
    }
    close(CMD);

    return ($? >> 8, join("", @out));
}

###
# return this modules mode
sub mode {

    my $_self = shift;
    return $_self->{MODINFO}->{MODE};
}

###
# return this modules description
sub desc {

    my $_self = shift;
    return $_self->{MODINFO}->{DESC};
}

1;

