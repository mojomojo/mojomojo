#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use Pod::Usage;
use Catalyst::Helper;
use YAML;
use File::Find;
use IO::All;
use Cwd;

my $help = 0;

GetOptions( 'help|?' => $help );

pod2usage(1) if  $help ;

my %files;

foreach my $file (<DATA>) {
    chomp($file);
    if (-d $file) {
	find({wanted=>\&pack_file,no_chdir=>1},$file);
    } else {
	$_=$file;
	pack_file();
    }
}

my $module="package MojoMojo::AppData;\n1;\n\n__DATA__\n";
$module .= Dump \%files;
$module > io ('lib/MojoMojo/AppData.pm');

sub pack_file {
   return if m|/\.|; 
   return if -d ;
   warn "packing $_";
   my $data < io(cwd."/".$_);
   $files{$_} = $data;
}

=head1 NAME

packer - MojoMojo File packer

=head1 SYNOPSIS

packer.pl [options]

 Options:
   -? -help    display this help and exits

 See also:
    perldoc MojoMojo

=head1 DESCRIPTION

compress the templates and other files required by catalyst to 
function into a YAML structure, and put it into AppData.pm

=head1 AUTHOR

Marcus Ramberg C<marcus@thefeed.no>

=head1 COPYRIGHT

Copyright 2004 Sebastian Riedel. All rights reserved.

This library is free software. You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

__DATA__
db/sqlite2/mojomojo.sql
root
