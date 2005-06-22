package MojoMojo::Formatter::Wiki;

# explicit link regexes

## list of start-end delimiter pairs
my @explicit_delims = ( qw{ \[\[ \]\] \(\( \)\) } );
my $explicit_separator = '\|';

sub _explicit_start_delims {
    my %delims = @explicit_delims;
    return keys %delims;
}
sub _explicit_end_delims {
    my %delims = @explicit_delims;
    return values %delims;
}
sub _generate_explicit_start {
    my $delims = join '|', _explicit_start_delims();
    return qr{(?: $delims )}x; # non-capturing match
}
sub _generate_explicit_end {
    my $delims = join '|', _explicit_end_delims();
    return qr{(?: $delims )}x; # non-capturing match
}
sub _generate_explicit_path {
    # non-greedily match characters that don't match the start-end and text delimiters
    my $delims =  ( join '', _explicit_end_delims() ) . $explicit_separator;
    return qr{[^$delims]+?};
}
sub _generate_explicit_text {
    # non-greedily match characters that don't match the start-end delimiters
    my $delims = join '', _explicit_end_delims();
    return qr{[^$delims]+?};
}

my $explicit_start     = _generate_explicit_start();
my $explicit_end       = _generate_explicit_end();
my $explicit_path      = _generate_explicit_path();
my $explicit_text      = _generate_explicit_text();

# implicit link (wikiword) regexes

my $wikiword        = qr{\b[A-Z][a-z]+[A-Z]\w*};
my $wikiword_escape = qr{\\};

sub _generate_non_wikiword_check {
    # we include '\/' to avoid wikiwords that are parts of urls
    # but why the question mark ('\?') at the end?
    my $non_wikiword_chars = ( join '', _explicit_start_delims() ) . $wikiword_escape . '\/' . '\?';
    return qr{( ?<! [$non_wikiword_chars] )}x;
}

my $non_wikiword_check = _generate_non_wikiword_check();

sub format_content_order { 30 }
sub format_content {
    my ($self,$content,$c)=@_;
    # Extract wikiwords, avoiding escaped and part of urls
    $$content =~ s{
                   $non_wikiword_check
                   ($wikiword)
                  }
                  { MojoMojo->wikiword($1, $c->req->base) }gex;

    # Remove escapes on escaped wikiwords. The escape means
    # that this wikiword is NOT a link to a wiki page.
    $$content =~ s{$wikiword_escape($wikiword)}
	         {$1}g;

    # Do explicit links, e.g. [[ /path/to/page | link text ]]
    $$content =~ s{
                   $explicit_start
                   \s*
                   ($explicit_path)
                   \s*
                   (?:
                      $explicit_separator
                      \s*
                      ($explicit_text)
                      \s*
                   )?
                   $explicit_end
                  }
                  { MojoMojo->wikiword($1, $c->req->base, $2) }gex;
}
1;
