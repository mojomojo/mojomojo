package MojoMojo::Formatter::TOC;

use base qw/MojoMojo::Formatter/;
use HTML::GenToc;

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

    if ($$content =~ s{<p>=toc</p>}{<!--mojomojoTOCwillgohere-->}g) {
        $$content .= "Was the TOC added?";
        my $toc = new HTML::GenToc(
            input => $$content,
            toc_entry => {
                h1 => 1, h2 => 2, h3 => 3,
                #h4 => 4, h5 => 5, h6 => 6
            },
            toc_end => {
                h1 => '/h1',  h2 => '/h2',  h3 => '/h3',
                #h4 => '/h4',  h5 => '/h5',  h6 => '/h6',
            },
            toc_tag => '!--mojomojoTOCwillgohere--',
            toc_tag_replace => 1,
            to_string => 1,
            debug => 0,
            use_id => 1
        );

        my $string;
        open(my $memory_file, '>', \$string);
        $$content = $toc->generate_toc(
            input => $$content,
            to_string => 1,
            outfile => $memory_file,
        );
    }
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
