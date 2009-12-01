#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 2;

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    use_ok 'Catalyst::Test', 'MojoMojo';
}

my $url = '/page_doesnt_exist.invalid_action';
my $url_RE = quotemeta $url;

content_like $url, qr/not found.*$url_RE\W/, 'error page URL';
