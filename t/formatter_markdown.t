#!/usr/bin/perl -w
use strict;
use MojoMojo::Formatter::Markdown;
use Test::More tests => 12;
use Test::Differences;

my ( $content, $got, $expected, $test );

$content = 'Here is an ![Image alt text](/image.jpg "Image title") image.';
$expected =
'<p>Here is an <img src="/image.jpg" alt="Image alt text" title="Image title" /> image.</p>'
  . "\n";    # Markdown makes sure there's a final "\n"
is( MojoMojo::Formatter::Markdown->main_format_content( \$content ),
    $expected, 'basic image' );

#----------------------------------------------------------------------------
$test    = '<div with="attributes"> in a code span';
$content = <<'MARKDOWN';
This is the code: `<div markdown="1">`.
MARKDOWN
eq_or_diff( MojoMojo::Formatter::Markdown->main_format_content( \$content ),
    <<'HTML', $test );
<p>This is the code: <code>&lt;div markdown="1"&gt;</code>.</p>
HTML

#----------------------------------------------------------------------------
$test    = 'blockquotes';
$content = <<'MARKDOWN';
Below is a blockquote:

> quoted text

A quote is above.
MARKDOWN
eq_or_diff( MojoMojo::Formatter::Markdown->main_format_content( \$content ),
    <<'HTML', $test );
<p>Below is a blockquote:</p>

<blockquote>
  <p>quoted text</p>
</blockquote>

<p>A quote is above.</p>
HTML

#----------------------------------------------------------------------------
$test    = 'direct <http://url.com> hyperlinks';
$content = <<'MARKDOWN';
This should be linked: <http://mojomojo.org>.
MARKDOWN
eq_or_diff( MojoMojo::Formatter::Markdown->main_format_content( \$content ),
    <<'HTML', $test );
<p>This should be linked: <a href="http://mojomojo.org">http://mojomojo.org</a>.</p>
HTML

#----------------------------------------------------------------------------
$test    = "don't make a <div> into <p><div></p>, for empty divs";
$content = <<'MARKDOWN';
<div>

</div>
MARKDOWN
eq_or_diff( MojoMojo::Formatter::Markdown->main_format_content( \$content ),
    <<'HTML', $test );
<div>

</div>
HTML

#----------------------------------------------------------------------------
$test    = "don't make a <div> into <p><div></p>, for divs wth attributes";
$content = <<'MARKDOWN';
<div class="content">

</div>
MARKDOWN
eq_or_diff( MojoMojo::Formatter::Markdown->main_format_content( \$content ),
    <<'HTML', $test );
<div class="content">

</div>
HTML

#----------------------------------------------------------------------------
$test =
"if div attributes are not quoted, they're fair game because that's invalid HTML Strict";
$content = <<'MARKDOWN';
<div class=this_must_be_quoted_otherwise_the_whole_div_is_not_HTML_but_junk>

</div>
MARKDOWN
eq_or_diff( MojoMojo::Formatter::Markdown->main_format_content( \$content ),
    <<'HTML', $test );
<p><div class=this_must_be_quoted_otherwise_the_whole_div_is_not_HTML_but_junk></p>

<p></div></p>
HTML

$TODO =
  "All tests below will fail because Markdown doesn't interpret markdown in 
HTML block elements, and does interpret block-level markdown in <pre> elements";

#----------------------------------------------------------------------------
$test    = "interpret block-level Markdown in divs without attributes";
$content = <<'MARKDOWN';
<div>
# heading 1
</div>
MARKDOWN
eq_or_diff( MojoMojo::Formatter::Markdown->main_format_content( \$content ),
    <<'HTML', $test );
<div>
<h1>heading 1</h1>

</div>
HTML

#----------------------------------------------------------------------------
$test    = "interpret inline Markdown in divs without attributes";
$content = <<'MARKDOWN';
<div>

*this should be emphasized*

</div>
MARKDOWN
eq_or_diff( MojoMojo::Formatter::Markdown->main_format_content( \$content ),
    <<'HTML', $test );
<div>

<em>this should be emphasized</em>

</div>
HTML

#----------------------------------------------------------------------------
$test    = "interpret Markdown in divs WITH attributes";
$content = <<'MARKDOWN';
<div class="content">

*this should be emphasized*

</div>
MARKDOWN
eq_or_diff( MojoMojo::Formatter::Markdown->main_format_content( \$content ),
    <<'HTML', $test );
<div class="content">

<em>this should be emphasized</em>

</div>
HTML

#----------------------------------------------------------------------------
$test    = "in <divs>, leave alone HTML like <span>s";
$content = <<'MARKDOWN';
<div class="photo_frame">

![alt text](/image.jpg "title")
<span class="caption">Caption</span>

</div>
MARKDOWN
eq_or_diff( MojoMojo::Formatter::Markdown->main_format_content( \$content ),
    <<'HTML', $test );
<div class="photo_frame">

<img src="/image.jpg" alt="alt text" title="title" /></p>
<span class="caption">Caption</span>

</div>
HTML

#----------------------------------------------------------------------------
$test    = "in <pres>, not even block-level Markdown should be interpreted";
$content = <<'MARKDOWN';
<pre lang="Perl">
# A comment, not a heading
[this isn't](a link)
[[this isn't a wikilink]]

|| this is not | a table ||
|| this is | a <pre> element ||
</pre>
MARKDOWN
eq_or_diff( MojoMojo::Formatter::Markdown->main_format_content( \$content ),
    <<'HTML', $test );
<pre lang="Perl">
# A comment, not a heading
[this isn't](a link)
[[this isn't a wikilink]]

|| this is not | a table ||
|| this is | a <pre> element ||
</pre>
HTML

