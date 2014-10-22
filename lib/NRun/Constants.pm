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
# Program: Constants.pm
# Author:  Timo Benk <benk@b1-systems.de>
# Date:    Mon Jul 8 18:32:15 2013 +0200
# Ident:   9aabc196df582c9b4ee3874e36e58d9f53d4e214
# Branch:  master
#
# Changelog:--reverse --grep '^tags.*relevant':-1:%an : %ai : %s
# 
# Timo Benk : 2013-05-21 18:47:43 +0200 : parameter --async added
# Timo Benk : 2013-06-13 13:59:01 +0200 : process output handling refined
#

###
# this package contains globally used constants.
###

package NRun::Constants;

our $CODE_SIGINT       = -255;
our $CODE_SIGTERM      = -254;
our $CODE_SIGALRM      = -253;
our $RSCD_NOT_ALIVE    = -251;
our $EXECUTON_FAILED   = -250;
our $MISSING_DNS_ENTRY = -249;
our $PING_FAILED       = -248;
our $CHECK_FAILED_PING = -247;
our $CHECK_FAILED_NS   = -246;
our $CHECK_FAILED_RSCD = -244;
our $RSCD_ERROR        = -128;

1;
