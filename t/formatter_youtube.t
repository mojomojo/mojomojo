#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 8;
use lib 't/lib';
use HTTP::Request::Common;
use FakeCatalystObject;

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    use_ok 'MojoMojo::Formatter::YouTube';
    use_ok 'Catalyst::Test', 'MojoMojo';
}

my ($content, $got, $expected);
my $fake_c = FakeCatalystObject->new;

$content = " youtube http://www.youtube.com/abc";
MojoMojo::Formatter::YouTube->format_content(\$content, $fake_c, undef);
is($content, " youtube http://www.youtube.com/abc\n", "formatter directly / not a {{YouTube ...}} tag");

$fake_c->set_reverse('pageadmin/edit');
$content = "{{youtube http://www.youtube.com/v=abcABC0}}\n";
MojoMojo::Formatter::YouTube->format_content(\$content, $fake_c, undef);
is( $content, 
    qq(<div style='width: 425px;height: 344px; border: 1px black dotted;'>Faking localization... YouTube Video ...fake complete.<br /><a href="http://www.youtube.com/v=abcABC0">http://www.youtube.com/v=abcABC0</a></div>\n),
    'formatter directly / preview / valid tag'
);

$fake_c->set_reverse('jsrpc/render');
$content = "{{youtube http://www.youtube.com/v=abcABC0}} xx\n";
MojoMojo::Formatter::YouTube->format_content(\$content, $fake_c, undef);
is( $content, 
    qq(<div style='width: 425px;height: 344px; border: 1px black dotted;'>Faking localization... YouTube Video ...fake complete.<br /><a href="http://www.youtube.com/v=abcABC0">http://www.youtube.com/v=abcABC0</a></div> xx\n),
    'formatter directly / preview / valid tag followed by text'
);

$content = "{{youtube http://wwwwwwww.youtube.com/abc}}";
MojoMojo::Formatter::YouTube->format_content(\$content, $fake_c, undef);
is( $content, 
    "Faking localization... YouTube Video ...fake complete.: http://wwwwwwww.youtube.com/abc Faking localization... is not a valid link to youtube video ...fake complete.\n", 
    'formatter directly / invalid YouTube link'
);

$fake_c->set_reverse('');
$got = $content = "{{youtube http://www.youtube.com/watch?v=ABC_abc_09}}";
$expected = qq(<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/ABC_abc_09&amp;hl=en"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/ABC_abc_09&amp;hl=en" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed></object>);
MojoMojo::Formatter::YouTube->format_content(\$got, $fake_c, undef);
is( $got, "$expected\n", 'formatter directly / final page rendering' );
# tests are closer to reality if they call the JSRPC renderer, so that
# the entire formatter chain gets exercised, as in actual wiki usage
TODO: {
    local $TODO = "Defang interferes with the YouTube formatter - see http://n2.nabble.com/Defang-issues-td4078508.html";
    $got = get( POST '/.jsrpc/render', [ content => $content ] );
    is( $got, "<p>$expected</p>\n", 'full formatter chain / final page rendering' );
}
