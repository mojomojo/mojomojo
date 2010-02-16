#!/usr/bin/perl -w
use strict;
use MojoMojo::Formatter::Dir;
use Test::More;
use lib 't/lib';
use Directory::Scratch;


BEGIN { 
    plan skip_all => 'Requirements not installed for Dir Formatter'
        unless MojoMojo::Formatter::Dir->module_loaded;

    plan tests => 10;

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
my $dir             = Directory::Scratch->new( DIR => 't/var', CLEANUP => 1);
$c->config->{'Formatter::Dir'}{whitelisting} = [ $dir ];


ok(! MojoMojo::Formatter::Dir->checkdir("$dir", $c), "Check directory");

# use to_xhtml to Format
$ret = MojoMojo::Formatter::Dir->to_xhtml($dir, $exclude, $baseuri, $path) || 'X';
like("$ret", qr/X/s, "Format empty directory in xhtml");

$dir->mkdir('foo');

$ret = MojoMojo::Formatter::Dir->to_xhtml($dir, $exclude, $baseuri, $path);
like($ret, qr{<div id="dirs"><ul><li><a href="/test/foo">\[foo\]</a></li></ul></div>\n}s,"Just a foo directory in xhtml");

$dir->touch('bar.txt', 'bla bla bla');
$dir->touch('bar.pod', "=head1 NAME\n\ntest");

$ret = MojoMojo::Formatter::Dir->to_xhtml($dir, $exclude, $baseuri, $path);
like($ret, qr{<div id="dirs"><ul><li><a href="/test/foo">\[foo\]</a></li></ul></div>\n<div id="files"><ul><li><a href="/bar_pod">bar_pod</a></li><li><a href="/bar_txt">bar_txt</a></li></ul></div>\n}s,"Return listing foo, bar.txt, bar.pod in xhtml");

# Dir with 'exclude'
$dir->mkdir('.baz');
$content = "<p>{{dir $dir exclude=foo|\.git|.baz}}</p>";
$ret = MojoMojo::Formatter::Dir->format_content(\$content, $c);
like($$ret, qr|<div id="files"><ul><li><a href="http://localhost//bar_pod">bar_pod</a></li><li><a href="http://localhost//bar_txt">bar_txt</a></li></ul></div>\n|s, "Use exclude=foo|\.git|.baz");

# test checkdir directly
$ret = MojoMojo::Formatter::Dir->checkdir("/etc/", $c);
like($ret, qr{Directory '/etc/' must be include in whitelisting ! see Formatter::Dir:whitelisting in mojomojo.conf}s, "checkdir with dir not in whitelist");

# use format_content with some errors
# Same test as before but with format_content
$content = "<p>{{dir /etc/}}</p>";
$ret = MojoMojo::Formatter::Dir->format_content(\$content, $c);
like($$ret, qr|Directory '/etc/' must be include in whitelisting ! see Formatter::Dir:whitelisting in mojomojo.conf|s, "format_content with dir not in whitelist");

# Dir does not exist
$content = "<p>{{dir $dir/test/}}</p>";
$ret = MojoMojo::Formatter::Dir->format_content(\$content, $c);
like($$ret, qr|'$dir/test/' is not a directory !|s, "Can not read dir");

# Dir with '..'
$content = "<p>{{dir $dir/test/../}}</p>";
$ret = MojoMojo::Formatter::Dir->format_content(\$content, $c);
like($$ret, qr|You can't use '..' in the name of directory|s, "Can't use '..' in dir name");


