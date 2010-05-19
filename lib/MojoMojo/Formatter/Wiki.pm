package MojoMojo::Formatter::Wiki;

use parent qw/MojoMojo::Formatter/;

use URI;
use Scalar::Util qw/blessed/;
use MojoMojo::Formatter::TOC;

=head1 NAME

MojoMojo::Formatter::Wiki - Handle interpage linking.

=head1 DESCRIPTION

This formatter handles intra-Wiki links specified between double square brackets
or parentheses: [[wiki link]] or ((another wiki link)). It will also indicate
missing links with a question mark and a link to the edit page. Links can be
implicit (like the two above), where the path is derived from the link text
by replacing spaces with underscores (<a href="wiki_link">wiki link</a>), or
explicit, where the path is specified before a '|' sign:

    [[/explicit/path|Link text goes here]]

Note that external links have a different syntax: [Link text](http://foo.com).

=head1 METHODS

=head2 format_content_order

Format order can be 1-99. The Wiki formatter runs on 10.

=cut

sub format_content_order { 10 }

## list of start-end delimiter pairs
my @explicit_delims    = (qw{ \[\[ \]\] \(\( \)\) });
my $explicit_separator = '\|';

my $wikiword_escape = qr{\\};

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
    return qr{(?: $delims )}x;    # non-capturing match
}

sub _generate_explicit_end {
    my $delims = join '|', _explicit_end_delims();
    return qr{(?: $delims )}x;    # non-capturing match
}

sub _generate_explicit_path {
    # non-greedily match characters that don't match the start-end and text delimiters
    my $not_an_end_delimiter_or_separator = '(?:(?!' . (join '|', _explicit_end_delims(), $explicit_separator) . ').)';  # produces (?: (?! ]] | \)\) | \| ) .)  # a character in a place where neither a ]], nor a )), nor a | is
    return qr{$not_an_end_delimiter_or_separator+?};
}

sub _generate_explicit_text {
    # non-greedily match characters that don't match the start-end delimiters
    my $not_an_end_delimiter = '(?:(?!' . ( join '|', _explicit_end_delims() ) . ').)';  # produces (?: (?! ]] | \)\) ) .)  # a character in a place where neither a ]] nor a )) starts
    return qr{$not_an_end_delimiter+?};
}

my $explicit_start = _generate_explicit_start();
my $explicit_end   = _generate_explicit_end();
my $explicit_path  = _generate_explicit_path();
my $explicit_text  = _generate_explicit_text();


sub _generate_non_wikiword_check {
    # FIXME: this evaluates incorrectly to a regexp that's clearly mistaken: (?x-ism:( ?<! [\[\[\(\((?-xism:\\)\/\?] ))
    # we include '\/' to avoid wikiwords that are parts of urls
    # but why the question mark ('\?') at the end?
    my $non_wikiword_chars =
        ( join '', _explicit_start_delims() ) . $wikiword_escape . '\/' . '\?';
    return qr{( ?<! [$non_wikiword_chars] )}x;
}

my $non_wikiword_check = _generate_non_wikiword_check();

=head2 strip_pre

Replace <pre ... with a placeholder

=cut

sub strip_pre {
    my $content = shift;
    my ( @parts, $res );
    $res = '';
    while (
        my ($part) =
        $$content =~ m{
            ^(.+?)
            <\s*pre\b[^>]*>}sx
        )
    {
        # $$content =~ s{^.+?<\s*pre\b[^>]*>}{}sx;
        $$content =~ s{^.+?<\s*pre(?:\s+lang=['"]*(.*?)['"]*")?>}{}sx;
        my $lang = $1 || '';
        my ($inner) = $$content =~ m{^(.+?)<\s*/pre\s*>}sx;
        unless ($inner) {
            $res .= $part;
            last;
        }
        push @parts, $inner;
        $res .= $part . "<!--pre_placeholder::$lang-->";
        $$content =~ s{^.+?<\s*/pre\s*>}{}sx;
    }
    $res .= $$content;
    return $res, @parts;
}

=head2 reinsert_pre

Put pre and lang back into place.

=cut

sub reinsert_pre {
    my ( $content, @parts ) = @_;
    foreach my $part (@parts) {
        $$content =~ s{<!--pre_placeholder::(.*?)-->}{<pre lang="$1">$part</pre>}sx;
    }
    return $$content;
}

=head2 format_content

Calls the formatter. Takes a ref to the content as well as the
context object.

=cut

# FIXME: should ACCEPT_CONTEXT?

sub format_content {
    my ( $class, $content, $c, $self ) = @_;

    # Extract wikiwords, avoiding escaped and part of urls
    my @parts;
    ( $$content, @parts ) = strip_pre($content);

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
        $explicit_end
        )
    }{ $1 }gx;

    # Remove escapes on escaped wikiwords. The escape means
    # that this wikiword is NOT a link to a wiki page.
    $$content =~ s{$wikiword_escape($explicit_start)}{$1}g;

    $$content = reinsert_pre( $content, @parts );
}

=head2 format_link <c> <wikilink> <base> [<link_text>]

Format a wikilink as an HTML hyperlink with the given link_text. If the wikilink
doesn't exist, it will be rendered as a hyperlink to an .edit page ready to be
created.

Since there is no difference in syntax between new and existing links, some
abiguities my occur when it comes to characters that are invalid in URLs. For
example,

* [[say "NO" to #8]] should be rendered as C<< <a href="say_%22NO%22_to_%238">say "NO" to #8</a> >>
* [[100% match]] should be rendered as C<< <a href="100%25_match>100% match</a> >>, URL-escaping the '%'
* but what about a user pasting an existing link, C<[[say_%22NO%22_to_%238]]>? We shouldn't URL-escape the '%' or '#' here.
* for links with explicit link text, we should definitiely not URL-escape the link: C<[[say_%22NO%22_to_%238|say "NO" to #8]]>

This is complicated by the fact that '#' can delimit the start of the anchor portion of a link.

* C<[[Mambo #5]]> - URL-escape '#' => Mambo_%235
* C<[[Mambo#origins]]> - do not URL-escape
* C<[[existing/link#Introduction|See the Introduction]]> - definitely do not URL-escape

Since escaping is somewhat magic and therefore potentially counter-intuitive,
we will:
* only URL-escape '#' if it follows a whitespace directly
* always URL-escape '%' unless it is followed by two uppercase hex digits
* always escape other characters that are invalid in URLs

=cut

sub format_link {

    #FIXME: why both base and $c?
    my ( $class, $c, $wikilink, $base, $link_text, $action) = @_;
    $base ||= $c->req->base;
   
    # The following control structures are used to build the wikilink
    # from the stashed path and $wikilink passed to this function.
     
    # May as well smoke the page stash from MojoMojo.pm since we got it eh?
    my $stashed_path = $c->stash->{path};
    
    # If the wikilink starts with a slash the pass it on through
    my $pass_wikilink_through;
    if ( $wikilink =~ m{^/} ) { 
        $pass_wikilink_through = 1; 
    }

    # Make sure the $stashed_path starts with a bang, uh I mean slash.
    elsif ( $stashed_path ) {
        $stashed_path = '/' . $stashed_path if $stashed_path !~ m{^/};
    }
    else { $stashed_path = '/'; }
    
    # Handle sibling case by making look it like the rest.
    if ( my ($sibling) = $wikilink =~ m'^\.\./(.*)$' ) {
        my ($parent) = $stashed_path =~ m'(.*)/.*$';
        $wikilink = $parent . '/' . $sibling;
    }
    elsif ( !$pass_wikilink_through ) {
        $wikilink = $stashed_path . '/' . $wikilink;
        
        # Old School Method:
        #    $wikilink = ( blessed $c->stash->{page} ? $c->stash->{page}->path : $c->stash->{page}->{path}  ). '/' . $wikilink
        #        unless $wikilink =~ m'^(\.\.)?/';
    }
    $c = MojoMojo->context unless ref $c;

    # keep the original wikilink for display, stripping leading slashes
    my $orig_wikilink = $wikilink;
    if ( $orig_wikilink =~ m|^ \s* /+ \s* $|x ) {
        $orig_wikilink = '/';
    }
    else {
        $orig_wikilink =~ s/.*\///;
    }
    my $fragment = '';
    for ($wikilink) {
        s/(?<!\s)#(.*)/$fragment = $1, ''/e;  # trim the anchor (fragment) portion away, in preparation for the page search below, and save it in $fragment
        s/\s/_/g;

        # MojoMojo doesn't support periods in wikilinks because they conflict with actions ('.edit', '.info' etc.);
        # actions are a finite set apparently, but it's possible to add new actions from formatter plugins (e.g. Comment).
        # At the same time, parent links (../sibling) or (../../nephew) should be left alone, but any other '.' should be replaced by '_'
        s'^(\.\./)+'MOJOMOJO_RESERVED_TREE_CROSSING_LINK'g;
        s/\./_/g;
        s'MOJOMOJO_RESERVED_TREE_CROSSING_LINK'../'g;
        # if there's no link text, URL-escape characters in the wikilink that are not valid in URLs
        if (!defined $link_text or $link_text eq '') {
            s/%(?![0-9A-F]{2})  # escape '%' unless it's followed by two uppercase hex digits
            | (?<=_)\#          # escape '#' only if it directly follows a whitespace (which had been replaced by a '_')
            | [":<=>?{|}]       # escape all other characters that are invalid in URLs
            /sprintf('%%%02X', ord($&))/egx;  # all other characters in the 0x21..0x7E range are OK in URLs; see the conflicting guidelines at http://www.ietf.org/rfc/rfc1738.txt and http://labs.apache.org/webarch/uri/rfc/rfc3986.html#reserved
        }
    }
    # if the fragment was not properly formatted as a fragment (per the rules explained in MojoMojo::Formatter::TOC::assembleAnchorName, i.e. i has an invalid character), convert it, unless it contains escaped characters already (.[0-9A-F]{2})
    if(MojoMojo::Formatter::TOC->module_loaded){
        $fragment = MojoMojo::Formatter::TOC::assembleAnchorName(undef, undef, undef, undef, $fragment)
            if $fragment ne '' and ($fragment =~ /[^A-Za-z0-9_:.-]/ or $fragment !~ /\.[0-9A-F]{2}/);
    }
    my $formatted = $link_text || $class->expand_wikilink($orig_wikilink);

    # convert relative paths to absolute paths
    if (
        $c->stash->{page}
        &&

        # drop spaces
        ref $c->stash->{page} eq 'MojoMojo::Model::DBIC::Page' && $wikilink !~ m|^/|
        )
    {
        $wikilink = URI->new_abs( $wikilink, $c->stash->{page}->path . "/" );
    }
    elsif ( $c->stash->{page_path} && $wikilink !~ m|^/| ) {
        $wikilink = URI->new_abs( $wikilink, $c->stash->{page_path} . "/" );
    }

    # make sure that base URL has no trailing slash, since the page path will have a leading slash
    my $url = $base;
    $url =~ s/[\/]+$//;

    # remove http://host/ from url
    $url =~ s!^https?://[^/]+!!;

    # use the normalized path string returned by path_pages:
    my ( $path_pages, $proto_pages ) = $c->model('DBIC::Page')->path_pages($wikilink);
    if ( defined $proto_pages && @$proto_pages ) {
        my $proto_page = pop @$proto_pages;
        $url .= $proto_page->{path};
        if ( $action) {
            $url .= ".$action" ;
            return qq{<a class="existingWikiWord" href="$url">$formatted</a>};
        }
        else {
            return qq{<span class="newWikiWord"><a title="}
              . $c->loc('Not found. Click to create this page.')
              . qq{" href="$url.edit">$formatted?</a></span>};
        }
    }
    else {
        my $page = pop @$path_pages;
        $url .= $page->path;
        $url .= ".$action" if $action;
        $url .= "#$fragment" if $fragment ne '';
        return qq{<a class="existingWikiWord" href="$url">$formatted</a>};
    }
}

=head2 expand_wikilink <wikilink>

Replace C<_> with spaces and unescape URL-encoded characters

=cut

sub expand_wikilink {
    my ( $class, $wikilink ) = @_;
    for ($wikilink) {
        s/\_/ /g;
        s/%([0-9A-F]{2})/chr(hex($1))/eg;
    }
    return $wikilink;
}

=head2 find_links <content> <page>

Find wiki links in content.

Return a listref of linked (existing) and wanted pages.

=cut

sub find_links {
    my ( $class, $content, $page ) = @_;
    my @linked_pages;
    my @wanted_pages;

    my @parts;
    ( $$content, @parts ) = strip_pre($content);

    my $explicit_regex =
    qr/$non_wikiword_check$explicit_start \s* ($explicit_path) \s* (?: $explicit_separator \s* $explicit_text \s* )? $explicit_end/x;

    while ( $$content =~ /$explicit_regex/g ) {
        my $link = $1;
        $link =~ s/\s/_/g;

        # convert relative paths to absolute paths
        if ( $link !~ m|^/| ) {
            $link = URI->new_abs( $link, ( $page->path || '' ) . "/" );
        }

        # use the normalized path string returned by path_pages:
        my ( $path_pages, $proto_pages ) =
        $page->result_source->resultset->path_pages($link);
        if ( defined $proto_pages && @$proto_pages ) {
            push @wanted_pages, pop @$proto_pages;
        }
        else {
            push @linked_pages, pop @$path_pages;
        }
    }
    $$content = reinsert_pre( $content, @parts );
    return ( \@linked_pages, \@wanted_pages );
}

=head1 SEE ALSO

L<MojoMojo>, L<Module::Pluggable::Ordered>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
