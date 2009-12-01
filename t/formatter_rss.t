#!/usr/bin/env perl
use strict;
use warnings;
use MojoMojo::Formatter::RSS;
use Test::More;
use lib 't/lib';
use FakeCatalystObject;

BEGIN {
    plan skip_all => 'Requirements not installed for the RSS formatter'
        unless MojoMojo::Formatter::RSS->module_loaded;
    plan tests => 4;
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    use_ok('Catalyst::Test', 'MojoMojo');
}

my $fake_c = FakeCatalystObject->new;
my ($content);

content_like '/.jsrpc/render?content=%7B%7Bhttp://localhost/.rss%7D%7D', qr'{{http://localhost/.rss}}',
    'invalidate the old "syntax"';

SKIP: {
    skip "set TEST_LIVE to run tests that requires a live Internet connection", 2
        if not $ENV{TEST_LIVE};
        
    content_like '/.jsrpc/render?content=%7B%7Bfeed http://rss.cnn.com/rss/cnn_latest.rss%7D%7D', 
        qr'<div class="feed">[^\n]+cnn\.com/[^\n]+</div>\Z',
        'CNN feed - one entry only';

    content_like '/.jsrpc/render?content=%7B%7Bfeed http://rss.cnn.com/rss/cnn_latest.rss 3%7D%7D', 
        qr'(<div class="feed">[^\n]+cnn\.com/[^\n]+</div>\s*){3}\Z',
        'CNN feed - exactly 3 entries';
}
