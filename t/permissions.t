#!/usr/bin/perl -w
use Test::More tests => 3;
BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    $ENV{CATALYST_DEBUG} = 0;
};
use_ok( Catalyst::Test, 'MojoMojo' );

is_deeply([ MojoMojo->_expand_path_elements('/help') ], ['/','/help']);
is_deeply([ MojoMojo->_expand_path_elements('/admin/foo') ], ['/','/admin','/admin/foo']);
