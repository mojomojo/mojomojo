#!/usr/bin/perl -w
use strict;
use MojoMojo::Formatter::Defang;
use Test::More tests => 11;
use Test::Differences;

my ( $content, $got, $expected, $test );

$test    = 'unclosed iframe src http not allowed';
$content = <<'HTML';
<iframe src=http://dandascalescu.com/bugs/mojomojo/scriptlet.html 
HTML
$expected =
'<!--defang_iframe defang_src=http://dandascalescu.com/bugs/mojomojo/scriptlet.html 
-->';
MojoMojo::Formatter::Defang->format_content( \$content );
eq_or_diff( $content, $expected, $test );

$test    = 'img src javascript not allowed';
$content = <<'HTML';
<IMG SRC="javascript:alert('XSS');">
HTML
$expected = <<'HTML';
<IMG defang_SRC="javascript:alert('XSS');">
HTML
MojoMojo::Formatter::Defang->format_content( \$content );
eq_or_diff( $content, $expected, $test );

$test    = 'unclosed img src javascript not allowed';
$content = <<'HTML';
<img src=javascript:alert('XSS') 
HTML
$expected = "<img defang_src=javascript:alert('XSS') 
>";
MojoMojo::Formatter::Defang->format_content( \$content );
eq_or_diff( $content, $expected, $test );

$test    = 'script src http not allowed';
$content = <<'HTML';
<SCRIPT SRC=http://ha.ckers.org/xss.js></SCRIPT>
HTML
$expected =
'<!--defang_SCRIPT SRC=http://ha.ckers.org/xss.js--><!--  --><!--/defang_SCRIPT-->
';
MojoMojo::Formatter::Defang->format_content( \$content );
eq_or_diff( $content, $expected, $test );

 # This test will fails when allowing img and src at default Defang (return 2) setting.
$test    = 'img src http not allowed';
$content = <<'HTML';
<img src="http://malicious.com/foto.jpg" />
HTML
$expected = '<img defang_src="http://malicious.com/foto.jpg" />
'; 
MojoMojo::Formatter::Defang->format_content( \$content );
eq_or_diff( $content, $expected, $test );

 # This test will fails when allowing img and src at default Defang (return 2) setting.
$test    = 'unclosed src http not allowed';
$content = <<'HTML';
<img src=http://malicious.com/xss.js 
HTML
$expected = '<img defang_src=http://malicious.com/xss.js 
>';
MojoMojo::Formatter::Defang->format_content( \$content );
eq_or_diff( $content, $expected, $test );

$test    = 'No quotes and semicolon img src javascript';
$content = <<'HTML';
<IMG SRC=javascript:alert('XSS')>
HTML
$expected = "<IMG defang_SRC=javascript:alert('XSS')>\n";
MojoMojo::Formatter::Defang->format_content( \$content );
eq_or_diff( $content, $expected, $test );

$test    = 'Link Title';
$content = <<'HTML';
<a href="http://mojomojo.org/" title="MojoMojo Home Page">mojomojo.org.</a>
HTML
$expected =
  '<a href="http://mojomojo.org/" title="MojoMojo Home Page">mojomojo.org.</a>
';
MojoMojo::Formatter::Defang->format_content( \$content );
eq_or_diff( $content, $expected, $test );

$test    = 'Protocol Resolution Bypass a href';
$content = '<A HREF="//www.google.com/">XSS</A>';
$expected = '<A defang_HREF="//www.google.com/">XSS</A>';
MojoMojo::Formatter::Defang->format_content( \$content );
eq_or_diff( $content, $expected, $test );


# This test will fails when allowing img and src at default Defang (return 2) setting.
$test    = 'Protocol Resolution Bypass img src';
$content = <<'HTML';
<img src="//ha.ckers.org/xss.js" />
HTML
$expected = '<img defang_src="//ha.ckers.org/xss.js" />
';
MojoMojo::Formatter::Defang->format_content( \$content );
eq_or_diff( $content, $expected, $test );

$test = 'javascript in href';
$content = "<A HREF='javascript:SomeEvilStuff'>XSS</A>";
$expected = "<A defang_HREF='javascript:SomeEvilStuff'>XSS</A>";
MojoMojo::Formatter::Defang->format_content( \$content );
eq_or_diff( $content, $expected, $test );
