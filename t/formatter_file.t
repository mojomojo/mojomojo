#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More  tests => 7;


use_ok('MojoMojo::Formatter::File');

my $dir = "t/var/files";
my %files = ( 'test.xml' => 'DocBook',
	      'test.pod' => 'Pod',
	      'test.tst' => 'Test',
	    );

foreach my $file ( keys %files ){
  my $plugin   = MojoMojo::Formatter::File->plugin($file);
  is($plugin, $files{$file});
  ok(MojoMojo::Formatter::File->format($plugin, "$dir/$file"));
}

