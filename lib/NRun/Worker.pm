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
# Date:    Fri May 24 08:03:19 2013 +0200
# Ident:   88db47d4612f4742ac757cc09f728ebcaf7f6815
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
# Timo Benk : 2013-05-21 18:47:43 +0200 : parameter --async added
# Timo Benk : 2013-05-22 13:09:13 +0200 : option --no-logfile was broken
# Timo Benk : 2013-05-22 13:20:36 +0200 : --skip-ping-check and --skip-ns-check enabled
# Timo Benk : 2013-05-24 08:03:19 +0200 : generic mode added
#

package NRun::Worker;

use strict;
use warnings;

use File::Basename;
use NRun::Semaphore;
use NRun::Signal;
use NRun::Constants;

###
# automagically load all available modules
INIT {

    my $basedir = dirname($INC{"NRun/Worker.pm"}) . "/Workers";

    opendir(DIR, $basedir) or die("$basedir: $!");
    while (my $module = readdir(DIR)) {

        if ($module =~ /\.pm$/i) {

            require "$basedir/$module";
        }
    }
    close DIR;
}

###
# all available workers will be registered here
my $workers = {};

###
# will be called by the worker modules on INIT.
#
# $_cfg - parameter hash where
# {
#   'MODE' - mode name
#   'DESC' - mode description
#   'NAME' - module name
# }
sub register {

    my $_cfg = shift;

    $workers->{$_cfg->{MODE}} = $_cfg;
}

###
# return all available worker modules
sub workers {

    return $workers;
}

###
# create a new object.
#
# <- the new object
sub new {

    my $_pkg = shift;

    my $self = {};
    bless $self, $_pkg;

    return $self;
}

###
# initialize this worker module.
#
# $_cfg - parameter hash where
# {
#   'hostname' - hostname this worker should act on
#   'dumper'   - dumper object
#   'logger'   - logger object
#   'skip_ns_check'   - skip nslookup test in pre_check()
#   'skip_ping_check' - skip ping test in pre_check()
# }
sub init {

    my $_self = shift;
    my $_cfg  = shift;

    $_self->{hostname} = $_cfg->{hostname};
    $_self->{dumper}   = $_cfg->{dumper};
    $_self->{logger}   = $_cfg->{logger};

    $_self->{skip_ns_check}   = $_cfg->{skip_ns_check};
    $_self->{skip_ping_check} = $_cfg->{skip_ping_check};
}

###
# signal handler.
sub handler {

    my $_pid  = shift;

    if ($$_pid != -128) {

        kill(KILL => $$_pid);
    }
}

###
# execute $_cmd.
#
# $_cmd -  the command to be executed
# <- (
#      $out - command output
#      $ret - the return code 
#    )
sub do {

    my $_self = shift;
    my $_cmd  = shift;

    chomp($_cmd);

    my $pid = -128;
    my @out = ();

    my $handler_alrm = NRun::Signal::register('ALRM', \&handler, [ \$pid ]);
    my $handler_int  = NRun::Signal::register('INT',  \&handler, [ \$pid ]);
    my $handler_term = NRun::Signal::register('TERM', \&handler, [ \$pid ]);

    $pid = open(CMD, "$_cmd 2>&1 |");
    if (not defined($pid)) {

        $_self->{dumper}->push("$_cmd: $!\n") if (defined($_self->{dumper}));
        $_self->{logger}->push("$_cmd: $!\n") if (defined($_self->{logger}));
        $_self->{dumper}->code($NRun::Constants::EXECUTION_FAILED) if (defined($_self->{dumper}));
        $_self->{logger}->code($NRun::Constants::EXECUTION_FAILED) if (defined($_self->{logger}));

        NRun::Signal::deregister('ALRM', $handler_alrm);
        NRun::Signal::deregister('INT',  $handler_int);
        NRun::Signal::deregister('TERM', $handler_term);

        return ( "$_cmd: $!\n", $NRun::Constants::EXECUTION_FAILED );
    }
    
    $_self->{dumper}->command("($pid) $_cmd") if (defined($_self->{dumper}));
    $_self->{logger}->command("($pid) $_cmd") if (defined($_self->{logger}));
    while (my $line = <CMD>) {
    
        $_self->{dumper}->push($line) if (defined($_self->{dumper}));
        $_self->{logger}->push($line) if (defined($_self->{logger}));
        push(@out, $line);
    }
    close(CMD);
    $_self->{dumper}->command() if (defined($_self->{dumper}));
    $_self->{logger}->command() if (defined($_self->{logger}));

    $_self->{dumper}->code($? >> 8) if (defined($_self->{dumper}));
    $_self->{logger}->code($? >> 8) if (defined($_self->{logger}));

    NRun::Signal::deregister('ALRM', $handler_alrm);
    NRun::Signal::deregister('INT',  $handler_int);
    NRun::Signal::deregister('TERM', $handler_term);


    return ( join("", @out), $? >> 8 );
}

###
# must be called at end of execution.
#
# global destruction in DESTROY is not safe
sub destroy {

    my $_self = shift;

    $_self->{dumper}->destroy() if (defined($_self->{dumper}));
    $_self->{logger}->destroy() if (defined($_self->{logger}));
}

###
# do some general checks.
#
# - ping check (will be checked if $_self->{skip_ns_check})
# - dns check (will be checked if $_self->{skip_dns_check)
#
# <- 1 on success and 0 on error
sub pre_check {

    my $_self = shift; 

    if (not (defined($_self->{skip_ns_check}) or gethostbyname($_self->{hostname}))) {

        $_self->{dumper}->push("dns entry is missing\n") if (defined($_self->{dumper}));
        $_self->{logger}->push("dns entry is missing\n") if (defined($_self->{logger}));
        $_self->{dumper}->code($NRun::Constants::MISSING_DNS_ENTRY) if (defined($_self->{dumper}));
        $_self->{logger}->code($NRun::Constants::MISSING_DNS_ENTRY) if (defined($_self->{logger}));

        return 0;
    }

    if (not (defined($_self->{skip_ping_check}) or Net::Ping->new()->ping($_self->{hostname}))) {

        $_self->{dumper}->push("not pinging\n") if (defined($_self->{dumper}));
        $_self->{logger}->push("not pinging\n") if (defined($_self->{logger}));
        $_self->{dumper}->code($NRun::Constants::PING_FAILED) if (defined($_self->{dumper}));
        $_self->{logger}->code($NRun::Constants::PING_FAILED) if (defined($_self->{logger}));

        return 0;
    }

    return 1;
}

1;

