#!/usr/bin/perl -w
use strict;
use Test::More tests => 3;
use MojoMojo::Formatter::Include;
use lib 't/lib';
use FakeCatalystObject;

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    use_ok( 'Catalyst::Test', 'MojoMojo' );
};

my $fake_c = FakeCatalystObject->new;
my ($content);

content_like '/.jsrpc/render?content=%7B%7Bhttp://localhost/help%7D%7D', qr/Wiki.*Syntax/,
    'include part of wiki';

SKIP: {
    skip "set TEST_LIVE to run tests that requires a live internet connection", 1
        if not $ENV{TEST_LIVE};
        
    $content = "{{http://github.com/marcusramberg/mojomojo/raw/85605d55158b1e6380457d4ddc31e34b7a77875a/Changes}}\n";
    MojoMojo::Formatter::Include->format_content(\$content, $fake_c, undef);
    like($content, qr{0\.999001\s+2007\-08\-29\s16\:29\:00});
}
