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
  SKIP:{ 
  my $package="MojoMojo::Formatter::File::".$plugin;
  skip("$file formatter not loaded",2) unless $package->module_loaded;
  is($plugin, $files{$file});
  ok(MojoMojo::Formatter::File->format($plugin, "$dir/$file"));
  }
}

