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
# Date:    Thu May 9 08:08:32 2013 +0200
# Ident:   03a00d9a9995d1ad059b127162589f3bdcebc8cc
# Branch:  master
#
# Changelog:--reverse --grep '^tags.*relevant':-1:%an : %ai : %s
# 
# Timo Benk : 2013-04-28 17:27:31 +0200 : initial checkin
# Timo Benk : 2013-05-09 07:31:52 +0200 : fix race condition in semaphore cleanup code
#

package NRun::Logger;

use strict;
use warnings;

use File::Path;
use NRun::Semaphore;

###
# create a new object.
#
# $_obj - parameter hash where
# {
#   'basedir'   - the basedir the logs should be written to
#   'semaphore' - the semaphore lock object
# }
# <- the new object
sub new {

    my $_pkg = shift;
    my $_obj = shift;

    my $self = {};
    bless $self, $_pkg;

    $self->{basedir}   = $_obj->{basedir};
    $self->{semaphore} = $_obj->{semaphore};

    mkpath("$self->{basedir}/hosts");

    unlink("$self->{basedir}/../latest");
    symlink("$self->{basedir}", "$self->{basedir}/../latest");

    return $self;
}

###
# log the output
#
# $_host - the host this result belongs to
# $_ret  - the script return code
# $_out  - the script output
sub log {

    my $_self = shift;
    my $_host = shift;
    my $_ret  = shift;
    my $_out  = shift;

    $_self->{semaphore}->lock();

    open(RES, ">>$_self->{basedir}/results.log")
      or die("$_self->{basedir}/results.log: $!");

    open(LOG, ">>$_self->{basedir}/hosts/$_host.log")
      or die("$_self->{basedir}/$_host.log: $!");

    open(OUT, ">>$_self->{basedir}/output.log")
      or die("$_self->{basedir}/output.log: $!");

    print RES "$_host; exit code $_ret; $_self->{basedir}/hosts/$_host.log\n";

    print LOG "$_out";

    $_out =~ s/^/$_host: /gms;

    chomp($_out);
    $_out .= "\n";    # ensure newline at end of line

    print OUT $_out;

    close(OUT);
    close(RES);
    close(LOG);

    $_self->{semaphore}->unlock();
}

1;

