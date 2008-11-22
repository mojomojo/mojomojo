#!/usr/bin/perl -w
use Test::More tests => 3;
BEGIN{
$ENV{CATALYST_CONFIG}='t/var/mojomojo.yml';
$ENV{CATALYST_DEBUG}=0;
};
use_ok( Catalyst::Test, 'MojoMojo' );
use_ok('MojoMojo::Controller::User');

ok( request('user')->is_success );
