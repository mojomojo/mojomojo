#!/usr/bin/perl -w
use strict;
use MojoMojo::Formatter::Defang;
use Test::More tests => 5;
use Test::Differences;

my ( $content, $got, $expected, $test );

$test    = 'pre tag - no attribute';
$content = <<'HTML';
<pre>
Hopen, Norway
</pre>
HTML
$expected = $content;
MojoMojo::Formatter::Defang->format_content( \$content );
eq_or_diff( $content, $expected, $test );

$test    = 'pre tag - lang HTML attribute';
$content = <<'HTML';
<pre lang="HTML">
Hopen, Norway
</pre>
HTML
$expected = $content;
MojoMojo::Formatter::Defang->format_content( \$content );
eq_or_diff( $content, $expected, $test );

$test    = 'pre tag - lang Perl attribute';
$content = <<'HTML';
<pre lang="Perl">
if 'Hopen, Norway';
</pre>
HTML
$expected = $content;
MojoMojo::Formatter::Defang->format_content( \$content );
eq_or_diff( $content, $expected, $test );

$test    = 'pre tag - no attribute and some text before a pre tag';
$content = <<'HTML';
Tinc família a
<pre>
Hopen, Norway
</pre>
HTML
$expected = $content;
MojoMojo::Formatter::Defang->format_content( \$content );
eq_or_diff( $content, $expected, $test );

$test     = 'remote image - should defang it';
$content  = '<img src="http://far.away.com/imatge.jpg" />';
$expected = '<img defang_src="http://far.away.com/imatge.jpg" />';
MojoMojo::Formatter::Defang->format_content( \$content );
eq_or_diff( $content, $expected, $test );
