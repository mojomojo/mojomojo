use Test::More tests => 17;
use_ok( Catalyst::Test, 'MojoMojo' );
use_ok('MojoMojo::C::Page');

ok( request('/.view')->is_success );
ok( request('/.print')->is_success );
ok( request('/.inline_tags')->is_success );
ok( request('/.list')->is_success );
ok( request('/.recent')->is_success );
ok( request('/.feeds')->is_success );
ok( request('/.rss')->is_success );
ok( request('/.rss_full')->is_success );
ok( request('/.atom')->is_success );
ok( request('/.highlight')->is_success );
ok( request('/.export')->is_success );
ok( request('/.suggest')->is_success );
ok( request('/.info')->is_success );
ok( request('/.search')->is_success );
ok( request('/.search_inline')->is_success );
