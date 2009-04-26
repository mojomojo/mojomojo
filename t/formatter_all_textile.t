#!/usr/bin/perl -w
use Test::More tests => 12;
use HTTP::Request::Common;
use Test::Differences;

my $original_formatter
  ;    # used to save/restore whatever formatter is set up in mojomojo.db
my $c;       # the Catalyst object of this live server
my $test;    # test description

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    $ENV{CATALYST_DEBUG}  = 0;
    use_ok('MojoMojo::Formatter::Textile')
      and note(
'Comprehensive/chained test of formatters, with the main formatter set to Textile'
      );
    use_ok( 'Catalyst::Test', 'MojoMojo' );
}

END {
    ok( $c->pref( main_formatter => $original_formatter ),
        'restore original formatter' );
}

( undef, $c ) = ctx_request('/');
ok( $original_formatter = $c->pref('main_formatter'),
    'save original formatter' );

ok( $c->pref( main_formatter => 'MojoMojo::Formatter::Textile' ),
    'set preferred formatter to Textile' );

my $content = '';
my $body = get( POST '/.jsrpc/render', [ content => $content ] );
is( $body, 'Please type something', 'empty body' );

#----------------------------------------------------------------------------
$test = 'headings';

#----------------------------------------------------------------------------
$content = <<'TEXTILE';
h1. Welcome to MojoMojo!

This is your front page. To start administrating your wiki, please log in with
username admin/password admin. At that point you will be able to set up your
configuration. If you want to play around a little with the wiki, just create
a [[New Page]] or edit this one through the edit link at the bottom.

h2. Need some assistance?

Check out our [[Help]] section.
TEXTILE
$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, <<'HTML', $test );
<h1>Welcome to MojoMojo!</h1>

<p>This is your front page. To start administrating your wiki, please log in with<br />
username admin/password admin. At that point you will be able to set up your<br />
configuration. If you want to play around a little with the wiki, just create<br />
a <span class="newWikiWord">New Page<a title="Not found. Click to create this page." href="/New_Page.edit">?</a></span> or edit this one through the edit link at the bottom.</p>

<h2>Need some assistance?</h2>

<p>Check out our <a class="existingWikiWord" href="/help">Help</a> section.</p>
HTML

#----------------------------------------------------------------------------
$test = 'HTML entities must be preserved in code sections';

#----------------------------------------------------------------------------
$content = <<'TEXTILE';
Here's some code:

<pre lang="Perl">
if (1 > 2) {
  print "test";
}
</pre>

Here too:

<pre>
if (1 < 2) {
  print "pre section & no lang specified";
}
</pre>
TEXTILE
$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, <<'HTML', $test );
<p>Here&#8217;s some code:</p>



<pre>
<b>if</b>&nbsp;(<span class="kateFloat">1</span>&nbsp;>&nbsp;<span class="kateFloat">2</span>)&nbsp;{
&nbsp;&nbsp;<span class="kateFunction">print</span>&nbsp;<span class="kateOperator">"</span><span class="kateString">test</span><span class="kateOperator">"</span>;
}
</pre>



<p>Here too:</p>



<pre>
if (1 < 2) {
  print "pre section & no lang specified";
}
</pre>
HTML

#----------------------------------------------------------------------------
$test = 'Is <br /> preserved?';

# NOTE: Textile turns \n in to <br /> so you don't need or want to do
# blab
# <br /> blah because you'll end up with:
# blab
# <br /><br />blah
$content = <<'TEXTILE';
Roses are red<br />Violets are blue
TEXTILE
$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, <<'HTML', $test );
<p>Roses are red<br />Violets are blue</p>
HTML

# This test is asking for a bit much perhaps.  Use <pre lang="code"> </pre> instead.
#----------------------------------------------------------------------------
#$test = '<div> with non-standard HTML attribute> in a code span - the HTML scrubber should leave this alone';
##----------------------------------------------------------------------------
#$content = <<'TEXTILE';
#This is the code: @<div aria_role="content">alguna cosa</div>@.
#TEXTILE
#$body = get(POST '/.jsrpc/render', [content => $content]);
#eq_or_diff($body, <<'HTML', $test);
#<p>This is the code: <code>&lt;div aria_role="content"&gt;</code>.</p>
#HTML

#----------------------------------------------------------------------------
$test = 'blockquotes';

#----------------------------------------------------------------------------
$content = <<'TEXTILE';
Below is a blockquote:

bq. quoted text

A quote is above.
TEXTILE
$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, <<'HTML', $test );
<p>Below is a blockquote:</p>

<blockquote><p>quoted text</p></blockquote>

<p>A quote is above.</p>
HTML

#----------------------------------------------------------------------------
$test = 'Handle # as first character in a line while using Perl highlight';

# TODO: This test demonstrates that Syntax Highlight is adding an empty span.
#       Investigate further and clean it up.
$content = <<'TEXTILE';
<pre lang="Perl">
# comment
</pre>
TEXTILE
$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, <<'HTML', $test );
<pre>
<span class="kateComment"><i>#&nbsp;comment</i></span><span class="kateComment"><i>
</i></span></pre>
HTML

#----------------------------------------------------------------------------
$test = 'Maintain complete set of html table tags. Use escape ==';
# NOTE: The opening escape string '==' turns into a \n when textile
#       is applied.
$content = <<'TEXTILE';
==<table>
<caption>Vegetable Price List</caption>
<colgroup><col /><col align="right" /></colgroup>
<thead>
    <tr>
      <th>Vegetable</th>
      <th>Cost per kilo</th>
    </tr>
</thead>
<tbody>
    <tr>
      <td>Lettuce</td>
      <td>$1</td>
    </tr>
    <tr>
      <td>Silver carrots</td>
      <td>$10.50</td>
    </tr>
    <tr>
      <td>Golden turnips</td>
      <td>$108.00</td>
    </tr>
</tbody>
</table>
==
TEXTILE

$expected = <<'HTML';
<table>
<caption>Vegetable Price List</caption>
<colgroup><col /><col align="right" /></colgroup>
<thead>
    <tr>
      <th>Vegetable</th>
      <th>Cost per kilo</th>
    </tr>
</thead>
<tbody>
    <tr>
      <td>Lettuce</td>
      <td>$1</td>
    </tr>
    <tr>
      <td>Silver carrots</td>
      <td>$10.50</td>
    </tr>
    <tr>
      <td>Golden turnips</td>
      <td>$108.00</td>
    </tr>
</tbody>
</table>
HTML
# We expect textile to leave this table as is, EXCPEPT for the escape lines (==).
$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, $expected, $test );


