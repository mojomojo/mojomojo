#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 6;
use lib 't/lib';
use FakeCatalystObject;

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    use_ok 'MojoMojo::Formatter::WikipediaLink';
    use_ok 'Catalyst::Test', 'MojoMojo';
}

my $fake_c;
( undef, $fake_c ) = ctx_request('/');
my $lang = $fake_c->pref('default_lang');

#----- ASCII
{
    my $content = 'see {{wikipedia Perl}}';
    MojoMojo::Formatter::WikipediaLink->format_content(\$content, $fake_c);
    is(
        $content,
        qq|see <a href="http://$lang.wikipedia.org/wiki/Perl">Perl</a>\n|,
        'default link',
    );
}

{
    my $content = 'see {{wikipedia:ja Perl}}';
    MojoMojo::Formatter::WikipediaLink->format_content(\$content, $fake_c);
    is(
        $content,
        qq|see <a href="http://ja.wikipedia.org/wiki/Perl">Perl</a>\n|,
        'specified language',
    );
}

{
    my $content = 'see {{wikipedia:ja こんにちは}}';
    MojoMojo::Formatter::WikipediaLink->format_content(\$content, $fake_c);
    is(
        $content,
        qq|see <a href="http://ja.wikipedia.org/wiki/%E3%81%93%E3%82%93%E3%81%AB%E3%81%A1%E3%81%AF">こんにちは</a>\n|,
        'unicode keyword',
    );
}

{
    my $content = 'see {{wikipedia Larry Wall}}';
    MojoMojo::Formatter::WikipediaLink->format_content(\$content, $fake_c);
    is(
        $content,
        qq|see <a href="http://$lang.wikipedia.org/wiki/Larry%20Wall">Larry Wall</a>\n|,
        'Larry Wall ;-P',
    );
}



