#!/usr/bin/perl -w
use strict;
use MojoMojo::Formatter::Dir;
use Test::More;
use lib 't/lib';
use FakeCatalystObject;


BEGIN { 
    plan skip_all => 'Requirements not installed for Dir Formatter' 
        unless MojoMojo::Formatter::Dir->module_loaded;

    plan tests => 1;
};


my $dir = "/tmp/plugindir";
my $baseuri = "/";
my $path    = "test";
my $content;

mkdir('/tmp/plugindir');
mkdir('/tmp/plugindir/toto');

$content = "{{dir $dir}}";
print MojoMojo::Formatter::Dir->to_xhtml($dir, $baseuri, $path);


#$content = MojoMojo::Formatter::Dir->format($dir, $fake_c);
#print $content;

rmdir('/tmp/plugindir');
