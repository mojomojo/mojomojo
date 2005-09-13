package MojoMojo::M::CDBI;

use strict;
use base 'Catalyst::Model::CDBI';

use Catalyst::Model::CDBI::Sweet;

die "No DSN defined" unless MojoMojo->config->{dsn};

=head1 NAME

MojoMojo::M::CDBI - Base Class for the MojoMojo CDBI Model

=head1 DESCRIPTION

This is the base class for the MojoMojo CDBI Data Model. it uses
CDBI::Loader to set the classes from sql.

=head1 OVERRIDEN METHODS

=over 4

=cut

__PACKAGE__->config(
    dsn                => MojoMojo->config->{dsn},
    namespace          => 'MojoMojo::M::Core',
    additional_classes => [
        qw/Class::DBI::FromForm Class::DBI::Sweet::Topping Class::DBI::AsXML/
    ],
);

=item new

Overridden to make classes ::Sweet subclasses.

=cut

sub new {
     my $class = shift;
     my $self = $class->NEXT::new(@_);
     foreach my $subclass ( $self->loader->classes ) {
         no strict 'refs';
         unshift @{ $subclass . '::ISA' }, 'Catalyst::Model::CDBI::Sweet';
     }
     return $self;
      # uncomment this to get dbh traces
#     ($self->loader->classes)[0]->db_Main()->trace(1);
}

=back

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE 

You may distribute this code under the same terms as Perl itself.

=cut

1;
