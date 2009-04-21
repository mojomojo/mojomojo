package MojoMojo::Formatter::Textile;

use base qw/MojoMojo::Formatter/;

use Text::Textile;
use Text::SmartyPants;
my $textile = Text::Textile->new( flavor => "xhtml1", charset => 'utf-8' );

# We do not want Text::Textile to encode HTML entities at all because it will encode something
# like &gt; into &amp;gt; which sucks
{
    no strict 'refs';
    no warnings;
    *{"Text::Textile::encode_html"} = sub { my ($self, $html) = @_; return $html; };
}

=head1 NAME

MojoMojo::Formatter::Textile - Texile formatting for your content

=head1 DESCRIPTION

This formatter processes content using L<Text::Textile2> This is a 
syntax for writing human-friendly formatted text.

=head1 METHODS

=over 4

=item primary_formatter

See also L<MojoMojo::Formatter/primary_formatter>.

=cut

sub primary_formatter { 1; }

=item format_content_order

Format order can be 1-99. The Textile formatter runs on 15

=cut

sub format_content_order { 15 }

=item format_content

calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ( $class, $content, $c ) = @_;

    # Let textile handle the rest
    return
        unless $c->pref('main_formatter') eq 'MojoMojo::Formatter::Textile'
            || !$c->pref('main_formatter');
    $$content = $textile->process($$content);
    $$content = Text::SmartyPants->process($$content);
}

=back 

=head1 SEE ALSO

L<MojoMojo>,L<Module::Pluggable::Ordered>,L<Text::Textile2>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 License

This module is licensed under the same terms as Perl itself.

=cut

1;
