#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 4;

BEGIN{
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
};

use_ok( 'Catalyst::Test', 'MojoMojo' );
use_ok( 'MojoMojo::Controller::Comment' );

ok( request('/.comment')->is_success,'get .comment');
ok( request('/.comment/login')->is_success,'get .comment/login' );
