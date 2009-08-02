#!/usr/bin/perl -w
use strict;
use MojoMojo::Formatter::SyntaxHighlight;
use HTTP::Request::Common;
use Test::More;
use Test::Differences;
my ( $content, $got, $expected, $test, $c, $original_formatter );

BEGIN {
    plan skip_all =>
      'Requirements not installed for Syntax Highligher Formatter'
      unless MojoMojo::Formatter::SyntaxHighlight->module_loaded;
    plan tests => 15;
    use_ok('MojoMojo::Formatter::Textile');
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
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

$test .= 'single word run through all formatters';
$content = 'palabra';

# We expect to get the word back surrounded with <p> tag and \n added.
$expected = '<p>' . $content . '</p>
';
$got = get( POST '/.jsrpc/render', [ content => $content ] );
is( $got, $expected, $test );

$test = 'single word run through all formatters with textile off';
$content = '==palabra==';

# We expect to get the word back surrounded with only \n added.
$expected = 'palabra
';
$got = get( POST '/.jsrpc/render', [ content => $content ] );
is( $got, $expected, $test );

$test    = 'two words run through all formatters';
$content = 'dues palabres';

# We expect to get the two words back surrounded with <p> tag and \n added.
$expected = '<p>' . $content . '</p>
';
$got = get( POST '/.jsrpc/render', [ content => $content ] );
is( $got, $expected, $test );

{
    $test = 'Single <code>';

    $content = <<HTML;
<pre lang="HTML">
<code>
Ha en god dag
</code>
</pre>
HTML

    $got = MojoMojo::Formatter::SyntaxHighlight->format_content( \$content );
    $expected = <<'HTML';
<pre>
<b>&lt;code&gt;</b>
Ha&nbsp;en&nbsp;god&nbsp;dag
<b>&lt;/code&gt;</b>
</pre>
HTML

    is( $$got, $expected, $test );
}

#-------------------------------------------------------------------------------
{
    $test = 'Single <div> from SyntaxHighlight->format_content';

    $content = <<'HTML';
<pre lang="HTML">
<div>
Ha en god dag
</div>
</pre>
HTML

    $got = MojoMojo::Formatter::SyntaxHighlight->format_content( \$content );
    $expected = '<pre>
<b>&lt;div&gt;</b>
Ha&nbsp;en&nbsp;god&nbsp;dag
<b>&lt;/div&gt;</b>
</pre>
';

    eq_or_diff( $$got, $expected, $test );

    $content = <<'HTML';
<pre lang="HTML">
<div>
Ha en god dag
</div>
</pre>
HTML

    # Now run through all formatters.
    $test = 'The same single <div> from the JSRPC renderer';
    $got = get( POST '/.jsrpc/render', [ content => $content ] );
    eq_or_diff( $got, $expected, $test );
}

{
    $test = 'Simple Perl';

    $content = <<Perl;
<pre lang="Perl">
    say "Hola Cabrón";
</pre>
Perl

    $got = MojoMojo::Formatter::SyntaxHighlight->format_content( \$content );
    $expected = <<Perl;
<pre>
&nbsp;&nbsp;&nbsp;&nbsp;say&nbsp;<span class="kateOperator">"</span><span class="kateString">Hola&nbsp;Cabrón</span><span class="kateOperator">"</span>;
</pre>
Perl

    is( $$got, $expected, $test );
}

{
    $test = 'Simple SQL SELECT';

    $content = <<SQL;
<pre lang="SQL">
select * from foo
</pre>
SQL

    $got = MojoMojo::Formatter::SyntaxHighlight->format_content( \$content );
    $expected = <<SQL;
<pre>
<b>select</b>&nbsp;*&nbsp;<b>from</b>&nbsp;foo
</pre>
SQL

    is( $$got, $expected, $test );
}

{
    $test = 'Simple HTML Form';

    $content = <<'HTML';
<pre lang="HTML">
    <form action="[% c.uri_for('/login') %]" method="get">
        <input type="text" name="openid_identifier" value="http://" />
        <button type="submit">Sign in with OpenID</button>
    </form>
</pre>
HTML

    $got = MojoMojo::Formatter::SyntaxHighlight->format_content( \$content );
    $expected = <<HTML;
<pre>
&nbsp;&nbsp;&nbsp;&nbsp;<b>&lt;form</b><span class="kateOthers">&nbsp;action=</span><span class="kateString">"[%&nbsp;c.uri_for('/login')&nbsp;%]"</span><span class="kateOthers">&nbsp;method=</span><span class="kateString">"get"</span><b>&gt;</b>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>&lt;input</b><span class="kateOthers">&nbsp;type=</span><span class="kateString">"text"</span><span class="kateOthers">&nbsp;name=</span><span class="kateString">"openid_identifier"</span><span class="kateOthers">&nbsp;value=</span><span class="kateString">"http://"</span>&nbsp;<b>/&gt;</b>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>&lt;button</b><span class="kateOthers">&nbsp;type=</span><span class="kateString">"submit"</span><b>&gt;</b>Sign&nbsp;in&nbsp;with&nbsp;OpenID<b>&lt;/button&gt;</b>
&nbsp;&nbsp;&nbsp;&nbsp;<b>&lt;/form&gt;</b>
</pre>
HTML
    is( $$got, $expected, $test );

}

{
    $test = 'More Complex Perl';
    my $content = <<PERL;
<pre lang="Perl">
    sub login : Local {
      my ( \$self, \$c ) = @_;

      # eval necessary because LWPx::ParanoidAgent
      # croaks if invalid URL is specified
      eval {
        # Authenticate against OpenID to get user URL
        if ( \$c->authenticate({}, 'openid' ) ) {
          # ...
        else {
          # ...
        }
      };

      if (\$@) {
        \$c->log->error("Failure during login: " . \$@);
        \$c->flash->{'error_msg'}='Failure during login: ' . \$@;
        \$c->stash->{'template'}='login.tt';
      }
    }
</pre>
PERL
    $got = MojoMojo::Formatter::SyntaxHighlight->format_content( \$content );
    my $wanted = <<'PERL';
<pre>
&nbsp;&nbsp;&nbsp;&nbsp;<b>sub&nbsp;</b><span class="kateFunction">login</span>&nbsp;:&nbsp;<b>Local</b>&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>my</b>&nbsp;(&nbsp;<span class="kateDataType">$self</span>,&nbsp;<span class="kateDataType">$c</span>&nbsp;)&nbsp;=&nbsp;;

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateComment"><i>#&nbsp;eval&nbsp;necessary&nbsp;because&nbsp;LWPx::ParanoidAgent</i></span><span class="kateComment"><i>
</i></span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateComment"><i>#&nbsp;croaks&nbsp;if&nbsp;invalid&nbsp;URL&nbsp;is&nbsp;specified</i></span><span class="kateComment"><i>
</i></span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateFunction">eval</span>&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateComment"><i>#&nbsp;Authenticate&nbsp;against&nbsp;OpenID&nbsp;to&nbsp;get&nbsp;user&nbsp;URL</i></span><span class="kateComment"><i>
</i></span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>if</b>&nbsp;(&nbsp;<span class="kateDataType">$c</span>-&gt;<span class="kateDataType">authenticate</span>({},&nbsp;<span class="kateOperator">'</span><span class="kateString">openid</span><span class="kateOperator">'</span>&nbsp;)&nbsp;)&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateComment"><i>#&nbsp;...</i></span><span class="kateComment"><i>
</i></span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>else</b>&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateComment"><i>#&nbsp;...</i></span><span class="kateComment"><i>
</i></span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;};

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>if</b>&nbsp;(<span class="kateVariable"><b>$@</b></span>)&nbsp;{
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateDataType">$c</span>-&gt;<span class="kateDataType">log</span>-&gt;<span class="kateDataType">error</span>(<span class="kateOperator">"</span><span class="kateString">Failure&nbsp;during&nbsp;login:&nbsp;</span><span class="kateOperator">"</span>&nbsp;.&nbsp;<span class="kateVariable"><b>$@</b></span>);
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateDataType">$c</span>-&gt;<span class="kateDataType">flash</span>-&gt;{<span class="kateOperator">'</span><span class="kateString">error_msg</span><span class="kateOperator">'</span>}=<span class="kateOperator">'</span><span class="kateString">Failure&nbsp;during&nbsp;login:&nbsp;</span><span class="kateOperator">'</span>&nbsp;.&nbsp;<span class="kateVariable"><b>$@</b></span>;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateDataType">$c</span>-&gt;<span class="kateDataType">stash</span>-&gt;{<span class="kateOperator">'</span><span class="kateString">template</span><span class="kateOperator">'</span>}=<span class="kateOperator">'</span><span class="kateString">login.tt</span><span class="kateOperator">'</span>;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}
&nbsp;&nbsp;&nbsp;&nbsp;}
</pre>
PERL
    is( $content, $wanted, $test );
}

