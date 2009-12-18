#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 4;

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    use_ok('MojoMojo::Formatter::Comment');
    can_ok('MojoMojo::Formatter::Comment', qw/format_content format_content_order/);
    use_ok('Catalyst::Test', 'MojoMojo');
};

my $body = get('/.jsrpc/render?content=%7B%7Bcomments%7D%7D');
like($body, qr/comments disabled for preview/, 'the comment formatter is recognized');
