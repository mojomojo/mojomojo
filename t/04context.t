use strict;
use warnings;
use Test::More;

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    use_ok( 'Catalyst::Test', 'MojoMojo' );
}

my ($response, $c) = ctx_request('/');
isa_ok( $c, 'MojoMojo');
ok( request('/')->is_success, 'Request should succeed' );

done_testing();