#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 9;
use lib 't/lib';
use FakeCatalystObject;

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    use_ok 'MojoMojo::Formatter::GoogleSearch';
    use_ok 'Catalyst::Test', 'MojoMojo';
}

my $fake_c = FakeCatalystObject->new;
my $content;

#----- ASCII
{
    $content = 'see {{google MojoMojo}}';
    MojoMojo::Formatter::GoogleSearch->format_content(\$content, $fake_c, undef);
    is(
        $content,
        qq|see <a href="http://www.google.com/search?q=MojoMojo">MojoMojo</a>\n|,
        'ASCII web search',
    );
}

{
    $content = 'see {{google:web MojoMojo}}';
    MojoMojo::Formatter::GoogleSearch->format_content(\$content, $fake_c, undef);
    is(
        $content,
        qq|see <a href="http://www.google.com/search?q=MojoMojo">MojoMojo</a>\n|,
        'ASCII web search',
    );
}

{
    $content = 'see {{google:image MojoMojo}}';
    MojoMojo::Formatter::GoogleSearch->format_content(\$content, $fake_c, undef);
    is(
        $content,
        qq|see <a href="http://www.google.com/images?q=MojoMojo">MojoMojo</a>\n|,
        'ASCII image search',
    );
}

{
    $content = 'see {{google:movie MojoMojo}}';
    MojoMojo::Formatter::GoogleSearch->format_content(\$content, $fake_c, undef);
    is(
        $content,
        qq|see <a href="http://www.google.com/search?tbs=vid%3A1&q=MojoMojo">MojoMojo</a>\n|,
        'ASCII movie search',
    );
}

{
    $content = 'see {{google:movie Perl MojoMojo}}';
    MojoMojo::Formatter::GoogleSearch->format_content(\$content, $fake_c, undef);
    is(
        $content,
        qq|see <a href="http://www.google.com/search?tbs=vid%3A1&q=Perl+MojoMojo">Perl MojoMojo</a>\n|,
        'ASCII movie search (two keywords)',
    );
}

#----- Unicode
{
    $content = 'see {{google もじょもじょ}}';
    MojoMojo::Formatter::GoogleSearch->format_content(\$content, $fake_c, undef);
    is(
        $content,
        qq|see <a href="http://www.google.com/search?q=%E3%82%82%E3%81%98%E3%82%87%E3%82%82%E3%81%98%E3%82%87">もじょもじょ</a>\n|,
        'ASCII web search (Unicode keyword)',
    );
}

#----- few keywords
{
    $content = 'see {{google もじょ モジョ}}';
    MojoMojo::Formatter::GoogleSearch->format_content(\$content, $fake_c, undef);
    is(
        $content,
        qq|see <a href="http://www.google.com/search?q=%E3%82%82%E3%81%98%E3%82%87+%E3%83%A2%E3%82%B8%E3%83%A7">もじょ モジョ</a>\n|,
        'ASCII web search (Unicode two keywords)',
    );
}
