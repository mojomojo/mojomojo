#!/usr/bin/perl -w
use strict;
use MojoMojo::Formatter::ScrubSrc;
use Test::More tests => 3;
use Test::Differences;

my ( $content, $got, $expected, $test );

#-------------------------------------------------------------------------------
$test = 'obfuscated iframe not allowed';
$content = <<'HTML';
<iframe src=http://dandascalescu.com/bugs/mojomojo/scriptlet.html 
HTML
MojoMojo::Formatter::ScrubSrc->format_content( \$content );
eq_or_diff( $content, <<'HTML', $test );

HTML

#-------------------------------------------------------------------------------
$test = 'obfuscated javascript not allowed';
$content = <<'HTML';
<img src=http://malicious.com/xss.js 
HTML
MojoMojo::Formatter::ScrubSrc->format_content( \$content );
eq_or_diff( $content, <<'HTML', $test );

HTML

#-------------------------------------------------------------------------------
$test = 'img src javascript not allowed';
$content = <<'HTML';
<img src=javascript:alert('XSS') 
HTML
MojoMojo::Formatter::ScrubSrc->format_content( \$content );
eq_or_diff( $content, <<'HTML', $test );

HTML

