use strict;
use MojoMojo::Formatter::TOC;

use Test;
BEGIN { plan tests => 1; }


my $content = <<'HTML';
=toc<br />
  <h1>The Big Step 1</h1>
  The first heading text hoes hero<br />
  <h1>The Big Step 2</h1>
  This is the second heading text<br />
    <h2>second header, first subheader</h2>
    Some subheader text here<br />
    <h2>second header, second subheader</h2>
    Another piece of subheadeg text here<br />
  <h1>The Big Step</h1>
  Third heading text<br />
  <h1>The Big Step</h1>
  Fourth heading text; anchor above needed uniquifying<br />
  <h1>The big Step</h1>
  Per http://www.w3.org/TR/REC-html40/struct/links.html#h-12.2.1, <br />
  &#8220;Anchor names must be unique within a document. Anchor names that differ only in case may not appear in the same document.&#8221;<br />
  <h1>The Big Step #6</h1>
  The number/hash sign is allowed in fragments; the fragment starts with the first hash.<br />
  No spec as a reference for this, but the anchors work in Firefox 3 and IE 6.<br />
  <h1>Calculation #7: 7/5&gt;3 or &lt;2?</h1>
  Hash marks in fragments work, as well as &#39;/&#39; and &#39;?&#39; signs. &lt; and &gt; are escaped.<br />
    <h2>&#x884C;&#x653F;&#x533A;&#x57DF;</h2>
    I have no idea <span class="caps">WTF </span>that means, but per per http://www.w3.org/TR/REC-html40/struct/links.html#h-12.2.1,<br />
    &#8220;Anchor names should be restricted to <span class="caps">ASCII </span>characters.&#8221;,<br />
    and MediaWiki does that too (see http://zh.wikipedia.org/wiki/&#x521A;&#x679C;&#x6C11;&#x4E3B;&#x5171;&#x548C;&#x56FD;)<br />
  <h1>#8: start with a number (hash) [pound] {comment} sign</h1>
  <h1>Lots of gibberish here: &#8220;!&#8221;#$%&amp;&#39;()*+,-./:;&lt;=&gt;?@[\]^_`{|}~</h1>
  Note how the straight quotes were replaced by smart quotes, which are invalid in id attributes for <span class="caps">XHTML</span> 1.0 (!)
HTML

MojoMojo::Formatter::TOC->format_content(\$content);
ok($content, <<'EOT');
<h1>Table of Contents</h1>
<ul><li><a href="#The_Big_Step_1">The Big Step 1</a></li>
<li><a href="#The_Big_Step_2">The Big Step 2</a>
<ul><li><a href="#second_header.2C_first_subheader">second header, first subheader</a></li>
<li><a href="#second_header.2C_second_subheader">second header, second subheader</a></li>
</ul></li>
<li><a href="#The_Big_Step">The Big Step</a></li>
<li><a href="#The_Big_Step_3">The Big Step</a></li>
<li><a href="#The_big_Step_4">The big Step</a></li>
<li><a href="#The_Big_Step_.236">The Big Step #6</a></li>
<li><a href="#Calculation_.237:_7.2F5.3E3_or_.3C2.3F">Calculation #7: 7/5&gt;3 or &lt;2?</a>
<ul><li><a href="#L行政区域">&#x884C;&#x653F;&#x533A;&#x57DF;</a></li>
</ul></li>
<li><a href="#L.238:_start_with_a_number_.28hash.29_.5Bpound.5D_.7Bcomment.7D_sign">#8: start with a number (hash) [pound] {comment} sign</a></li>
<li><a href="#Lots_of_gibberish_here:_.201C.21.201D.23.24.25.26.27.28.29.2A.2B.2C-..2F:.3B.3C.3D.3E.3F.40.5B.5C.5D.5E_.60.7B.7C.7D.7E">Lots of gibberish here: &#8220;!&#8221;#$%&amp;&#39;()*+,-./:;&lt;=&gt;?@[\]^_`{|}~</a></li>
</ul>
<br />
  <h1 id='The_Big_Step_1'>The Big Step 1</h1>
  The first heading text hoes hero<br />
  <h1 id='The_Big_Step_2'>The Big Step 2</h1>
  This is the second heading text<br />
    <h2 id='second_header.2C_first_subheader'>second header, first subheader</h2>
    Some subheader text here<br />
    <h2 id='second_header.2C_second_subheader'>second header, second subheader</h2>
    Another piece of subheadeg text here<br />
  <h1 id='The_Big_Step'>The Big Step</h1>
  Third heading text<br />
  <h1 id='The_Big_Step_3'>The Big Step</h1>
  Fourth heading text; anchor above needed uniquifying<br />
  <h1 id='The_big_Step_4'>The big Step</h1>
  Per http://www.w3.org/TR/REC-html40/struct/links.html#h-12.2.1, <br />
  &#8220;Anchor names must be unique within a document. Anchor names that differ only in case may not appear in the same document.&#8221;<br />
  <h1 id='The_Big_Step_.236'>The Big Step #6</h1>
  The number/hash sign is allowed in fragments; the fragment starts with the first hash.<br />
  No spec as a reference for this, but the anchors work in Firefox 3 and IE 6.<br />
  <h1 id='Calculation_.237:_7.2F5.3E3_or_.3C2.3F'>Calculation #7: 7/5&gt;3 or &lt;2?</h1>
  Hash marks in fragments work, as well as &#39;/&#39; and &#39;?&#39; signs. &lt; and &gt; are escaped.<br />
    <h2 id='L行政区域'>&#x884C;&#x653F;&#x533A;&#x57DF;</h2>
    I have no idea <span class="caps">WTF </span>that means, but per per http://www.w3.org/TR/REC-html40/struct/links.html#h-12.2.1,<br />
    &#8220;Anchor names should be restricted to <span class="caps">ASCII </span>characters.&#8221;,<br />
    and MediaWiki does that too (see http://zh.wikipedia.org/wiki/&#x521A;&#x679C;&#x6C11;&#x4E3B;&#x5171;&#x548C;&#x56FD;)<br />
  <h1 id='L.238:_start_with_a_number_.28hash.29_.5Bpound.5D_.7Bcomment.7D_sign'>#8: start with a number (hash) [pound] {comment} sign</h1>
  <h1 id='Lots_of_gibberish_here:_.201C.21.201D.23.24.25.26.27.28.29.2A.2B.2C-..2F:.3B.3C.3D.3E.3F.40.5B.5C.5D.5E_.60.7B.7C.7D.7E'>Lots of gibberish here: &#8220;!&#8221;#$%&amp;&#39;()*+,-./:;&lt;=&gt;?@[\]^_`{|}~</h1>
  Note how the straight quotes were replaced by smart quotes, which are invalid in id attributes for <span class="caps">XHTML</span> 1.0 (!)
EOT
