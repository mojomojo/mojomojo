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
    <pre>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>&lt;form</b><span class="Others">&nbsp;action=</span><span class="String">"[%&nbsp;c.uri_for('/login')&nbsp;%]"</span><span class="Others">&nbsp;method=</span><span class="String">"get"</span><b>&gt;</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>&lt;input</b><span class="Others">&nbsp;type=</span><span class="String">"text"</span><span class="Others">&nbsp;name=</span><span class="String">"openid_identifier"</span><span class="Others">&nbsp;value=</span><span class="String">"http://"</span>&nbsp;<b>/&gt;</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>&lt;button</b><span class="Others">&nbsp;type=</span><span class="String">"submit"</span><b>&gt;</b>Sign&nbsp;in&nbsp;with&nbsp;OpenID<b>&lt;/button&gt;</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>&lt;/form&gt;</b>&nbsp;&nbsp;&nbsp;&nbsp;</pre>
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
    <pre>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>sub&nbsp;</b><span class="Function">login</span>&nbsp;:&nbsp;<b>Local</b>&nbsp;{&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>my</b>&nbsp;(&nbsp;<span class="DataType">\$self</span>,&nbsp;<span class="DataType">\$c</span>&nbsp;)&nbsp;=&nbsp;;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="Comment"><i>#&nbsp;eval&nbsp;necessary&nbsp;because&nbsp;LWPx::ParanoidAgent</i></span><span class="Comment"><i></i></span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="Comment"><i>#&nbsp;croaks&nbsp;if&nbsp;invalid&nbsp;URL&nbsp;is&nbsp;specified</i></span><span class="Comment"><i></i></span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="Function">eval</span>&nbsp;{&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="Comment"><i>#&nbsp;Authenticate&nbsp;against&nbsp;OpenID&nbsp;to&nbsp;get&nbsp;user&nbsp;URL</i></span><span class="Comment"><i></i></span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>if</b>&nbsp;(&nbsp;<span class="DataType">\$c</span>-&gt;<span class="DataType">authenticate</span>({},&nbsp;<span class="Operator">'</span><span class="String">openid</span><span class="Operator">'</span>&nbsp;)&nbsp;)&nbsp;{&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="Comment"><i>#&nbsp;...</i></span><span class="Comment"><i></i></span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>else</b>&nbsp;{&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="Comment"><i>#&nbsp;...</i></span><span class="Comment"><i></i></span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;};&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>if</b>&nbsp;(<span class="Variable"><b>\$@</b></span>)&nbsp;{&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="DataType">\$c</span>-&gt;<span class="DataType">log</span>-&gt;<span class="DataType">error</span>(<span class="Operator">"</span><span class="String">Failure&nbsp;during&nbsp;login:&nbsp;</span><span class="Operator">"</span>&nbsp;.&nbsp;<span class="Variable"><b>\$@</b></span>);&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="DataType">\$c</span>-&gt;<span class="DataType">flash</span>-&gt;{<span class="Operator">'</span><span class="String">error_msg</span><span class="Operator">'</span>}=<span class="Operator">'</span><span class="String">Failure&nbsp;during&nbsp;login:&nbsp;</span><span class="Operator">'</span>&nbsp;.&nbsp;<span class="Variable"><b>\$@</b></span>;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="DataType">\$c</span>-&gt;<span class="DataType">stash</span>-&gt;{<span class="Operator">'</span><span class="String">template</span><span class="Operator">'</span>}=<span class="Operator">'</span><span class="String">login.tt</span><span class="Operator">'</span>;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}&nbsp;&nbsp;&nbsp;&nbsp;</pre>
PERL
}
