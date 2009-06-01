use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Catalyst::Test 'MojoMojo';
use Data::Dumper;
use Test::More tests => 2;

my ($response, $c) = ctx_request('/');
isa_ok( $c, 'MojoMojo');
ok( request('/')->is_success, 'Request should succeed' );
