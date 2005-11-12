#!/usr/local/bin/perl -w

use strict;
use Getopt::Long;
use Pod::Usage;
use Catalyst::Helper;

my $help = 0;
my $nonew = 0;
my $short = 0;

GetOptions(
    'help|?' => \$help,
    'nonew'  => \$nonew,
    'short'  => \$short
 );

pod2usage(1) if ( $help || !$ARGV[0] );

my $helper =
    Catalyst::Helper->new( { '.newfiles' => !$nonew, short => $short } );

pod2usage(1) unless $helper->mk_component( 'MojoMojo', @ARGV );

1;

=head1 NAME

mojomojo_create.pl - Create a new Catalyst Component

=head1 SYNOPSIS

mojomojo_create.pl [options] model|view|controller name [helper] [options]

 Options:
   -help     display this help and exits
   -nonew    don't create a .new file where a file to be created exists
   -short    use short types, like C instead of Controller...

 Examples:
   mojomojo_create.pl controller My::Controller
   mojomojo_create.pl view My::View
   mojomojo_create.pl view MyView TT
   mojomojo_create.pl view TT TT
   mojomojo_create.pl model My::Model
   mojomojo_create.pl model SomeDB CDBI dbi:SQLite:/tmp/my.db
   mojomojo_create.pl model AnotherDB CDBI dbi:Pg:dbname=foo root 4321

 See also:
   perldoc Catalyst::Manual
   perldoc Catalyst::Manual::Intro

=head1 DESCRIPTION

Create a new Catalyst Component.

Existing component files are not overwritten.  If any of the component files
to be created already exist the file will be written with a '.new' suffix.
This behavior can be suppressed with the C<-nonew> option.

=head1 AUTHOR

Sebastian Riedel, C<sri\@oook.de>

=head1 COPYRIGHT

Copyright 2004 Sebastian Riedel. All rights reserved.

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
