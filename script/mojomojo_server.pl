#!/usr/bin/perl -w

BEGIN { 
    $ENV{CATALYST_ENGINE} = 'HTTP';
    $ENV{CATALYST_SCRIPT_GEN} = 3;
}  

use strict;
use Getopt::Long;
use Pod::Usage;
use FindBin;
use lib "$FindBin::Bin/../lib";
use MojoMojo;

my $help = 0;
my $port = 3000;

GetOptions( 'help|?' => \$help, 'port=s' => \$port );

pod2usage(1) if $help;

MojoMojo->run($port);

1;

=head1 NAME

server - Catalyst Testserver

=head1 SYNOPSIS

server.pl [options]

 Options:
   -? -help    display this help and exits
   -p -port    port (defaults to 3000)

 See also:
   perldoc Catalyst::Manual
   perldoc Catalyst::Manual::Intro

=head1 DESCRIPTION

Run a Catalyst Testserver for this application.

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 COPYRIGHT

Copyright 2004 Sebastian Riedel. All rights reserved.

This library is free software. You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

