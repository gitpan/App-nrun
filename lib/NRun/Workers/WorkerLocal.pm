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
# Program: WorkerLocal.pm
# Author:  Timo Benk <benk@b1-systems.de>
# Date:    Thu May 9 08:08:32 2013 +0200
# Ident:   03a00d9a9995d1ad059b127162589f3bdcebc8cc
# Branch:  master
#
# Changelog:--reverse --grep '^tags.*relevant':-1:%an : %ai : %s
# 
# Timo Benk : 2013-04-28 17:27:31 +0200 : initial checkin
# Timo Benk : 2013-04-29 18:53:21 +0200 : introducing ncopy
# Timo Benk : 2013-05-08 09:55:24 +0200 : TARGET_HOST is now visible in ps output
#

package WorkerLocal;

use strict;
use warnings;

use File::Basename;
use NRun::Worker;

our @ISA = qw(NRun::Worker);

###
# module specification
our $MODINFO = {

  'MODE' => "local",
  'DESC' => "execute the script locally, set TARGET_HOST on each execution",
};

###
# create a new object.
#
# <- the new object
sub new {

    my $_pkg = shift;
    my $_obj = shift;

    my $self = {};
    bless $self, $_pkg;

    $self->{MODINFO} = $MODINFO;
    return $self;
}

###
# copy a file to $_host.
#
# $_host   - the host the command should be exeuted on
# $_source - source file to be copied
# $_target - destination $_source should be copied to
# <- (
#      $ret - the return code
#      $out - command output
#    )
sub copy {

    my $_self   = shift;
    my $_host   = shift;
    my $_source = shift;
    my $_target = shift;

    return (1, "not implemented");
}

###
# execute the command locally and set environment variable TARGET_HOST
# to $_host.
#
# $_host    - the host the command should be exeuted on
# $_command - the command that should be executed
# $_args    - arguments that should be supplied to $_command
# <- (
#      $ret - the return code
#      $out - command output
#    )
sub execute {

    my $_self    = shift;
    my $_host    = shift;
    my $_command = shift;
    my $_args    = shift;

    return _("TARGET_HOST=$_host $_command $_args");
}

###
# delete a file on $_host.
#
# $_host - the host the command should be exeuted on
# $_file - the command that should be executed
# <- (
#      $ret - the return code
#      $out - command output
#    )
sub delete {

    my $_self = shift;
    my $_host = shift;
    my $_file = shift;

    return (1, "not implemented");
}

1;

