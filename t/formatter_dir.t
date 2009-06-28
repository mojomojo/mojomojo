#!/usr/bin/perl -w
use strict;
use MojoMojo::Formatter::Dir;
use Test::More;
use lib 't/lib';
use FakeCatalystObject;
use Directory::Scratch;


BEGIN { 
    plan skip_all => 'Requirements not installed for Dir Formatter'
        unless MojoMojo::Formatter::Dir->module_loaded;

    plan tests => 3;
};


my $baseuri = "/";
my $path    = "test";
my $content;
my $ret;


my $dir = Directory::Scratch->new();

$content = "{{dir $dir}}";
$ret = MojoMojo::Formatter::Dir->to_xhtml($dir, $baseuri, $path);
is($ret, <<HTML);
<div id="dirs"><ul></ul></div>
<div id="files"><ul></ul></div>
HTML


$dir->mkdir('foo');

$ret = MojoMojo::Formatter::Dir->to_xhtml($dir, $baseuri, $path);
is($ret, <<HTML);
<div id="dirs"><ul><li><a href="/test/foo">[foo]</a></li></ul></div>
<div id="files"><ul></ul></div>
HTML


$dir->touch('bar.txt', 'bla bla bla');
$dir->touch('bar.pod', '=head1 NAME\n\ntest');

$ret = MojoMojo::Formatter::Dir->to_xhtml($dir, $baseuri, $path);
is($ret, <<HTML);
<div id="dirs"><ul><li><a href="/test/foo">[foo]</a></li></ul></div>
<div id="files"><ul><li><a href="/test/bar_pod">bar_pod</a></li><li><a href="/test/bar_txt">bar_txt</a></li></ul></div>
HTML
