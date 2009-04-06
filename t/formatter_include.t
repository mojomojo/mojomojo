#!/usr/bin/perl -w
use Test::More;
use MojoMojo::Formatter::Include;
use lib 't/lib';
use DummyCatalystObject;

if ($ENV{TEST_LIVE}) {
    plan tests => 2;
}
else {
    plan skip_all => "set TEST_LIVE to run tests that requires a live internet connection";
}

my ($content,$exist,$new);
my $fake_c = DummyCatalystObject->new;

$content = "{{http://github.com/marcusramberg/mojomojo/raw/85605d55158b1e6380457d4ddc31e34b7a77875a/Changes\n";
MojoMojo::Formatter::Include->format_content(\$content, $fake_c, undef);
warn("Content is $content");
like($content, qr{0\.999001\s+2007\-08\-29\s16\:29\:00});

$content = "\n=http://example.com/test/\n";
MojoMojo::Formatter::Include->format_content(\$content, $fake_c, undef);
like($content, qr{part of own site, cannot include});
