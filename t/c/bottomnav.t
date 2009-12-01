#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    use_ok( 'Catalyst::Test', 'MojoMojo' );
}
ok( request('/.info')->is_success,   'show page info' );
ok( request('/.print')->is_success,  'print root' );
ok( request('/.rss')->is_success,    'get rss' );
ok( request('/.inline')->is_success, 'inline' );

done_testing();
