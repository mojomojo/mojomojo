package MojoMojo::Formatter::Textile;

use Text::Textile2;
use Text::SmartyPants;
my $textile = Text::Textile2->new(flavor=>"xhtml1",charset=>'utf-8');

=head1 NAME

MojoMojo::Formatter::Textile - Texile formatting for your content

=head1 DESCRIPTION

This formatter processes content using L<Text::Textile2> This is a 
syntax for writing human-friendly formatted text.

=head1 METHODS

=over 4

=item format_content_order

Format order can be 1-99. The Textile formatter runs on 15

=cut

sub format_content_order { 15 }

=item format_content

calls the formatter. Takes a ref to the content as well as the
context object.

=cut


sub format_content {
    my ($class,$content,$c)=@_;
    # Let textile handle the rest
    $$content= $textile->process( $$content );
    $$content= Text::SmartyPants->process( $$content );
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
