#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 9;

use MojoMojo::Formatter::IRCLog;



my $content;

my $ib = "\n{{irc}}\n";
my $ie = "\n{{end}}\n";
my $ob = "\n==\n<dl>\n";
my $oe = "</dl>\n==\n";
my $font = '<font color="navy">';
$content = "${ib}<nick> text$ie";
MojoMojo::Formatter::IRCLog->format_content(\$content);
is($content, "$ob<dt>$font\[[nick]]</font></dt>\n<dd>text</dd>\n$oe", "basic");
$content = "${ib}<nick> nick2$ie";
MojoMojo::Formatter::IRCLog->format_content(\$content);
is($content, "$ob<dt>$font\[[nick]]</font></dt>\n<dd>nick2</dd>\n$oe", "nick nick2");
$content = "${ib}12:00 <nick> text$ie";
MojoMojo::Formatter::IRCLog->format_content(\$content);
is($content, "$ob<dt>$font\[[nick]]</font></dt>\n<dd>text</dd>\n$oe", "with timestamp");
$content = "${ib}12:00 < nick> text$ie";
MojoMojo::Formatter::IRCLog->format_content(\$content);
is($content, "$ob<dt>$font\[[nick]]</font></dt>\n<dd>text</dd>\n$oe", "with space");
$content = "${ib}12:00 <\@nick> text$ie";
MojoMojo::Formatter::IRCLog->format_content(\$content);
is($content, "$ob<dt>$font\[[nick]]</font></dt>\n<dd>text</dd>\n$oe", "op");
$content = "${ib}12:00 <%nick> text$ie";
MojoMojo::Formatter::IRCLog->format_content(\$content);
is($content, "$ob<dt>$font\[[nick]]</font></dt>\n<dd>text</dd>\n$oe", "half-op");
$content = "${ib}12:00 <+nick> text$ie";
MojoMojo::Formatter::IRCLog->format_content(\$content);
is($content, "$ob<dt>$font\[[nick]]</font></dt>\n<dd>text</dd>\n$oe", "voice");
$content = "${ib}12:00 <+nick> text\nmore$ie";
MojoMojo::Formatter::IRCLog->format_content(\$content);
is($content, "$ob<dt>$font\[[nick]]</font></dt>\n<dd>text more</dd>\n$oe", "multi-line");

$content = "${ib}12:00 <+nick> text\nmore$ie${ib}12:00 <+nick> text\nmore$ie";
MojoMojo::Formatter::IRCLog->format_content(\$content);
is($content, "$ob<dt>$font\[[nick]]</font></dt>\n<dd>text more</dd>\n$oe$ob<dt>$font\[[nick]]</font></dt>\n<dd>text more</dd>\n$oe", "multi-block");
