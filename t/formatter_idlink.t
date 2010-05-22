#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 7;
use lib 't/lib';
use FakeCatalystObject;

BEGIN {
    use_ok 'MojoMojo::Formatter::IDLink';
    use_ok 'Catalyst::Test', 'MojoMojo';
}

my $fake_c;
( undef, $fake_c ) = ctx_request('/');

{
    my $content = 'ask {{id bayashi}}';
    MojoMojo::Formatter::IDLink->format_content(\$content, $fake_c);
    is(
        $content,
        qq|ask <a href="http://twitter.com/bayashi">bayashi</a>\n|,
        'default',
    );
}

{
    my $content = 'ask {{id:htb bayashi_net}}';
    MojoMojo::Formatter::IDLink->format_content(\$content, $fake_c);
    is(
        $content,
        qq|ask <a href="http://b.hatena.ne.jp/bayashi_net">bayashi_net</a>\n|,
        'htb',
    );
}

{
    my $content = 'ask {{id:htd bayashi_net}}';
    MojoMojo::Formatter::IDLink->format_content(\$content, $fake_c);
    is(
        $content,
        qq|ask <a href="http://d.hatena.ne.jp/bayashi_net">bayashi_net</a>\n|,
        'htd',
    );
}

{
    my $content = 'ask {{id:cpan bayashi}}';
    MojoMojo::Formatter::IDLink->format_content(\$content, $fake_c);
    is(
        $content,
        qq|ask <a href="http://search.cpan.org/~bayashi/">bayashi</a>\n|,
        'cpan',
    );
}

{
    my $content = 'ask {{id:fb dai.okabayashi}}';
    MojoMojo::Formatter::IDLink->format_content(\$content, $fake_c);
    is(
        $content,
        qq|ask <a href="http://facebook.com/dai.okabayashi">dai.okabayashi</a>\n|,
        'facebook',
    );
}
