#!/usr/bin/perl
use Test::More tests => 4;
BEGIN{
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
};
use_ok( Catalyst::Test, 'MojoMojo' );

my ( $res, $c ) = ctx_request('/');
$c->config->{'Formatter::Dir'}{whitelisting} = 't/var/files';
$c->config->{'Formatter::Dir'}{prefix_url} = '/myfiles';

is( request('/badurl/catalyst.png')->code,'404', 'bad prefix_url, do 404' );
ok( request('/.static/catalyst.png')->is_success, 'view image' );
contenttype_is('/.static/catalyst.png', 'image/png', 'show image type' )
