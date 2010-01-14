#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;
#use MojoMojo::Formatter::Dir;
use MojoMojo::Formatter::File;

BEGIN { 
    plan skip_all => 'Requirements not installed for Dir Formatter'
        unless MojoMojo::Formatter::File->module_loaded;

    plan tests => 14;

    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    $ENV{CATALYST_DEBUG}  = 0;
    use_ok 'Catalyst::Test', 'MojoMojo';
};

use_ok('MojoMojo::Formatter::File');

my $c;
my $ret;
( undef, $c ) = ctx_request('/');
my $dir       = "t/var/files/";
my $content;

my %files = (
    'test.pod' => 'Pod',
    'test.txt' => 'Text',
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


$c->config->{'Formatter::Dir'}{whitelisting} = [ $dir ];

# check checkfile with good file
ok(! MojoMojo::Formatter::File->checkfile("$dir/test.txt", $c));

# Check good text file
$content = "<p>{{file Text $dir/test.txt}}</p>";
$ret = MojoMojo::Formatter::File->format_content(\$content, $c);
like($$ret, qr{<div class="formatter_txt">\n<p>Text file</p> <p><a href="http://mojomojo.org/">http://mojomojo.org</a></p></div>}s, "Text file is formated");

# check checkfile with file not include in whitelist
$ret = MojoMojo::Formatter::File->checkfile("/etc/passwd", $c);
like($ret, qr{Directory '/etc/' must be include in whitelisting ! see Formatter::Dir:whitelisting in mojomojo.conf}s, "Checkfile with file not in whitelist");

# check checkfile with '..' in directory 
$ret = MojoMojo::Formatter::File->checkfile("$dir/../", $c);
like($ret, qr{You can't use '..' in the name of file}s, "Checkfile with '..' in directory");

# Errors in format_content return a ref SCALAR
# format content directory not include in whitelist
$content = '<p>{{file Text /tmp/test.txt}}</p>';
$ret = MojoMojo::Formatter::File->format_content(\$content, $c);
like($$ret, qr{Directory '/tmp/' must be include in whitelisting ! see Formatter::Dir:whitelisting in mojomojo.conf}s, "Format content not include in whitelist");

# file does not exist
$content = "<p>{{file Pod $dir/bla.txt}}</p>";
$ret = MojoMojo::Formatter::File->format_content(\$content, $c);
like($$ret, qr|Can not read 't/var/files//bla.txt' !|s, "Can not read file");

# format with no plugin
$content = '<p>{{file $dir/test.txt}}</p>';
$ret = MojoMojo::Formatter::File->format_content(\$content, $c);
like($$ret, qr/{{file \$dir\/test.txt}}/s, "No plugin is provided");


# Check bad plugin
$content = "<p>{{file Bla $dir/test.txt}}</p>";
$ret = MojoMojo::Formatter::File->format_content(\$content, $c);
like($$ret, qr/Can't find plugin for $dir\/test.txt !/s, "This is a bad plugin");


