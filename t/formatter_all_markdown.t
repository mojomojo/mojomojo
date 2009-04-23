#!/usr/bin/perl -w
use Test::More tests => 10;
use HTTP::Request::Common;
use Test::Differences;

my $original_formatter;  # used to store whatever formatter is set up in mojomojo.db
my $c;  # the Catalyst object of this live server

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    $ENV{CATALYST_DEBUG} = 0;
    use_ok('MojoMojo::Formatter::Markdown') and note('Comprehensive/chained test of formatters, with the main formatter set to MultiMarkdown');
    use_ok(Catalyst::Test, 'MojoMojo');
    
    (undef, $c) = ctx_request('/');
    ok($original_formatter = $c->pref(main_formatter), 'save original formatter');
};

END {
    ok($c->pref(main_formatter => $original_formatter), 'restore original formatter');
};

ok($c->pref(main_formatter => 'MojoMojo::Formatter::Markdown'), 'set preferred formatter to Markdown');

my $content = '';
my $body = get(POST '/.jsrpc/render', [content => $content]);
is($body, 'Please type something', 'empty body');

$content = <<MARKDOWN;
# Heading 1
paragraph
## Heading 2
MARKDOWN
$body = get(POST '/.jsrpc/render', [content => $content]);
eq_or_diff($body, <<HTML, 'headings');
<h1>Heading 1</h1>

<p>paragraph</p>

<h2>Heading 2</h2>
HTML


$content = <<MARKDOWN;
Print media uses <span style="font-family: Times New Roman">Times New Roman</span> fonts.
MARKDOWN
$body = get(POST '/.jsrpc/render', [content => $content]);
is($body, <<HTML, '<span>s need to be kept because they are the only way to specift text attributes');
<p>Print media uses <span style="font-family: Times New Roman">Times New Roman</span> fonts.</p>
HTML


$content = <<MARKDOWN;
Here's some code:

    1 < 2 && '4' > "3"

HTML entities must be preserved in code sections.
MARKDOWN
$body = get(POST '/.jsrpc/render', [content => $content]);
eq_or_diff($body, <<HTML, 'HTML entities must be preserved in code sections');
<p>Here's some code:</p>

<pre><code>1 < 2 && '4' > "3"
</code></pre>

<p>HTML entities must be preserved in code sections.</p>
HTML


#$content = <<MARKDOWN;
#Divs can be used to add captions to images
#
#<div class=photo style="float: right; border: 1px dotted black; text-align: center">
#![alt text](/.static/catalyst.png "Image title")  
#<span style="color: green">This is an image caption</span>
#</div>
#
#Divs, spans, and their styling attributes must be kept.
#MARKDOWN
#$body = get(POST '/.jsrpc/render', [content => $content]);
#eq_or_diff($body, <<HTML, 'keep divs, spans and their styling attributes');
#<p>Divs can be used to add captions to images</p>
#
#<div class="photo" style="float: right; border: 1px dotted black; text-align: center">
#<img src="/.static/catalyst.png" alt="alt text" title="Image title" /> <br />
#<span style="color: green">This is an image caption</span>
#</div>
#
#<p>Divs, spans, and their styling attributes must be kept.</p>
#HTML
#
#
#$content = <<MARKDOWN;
#<pre lang="Perl">
## A comment, not a heading
#</pre>
#MARKDOWN
#$body = get(POST '/.jsrpc/render', [content => $content]);
#eq_or_diff($body, <<HTML, 'no Markdown parsing in <pre> sections');
#<pre>
#<span class="kateComment">#&nbsp;A&nbsp;comment,&nbsp;not&nbsp;a&nbsp;heading</span>
#</pre>
#HTML


$content = <<MARKDOWN;
This is a child page with a link to a [[../new_sibling]].
MARKDOWN
$body = get(POST '/parent/child.jsrpc/render', [content => $content]);
is($body, <<HTML, 'wikilink to ../sibling');
<p>This is a child page with a link to a <span class="newWikiWord">new sibling<a title="Not found. Click to create this page." href="/../new_sibling.edit">?</a></span>.</p>
HTML
