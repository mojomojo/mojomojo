#!/usr/local/bin/perl -w

BEGIN { $ENV{CATALYST_ENGINE} ||= 'FastCGI' }

use strict;
use Getopt::Long;
use Pod::Usage;
use FindBin;
use lib "$FindBin::Bin/../lib";
use MojoMojo;

my $help = 0;
my ( $listen, $nproc );
 
GetOptions(
    'help|?'     => \$help,
    'listen|l=s' => \$listen,
    'nproc|n=i'  => \$nproc,
);

pod2usage(1) if $help;

MojoMojo->run( $listen, { nproc => $nproc } );

1;

=head1 NAME

mojomojo_fastcgi.pl - Catalyst FastCGI

=head1 SYNOPSIS

mojomojo_fastcgi.pl [options]
 
 Options:
   -? -help      display this help and exits
   -l -listen    Socket path to listen on
                 (defaults to standard input)
                 can be HOST:PORT, :PORT or a
                 filesystem path
   -n -nproc     specify number of processes to keep
                 to serve requests (defaults to 1)

=head1 DESCRIPTION

Run a Catalyst application as fastcgi.

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 COPYRIGHT

Copyright 2004 Sebastian Riedel. All rights reserved.

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
