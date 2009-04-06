#!/usr/bin/perl -w
use Test::More tests => 20;
use MojoMojo::Formatter::Wiki;
use lib 't/lib';
use DummyCatalystObject;

my ($content,$exist,$new);
# this fake object returns different path_pages based on whether a wiki link containing the text "existing"
my $fake_c = DummyCatalystObject->new;

$content = '\[[WikiWord]]';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, '[[WikiWord]]', 'escaping opening [[');

$content = '/[[wikiword]]';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, '/[[wikiword]]', 'escaping URL path');

$content = "WikiWord";
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, 'WikiWord', 'no CamelCase for new WikiWords');

$content = "ExistingWord";
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, 'ExistingWord', 'no CamelCase for existing WikiWords');

$content = 'This is an [[explicit_link|explicit wiki link]].';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, 'This is an <span class="newWikiWord">explicit wiki link<a title="Faking localization... Not found. Click to create this page. ...fake complete." href="/explicit_link.edit">?</a></span>.', 'explicit wiki links');

$content = 'New [[wiki link]]. No <pre lang="">[[wiki link]] hyperlinking in code sections</pre>. Here is an [[Existing_link]]';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, 'New <span class="newWikiWord">wiki link<a title="Faking localization... Not found. Click to create this page. ...fake complete." href="/wiki_link.edit">?</a></span>. No <pre lang="">[[wiki link]] hyperlinking in code sections</pre>. Here is an <a class="existingWikiWord" href="/Existing_link">Existing link</a>', 'no wiki link hyperlinking in code sections');

$content = 'This is an [[explicit_link|explicit wiki link with (parens) and [square brackets] in the text]].';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, 'This is an <span class="newWikiWord">explicit wiki link with (parens) and [square brackets] in the text<a title="Faking localization... Not found. Click to create this page. ...fake complete." href="/explicit_link.edit">?</a></span>.', 'explicit wiki links with parens and square brackets in the text');

$content = 'Implicit link: [[Devil\'s_advocate_(disambiguation)]].';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, 'Implicit link: <span class="newWikiWord">Devil\'s advocate (disambiguation)<a title="Faking localization... Not found. Click to create this page. ...fake complete." href="/Devil\'s_advocate_(disambiguation).edit">?</a></span>.', 'implicit link with apostrophe and parens in the path');

$content = 'Implicit link with [[a [square] bracket]].';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, 'Implicit link with <span class="newWikiWord">a [square] bracket<a title="Faking localization... Not found. Click to create this page. ...fake complete." href="/a_[square]_bracket.edit">?</a></span>.', 'implicit link with a [square] bracket');

TODO: {
    local $TODO = 'Not exactly a critical issue';
    $content = 'Implicit link: [[Closed_square_bracket_at_the_[end]]].';
    MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
    is($content, 'Implicit link: <span class="newWikiWord">Closed square bracket at the [end]<a title="Faking localization... Not found. Click to create this page. ...fake complete." href="/Closed_square_bracket_at_the_[end].edit">?</a></span>.', 'implicit link with closed square bracket at the end');
}

$content = '[[Say a 100% "NO" to #8]]';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, '<span class="newWikiWord">Say a 100% "NO" to #8<a title="Faking localization... Not found. Click to create this page. ...fake complete." href="/Say_a_100%25_%22NO%22_to_%238.edit">?</a></span>', 'implicit wikilink with anchor (#) sign');

$content = 'explicit link with anchor [[/existing/link#new_anchor|Anchor within existing page]].';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, 'explicit link with anchor <a class="existingWikiWord" href="existing/link#new_anchor">Anchor within existing page</a>.', 'explicit link with anchor. path_pages must strip the anchor');

$content = '[[/existing_say_%22NO%22_to_%238|Say "NO" to #8]]';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, '<a class="existingWikiWord" href="existing_say_%22NO%22_to_%238">Say "NO" to #8</a>', 'explicit wikilink with already URL-encoded characters');

$content = '[[79.1% of Americans believe in miracles]]';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, '<span class="newWikiWord">79.1% of Americans believe in miracles<a title="Faking localization... Not found. Click to create this page. ...fake complete." href="/79.1%25_of_Americans_believe_in_miracles.edit">?</a></span>', 'link with a period');



# find_links() tests

$content = 'There is one [[Existing Word]] in this text';
($exist, $new) = MojoMojo::Formatter::Wiki->find_links(\$content, $fake_c);
is(@$exist, 1);
is(@$new, 0);

$content = 'There is one explicit [[Wiki Word]] in this text';
($exist, $new) = MojoMojo::Formatter::Wiki->find_links(\$content, $fake_c);
is(@$exist, 0);
is(@$new, 1);

$content = '[[Wiki Word]] <pre lang="">Blah HubbaBubba Wikiwiord</pre> blah humbug [[Existing Wiki Word]]';
($exist, $new) = MojoMojo::Formatter::Wiki->find_links(\$content, $fake_c);
is(@$exist, 1);
is(@$new, 1);

