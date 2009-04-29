package MojoMojo::Formatter::ScrubSrc;

use base qw/MojoMojo::Formatter/;

use XML::Clean;

=head1 NAME

MojoMojo::Formatter::ScrubSrc - Scrub any tag that has an external src:
    <\w+\s+src=(?:")?http

=head1 DESCRIPTION

This formatter removes strings that look like tags with external C<src >
attribute values.  The idea is to prevent external source scripts from
showing up in C<iframe>, C<img> etc. tags that use invalid XHTML.  However, it
probably is better to enforce valid XHTML first, then one can rely more on
existing tools such as HTML::Scrubber.

=head1 METHODS

=over 4

=item format_content_order

Format order can be 1-99. The ScrubSrc formatter runs on 16, just after Scrub.

=cut

sub format_content_order { 8 }

=item format_content

Calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ( $class, $content, $c ) = @_;

    my @regex_strings_to_remove = (
        '<\w+\s+src=(?:[\'|"])?http.* ',
        '<\w+\s+src=(?:[\'|"])?javascript.* ',
    );
    @compiled_regexes_to_remove =
      map { qr/$_/ } @regex_strings_to_remove;
    foreach my $rm_regex (@compiled_regexes_to_remove) {
        $$content =~ s{$rm_regex}{}igmx;
    }
    return;
}

=back

=head1 SEE ALSO

L<MojoMojo>, L<Module::Pluggable::Ordered>, L<XML::Clean>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut

1;
