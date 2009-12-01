#!/usr/bin/env perl
use strict;
use warnings;
use MojoMojo::Formatter::TOC;

use Test::More tests => 8;
use Test::Differences;

#--- Basic functionality --------------------------------------------
my $content = <<HTML;
{{toc}}
<h1>Chapter 1</h1>
Some text here
<h1>Chapter 2</h1>
Second chapter
HTML

MojoMojo::Formatter::TOC->format_content(\$content);
eq_or_diff($content, <<'EOT', 'basic functionality') or BAIL_OUT("Basic functionality failure");
<div class="toc">
<ul>
   <li><a href="#Chapter_1">Chapter 1</a></li>
   <li><a href="#Chapter_2">Chapter 2</a></li>
</ul>
</div>
<h1><a name="Chapter_1"></a>Chapter 1</h1>
Some text here
<h1><a name="Chapter_2"></a>Chapter 2</h1>
Second chapter
EOT


# ------------------------------------------------------------------------------
# --- Sanity check for replacing text around {{toc}} http://rt.cpan.org/Ticket/Display.html?id=43797
# ------------------------------------------------------------------------------
$content = "The toc should go {{toc}} here.<h1>Chapter 1</h1>\n";
MojoMojo::Formatter::TOC->format_content(\$content);
eq_or_diff($content, <<'HTML', 'the insertionPoint token must not obliterate the text around it - RT # 43797');
The toc should go <div class="toc">
<ul>
   <li><a href="#Chapter_1">Chapter 1</a></li>
</ul>
</div> here.<h1><a name="Chapter_1"></a>Chapter 1</h1>
HTML



# ------------------------------------------------------------------------------
# --- Short test of character set in anchor names - must be [A-Za-z0-9_:.-] only
# ------------------------------------------------------------------------------
$content = <<'HTML';
{{toc}}
  <h1>&#x884C;&#x653F;&#x533A;&#x57DF;</h1>

  Per http://www.w3.org/TR/REC-html40/struct/links.html#h-12.2.1,
  &#8220;Anchor names should be restricted to ASCII characters.&#8221;,
  and MediaWiki does that too (see http://zh.wikipedia.org/wiki/&#x521A;&#x679C;&#x6C11;&#x4E3B;&#x5171;&#x548C;&#x56FD;)
HTML

MojoMojo::Formatter::TOC->format_content(\$content);
eq_or_diff($content, <<'HTML', 'short test of character set in anchor names', {max_width => 120});
<div class="toc">
<ul>
   <li><a href="#L.E8.A1.8C.E6.94.BF.E5.8C.BA.E5.9F.9F">&#x884C;&#x653F;&#x533A;&#x57DF;</a></li>
</ul>
</div>
  <h1><a name="L.E8.A1.8C.E6.94.BF.E5.8C.BA.E5.9F.9F"></a>&#x884C;&#x653F;&#x533A;&#x57DF;</h1>

  Per http://www.w3.org/TR/REC-html40/struct/links.html#h-12.2.1,
  &#8220;Anchor names should be restricted to ASCII characters.&#8221;,
  and MediaWiki does that too (see http://zh.wikipedia.org/wiki/&#x521A;&#x679C;&#x6C11;&#x4E3B;&#x5171;&#x548C;&#x56FD;)
HTML


# ------------------------------------------------------------------------
# --- Comprehensive test of character set in anchor names
# ------------------------------------------------------------------------
$content = <<'HTML';
{{toc}}
  <h1>The Big Step 1</h1>
  The first heading text goes here<br />
  <h1>The Big Step 2</h1>
  This is the second heading text<br />
    <h2>second header, first subheader</h2>
    Some subheader text here<br />
    <h2>second header, second subheader</h2>
    Another piece of subheader text here<br />
  <h1>The Big Step</h1>
  Third text for heading h1 #3<br />
  <h1>The Big Step #6</h1>
  Per the XHTML 1.0 spec, the number/hash sign is NOT allowed in fragments; in practice, the fragment starts with the first hash.<br />
  Such anchors also work in Firefox 3 and IE 6.<br />
  <h1>Calculation #7: 7/5&gt;3 or &lt;2?</h1>
  Hail the spec, http://www.w3.org/TR/REC-html40/types.html#type-name:
  ID and NAME tokens must begin with a letter ([A-Za-z]) and may be followed by any number of letters, digits ([0-9]), hyphens ("-"), underscores ("_"), colons (":"), and periods (".").
  <h1>#8: start with a number (hash) [pound] {comment} sign</h1>
  <h1>Lots of gibberish here: &#8220;!&#8221;#$%&amp;&#39;()*+,-./:;&lt;=&gt;?@[\]^_`{|}~</h1>
  Note how the straight quotes were replaced by smart quotes, which are invalid in id attributes for <span class="caps">XHTML</span> 1.0 (!)
HTML

MojoMojo::Formatter::TOC->format_content(\$content);
eq_or_diff($content, <<'EOT', 'comprehensive test of character set in anchor names', {max_width => 120});
<div class="toc">
<ul>
   <li><a href="#The_Big_Step_1">The Big Step 1</a></li>
   <li><a href="#The_Big_Step_2">The Big Step 2</a>
      <ul>
         <li><a href="#second_header.2C_first_subheader">second header, first subheader</a></li>
         <li><a href="#second_header.2C_second_subheader">second header, second subheader</a></li>
      </ul>
   </li>
   <li><a href="#The_Big_Step">The Big Step</a></li>
   <li><a href="#The_Big_Step_.236">The Big Step #6</a></li>
   <li><a href="#Calculation_.237:_7.2F5.3E3_or_.3C2.3F">Calculation #7: 7/5&gt;3 or &lt;2?</a></li>
   <li><a href="#L.238:_start_with_a_number_.28hash.29_.5Bpound.5D_.7Bcomment.7D_sign">#8: start with a number (hash) [pound] {comment} sign</a></li>
   <li><a href="#Lots_of_gibberish_here:_.E2.80.9C.21.E2.80.9D.23.24.25.26.27.28.29.2A.2B.2C-..2F:.3B.3C.3D.3E.3F.40.5B.5C.5D.5E_.60.7B.7C.7D.7E">Lots of gibberish here: &#8220;!&#8221;#$%&amp;&#39;()*+,-./:;&lt;=&gt;?@[\]^_`{|}~</a></li>
</ul>
</div>
  <h1><a name="The_Big_Step_1"></a>The Big Step 1</h1>
  The first heading text goes here<br />
  <h1><a name="The_Big_Step_2"></a>The Big Step 2</h1>
  This is the second heading text<br />
    <h2><a name="second_header.2C_first_subheader"></a>second header, first subheader</h2>
    Some subheader text here<br />
    <h2><a name="second_header.2C_second_subheader"></a>second header, second subheader</h2>
    Another piece of subheader text here<br />
  <h1><a name="The_Big_Step"></a>The Big Step</h1>
  Third text for heading h1 #3<br />
  <h1><a name="The_Big_Step_.236"></a>The Big Step #6</h1>
  Per the XHTML 1.0 spec, the number/hash sign is NOT allowed in fragments; in practice, the fragment starts with the first hash.<br />
  Such anchors also work in Firefox 3 and IE 6.<br />
  <h1><a name="Calculation_.237:_7.2F5.3E3_or_.3C2.3F"></a>Calculation #7: 7/5&gt;3 or &lt;2?</h1>
  Hail the spec, http://www.w3.org/TR/REC-html40/types.html#type-name:
  ID and NAME tokens must begin with a letter ([A-Za-z]) and may be followed by any number of letters, digits ([0-9]), hyphens ("-"), underscores ("_"), colons (":"), and periods (".").
  <h1><a name="L.238:_start_with_a_number_.28hash.29_.5Bpound.5D_.7Bcomment.7D_sign"></a>#8: start with a number (hash) [pound] {comment} sign</h1>
  <h1><a name="Lots_of_gibberish_here:_.E2.80.9C.21.E2.80.9D.23.24.25.26.27.28.29.2A.2B.2C-..2F:.3B.3C.3D.3E.3F.40.5B.5C.5D.5E_.60.7B.7C.7D.7E"></a>Lots of gibberish here: &#8220;!&#8221;#$%&amp;&#39;()*+,-./:;&lt;=&gt;?@[\]^_`{|}~</h1>
  Note how the straight quotes were replaced by smart quotes, which are invalid in id attributes for <span class="caps">XHTML</span> 1.0 (!)
EOT


# ------------------------------------------------------------------------
# --- range of header levels to make TOC out of: 1-1
# ------------------------------------------------------------------------
$content = <<'HTML';
{{toc 1-1}}
  <h1>The Big Step 1</h1>
  The first heading text goes here<br />
  <h1>The Big Step 2</h1>
  This is the second heading text<br />
    <h2>second header, first subheader</h2>
    Some subheader text here<br />
    <h2>second header, second subheader</h2>
    Another piece of subheader text here<br />
  <h1>The Big Step #3</h1>
  another h1
    <h2>Second level heading</h2>
      <h3>Third level heading</h3>
        <h4>fourth level heading</h4>
        header text level 4
          <h5>Fifth level heading</h5>
  <h1>Back to level one with an interrobang&#x203D;</h1>
  '&#x203D;' is an interrobang.
</div>
HTML


MojoMojo::Formatter::TOC->format_content(\$content);
eq_or_diff($content, <<'HTML', 'range of header levels to make TOC out of: 1-1', {max_width => 120});
<div class="toc">
<ul>
   <li><a href="#The_Big_Step_1">The Big Step 1</a></li>
   <li><a href="#The_Big_Step_2">The Big Step 2</a></li>
   <li><a href="#The_Big_Step_.233">The Big Step #3</a></li>
   <li><a href="#Back_to_level_one_with_an_interrobang.E2.80.BD">Back to level one with an interrobang&#x203D;</a></li>
</ul>
</div>
  <h1><a name="The_Big_Step_1"></a>The Big Step 1</h1>
  The first heading text goes here<br />
  <h1><a name="The_Big_Step_2"></a>The Big Step 2</h1>
  This is the second heading text<br />
    <h2>second header, first subheader</h2>
    Some subheader text here<br />
    <h2>second header, second subheader</h2>
    Another piece of subheader text here<br />
  <h1><a name="The_Big_Step_.233"></a>The Big Step #3</h1>
  another h1
    <h2>Second level heading</h2>
      <h3>Third level heading</h3>
        <h4>fourth level heading</h4>
        header text level 4
          <h5>Fifth level heading</h5>
  <h1><a name="Back_to_level_one_with_an_interrobang.E2.80.BD"></a>Back to level one with an interrobang&#x203D;</h1>
  '&#x203D;' is an interrobang.
</div>
HTML


# ------------------------------------------------------------------------
# --- range of header levels to make TOC out of: 5-
# ------------------------------------------------------------------------
$content = <<'HTML';
{{toc 5-}}
  <h1>The Big Step 1</h1>
  The first heading text goes here<br />
  <h1>The Big Step 2</h1>
  This is the second heading text<br />
    <h2>second header, first subheader</h2>
    Some subheader text here<br />
    <h2>second header, second subheader</h2>
    Another piece of subheader text here<br />
  <h1>The Big Step #3</h1>
  another h1
    <h2>Second level heading</h2>
      <h3>Third level heading</h3>
        <h4>fourth level heading</h4>
        header text level 4
          <h5>Fifth level heading</h5>
  <h1>Back to level one with an interrobang&#x203D;</h1>
  '&#x203D;' is an interrobang.
</div>
HTML

MojoMojo::Formatter::TOC->format_content(\$content);
eq_or_diff($content, <<'HTML', 'range of header levels to make TOC out of: 5-', {max_width => 120});
<div class="toc">
<ul>
   <li><a href="#Fifth_level_heading">Fifth level heading</a></li>
</ul>
</div>
  <h1>The Big Step 1</h1>
  The first heading text goes here<br />
  <h1>The Big Step 2</h1>
  This is the second heading text<br />
    <h2>second header, first subheader</h2>
    Some subheader text here<br />
    <h2>second header, second subheader</h2>
    Another piece of subheader text here<br />
  <h1>The Big Step #3</h1>
  another h1
    <h2>Second level heading</h2>
      <h3>Third level heading</h3>
        <h4>fourth level heading</h4>
        header text level 4
          <h5><a name="Fifth_level_heading"></a>Fifth level heading</h5>
  <h1>Back to level one with an interrobang&#x203D;</h1>
  '&#x203D;' is an interrobang.
</div>
HTML


TODO: {
    local $TODO = 'HTML::Toc needs to support a way of checking for existing anchor names when generating a new one';

# ------------------------------------------------------------------------
# --- Anchor names must be unique -----------------------------------------
# --- Reference: http://www.w3.org/TR/REC-html40/struct/links.html#h-12.2.1
# --- "Anchor names must be unique within a document. Anchor names that differ only in case may not appear in the same document."
# ------------------------------------------------------------------------

    $content = <<'HTML';
{{toc}}
<h1>Chapter 1</h1>
<h2>Notes</h2>
Notes that belong to Chapter 1
<h1>Chapter 2</h1>
<h2>Notes</h2>
Notes that belong to Chapter 2
HTML

    MojoMojo::Formatter::TOC->format_content(\$content);
    eq_or_diff($content, <<'HTML', 'unique anchor names', {max_width => 120});
<div class="toc">
<ul>
   <li><a href="#Chapter_1">Chapter 1</a>
      <ul>
         <li><a href="#Notes">Notes</a></li>
      </ul>
   </li>
   <li><a href="#Chapter_2">Chapter 2</a>
      <ul>
         <li><a href="#Notes_2">Notes</a></li>
      </ul>
   </li>
</ul>
</div>
<h1><a name="Chapter_1"></a>Chapter 1</h1>
<h2><a name="Notes"></a>Notes</h2>
Notes that belong to Chapter 1
<h1><a name="Chapter_2"></a>Chapter 2</h1>
<h2><a name="Notes_2"></a>Notes</h2>
Notes that belong to Chapter 2
HTML

# ------------------------------------------------------------------------
# --- Conflicting anchor names due to encoding of forbidden characters
# ------------------------------------------------------------------------
    $content = <<'HTML';
{{toc}}
  <h1>.25%</h1>
  <h1>%.25</h1>
  <h1>.25</h1>
  <h1>%</h1>
  <h1>Yes...</h1>
  <h1>%</h1>
  Per http://www.w3.org/TR/REC-html40/types.html#type-name,
  &#8220;ID and NAME tokens must begin with a letter ([A-Za-z]) and may be followed by any number of letters, digits ([0-9]), hyphens ("-"), underscores ("_"), colons (":"), and periods (".").&#8221;,
  and MediaWiki does that too (see http://en.wikipedia.org/wiki/Hierarchies#Ethics.2C_behavioral_psychology.2C_philosophies_of_identity)

  <h1>The Big Step</h1>
  <h1>The big Step</h1>
  Per http://www.w3.org/TR/REC-html40/struct/links.html#h-12.2.1, <br />
  &#8220;Anchor names must be unique within a document. Anchor names that differ only in case may not appear in the same document.&#8221;<br />
  <h1>The Big Step 2</h1>
  MediaWiki fails here, see http://en.wikipedia.org/w/index.php?title=User:Dandv/Sandbox&oldid=274553709#The_Big_Step_2

HTML

    MojoMojo::Formatter::TOC->format_content(\$content);
    eq_or_diff($content, <<'HTML', 'conflicting anchor names due to encoding of forbidden characters', {max_width => 120});
<div class="toc">
<ul>
   <li><a href="#L.25.25">.25%</a></li>
   <li><a href="#L.25.25_2">%.25</a></li>
   <li><a href="#L.25">.25</a></li>
   <li><a href="#L.25_2">%</a></li>
   <li><a href="#Yes...">Yes...</a></li>
   <li><a href="#L.25_3">%</a></li>
   <li><a href="#The_Big_Step">%</a></li>
   <li><a href="#The_big_step_2">The big step</a></li>
   <li><a href="#The_Big_Step_2_2">The Big Step 2</a></li>
</ul>
</div>
  <h1><a name="L.25.25"></a>.25%</h1>
  <h1><a name="L.25.25_2"></a>%.25</h1>
  <h1><a name="L.25"></a>.25</h1>
  <h1><a name="L.25_2"></a>%</h1>
  <h1><a name="Yes..."></a>Yes...</h1>
  <h1><a name="L.25_3"></a>%</h1>
  Per http://www.w3.org/TR/REC-html40/types.html#type-name,
  &#8220;ID and NAME tokens must begin with a letter ([A-Za-z]) and may be followed by any number of letters, digits ([0-9]), hyphens ("-"), underscores ("_"), colons (":"), and periods (".").&#8221;,
  and MediaWiki does that too (see http://en.wikipedia.org/wiki/Hierarchies#Ethics.2C_behavioral_psychology.2C_philosophies_of_identity)

  <h1><a name="The_Big_Step"></a>The Big Step</h1>
  <h1><a name="The_big_step_2"></a>The big step</h1>
  Per http://www.w3.org/TR/REC-html40/struct/links.html#h-12.2.1, <br />
  &#8220;Anchor names must be unique within a document. Anchor names that differ only in case may not appear in the same document.&#8221;<br />
  <h1><a name="The_Big_Step_2_2"></a>The Big Step 2</h1>
  MediaWiki fails here, see http://en.wikipedia.org/w/index.php?title=User:Dandv/Sandbox&oldid=274553709#The_Big_Step_2

HTML

}  # TODO tests
