#!/usr/bin/perl -w
use strict;
use MojoMojo::Formatter::Textile;
use Test::More tests => 4;
use Test::Differences;

my ( $content, $got, $expected, $test );

$test    = 'pre tag - no attribute';
$content = << 'HTML';
<pre>
Hopen, Norway
</pre>
HTML

$expected = '<pre>
Hopen, Norway
</pre>';
MojoMojo::Formatter::Textile->main_format_content( \$content );
eq_or_diff( $content, $expected, $test );

$test = 'pre tag - no attribute and some text before a pre tag';
$content = <<'HTML';
Tinc família a
<pre>
Hopen, Norway
</pre>
HTML

$expected = '<p>Tinc família a</p>


<pre>
Hopen, Norway
</pre>';
MojoMojo::Formatter::Textile->main_format_content( \$content );
eq_or_diff( $content, $expected, $test );

$test     = 'remote image';
$content  = '<img src="http://far.away.com/imatge.jpg" />';
$expected = '<p><img src="http://far.away.com/imatge.jpg" /></p>';
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
