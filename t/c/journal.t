#!/usr/bin/perl -w
use Test::More tests => 2;
BEGIN{
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
};
use_ok( Catalyst::Test, 'MojoMojo' );
use_ok('MojoMojo::Controller::Journal');

#ok( request('/.journal')->is_success );
