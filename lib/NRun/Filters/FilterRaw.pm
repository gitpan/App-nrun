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
# Program: FilterRaw.pm
# Author:  Timo Benk <benk@b1-systems.de>
# Date:    Thu Jun 20 13:15:16 2013 +0200
# Ident:   d297da0e4f99160448131e356837143722675862
# Branch:  master
#
# Changelog:--reverse --grep '^tags.*relevant':-1:%an : %ai : %s
# 
# Timo Benk : 2013-06-13 13:59:01 +0200 : process output handling refined
# Timo Benk : 2013-06-13 20:32:17 +0200 : using __PACKAGE__ is less error-prone
# Timo Benk : 2013-06-14 17:38:58 +0200 : --no-hostname option removed
#

###
# this filter prints the raw data received by the worker modules.
###

package NRun::Filters::FilterRaw;

use strict;
use warnings;

use File::Basename;
use NRun::Filter;

our @ISA = qw(NRun::Filter);

BEGIN {

    NRun::Filter::register ( {

        'FILTER' => "raw",
        'DESC'   => "dump the raw data received from the worker module",
        'NAME'  => __PACKAGE__,
    } );
}

###
# create a new object.
#
# <- the new object
sub new {

    my $_pkg = shift;
    my $_obj = shift;

    my $self = {};
    bless $self, $_pkg;

    return $self;
}

###
# initialize this filter module.
sub init {

    my $_self = shift;
}


###
# handle one line of data written on stdout.
#
# expected data format:
#
# HOSTNAME;[stdout|stderr];TSTAMP;PID;PID(CHILD);[debug|error|exit|output|end];"OUTPUT"
#
# $_data - the data to be handled
sub stdout {

    my $_self = shift;
    my $_data = shift;

    print STDOUT $_data;
}

###
# handle one line of data written on stderr.
#
# expected data format:
#
# HOSTNAME;[stdout|stderr];TSTAMP;PID;PID(CHILD);[debug|error|exit|output|end];"OUTPUT"
#
# $_data - the data to be handled
sub stderr {

    my $_self = shift;
    my $_data = shift;

    print STDERR $_data;
}

1;
