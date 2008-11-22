#!/usr/bin/perl -w
use Test::More tests => 8;

use MojoMojo::Formatter::IRCLog;



my $content;

my $ib = "\n=irc\n";
my $ie = "\n=irc\n";
my $ob = "\n==\n<dl>\n";
my $oe = "</dl>\n==\n";
$content = "${ib}<nick> text$ie";
MojoMojo::Formatter::IRCLog->format_content(\$content);
is($content, "$ob<dt>[[nick]]</dt>\n<dd>text</dd>\n$oe", "basic");
$content = "${ib}12:00 <nick> text$ie";
MojoMojo::Formatter::IRCLog->format_content(\$content);
is($content, "$ob<dt>[[nick]]</dt>\n<dd>text</dd>\n$oe", "with timestamp");
$content = "${ib}12:00 < nick> text$ie";
MojoMojo::Formatter::IRCLog->format_content(\$content);
is($content, "$ob<dt>[[nick]]</dt>\n<dd>text</dd>\n$oe", "with space");
$content = "${ib}12:00 <\@nick> text$ie";
MojoMojo::Formatter::IRCLog->format_content(\$content);
is($content, "$ob<dt>[[nick]]</dt>\n<dd>text</dd>\n$oe", "op");
$content = "${ib}12:00 <%nick> text$ie";
MojoMojo::Formatter::IRCLog->format_content(\$content);
is($content, "$ob<dt>[[nick]]</dt>\n<dd>text</dd>\n$oe", "half-op");
$content = "${ib}12:00 <+nick> text$ie";
MojoMojo::Formatter::IRCLog->format_content(\$content);
is($content, "$ob<dt>[[nick]]</dt>\n<dd>text</dd>\n$oe", "voice");
$content = "${ib}12:00 <+nick> text\nmore$ie";
MojoMojo::Formatter::IRCLog->format_content(\$content);
is($content, "$ob<dt>[[nick]]</dt>\n<dd>text more</dd>\n$oe", "multi-line");

$content = "${ib}12:00 <+nick> text\nmore$ie${ib}12:00 <+nick> text\nmore$ie";
MojoMojo::Formatter::IRCLog->format_content(\$content);
is($content, "$ob<dt>[[nick]]</dt>\n<dd>text more</dd>\n$oe$ob<dt>[[nick]]</dt>\n<dd>text more</dd>\n$oe", "multi-block");



