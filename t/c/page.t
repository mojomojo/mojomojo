#!/usr/bin/perl -w
use Test::More tests => 17;
BEGIN{
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    $ENV{CATALYST_DEBUG}  = 0;
};
use_ok( Catalyst::Test, 'MojoMojo' );
use_ok('MojoMojo::Controller::Page');

ok( request('/.view')->is_success, 'view root' );
ok( request('/.print')->is_success, 'print root' );
ok( request('/.inline_tags')->is_success, 'show inline tags' );
ok( request('/.list')->is_success , 'list nodes');
ok( request('/.recent')->is_success, 'recent nodes' );
ok( request('/.feeds')->is_success,'show feeds' );
ok( request('/.rss')->is_success , 'get rss');
ok( request('/.rss_full')->is_success, 'get full content rss' );
ok( request('/.atom')->is_success, 'get atom feed' );
ok( request('/.export')->is_success, 'show export page' );
is( request('/.suggest')->code,'404', 'show a suggest page, do 404' );
ok( request('/.info')->is_success, 'show page info' );

ok( request('/.search?query=foo')->is_success, 'show search page' );
ok( request('/.search/inline?query=foo')->is_success, 'show inline search' );

content_like('/', qr'<title>\s*/\s+-\s+MojoMojo\s*</title>', 'root page title matches the test wiki name');
