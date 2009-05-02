#!/usr/bin/perl -w
use strict;
use MojoMojo::Formatter::Stripper;
use Test::More tests => 9;
use Test::Differences;

my ( $content, $got, $expected, $test );

$test = 'unclosed iframe src http not allowed';
$content = <<'HTML';
<iframe src=http://dandascalescu.com/bugs/mojomojo/scriptlet.html 
HTML
$expected = '<!--filtered-->';
MojoMojo::Formatter::Stripper->format_content( \$content );
eq_or_diff( $content, $expected, $test );


$test = 'img src javascript not allowed';
$content = <<'HTML';
<IMG SRC="javascript:alert('XSS');">
HTML
$expected = "<img />\n";
MojoMojo::Formatter::Stripper->format_content( \$content );
eq_or_diff( $content, $expected, $test );


$test = 'unclosed img src javascript not allowed';
$content = <<'HTML';
<img src=javascript:alert('XSS') 
HTML
$expected = '<!--filtered-->';
MojoMojo::Formatter::Stripper->format_content( \$content );
eq_or_diff( $content, $expected, $test );


$test = 'img src http not allowed';
$content = <<'HTML';
<SCRIPT SRC=http://ha.ckers.org/xss.js></SCRIPT>
HTML
$expected = "<!--filtered--><!--filtered-->\n";
MojoMojo::Formatter::Stripper->format_content( \$content );
eq_or_diff( $content, $expected, $test );


$test = 'unclosed src http not allowed';
$content = <<'HTML';
<img src=http://malicious.com/xss.js 
HTML
$expected = '<!--filtered-->';
MojoMojo::Formatter::Stripper->format_content( \$content );
eq_or_diff( $content, $expected, $test );


$test = 'No quotes and semicolon img src javascript';
$content = <<'HTML';
<IMG SRC=javascript:alert('XSS')>
HTML
$expected = "<img />\n";
MojoMojo::Formatter::Stripper->format_content( \$content );
eq_or_diff( $content, $expected, $test );

$test = 'Link Title';
$content = <<'HTML';
<a href="http://mojomojo.org/" title="MojoMojo Home Page">mojomojo.org.</a>
HTML
$expected = '<a href="http://mojomojo.org/" title="MojoMojo Home Page">mojomojo.org.</a>
';
MojoMojo::Formatter::Stripper->format_content( \$content );
eq_or_diff( $content, $expected, $test );

$test = 'Protocol Resolution Bypass a href';
$content = <<'HTML';
<A HREF="//www.google.com/">XSS</A>
HTML
$expected = "<a>XSS</a>\n";
MojoMojo::Formatter::Stripper->format_content( \$content );
eq_or_diff( $content, $expected, $test );


$test = 'Protocol Resolution Bypass img src';
$content = <<'HTML';
<img src="//ha.ckers.org/xss.js" />
HTML
$expected = "<img />\n";
MojoMojo::Formatter::Stripper->format_content( \$content );
eq_or_diff( $content, $expected, $test );

