package MojoMojo::Formatter::Wiki;

use URI;

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
    my ($class, $content, $c) = @_;
    # Extract wikiwords, avoiding escaped and part of urls
    $$content =~ s{
        $non_wikiword_check
        ($wikiword)
    }{ $class->format_link($c, $1, $c->req->base) }gex;

    # Remove escapes on escaped wikiwords. The escape means
    # that this wikiword is NOT a link to a wiki page.
    $$content =~ s{$wikiword_escape($wikiword)}{$1}g;

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
    }{ $class->format_link($c, $1, $c->req->base, $2) }gex;
}

sub format_link {
    my ($class, $c, $word, $base, $link_text) = @_;
    die "No base for $word" unless $base;
    $c = MojoMojo->context unless ref $c;

    # keep the original wikiword for display, stripping leading slashes
    my $orig_word = $word;
    $orig_word =~ s/.*\/// unless $orig_word eq '/';
    my $formatted = $link_text || $class->expand_wikiword($orig_word);

    # convert relative paths to absolute paths
    if($c->stash->{page} &&
        ref $c->stash->{page} eq 'MojoMojo::M::Core::Page' &&
        $word !~ m|^/|) {
        $word = URI->new_abs( $word, $c->stash->{page}->path."/" );
    } elsif ( $c->stash->{page_path} && $word !~ m|^/|) {
        $word = URI->new_abs( $word, $c->stash->{page_path}."/" );
    }

    # make sure that base url has no trailing slash, since
    # the page path will have a leading slash
    my $url =  $base;
    $url    =~ s/[\/]+$//;

    # use the normalized path string returned by path_pages:
    my ($path_pages, $proto_pages) = MojoMojo::M::Core::Page->path_pages( $word );
    if (@$proto_pages) {
        my $proto_page = pop @$proto_pages;
        $url .= $proto_page->{path};
    } else {
        my $page = pop @$path_pages;
        $url .= $page->path;
        return qq{<a class="existingWikiWord" href="$url">$formatted</a> };
    }
    return qq{<span class="newWikiWord">$formatted<a href="$url">?</a></span>};
}

sub expand_wikiword {
    my ($class, $word) = @_;
    $word =~ s/([a-z])([A-Z])/$1 $2/g;
    $word =~ s/\_/ /g;
    return $word;
}

sub find_links {
    my ($class, $content, $page) = @_;
    my @linked_pages;
    my @wanted_pages;
    my $c = MojoMojo->context;

    my $wikiword_regex = qr/$non_wikiword_check($wikiword)/x;
    my $explicit_regex = qr/$explicit_start \s* ($explicit_path) \s* (?: $explicit_separator \s* $explicit_text \s* )? $explicit_end/x;

    for ($wikiword_regex, $explicit_regex) {
        while ($$content =~ /$_/g) {
            my $link = $1;
	   # convert relative paths to absolute paths
	   if ($link !~ m|^/|) {
	       $link = URI->new_abs( $link, $page->path."/" );
	   }
	   # use the normalized path string returned by path_pages:
	   my ($path_pages, $proto_pages) = MojoMojo::M::Core::Page->path_pages( $link );
	   if (@$proto_pages) {
	       push @wanted_pages, pop @$proto_pages;
	   } else {
	       push @linked_pages, pop @$path_pages;
            }
        }
    }
    return (\@linked_pages, \@wanted_pages);
}

1;
