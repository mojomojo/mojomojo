#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use MojoMojo::Formatter::Include;
use lib 't/lib';
use FakeCatalystObject;

BEGIN {
    plan skip_all => 'Requirements not installed for the Include formatter'
        unless MojoMojo::Formatter::Include->module_loaded;
    plan tests => 2;
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    use_ok('Catalyst::Test', 'MojoMojo');
}

my $fake_c = FakeCatalystObject->new;
my ($content);

#content_like('/.jsrpc/render?content=%7B%7Bhttp://localhost/help%7D%7D', qr'{{http://localhost/help}}',
#    'invalidate the old "syntax"');

# match against the start of the string, \A, to make sure no page cruft gets included besides the content
#content_like('/.jsrpc/render?content=%7B%7Binclude http://localhost/help%7D%7D', qr/\A<h1>Help/,
#             'include part of wiki, absolute URL');
#content_like('/.jsrpc/render?content=%7B%7Binclude /help%7D%7D', qr/\A<h1>Help/,
#    'include part of wiki, relative URL');

#content_like('/help.jsrpc/render?content=%7B%7Binclude http://localhost/%7D%7D', qr/\A<h1>Welcome\sto\sMojoMojo/,
#    'include the root page, absolute URL');
#content_like('/help.jsrpc/render?content=%7B%7Binclude /%7D%7D', qr/\A<h1>Welcome\sto\sMojoMojo/,
#    'include the root page, relative URL');

SKIP: {
    skip "set TEST_LIVE to run tests that requires a live Internet connection", 1
        if not $ENV{TEST_LIVE};

    $content = "{{include http://github.com/mojomojo/mojomojo/raw/85605d55158b1e6380457d4ddc31e34b7a77875a/Changes}}\n";
    MojoMojo::Formatter::Include->format_content(\$content, $fake_c, undef);
    like($content, qr{0\.999001\s+2007\-08\-29\s16\:29\:00}, 'include Changes file from GitHub');
}
