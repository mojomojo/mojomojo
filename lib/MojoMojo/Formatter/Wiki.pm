package MojoMojo::Formatter::Wiki;

sub format_content_order { 30 }
sub format_content {
    my ($self,$content,$c)=@_;
    # Extract wikiwords, avoiding escaped and part of urls
    $$content =~ s{
                   ( ?<! [\?\\\/\[] )        # following pattern does not follow '?', '\', '/', or '['
                   ( \b[A-Z][a-z]+[A-Z]\w* ) # match CamelCase, StudlyCaps, whatever you want to call it...
                  }
                  { MojoMojo->wikiword($1, $c->req->base) }gex;

    # Remove escapes on escaped wikiwords, e.g. \WikiWord. The escape
    # means that this wikiword is NOT a link to a wiki page.
    $$content =~ s{\\(\b[A-Z][a-z]+[A-Z]\w*)}
	         {$1}g;

    # Do explicit links, e.g. [[ /path/to/page | link text ]]
    $$content =~ s{
                   (?: \[\[ | \(\( )  # non-capturing match of '[[' or '(('
                   \s*
                   ( [^\]\)|]+? )     # non-greedily capture page path: characters not matching ']', ')', or '|'
                   \s*
                   (?:                # start of link text capture
                      \|              # '|' indicates that link text follows
                      \s*
                      ( [^\]\)]+? )   # non-greedily capture link text: characters not matching ']' or ')'
                      \s*
                   )?                 # end of link text capture, matching 1 or 0 time(s)
                   (?: \]\] | \)\) )  # non-capturing match of ']]' or '))'
                  }
                  { MojoMojo->wikiword($1, $c->req->base, $2) }gex;
}
1;
