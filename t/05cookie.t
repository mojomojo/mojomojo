use strict;
use warnings;
use HTTP::Request::Common;
use Test::More tests => 3;

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    use_ok( 'Catalyst::Test', 'MojoMojo' );
}

# Test that a cookie is not set when an anonymous user (non-authenticated) requests the root node.
my $response = request('/');
ok( !$response->headers->header('set-cookie'), 'No cookie set for anonymous request of "/"' );

# Test that a cookie is set when logging in.
my $login = 'admin';
my $pass  = 'admin';
$response = request( POST '/.login', [ login => $login, pass => $pass ] );
ok( $response->headers->header('set-cookie'), 'Yes, cookie set when logging in.' );
