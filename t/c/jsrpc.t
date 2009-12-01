#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 5;

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
}

use_ok( 'Catalyst::Test', 'MojoMojo' );
use_ok( 'MojoMojo::Controller::Jsrpc' );

my $req = request('/.jsrpc/render?content=123');
ok( $req->is_success );

my $content = $req->content;  # content ends with a LF
is( $content, "<p>123</p>\n", 'correct body returned' );
ok( request('/.jsrpc/child_menu')->is_success );
