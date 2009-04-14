#!/usr/bin/perl -w
use strict;
use MojoMojo::Formatter::CPANHyperlink;

use Test::More tests => 5;

my $content = '{{cpan Moose}} is a great module';
MojoMojo::Formatter::CPANHyperlink->format_content(\$content);
is($content, '<a href="http://search.cpan.org/perldoc?Moose">Moose</a> is a great module', 'one-word module');

$content = '{{cpan Tie::IxHash}} should be in core';
MojoMojo::Formatter::CPANHyperlink->format_content(\$content);
is($content, '<a href="http://search.cpan.org/perldoc?Tie::IxHash">Tie::IxHash</a> should be in core', 'multi-word module');

$content = '{{cpan 2+3}} is not a valid module name';
MojoMojo::Formatter::CPANHyperlink->format_content(\$content);
is($content, '{{cpan 2+3}} is not a valid module name', 'invalid module name');

$content = '{{cpan 2::Pac}} is not a valid module name';
MojoMojo::Formatter::CPANHyperlink->format_content(\$content);
is($content, '{{cpan 2::Pac}} is not a valid module name', 'invalid module name');

$content = '{{cpan _::_}} is, maybe surprisingly, a valid module name';
MojoMojo::Formatter::CPANHyperlink->format_content(\$content);
is($content, '<a href="http://search.cpan.org/perldoc?_::_">_::_</a> is, maybe surprisingly, a valid module name', 'surprisingly valid module name');
