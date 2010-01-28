#!/usr/bin/perl -w
use Test::More tests => 5;
BEGIN{
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
};
use_ok( Catalyst::Test, 'MojoMojo' );
use_ok('MojoMojo::Controller::Page');

is( request('/badurl/catalyst.png')->code,'404', 'bad prefix_url, do 404' );
ok( request('/.static/catalyst.png')->is_success, 'view image' );
contenttype_is('/.static/catalyst.png', 'image/png', 'show image type' )
