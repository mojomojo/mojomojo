package MojoMojo::Formatter;

sub primary_formatter { 0; }

=head1 NAME

MojoMojo::Formatter - Base class for all formatters

=head1 DESCRIPTION

Base class for all l<MojoMojo> Formatters.

=head1 METHODS

=head2 primary_formatter

Primary formatters are those who handle the basic job of translating markup to HTML. 
In the default distribution there are currently two, Textile and Markdown, with Textile
being the default setting. You can change this through Prefs.


=head1 SEE ALSO

L<MojoMojo>,L<MojoMojo::Formatter::Textile>,L<MojoMojo::Formatter::Markdown>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 License

This module is licensed under the same terms as Perl itself.

=cut

1;