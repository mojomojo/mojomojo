#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    use_ok( 'Catalyst::Test', 'MojoMojo' );
}

ok( request('/.recent')->is_success, 'Recent Page' );
ok( request('/.tags')->is_success,   'Tags Page' );
ok( request('/.users')->is_success,  'Authors Page' );
ok( request('/.feeds')->is_success,  'Feeds Page' );
ok( request('/.export')->is_success, 'Export Page' );

done_testing();
