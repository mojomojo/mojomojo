#!/usr/bin/perl -w
use strict;
use MojoMojo::Formatter::Textile;
use Test::More tests => 6;
use Test::Differences;

my ( $content, $got, $expected, $test );


#----------------------------------------------------------------------------
$test = 'extra EOL at EOF';
$content  = 'foo';
$expected = "<p>foo</p>\n";
is( MojoMojo::Formatter::Textile->main_format_content( \$content ), $expected, $test );

$test = 'consecutive EOL at EOF collapsed into one';
$content  = "foo\n\n";
$expected = "<p>foo</p>\n";
is( MojoMojo::Formatter::Textile->main_format_content( \$content ), $expected, $test );


#----------------------------------------------------------------------------
$test    = 'pre tag - no attribute';
$content = << 'TEXTILE';
<pre>
Hopen, Norway
</pre>
TEXTILE

$expected = <<'HTML';
<pre>
Hopen, Norway
</pre>
HTML
MojoMojo::Formatter::Textile->main_format_content( \$content );
eq_or_diff( $content, $expected, $test );

$test = 'pre tag - no attribute and some text before a pre tag';
$content = <<'TEXTILE';
Tinc família a
<pre>
Hopen, Norway
</pre>
TEXTILE

$expected = <<'HTML';
<p>Tinc família a</p>


<pre>
Hopen, Norway
</pre>
HTML
MojoMojo::Formatter::Textile->main_format_content( \$content );
eq_or_diff( $content, $expected, $test );

$test     = 'remote image';
$content  = '<img src="http://far.away.com/imatge.jpg" />';
$expected = '<p><img src="http://far.away.com/imatge.jpg" /></p>' . "\n";
MojoMojo::Formatter::Textile->main_format_content( \$content );
eq_or_diff( $content, $expected, $test );

#----------------------------------------------------------------------------
$test    = "Do not encode non-markup Unicode characters";
$content = <<'TEXTILE';
Odd as they may be, leave these characters alone:
להפסיק להשתמש המזוין שפות זרות
áéíóú¿¡üñ
TEXTILE
eq_or_diff( MojoMojo::Formatter::Textile->main_format_content( \$content ), $content, $test );
