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
# Program: Logger.pm
# Author:  Timo Benk <benk@b1-systems.de>
# Date:    Mon Jul 8 18:32:15 2013 +0200
# Ident:   9aabc196df582c9b4ee3874e36e58d9f53d4e214
# Branch:  HEAD, v1.1.1, origin/master, origin/HEAD, master
#
# Changelog:--reverse --grep '^tags.*relevant':-1:%an : %ai : %s
# 
# Timo Benk : 2013-04-28 17:27:31 +0200 : initial checkin
# Timo Benk : 2013-05-09 07:31:52 +0200 : fix race condition in semaphore cleanup code
# Timo Benk : 2013-05-21 18:47:43 +0200 : parameter --async added
# Timo Benk : 2013-06-13 13:59:01 +0200 : process output handling refined
# Timo Benk : 2013-06-14 17:38:58 +0200 : --no-hostname option removed
#

###
# this is the base module for all logger implementations and
# it is responsible for loading the available implementations
# at runtime.
#
# a logger formats the ouput from the child processes and writes
# this formatted output into a logfile.
#
# derived modules must implement the following subs's
#
# - init($cfg)
# - stderr($data)
# - stdout($data)
#
# a derived module must call register() in BEGIN{}, otherwise it will not
# be available.
#
# the output (which is generated by the worker processes, collected by the
# sink object and passed to the filter/logger modules) is expected to match
# the following format:
#
# HOSTNAME;[stdout|stderr];TSTAMP;PID;PID(CHILD);[debug|error|exit|output|end];"OUTPUT"
###

package NRun::Logger;

use strict;
use warnings;

use File::Basename;

###
# automagically load all available modules
INIT {

    my $basedir = dirname($INC{"NRun/Logger.pm"}) . "/Loggers";

    opendir(DIR, $basedir) or die("$basedir: $!");
    while (my $module = readdir(DIR)) {

        if ($module =~ /\.pm$/i) {

            require "$basedir/$module";
        }
    }
    close DIR;
}

###
# all available logger will be registered here
my $loggers = {};

###
# will be called by the logger modules on INIT.
#
# $_cfg - parameter hash where
# {
#   'LOGGER' - logger name
#   'DESC'   - logger description
#   'NAME'   - module name
# }
sub register {

    my $_cfg = shift;

    $loggers->{$_cfg->{LOGGER}} = $_cfg;
}

###
# return all available logger modules
sub loggers {

    return $loggers;
}

1;
