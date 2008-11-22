#!/usr/bin/perl -w
use Test::More tests => 2;

# Formatter basics
use_ok('MojoMojo::Formatter::Comment');
can_ok('MojoMojo::Formatter::Comment', qw/format_content format_content_order/);

