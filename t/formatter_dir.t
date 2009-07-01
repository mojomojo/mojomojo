#!/usr/bin/perl -w
use strict;
use MojoMojo::Formatter::Dir;
use Test::More;
use lib 't/lib';
use Directory::Scratch;


BEGIN { 
    plan skip_all => 'Requirements not installed for Dir Formatter'
        unless MojoMojo::Formatter::Dir->module_loaded;

    plan tests => 6;

    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    $ENV{CATALYST_DEBUG}  = 0;
    use_ok 'Catalyst::Test', 'MojoMojo';
   # use_ok 'Test::WWW::Mechanize::Catalyst', 'MojoMojo';
};

my $c;
my $baseuri = "";
my $path    = "test";
my $exclude = "";
my $content;
my $ret;

( undef, $c )       = ctx_request('/');
my $dir             = Directory::Scratch->new(CLEANUP => 1);

$c->config->{'Formatter::Dir'}{whitelisting} = [ $dir ];

ok(! MojoMojo::Formatter::Dir->checkdir("$dir", $c));

$ret = MojoMojo::Formatter::Dir->checkdir("/etc/", $c);
is($ret, <<HTML);
Directory '/etc/' must be include in whitelisting ! see Formatter::Dir:whitelisting in mojomojo.conf
HTML


$ret = MojoMojo::Formatter::Dir->to_xhtml($dir, $exclude, $baseuri, $path);
is($ret, <<HTML);
<div id="dirs"><ul></ul></div>
<div id="files"><ul></ul></div>
HTML


$dir->mkdir('foo');

$ret = MojoMojo::Formatter::Dir->to_xhtml($dir, $exclude, $baseuri, $path);
is($ret, <<HTML);
<div id="dirs"><ul><li><a href="/test/foo">[foo]</a></li></ul></div>
<div id="files"><ul></ul></div>
HTML


$dir->touch('bar.txt', 'bla bla bla');
$dir->touch('bar.pod', "=head1 NAME\n\ntest");

$ret = MojoMojo::Formatter::Dir->to_xhtml($dir, $exclude, $baseuri, $path);
is($ret, <<HTML);
<div id="dirs"><ul><li><a href="/test/foo">[foo]</a></li></ul></div>
<div id="files"><ul><li><a href="/test/bar_pod">bar_pod</a></li><li><a href="/test/bar_txt">bar_txt</a></li></ul></div>
HTML


