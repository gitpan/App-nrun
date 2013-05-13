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
# Program: WorkerRsh.pm
# Author:  Timo Benk <benk@b1-systems.de>
# Date:    Mon May 13 18:54:32 2013 +0200
# Ident:   beeacd63b3b9e6fe986adc9c52feb80ebaf984d8
# Branch:  master
#
# Changelog:--reverse --grep '^tags.*relevant':-1:%an : %ai : %s
# 
# Timo Benk : 2013-04-28 17:27:31 +0200 : initial checkin
# Timo Benk : 2013-04-28 20:02:52 +0200 : options --skip-ping-check and --skip-ns-check added
# Timo Benk : 2013-04-28 22:01:00 +0200 : ping and ns check moved into Main::callback_action
# Timo Benk : 2013-04-29 18:53:21 +0200 : introducing ncopy
#

package WorkerRsh;

use strict;
use warnings;

use File::Basename;
use NRun::Worker;
use POSIX qw(getuid);

our @ISA = qw(NRun::Worker);

###
# module specification
our $MODINFO = {

  'MODE' => "rsh",
  'DESC' => "rsh based remote execution",
};

###
# create a new object.
#
# $_cfg - parameter hash where
# {
#   'rsh_args'   - arguments supplied to the rsh binary
#   'rcp_args'   - arguments supplied to the rcp binary
#   'rsh_binary' - rsh binary to be executed
#   'rcp_binary' - rcp binary to be executed
#   'rsh_user'   - rsh login user
#   'rcp_user'   - rcp login user
# }
# <- the new object
sub new {

    my $_pkg = shift;
    my $_cfg = shift;

    my $self = {};
    bless $self, $_pkg;

    $self->{rsh_args}   = $_cfg->{rsh_args};
    $self->{rcp_args}   = $_cfg->{rcp_args};
    $self->{rsh_binary} = $_cfg->{rsh_binary};
    $self->{rcp_binary} = $_cfg->{rcp_binary};
    $self->{rsh_user}   = $_cfg->{rsh_user};
    $self->{rcp_user}   = $_cfg->{rcp_user};

    if (not defined($self->{rsh_user})) {

        ($self->{rsh_user}) = getpwuid(getuid());
    }

    if (not defined($self->{rcp_user})) {

        ($self->{rcp_user}) = getpwuid(getuid());
    }

    $self->{MODINFO} = $MODINFO;
    return $self;
}

###
# copy a file using rsh to $_host.
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

    return _("$_self->{rcp_binary} $_self->{rcp_args} $_source $_self->{rcp_user}\@$_host:$_target");
}

###
# execute the command using rsh on $_host.
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

    return _("$_self->{rsh_binary} $_self->{rsh_args} -l $_self->{rsh_user} $_host $_command $_args");
}

###
# delete a file using rsh on $_host.
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

    return _("$_self->{rsh_binary} $_self->{rsh_args} -l $_self->{rsh_user} $_host rm -f \"$_file\"");
}

1;

