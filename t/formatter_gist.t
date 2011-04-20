#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 7;
use lib 't/lib';
use HTTP::Request::Common;
use FakeCatalystObject;

BEGIN {
    use_ok 'Catalyst::Test', 'MojoMojo';
    use_ok 'MojoMojo::Formatter::Gist';
}

my $fake_c = FakeCatalystObject->new;

{
    my $content = "see {{gist }}";
    MojoMojo::Formatter::Gist->format_content(\$content, $fake_c);
    is(
        $content,
        qq|see {{gist }}\n|,
        "blank (no format)",
    );
}

{
    my $content = "see {{gist 618402}}";
    MojoMojo::Formatter::Gist->format_content(\$content, $fake_c);
    is(
        $content,
        qq|see <script src="https://gist.github.com/618402.js"></script>\n|,
        "normal",
    );
}

$fake_c->set_reverse('pageadmin/edit');
{
    my $content = "see {{gist 618402}}";
    MojoMojo::Formatter::Gist->format_content(\$content, $fake_c);
    is(
        $content,
        qq|see <div style='width: 95%;height: 90px; border: 1px black dotted;'>Faking localization... Gist Script ...fake complete. - <a href="https://gist.github.com/618402">gist:618402</a></div>\n|,
        "edit / valid tag",
    );
}

$fake_c->set_reverse('jsrpc/render');
{
    my $content = "see {{gist 618402}}";
    MojoMojo::Formatter::Gist->format_content(\$content, $fake_c);
    is(
        $content,
        qq|see <div style='width: 95%;height: 90px; border: 1px black dotted;'>Faking localization... Gist Script ...fake complete. - <a href="https://gist.github.com/618402">gist:618402</a></div>\n|,
        "jsrpc/render / valid tag",
    );
}

$fake_c->set_reverse('');
{
    my $content = "see {{gist 123invalid123}}";
    MojoMojo::Formatter::Gist->format_content(\$content, $fake_c);
    is(
        $content,
        qq|see {{gist 123invalid123}}\n|,
        "invalid ID",
    );
}

