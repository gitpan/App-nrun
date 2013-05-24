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
# Program: WorkerGeneric.pm
# Author:  Timo Benk <benk@b1-systems.de>
# Date:    Fri May 24 08:03:19 2013 +0200
# Ident:   88db47d4612f4742ac757cc09f728ebcaf7f6815
# Branch:  master
#
# Changelog:--reverse --grep '^tags.*relevant':-1:%an : %ai : %s
# 
# Timo Benk : 2013-05-24 08:03:19 +0200 : generic mode added
#

package NRun::Worker::WorkerGeneric;

use strict;
use warnings;

use File::Basename;
use NRun::Worker;
use POSIX qw(getuid);

our @ISA = qw(NRun::Worker);

BEGIN {

    NRun::Worker::register ( {

        'MODE' => "generic",
        'DESC' => "generic mode",
        'NAME' => "NRun::Worker::WorkerGeneric",
    } );
}

###
# create a new object.
#
# <- the new object
sub new {

    my $_pkg = shift;
    my $_cfg = shift;

    my $self = {};
    bless $self, $_pkg;

    return $self;
}

###
# initialize this worker module.
#
# $_cfg - parameter hash where
# {
#   'hostname'       - hostname this worker should act on
#   'dumper'         - dumper object
#   'logger'         - logger object
#   'generic_copy'   - commandline for the copy command (SOURCE, TARGET, HOSTNAME will be replaced)
#   'generic_exec'   - commandline for the exec command (COMMAND, ARGUMENTS, HOSTNAME will be replaced)
#   'generic_delete' - commandline for the delete command (FILE, HOSTNAME will be replaced)
# }
sub init {

    my $_self = shift;
    my $_cfg  = shift;

    $_self->SUPER::init($_cfg);

    $_self->{generic_copy}   = $_cfg->{generic_copy};
    $_self->{generic_exec}   = $_cfg->{generic_exec};
    $_self->{generic_delete} = $_cfg->{generic_delete};
}

###
# copy a file to $_self->{hostname}.
#
# $_source - source file to be copied
# $_target - destination $_source should be copied to
# <- the return code
sub copy {

    my $_self   = shift;
    my $_source = shift;
    my $_target = shift;

    my $cmdline = $_self->{generic_copy};

    $cmdline =~ s/SOURCE/$_source/g;
    $cmdline =~ s/TARGET/$_target/g;
    $cmdline =~ s/HOSTNAME/$_self->{hostname}/g;

    my ( $out, $ret ) = $_self->do($cmdline);

    return $ret;
}

###
# execute the command on $_self->{hostname}.
#
# $_command - the command that should be executed
# $_args    - arguments that should be supplied to $_command
# <- the return code
sub execute {

    my $_self    = shift;
    my $_command = shift;
    my $_args    = shift;

    my $cmdline = $_self->{generic_exec};

    $cmdline =~ s/COMMAND/$_command/g;
    $cmdline =~ s/ARGUMENTS/$_args/g;
    $cmdline =~ s/HOSTNAME/$_self->{hostname}/g;

    my ( $out, $ret ) = $_self->do($cmdline);

    return $ret;
}

###
# delete a file on $_self->{hostname}.
#
# $_file - the file that should be deleted
# <- the return code
sub delete {

    my $_self = shift;
    my $_file = shift;

    my $cmdline = $_self->{generic_delete};

    $cmdline =~ s/FILE/$_file/g;
    $cmdline =~ s/HOSTNAME/$_self->{hostname}/g;

    my ( $out, $ret ) = $_self->do($cmdline);

    return $ret;
}

1;

