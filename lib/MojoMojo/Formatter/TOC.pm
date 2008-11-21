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

calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ( $class, $content ) = @_;

    # replace the =toc markup tag if it's on a line of its own (<p>), or not (followed by <br />)
    if ($$content =~ s{<p>=toc</p>|(?<=>)?=toc(?=<br)}{<!--mojomojoTOCwillgohere-->}g) {
        # workaround for http://rt.cpan.org/Public/Bug/Display.html?id=40983
        local *STDOUT;
        my $output;
        open STDOUT, '>:utf8', \$output or die "Can't open STDOUT: $!";
        
        my $toc = new HTML::GenToc(
            toc_entry => {
                h1 => 1, h2 => 2, h3 => 3,
                h4 => 4, h5 => 5, h6 => 6
            },
            toc_end => {
                h1 => '/h1',  h2 => '/h2',  h3 => '/h3',
                h4 => '/h4',  h5 => '/h5',  h6 => '/h6',
            },
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
        # Of all ASCII punctuation, !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~, only -_.: are allowed in id values
        # high-ASCII characters (e.g. Chinese characters) are allowed (test "<h1 id="行政区域">header</h1>" at http://validator.w3.org/#validate_by_input+with_options), except for smart quotes (!), see http://www.w3.org/Search/Mail/Public/search?type-index=www-validator&index-type=t&keywords=[VE][122]+smart+quotes&search=Search+Mail+Archives
        # However, that contradicts the HTML 4.01 spec: "Anchor names should be restricted to ASCII characters." - http://www.w3.org/TR/REC-html40/struct/links.html#h-12.2.1
        # Finally, note that pod2html fails miserably to generate XHTML-compliant anchor links. See http://validator.w3.org/check?uri=http%3A%2F%2Fsearch.cpan.org%2Fdist%2FCatalyst-Runtime%2Flib%2FCatalyst%2FRequest.pm&charset=(detect+automatically)&doctype=XHTML+1.0+Transitional&group=0&user-agent=W3C_Validator%2F1.606
        $name =~ s/\s/_/g;
        decode_entities($name);  # we need to replace [#&;] only when they are NOT part of an HTML entity. decode_entities saves us from crafting a nasty regexp
        use utf8;  # necessary for replacing “”, even in perl 5.10; see http://www.perlmonks.org/?node=Unicode%2C%20regex%27s%2C%20encodings%2C%20and%20all%20that%20(Perl%205.6%20and%205.8)
        $name =~ s/([!"#\$%&'()*+,\/;<=>?@\[\\\]\^`{|}~“”])/'.'.sprintf('%02X', ord($1))/eg;  # MediaWiki also uses the period, see http://en.wikipedia.org/wiki/Hierarchies#Ethics.2C_behavioral_psychology.2C_philosophies_of_identity
        $name = 'L'.$name if $name =~ /\A[^A-Za-z]/; # "ID and NAME tokens must begin with a letter ([A-Za-z])"
        
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
