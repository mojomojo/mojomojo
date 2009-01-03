#!/usr/bin/perl -w
use strict;
use MojoMojo::Formatter::SyntaxHighlight;

use Test;
BEGIN { plan tests => 2 }

{
    my $content = <<HTML;
    <pre lang="HTML">
        <form action="[% c.uri_for('/login') %]" method="get">
            <input type="text" name="openid_identifier" value="http://" />
            <button type="submit">Sign in with OpenID</button>
        </form>
    </pre>
HTML
    MojoMojo::Formatter::SyntaxHighlight->format_content(\$content);
    ok($content, <<HTML);
    <pre>\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>&lt;form</b><span class="kateOthers">&nbsp;action=</span><span class="kateString">"[%&nbsp;c.uri_for('/login')&nbsp;%]"</span><span class="kateOthers">&nbsp;method=</span><span class="kateString">"get"</span><b>&gt;</b>\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>&lt;input</b><span class="kateOthers">&nbsp;type=</span><span class="kateString">"text"</span><span class="kateOthers">&nbsp;name=</span><span class="kateString">"openid_identifier"</span><span class="kateOthers">&nbsp;value=</span><span class="kateString">"http://"</span>&nbsp;<b>/&gt;</b>\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>&lt;button</b><span class="kateOthers">&nbsp;type=</span><span class="kateString">"submit"</span><b>&gt;</b>Sign&nbsp;in&nbsp;with&nbsp;OpenID<b>&lt;/button&gt;</b>\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>&lt;/form&gt;</b>\n&nbsp;&nbsp;&nbsp;&nbsp;</pre>
HTML
}

{
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
    MojoMojo::Formatter::SyntaxHighlight->format_content(\$content);
    ok($content, <<PERL);
    <pre>\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>sub&nbsp;</b><span class="kateFunction">login</span>&nbsp;:&nbsp;<b>Local</b>&nbsp;{\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>my</b>&nbsp;(&nbsp;<span class="kateDataType">\$self</span>,&nbsp;<span class="kateDataType">\$c</span>&nbsp;)&nbsp;=&nbsp;;\n\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateComment"><i>#&nbsp;eval&nbsp;necessary&nbsp;because&nbsp;LWPx::ParanoidAgent</i></span><span class="kateComment"><i>\n</i></span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateComment"><i>#&nbsp;croaks&nbsp;if&nbsp;invalid&nbsp;URL&nbsp;is&nbsp;specified</i></span><span class="kateComment"><i>\n</i></span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateFunction">eval</span>&nbsp;{\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateComment"><i>#&nbsp;Authenticate&nbsp;against&nbsp;OpenID&nbsp;to&nbsp;get&nbsp;user&nbsp;URL</i></span><span class="kateComment"><i>\n</i></span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>if</b>&nbsp;(&nbsp;<span class="kateDataType">\$c</span>-&gt;<span class="kateDataType">authenticate</span>({},&nbsp;<span class="kateOperator">'</span><span class="kateString">openid</span><span class="kateOperator">'</span>&nbsp;)&nbsp;)&nbsp;{\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateComment"><i>#&nbsp;...</i></span><span class="kateComment"><i>\n</i></span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>else</b>&nbsp;{\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateComment"><i>#&nbsp;...</i></span><span class="kateComment"><i>\n</i></span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;};\n\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>if</b>&nbsp;(<span class="kateVariable"><b>\$@</b></span>)&nbsp;{\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateDataType">\$c</span>-&gt;<span class="kateDataType">log</span>-&gt;<span class="kateDataType">error</span>(<span class="kateOperator">"</span><span class="kateString">Failure&nbsp;during&nbsp;login:&nbsp;</span><span class="kateOperator">"</span>&nbsp;.&nbsp;<span class="kateVariable"><b>\$@</b></span>);\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateDataType">\$c</span>-&gt;<span class="kateDataType">flash</span>-&gt;{<span class="kateOperator">'</span><span class="kateString">error_msg</span><span class="kateOperator">'</span>}=<span class="kateOperator">'</span><span class="kateString">Failure&nbsp;during&nbsp;login:&nbsp;</span><span class="kateOperator">'</span>&nbsp;.&nbsp;<span class="kateVariable"><b>\$@</b></span>;\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateDataType">\$c</span>-&gt;<span class="kateDataType">stash</span>-&gt;{<span class="kateOperator">'</span><span class="kateString">template</span><span class="kateOperator">'</span>}=<span class="kateOperator">'</span><span class="kateString">login.tt</span><span class="kateOperator">'</span>;\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}\n&nbsp;&nbsp;&nbsp;&nbsp;</pre>
PERL
}
