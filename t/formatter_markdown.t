#!/usr/bin/perl -w
use strict;
use MojoMojo::Formatter::Markdown;
use Test::More tests => 15;
use Test::Differences;

my ( $content, $got, $expected, $test );

#----------------------------------------------------------------------------
$test = 'extra EOL at EOF';
$content  = 'foo';
$expected = "<p>foo</p>\n";
is( MojoMojo::Formatter::Markdown->main_format_content( \$content ), $expected, $test );

$test = 'consecutive EOL at EOF collapsed into one';
$content  = "foo\n\n";
$expected = "<p>foo</p>\n";
is( MojoMojo::Formatter::Markdown->main_format_content( \$content ), $expected, $test );


#----------------------------------------------------------------------------
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
<div class=this_must_be_quoted_otherwise_the_whole_div_is_not_HTML_but_junk>

</div>
HTML


#----------------------------------------------------------------------------
$test    = 'do not interpret block-level Markdown in divs without attributes';
$content = <<'MARKDOWN';
<div>
# not a heading 1
</div>
MARKDOWN
eq_or_diff( MojoMojo::Formatter::Markdown->main_format_content( \$content ),
    <<'HTML', $test );
<div>
# not a heading 1
</div>
HTML


$test    = 'do interpret block-level Markdown in divs with the markdown="1" attribute';
$content = <<'MARKDOWN';
<div markdown="1">
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
$test    = 'do not interpret inline Markdown in divs without attributes';
$content = <<'MARKDOWN';
<div>

*this should be left as is*

</div>
MARKDOWN
eq_or_diff( MojoMojo::Formatter::Markdown->main_format_content( \$content ),
    <<'HTML', $test );
<div>

*this should be left as is*

</div>
HTML


$test    = 'do interpret inline Markdown in divs with a markdown="on" attribute';
$content = <<'MARKDOWN';
<div markdown="on">

*this should be emphasized*

</div>
MARKDOWN
eq_or_diff( MojoMojo::Formatter::Markdown->main_format_content( \$content ),
    <<'HTML', $test );
<div>
<p><em>this should be emphasized</em></p>
</div>
HTML



#----------------------------------------------------------------------------
$test    = "interpret Markdown in divs with other attributes besides markdown='1'";
$content = <<'MARKDOWN';
<div class="content" markdown='1'>

*this should be emphasized*

</div>
MARKDOWN
eq_or_diff( MojoMojo::Formatter::Markdown->main_format_content( \$content ),
    <<'HTML', $test );
<div class="content">
<p><em>this should be emphasized</em></p>
</div>
HTML



#----------------------------------------------------------------------------
$test    = 'in <divs markdown="1">, leave alone HTML like <span>s';
$content = <<'MARKDOWN';
<div class="photo_frame" markdown="1">

![alt text](/image.jpg "title")
<span class="caption">Caption</span>

</div>
MARKDOWN
eq_or_diff( MojoMojo::Formatter::Markdown->main_format_content( \$content ),
    <<'HTML', $test );
<div class="photo_frame">
<p><img src="/image.jpg" alt="alt text" title="title" />
<span class="caption">Caption</span></p>
</div>
HTML


