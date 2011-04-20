#!/usr/bin/env perl
use strict;
use warnings;
use MojoMojo;

MojoMojo->setup_engine('PSGI');
my $app = sub { MojoMojo->run(@_) };

