#!/usr/bin/perl -w
use Test::More tests => 30;
use HTTP::Request::Common;
use Test::Differences;
use FindBin '$Bin';
use lib "$Bin/../lib";
use Data::Dumper;

my $original_formatter
  ;    # used to save/restore whatever formatter is set up in mojomojo.db
my $c;       # the Catalyst object of this live server
my $test;    # test description

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
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
#warn Dumper $c->config;
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

This is your front page. Create
a [[New Page]] or edit this one
through the edit link at the bottom.

h2. Need some assistance?

Check out our [[Help]] section.
TEXTILE
$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, <<'HTML', $test );
<h1>Welcome to MojoMojo!</h1>

<p>This is your front page. Create<br />
a <span class="newWikiWord"><a title="Not found. Click to create this page." href="/New_Page.edit">New Page?</a></span> or edit this one<br />
through the edit link at the bottom.</p>

<h2>Need some assistance?</h2>

<p>Check out our <a class="existingWikiWord" href="/help">Help</a> section.</p>
HTML

{
    $test = 'say Perl';

    $content = <<'TEXTILE';
<pre lang="Perl">
    say "Hola Cabrón";
</pre>
TEXTILE

    $expected = <<HTML;
<pre>
&nbsp;&nbsp;&nbsp;&nbsp;say&nbsp;<span class="kateOperator">"</span><span class="kateString">Hola&nbsp;Cabrón</span><span class="kateOperator">"</span>;
</pre>
HTML

    # Now run through all formatters.
    $test .= ' - run through all formatters';
    $got = get( POST '/.jsrpc/render', [ content => $content ] );
    eq_or_diff( $got, $expected, $test );
}


#----------------------------------------------------------------------------
$test = 'Test > in <pre lang="Perl"> section.';

$content = <<'TEXTILE';
<pre lang="Perl">
if (1 > 2) {
  print "test";
}
</pre>
TEXTILE
$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, <<'HTML', $test );
<pre>
<b>if</b>&nbsp;(<span class="kateFloat">1</span>&nbsp;&gt;&nbsp;<span class="kateFloat">2</span>)&nbsp;{
&nbsp;&nbsp;<span class="kateFunction">print</span>&nbsp;<span class="kateOperator">"</span><span class="kateString">test</span><span class="kateOperator">"</span>;
}
</pre>
HTML

#----------------------------------------------------------------------------
$test    = 'Only a <pre> section - no attribute';
$content = <<'TEXTILE';
<pre>
Hopen, Norway
</pre>
TEXTILE
$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, $content, $test );

TODO: {
    local $TODO = 'something before a pre adds defang_lang attribute to pre';
    # We'd like this test to pass, but our current setup with Defang
    # adds
    #     defang_lang=""
    # attribute to <pre> when there is some content before a pre.
    # (even a pre itself)
    $test    = 'pre tag - no attribute and some text before pre';
    $content = <<'TEXTILE';
Jeg har familie i
<pre>
Hopen, Norway
</pre>
TEXTILE
    $expected = <<'HTML';
<p>Jeg har familie i</p>
<pre>
Hopen, Norway
</pre>
HTML
    $body = get( POST '/.jsrpc/render', [ content => $content ] );
    eq_or_diff( $body, $expected, $test );
}

$test    = 'pre tag - no attribute and some text after pre';
$content = <<'HTML';
<pre>
Hopen, Norway
</pre>
er et sted langt mot nord.
HTML
$expected = '<pre>
Hopen, Norway
</pre>


<p>er et sted langt mot nord.</p>
';
$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, $expected, $test );


#----------------------------------------------------------------------------
$test = "HTML tags inside <pre> sections should be preserved. Also test for GIGO: a stray '<'.";

$content = <<'TEXTILE';
<pre>
<span>
if (1 < 2) {
  print "pre section & no lang specified";
}
</span>
</pre>
TEXTILE

$expected= <<'HTML';
<pre>
<span>
if (1  2) {
  print "pre section & no lang specified";
}
</span>
</pre>
HTML

$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, $expected, $test );

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
$test    = '<code> behave like normal wrt to <span> - Use textile escape ==';
$content = <<'TEXTILE';
==<code><span style="font-size: 1.5em;">alguna cosa</span></code>
==
TEXTILE
$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, <<'HTML', $test );
<code><span style="font-size: 1.5em;">alguna cosa</span></code>
HTML

# Check that @ transforms to <code>
#----------------------------------------------------------------------------
$test    = '@word@ behavior';
$content = <<'TEXTILE';
@mot@
TEXTILE
$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, <<'HTML', $test );
<p><code>mot</code></p>
HTML

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
$test = 'Simple html table tags. Use textile escape ==';

# NOTE: The opening escape string '==' turns into a \n when textile
#       is applied.  colgroup was moved as it confused Defang.
$content = <<'TEXTILE';
==<table>
    <tr>
      <th>Vegetable</th>
    </tr>
    <tr>
      <td>Mr Potato</td>
    </tr>
</table>
==
TEXTILE

$expected = <<'HTML';
<table>
    <tr>
      <th>Vegetable</th>
    </tr>
    <tr>
      <td>Mr Potato</td>
    </tr>
</table>
HTML

# We expect textile to leave this table as is, EXCPEPT for the escape lines (==).
$body = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $body, $expected, $test );

#----------------------------------------------------------------------------
$test = 'Maintain complete set of html table tags. Use textile escape ==';

# NOTE: The opening escape string '==' turns into a \n when textile
#       is applied.  colgroup was removed as it confused Defang.
$content = <<'TEXTILE';
==<table>
<caption>Vegetable Price List</caption>
<colgroup>
<col /><col align="char" char="." />
</colgroup>
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
<colgroup>
<col /><col align="char" char="." />
</colgroup>
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

#-------------------------------------------------------------------------------
$test    = 'POD while Textile is the main formatter';
$content = <<'TEXTILE';
{{pod}}

=head1 NAME

Some POD here

=cut

{{end}}
TEXTILE
$body = get( POST '/.jsrpc/render', [ content => $content ] );
like( $body, qr'<h1><a.*NAME.*/h1>'s, "POD: there is an h1 NAME" );

{
    $test = 'Simple SQL SELECT';

    $content = <<SQL;
<pre lang="SQL">
select * from foo
</pre>
SQL

    $expected = <<SQL;
<pre>
<b>select</b>&nbsp;*&nbsp;<b>from</b>&nbsp;foo
</pre>
SQL

    $test .= ' - run through all formatters';
    $got = get( POST '/.jsrpc/render', [ content => $content ] );
    eq_or_diff( $got, $expected, $test );

}

#-------------------------------------------------------------------------------
$test = 'XML tag in <pre lang="HTML"> run through the JSRPC renderer';

$content = <<TEXTILE;
<pre lang="XML">
<foo>
some text here
</foo>
</pre>
TEXTILE

$expected = <<'HTML';
<pre>
<b>&lt;foo&gt;</b>
some&nbsp;text&nbsp;here
<b>&lt;/foo&gt;</b>
</pre>
HTML

$got = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $got, $expected, $test );



#-------------------------------------------------------------------------------
$test = 'HTML tag in <pre lang="HTML"> run through the JSRPC renderer';

$content = <<TEXTILE;
<pre lang="HTML">
<textarea>
some text here
</textarea>
</pre>
TEXTILE

$expected = <<'HTML';
<pre>
<b>&lt;textarea&gt;</b>
some&nbsp;text&nbsp;here
<b>&lt;/textarea&gt;</b>
</pre>
HTML

$got = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $got, $expected, $test );



#-------------------------------------------------------------------------------
TODO: {
    local $TODO = "Textile processes '<code>' tags specially; even '&lt;code&gt;' gets converted to '<code>'";

    $test = '<code> tag in <pre lang="HTML"> run through the JSRPC renderer';

    $content = <<TEXTILE;
<pre lang="HTML">
<code>
some text here
</code>
</pre>
TEXTILE

    $expected = <<'HTML';
<pre>
<b>&lt;code&gt;</b>
some&nbsp;text&nbsp;here
<b>&lt;/code&gt;</b>
</pre>
HTML

    $got = get( POST '/.jsrpc/render', [ content => $content ] );
    eq_or_diff( $got, $expected, $test );


    #-------------------------------------------------------------------------------
    $test = 'For comparison, "<code>" and "<tt>" strings in <pre lang="Perl"> run through the JSRPC renderer';

    $content = <<TEXTILE;
<pre lang="Perl">
"Monotype: use <tt>.";
"Source code: <code>.";
</pre>
TEXTILE

    $expected = <<'HTML';
<pre>
<span class="kateOperator">"</span><span class="kateString">Monotype:&nbsp;use&nbsp;&lt;tt&gt;.</span><span class="kateOperator">"</span>;
<span class="kateOperator">"</span><span class="kateString">Source&nbsp;code:&nbsp;&lt;code&gt;.</span><span class="kateOperator">"</span>;
</pre>
HTML

    $got = get( POST '/.jsrpc/render', [ content => $content ] );
    eq_or_diff( $got, $expected, $test );
}

#-------------------------------------------------------------------------------
$test    = 'img src http not allowed';
$content = <<'HTML';
<img src="http://malicious.com/foto.jpg" />
HTML
$expected = '<p><img defang_src="http://malicious.com/foto.jpg" /></p>
';
$got = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $got, $expected, $test );

$test    = 'img src https not allowed';
$content = <<'HTML';
<img src="https://malicious.com/foto.jpg" />
HTML
$expected = '<p><img defang_src="https://malicious.com/foto.jpg" /></p>
';
$got = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $got, $expected, $test );

$test    = 'img src with bypass protocol not allowed';
$content = <<'HTML';
<img src="//malicious.com/foto.jpg" />
HTML
$expected = '<p><img defang_src="//malicious.com/foto.jpg" /></p>
';
$got = get( POST '/.jsrpc/render', [ content => $content ] );
eq_or_diff( $got, $expected, $test );

$test    = 'remote img src allowed in .conf';
$content = <<'HTML';
<p><object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/P_hTFilWY9w&amp;hl=en"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/P_hTFilWY9w&amp;hl=en" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed></object></p>
HTML
$expected = $content;
$got = get( POST '/.jsrpc/render', [ content => $content ] );
is( $got, $expected, $test );
