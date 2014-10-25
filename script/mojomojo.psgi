#!/usr/bin/env perl
use strict;
use warnings;
use MojoMojo;

my $app = MojoMojo->psgi_app(@_);

