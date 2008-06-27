#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  hash_passwords.pl
#
#        USAGE:  ./hash_passwords.pl 
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Marcus Ramberg (MRAMBERG), <mramberg@cpan.org>
#      COMPANY:  Nordaaker Ltd
#      VERSION:  1.0
#      CREATED:  06/27/2008 22:59:39 CEST
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use MojoMojo;

my $users=MojoMojo->model('DBIC::Person')->search;
while (my $user=$users->next) {
    $user->pass($user->get_column('pass'));
    $user->update;
}
