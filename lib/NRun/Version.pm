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
# Program: Version.pm
# Author:  Timo Benk <benk@b1-systems.de>
# Date:    Fri Jun 21 09:33:02 2013 +0200
# Ident:   0a0888f029838afc5f9e5ef6753b7f5682eadab1
# Branch:  master
#
# Changelog:--reverse --grep '^tags.*relevant':-1:%an : %ai : %s
# 
# Timo Benk : 2013-05-04 18:44:26 +0200 : unnecessary use's removed
# Timo Benk : 2013-05-04 19:16:01 +0200 : being more portable
# Timo Benk : 2013-05-06 09:03:50 +0200 : version set to 1.0.0
# Timo Benk : 2013-05-08 14:20:54 +0200 : development release 1.0.0_0
# Timo Benk : 2013-05-09 08:08:32 +0200 : development release 1.0.0_1
# Timo Benk : 2013-05-09 08:11:50 +0200 : development release 1.0.0_2
# Timo Benk : 2013-05-13 18:50:47 +0200 : development release 1.0.0_3
# Timo Benk : 2013-05-13 19:02:35 +0200 : development release 1.0.0_4
# Timo Benk : 2013-05-21 18:49:02 +0200 : development release 1.0.0_5
# Timo Benk : 2013-05-23 10:10:14 +0200 : development release 1.0.0_6
# Timo Benk : 2013-05-26 07:28:04 +0200 : development
# Timo Benk : 2013-06-13 13:59:01 +0200 : process output handling refined
# Timo Benk : 2013-06-20 09:09:10 +0200 : version counter increased
# Timo Benk : 2013-06-20 19:35:35 +0200 : version counter increased
# Timo Benk : 2013-06-21 09:33:02 +0200 : version counter increased
#

###
# this package contains the nrun version string.
###

package NRun::Version;

use version;

our $VERSION = qv(1.1.0);

