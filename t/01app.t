#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 3;
use lib qw 't/lib';
use MojoMojoTestSchema;

$ENV{CATALYST_DEBUG} = 0;
ok( MojoMojoTestSchema->init_schema(populate => 1),
    'populate test schema and create config file to be used by subsequent tests'
);
$ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';

use_ok( 'Catalyst::Test', 'MojoMojo' );

ok( request('/')->is_success, 'get the root page' );
