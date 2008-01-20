use Test::More tests => 17;
$ENV{CATALYST_DEBUG}=0;
use_ok( Catalyst::Test, 'MojoMojo' );
use_ok('MojoMojo::Controller::Page');

ok( request('/.view')->is_success, 'can view root' );
ok( request('/.print')->is_success, 'can print root' );
ok( request('/.inline_tags')->is_success, 'can show inline tags' );
ok( request('/.list')->is_success , 'can list nodes');
ok( request('/.recent')->is_success, 'can recent nodes' );
ok( request('/.feeds')->is_success,'can show feeds' );
ok( request('/.rss')->is_success , 'can get rss');
ok( request('/.rss_full')->is_success,'can get full content rss' );
ok( request('/.atom')->is_success,'can get atom feed' );
ok( request('/.highlight')->is_success,'can highlight changes' );
ok( request('/.export')->is_success, 'can show export page' );
is( request('/.suggest')->code,'404','show a suggest page, do 404' );
ok( request('/.info')->is_success,'Can show page info' );
SKIP: {
skip 'Search has problems',2 ;
ok( request('/.search?query=foo')->is_success,'Can show search page' );
ok( request('/.search/inline?query=foo')->is_success,'can show inline search' );};
