#!/usr/bin/perl -w
use Test::More tests => 4;
BEGIN {
    $ENV{CATALYST_CONFIG}='t/var/mojomojo.yml';
    $ENV{CATALYST_DEBUG}=0;
    use_ok('MojoMojo::Formatter::Comment');
    can_ok('MojoMojo::Formatter::Comment', qw/format_content format_content_order/);
    use_ok(Catalyst::Test, 'MojoMojo');
};

$body = get('/.jsrpc/render?content=%7B%7Bcomments%7D%7D');
like($body, qr/comments disabled for preview/, 'the comment formatter is recognized');
