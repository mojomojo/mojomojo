#!/usr/bin/perl -w
use MojoMojo::Formatter::YouTube;
use Test::More tests => 5;
use lib 't/lib';
use DummyCatalystObject;

my $content;
my $fake_c = DummyCatalystObject->new;

$content = " youtube http://www.youtube.com/abc";
MojoMojo::Formatter::YouTube->format_content(\$content, $fake_c, undef);
#warn("Content is $content");
is($content, " youtube http://www.youtube.com/abc\n", "no youtube formatter line");

$fake_c->set_reverse('pageadmin/edit');
$content = "{{youtube http://www.youtube.com/v=abcABC0}}\n";
MojoMojo::Formatter::YouTube->format_content(\$content, $fake_c, undef);
#warn("Content is $content");
is($content, qq(<div style='width: 425px;height: 344px; border: 1px black dotted;'>Faking localization... YouTube Video ...fake complete.<br /><a href="http://www.youtube.com/v=abcABC0">http://www.youtube.com/v=abcABC0</a></div>\n));

$fake_c->set_reverse('jsrpc/render');
$content = "{{youtube http://www.youtube.com/v=abcABC0}} xx\n";
MojoMojo::Formatter::YouTube->format_content(\$content, $fake_c, undef);
#warn("Content is $content");
is($content, qq(<div style='width: 425px;height: 344px; border: 1px black dotted;'>Faking localization... YouTube Video ...fake complete.<br /><a href="http://www.youtube.com/v=abcABC0">http://www.youtube.com/v=abcABC0</a></div> xx\n));

$content = "{{youtube http://wwwwwwww.youtube.com/abc}}";
MojoMojo::Formatter::YouTube->format_content(\$content, $fake_c, undef);
#warn("Content is $content");
is($content, "Faking localization... YouTube Video ...fake complete.: http://wwwwwwww.youtube.com/abc Faking localization... is not a valid link to youtube video ...fake complete.\n", "no youtube link");

$fake_c->set_reverse('');
$content = "{{youtube http://www.youtube.com/watch?v=ABC_abc_09}}";
MojoMojo::Formatter::YouTube->format_content(\$content, $fake_c, undef);
#warn("Content is $content");
is($content, qq(<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/ABC_abc_09&hl=en"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/ABC_abc_09&hl=en" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed></object>\n));
