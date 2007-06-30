package MojoMojo::Formatter::Wiki;

use URI;

=head1 NAME

MojoMojo::Formatter::Wiki - Handle interpage linking.

=head1 DESCRIPTION

This formatter handles Wiki links using the [[explicit]] and
ImplicitLink syntax. It will also indicate missing links with 
a question mark and a link to the edit page. In explicit mode, 
you can prefix the wikiword with an namespace, just like in a
normal url. For example: [[../marcus]] or [[/oslo/vacation]].

=head1 METHODS

=over 4

=item format_content_order

Format order can be 1-99. The Wiki formatter runs on 30

=cut

sub format_content_order { 30 }

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

=item format_content

calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ($class, $content, $c, $self) = @_;
    # Extract wikiwords, avoiding escaped and part of urls
    $$content =~ s{
        $non_wikiword_check
        ($wikiword)
    }{ $class->format_link($c, $1, $c->req->base,) }gex;

    # Remove escapes on escaped wikiwords. The escape means
    # that this wikiword is NOT a link to a wiki page.
    $$content =~ s{$wikiword_escape($wikiword)}{$1}g;

    # Do explicit links, e.g. [[ /path/to/page | link text ]]
    $$content =~ s{
        $non_wikiword_check
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
    $$content =~ s{
        $non_wikiword_check
	(
        $explicit_start
        \s*
        $explicit_path
        \s*
        (?:
           $explicit_separator
           \s*
           $explicit_text
           \s*
        )?
        $explicit_end)
    }{ $1 }gx;
}

=item format_link <c> <word> <base> [<link_text>]

Format a wikiword as a link

=cut

sub format_link {
    #FIXME: why both base and $c?
    my ($class, $c, $word, $base, $link_text) = @_;
    $base ||= $c->req->base;
    $word=$c->stash->{page}->path.'/'.$word unless $word =~ m|^[/\.]|;
    $c = MojoMojo->context unless ref $c;

    # keep the original wikiword for display, stripping leading slashes
    my $orig_word = $word;
    if ($orig_word =~ m|^ \s* /+ \s* $|x) {
        $orig_word = '/';
    }
    else {
        $orig_word =~ s/.*\///;
    }
    $word =~ s/\s/_/g;
    my $formatted = $link_text || $class->expand_wikiword($orig_word);


    # convert relative paths to absolute paths
    if($c->stash->{page} &&
        # drop spaces
        ref $c->stash->{page} eq 'MojoMojo::Schema::Page' &&
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
    my ($path_pages, $proto_pages) = 
	$c->model('DBIC::Page')->path_pages( $word );
if (defined $proto_pages && @$proto_pages) {
    my $proto_page = pop @$proto_pages;
    $url .= $proto_page->{path};
} else {
    my $page = pop @$path_pages;
    $url .= $page->path;
    return qq{<a class="existingWikiWord" href="$url">$formatted</a> };
}
return qq{<span class="newWikiWord">$formatted<a title="Not found. Click to create this page." href="$url.edit">?</a></span>};
}

=item expand_wikiword <word>

Expand mixed case and _ with spaces.

=cut

sub expand_wikiword {
    my ($class, $word) = @_;
    $word =~ s/([a-z])([A-Z])/$1 $2/g;
    $word =~ s/\_/ /g;
    return $word;
}

=item find_links <content> <page>

Find wiki links in content.

Return a listref of linked and wanted pages.

=cut

sub find_links {
    my ($class, $content, $page) = @_;
    my @linked_pages;
    my @wanted_pages;
    #my $c = MojoMojo->context;

    my $wikiword_regex = qr/$non_wikiword_check($wikiword)/x;
    my $explicit_regex = qr/$non_wikiword_check$explicit_start \s* ($explicit_path) \s* (?: $explicit_separator \s* $explicit_text \s* )? $explicit_end/x;

    for ($wikiword_regex, $explicit_regex) {
        while ($$content =~ /$_/g) {
            my $link = $1;
	   # convert relative paths to absolute paths
	   if ($link !~ m|^/|) {
	       $link = URI->new_abs( $link, ($page->path||'')."/" );
	   }
	   # use the normalized path string returned by path_pages:
	   my ($path_pages, $proto_pages) = 
	       $page->result_source->resultset->path_pages( $link );
	   if (defined $proto_pages && @$proto_pages) {
	       push @wanted_pages, pop @$proto_pages;
	   } else {
	       push @linked_pages, pop @$path_pages;
            }
        }
    }
    return (\@linked_pages, \@wanted_pages);
}

=back

=head1 SEE ALSO

L<MojoMojo>,L<Module::Pluggable::Ordered>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut

1;
