package MojoMojo::Formatter::Textile;

use parent 'MojoMojo::Formatter';

use Text::Textile;
use Text::SmartyPants;
my $textile = Text::Textile->new( flavor => "xhtml1", charset => 'utf-8' );

# We do not want Text::Textile to encode HTML entities at all because it will encode something
# like &gt; into &amp;gt; which sucks
{
    no strict 'refs';
    no warnings;
#    *{"Text::Textile::encode_html"} = sub { my ($self, $html) = @_; return $html; };
}

=head1 NAME

MojoMojo::Formatter::Textile - Texile+SmartyPants formatting for your content

=head1 DESCRIPTION

This formatter processes content using L<Text::Textile> (a syntax for writing
human-friendly formatted text), then post-processing that using L<Text::SmartyPants>
(which transforms plain ASCII punctuation characters into "smart" typographic
punctuation HTML entities, such as smart quotes or the ellipsis character).

Textile reference: <http://hobix.com/textile/>

=head1 METHODS

=over 4

=item main_format_content

Calls the formatter. Takes a ref to the content as well as the
context object. Note that this is different from the format_content method
of non-main formatters. This is because we don't want all main formatters
to be called when iterating over pluggable modules in
L<MojoMojo::Schema::ResultSet::Content::format_content>.

C<main_format_content> will only be called by <MojoMojo::Formatter::Main>.

=cut

sub main_format_content {
    my ( $class, $content ) = @_;

    # Let textile handle the rest
    $$content = $textile->process($$content);
    $$content = Text::SmartyPants->process($$content);
}

=back 

=head1 SEE ALSO

L<MojoMojo>, L<Module::Pluggable::Ordered>, L<Text::Textile>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 License

This module is licensed under the same terms as Perl itself.

=cut

1;
