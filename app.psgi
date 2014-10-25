#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use MojoMojo;

my $app = MojoMojo->psgi_app(@_);

