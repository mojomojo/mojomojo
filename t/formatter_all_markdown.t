#!/usr/bin/perl -w
# Comprehensive/chained test of formatters, with the main formatter set to MultiMarkdown
use Test::More tests => 20;
use HTTP::Request::Common;
use Test::Differences;

my $original_formatter;    # current formatter set up in mojomojo.db
my $c;                     # the Catalyst object of this live server
my $test;                  # test description

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    $ENV{CATALYST_DEBUG}  = 0;
    use_ok 'MojoMojo::Formatter::Markdown';
    use_ok 'Catalyst::Test', 'MojoMojo';
}

END {
    ok( $c->pref( main_formatter => $original_formatter ),
        'restore original formatter' );
}

( undef, $c ) = ctx_request('/');
ok( $original_formatter = $c->pref('main_formatter'),
    'save original formatter' );

ok( $c->pref( main_formatter => 'MojoMojo::Formatter::Markdown' ),
    'set preferred formatter to Markdown' );

#-------------------------------------------------------------------------------
$test = "empty body";
my $content = '';
my $body = get( POST '/.jsrpc/render', [ content => $content ] );
is( $body, 'Please type something', $test );


#-------------------------------------------------------------------------------
$test    = 'headings';
$content = <<'MARKDOWN';
# Heading 1
paragraph
## Heading 2
MARKDOWN
$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, <<'HTML', $test );
<h1>Heading 1</h1>

<p>paragraph</p>

<h2>Heading 2</h2>
HTML


#-------------------------------------------------------------------------------
$test = 'direct <http://url.com> hyperlinks';
$content = <<'MARKDOWN';
This should be linked: <http://mojomojo.org>.
MARKDOWN
$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, <<'HTML', $test );
<p>This should be linked: <a href="http://mojomojo.org">http://mojomojo.org</a>.</p>
HTML


#-------------------------------------------------------------------------------
$test = '<span>s need to be kept because they are the only way to specify text attributes';
$content = <<'MARKDOWN';
Print media uses <span style="font-family: Times New Roman">Times New Roman</span> fonts.
MARKDOWN
$body = get( POST '/.jsrpc/render', [ content => $content ] );
is( $body, <<HTML, $test );
<p>Print media uses <span style="font-family: Times New Roman">Times New Roman</span> fonts.</p>
HTML


#-------------------------------------------------------------------------------
$test = 'HTML entities must be preserved in code sections';
$content = <<'MARKDOWN';
Here's some code:

    1 < 2 && '4' > "3"

HTML entities must be preserved in code sections.
MARKDOWN
$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, <<'HTML', $test );
<p>Here's some code:</p>

<pre><code>1 < 2 && '4' > "3"
</code></pre>

<p>HTML entities must be preserved in code sections.</p>
HTML


#----------------------------------------------------------------------------
$test  = '<div> with HTML attribute in a code span';
$content = <<'MARKDOWN';
This is the code: `<div class="content">`.
MARKDOWN
$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, <<'HTML', $test );
<p>This is the code: <code>&lt;div class="content"&gt;</code>.</p>
HTML


$test = '<div> with non-standard HTML attribute> in a code span - the HTML scrubber should leave this alone';
$content = <<'MARKDOWN';
This quoted div has an ARIA role attribute: `<div role="content">`.
MARKDOWN
$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, <<'HTML', $test );
<p>This quoted div has an ARIA role attribute: <code>&lt;div role="content"&gt;</code>.</p>
HTML


$test    = '<br/>s need to be preserved';
$content = <<'MARKDOWN';
Roses are red<br/>
Violets are blue
MARKDOWN
$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, <<'HTML', $test );
<p>Roses are red<br/>
Violets are blue</p>
HTML


#-------------------------------------------------------------------------------
$test    = 'blockquotes';
$content = <<'MARKDOWN';
Below is a blockquote:

> quoted text

A quote is above.
MARKDOWN
$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, <<'HTML', $test );
<p>Below is a blockquote:</p>

<blockquote>
  <p>quoted text</p>
</blockquote>

<p>A quote is above.</p>
HTML


#-------------------------------------------------------------------------------
$test    = 'wikilink to ../new_sibling';
$content = <<'MARKDOWN';
This is a child page with a link to a [[../new_sibling]].
MARKDOWN
$body = get( POST '/parent/child.jsrpc/render', [ content => $content ] );
is( $body, <<'HTML', $test );
<p>This is a child page with a link to a <span class="newWikiWord"><a title="Not found. Click to create this page." href="/../new_sibling.edit">new sibling?</a></span>.</p>
HTML


#-------------------------------------------------------------------------------
TODO: {
    local $TODO = "markdown flag";
    $test    = '<div> with markdown="1"';
    $content = <<'MARKDOWN';
We want to be able to have Markdown interpreted in `<div markdown="1">` sections
so that we can build sidebars, photo divs etc.

<div class="navbar" markdown="1">
* [[Home]]
* [[Products]]
* [[About]]

![alt text](/.static/catalyst.png "Image title")
<span style="color: green">This is an image caption</span>
</div>

The above should render as a list of items with an image and caption below.
MARKDOWN
    $body = get( POST '/.jsrpc/render', [ content => $content ] );
    eq_or_diff( $body, <<'HTML', $test );
<p>We want to be able to have Markdown interpreted in <code>&lt;div markdown="1"&gt;</code> sections
so that we can build sidebars, photo divs etc.</p>

<div class="navbar">
<ul>
<li><span class="newWikiWord">Home<a title="Not found. Click to create this page." href="/Home.edit">?</a></span>
<li><span class="newWikiWord">Products<a title="Not found. Click to create this page." href="/Products.edit">?</a></span>
<li><span class="newWikiWord">About<a title="Not found. Click to create this page." href="/About.edit">?</a></span>
</ul>

<img src="/.static/catalyst.png" alt="alt text]" "Image title" ./>
<span style="color: green">This is an image caption</span>
</div>

<p>The above should render as a list of items with an image and caption below.</p>
HTML
}


#-------------------------------------------------------------------------------
TODO: {
    local $TODO = "We'd like this test to pass, but it won't until Text::Markdown passes it.";
    $test = 'Markdown should not parse block-level markdown in <pre> tags';
    $content = <<'MARKDOWN';
<pre lang="Perl">
# A comment, not a heading
</pre>
MARKDOWN
    $body = get( POST '/.jsrpc/render', [ content => $content ] );
    eq_or_diff( $body, <<'HTML', $test );
<pre>
<span class="kateComment">#&nbsp;A&nbsp;comment,&nbsp;not&nbsp;a&nbsp;heading</span>
</pre>
HTML
}


#-------------------------------------------------------------------------------
$test = 'in <pre>, 4 leading spaces should not be interpreted as another <pre>';
$content = <<'MARKDOWN';
<pre>
if (...) {

    foo();
}
</pre>
MARKDOWN
$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, <<'HTML', $test );
<pre>
if (...) {

    foo();
}
</pre>
HTML


#-------------------------------------------------------------------------------
$test = 'in <pre lang=...>, 4 leading spaces should not be interpreted as another <pre>';
$content = <<'MARKDOWN';
<pre lang="Perl">
if (...) {

    foo();
}
</pre>
MARKDOWN
$body = get( POST '/.jsrpc/render', [ content => $content ] );
# Kate has another bug here, that the 'if' should be in a <span class="kateOperator">,
# not simply in <b>if</b>
eq_or_diff( $body, <<'HTML', $test );
<pre>
<b>if</b>&nbsp;(...)&nbsp;{

&nbsp;&nbsp;&nbsp;&nbsp;foo();
}
</pre>
HTML


#-------------------------------------------------------------------------------
$test = 'POD while Markdown is the main formatter';
$content = <<'MARKDOWN';
{{pod}}

=head1 NAME

Some POD here
{{end}}
MARKDOWN
$body = get( POST '/.jsrpc/render', [ content => $content ] );
like($body, qr'<h1><a.*NAME.*/h1>'s, "POD: there is an h1 NAME");
