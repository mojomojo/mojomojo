package MojoMojo::Formatter::TOC;

use base qw/MojoMojo::Formatter/;
require HTML::GenToc;
use HTML::Entities;

=head1 NAME

MojoMojo::Formatter::TOC - replace =toc with table of contents

=head1 DESCRIPTION

This formatter will replace C<=toc> with a table of contents, using
HTML::GenToc. If you don't want an element to be included in the TOC,
make it have C<class="notoc">

=head1 METHODS

=over 4

=item format_content_order

The TOC formatter expects HTML input so it needs to run after the main
formatter. Since comment-type formatters could add a heading for the
comment section, the TOC formatter will run with a priority of 95

=cut

sub format_content_order { 95 }

=item format_content

Calls the formatter. Takes a ref to the content as well as the context object.
The format for the toc plugin invocation is:

  =toc M-     # start from Header level M
  =toc -N     # stop at Header level N
  =toc M-N    # process only header levels M..N

where M is the minimum heading level to include in the TOC, and N is the
maximum level (depth). For example, suppose you only have one H1 on the page
so it doesn't make sense to add it to the TOC; also, assume you and don't want
to include any headers smaller than H3. The =toc markup to achieve that would be:

  =toc 2-3
  
Defaults to 1-6.

=cut

sub format_content {
    my ( $class, $content ) = @_;

    my $toc_params_RE = qr/\s+ (\d+)? \s* - \s* (\d+)?/x;
    while (
        # replace the =toc markup tag if it's on a line of its own (<p>), or not (followed by <br />)
        $$content =~ s{
            (<p>)=toc(?:$toc_params_RE)? \s* </p>
          | (?<=>)?=toc(?:$toc_params_RE)? \s* (?=<br)
        }{<!--mojomojoTOCwillgohere-->}x) {
        my ($toc_h_min, $toc_h_max);
        # FIXME: Perl 5.10 has a regexp branch reset operator which simplifies this
        if ($1) {
            # matched the <p> branch
            $toc_h_min = $2 || 1;
            $toc_h_max = $4 || 12;
        } else {
            # matched the <br branch
            $toc_h_min = $4 || 1;
            $toc_h_max = $5 || 12;  # 6 is the HTML max, but hey, knock yourself out
        }
        
        my %toc_entry, my %toc_end;
        for ($toc_h_min..$toc_h_max) {
            $toc_entry{"h$_"} = $_;
            $toc_end{"h$_"} = "/h$_";
        }
        
        # workaround for http://rt.cpan.org/Public/Bug/Display.html?id=40983
        local *STDOUT;
        my $output;
        open STDOUT, '>:utf8', \$output or die "Can't open STDOUT: $!";
        
        my $toc = new HTML::GenToc(
            toc_entry => \%toc_entry,
            toc_end => \%toc_end,
            toclabel => '',  # no default "Table of Contents" header. The user can add it if needed
            toc_tag => '!--mojomojoTOCwillgohere--',
            toc_tag_replace => 1,
            use_id => 1  # to avoid the different style applied by default to <a name> elements
        );

        $toc->generate_toc(
            input => $$content,
            inline => 1,
            to_string => 1,
            output => '',
        );
        $$content = $output;
        return 1;
    }
}

=pod

# SEO-friendly anchors

Anchors should be generated with SEO- (and human-) friendly names, i.e. out of the entire
token text, instead of being numeric or reduced to the first word(s) of the token.
In the spirit of http://seo2.0.onreact.com/top-10-fatal-url-design-mistakes, compare:

  http://beachfashion.com/photos/Pamela_Anderson#In_red_swimsuit_in_Baywatch
    vs.
  http://beachfashion.com/photos/Pamela_Anderson#in

Which one speaks your language more, which one will you rather click?

The anchor names generated are compliant with XHTML1.0 Strict. Also, per the
HTML 4.01 spec, anchors that differ only in case may not appear in the same
document and anchor names should be restricted to ASCII characters.

The sub below overrides make_anchor_name in HTML::GenToc to create friendly
anchor names.
=cut

{ no warnings 'redefine', 'once';
*HTML::GenToc::make_anchor_name = sub ($%) {
    my $self = shift;
    my %args = (
        content=>'',  # will be overwritten by one of @_
        anchors=>undef,
        @_
    );
    my $name = $args{content};  # the anchor name will most often be very close to the token content

    if ($name !~ /^\s*$/) {
        # generate a SEO-friendly anchor right from the token content
        # The allowed character set is limited first by the URI specification for fragments, http://tools.ietf.org/html/rfc3986#section-2: characters
        # then by the limitations of the values of 'id' and 'name' attributes: http://www.w3.org/TR/REC-html40/types.html#type-name
        # Eventually, the only punctuation allowed in id values is [_.:-]
        # Unicode characters with code points > 0x7E (e.g. Chinese characters) are allowed (test "<h1 id="行政区域">header</h1>" at http://validator.w3.org/#validate_by_input+with_options), except for smart quotes (!), see http://www.w3.org/Search/Mail/Public/search?type-index=www-validator&index-type=t&keywords=[VE][122]+smart+quotes&search=Search+Mail+Archives
        # However, that contradicts the HTML 4.01 spec: "Anchor names should be restricted to ASCII characters." - http://www.w3.org/TR/REC-html40/struct/links.html#h-12.2.1
        # ...and the [A-Za-z] class of letters mentioned at http://www.w3.org/TR/REC-html40/types.html#type-name
        # Finally, note that pod2html fails miserably to generate XHTML-compliant anchor links. See http://validator.w3.org/check?uri=http%3A%2F%2Fsearch.cpan.org%2Fdist%2FCatalyst-Runtime%2Flib%2FCatalyst%2FRequest.pm&charset=(detect+automatically)&doctype=XHTML+1.0+Transitional&group=0&user-agent=W3C_Validator%2F1.606
        $name =~ s/\s/_/g;
        decode_entities($name);  # we need to replace [#&;] only when they are NOT part of an HTML entity. decode_entities saves us from crafting a nasty regexp
        $name =~ s/([^\w_.:-])/'.'.sprintf('%02X', ord($1))/eg;  # MediaWiki also uses the period, see http://en.wikipedia.org/wiki/Hierarchies#Ethics.2C_behavioral_psychology.2C_philosophies_of_identity
        $name = 'L'.$name if $name =~ /\A\W/; # "ID and NAME tokens must begin with a letter ([A-Za-z])"
    }
    $name = 'id' if $name eq '';

    # check if it already exists; if so, add a number 
    my $anch_num = 1;
    my $word_name = $name;
    # Reference: http://www.w3.org/TR/REC-html40/struct/links.html#h-12.2.1
    # Anchor names must be unique within a document. Anchor names that differ only in case may not appear in the same document.
    while (grep {lc $_ eq lc $name} keys %{$args{anchors}}) {
        # FIXME (in caller sub): to avoid the grep above, the $args{anchors} hash
        # should have as key the lowercased anchor name, and as value its actual value (instead of '1')
        $name = $word_name . "_$anch_num";
        $anch_num++;
    }

    return $name;
} # make_anchor_name
}

=back

=head1 SEE ALSO

L<MojoMojo> and L<Module::Pluggable::Ordered>.

=head1 AUTHORS

Dan Dascalescu <ddascalescu at g-mail>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut

1;
