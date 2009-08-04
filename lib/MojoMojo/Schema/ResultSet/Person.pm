package MojoMojo::Schema::ResultSet::Person;

use strict;
use warnings;
use parent qw/MojoMojo::Schema::Base::ResultSet/;

=head1 NAME

MojoMojo::Schema::ResultSet::Person

=head1 METHODS

=head2 get_person

Get a person by login.

=cut

sub get_person {
    my ( $self, $login ) = @_;
    my ($person) = $self->search( { login => $login } );
}

=head2 get_user

Same as L</get_person>.

=cut

sub get_user {
    my ( $self, $user ) = @_;
    return $self->search( { login => $user } )->next();
}

=head2 registration_profile

Returns a L<Data::FormValidator> profile for registration.

=cut

sub registration_profile {
    my ( $self, $schema ) = @_;
    return {
        email => {
            constraint => 'email',
            name       => 'Invalid format'
        },
        login => [
            {
                constraint => qr/^\w{3,10}$/,
                name       => 'only letters, 3-10 chars'
            },
            {
                constraint => sub { $self->user_free( $schema, @_ ) },
                name       => 'Username taken'
            }
        ],
        name => {
            constraint => qr/^\S+\s+\S+/,
            name       => 'Full name please'
        },
        pass => {
            constraint => \&pass_matches,
            params     => [qw( pass confirm)],
            name       => "Password doesn't match"
        }
    };
}

=head2 user_free

Check if a username is available. Returns 1 for available, 0 for in use.

=cut

sub user_free {
    my ( $class, $schema, $login ) = @_;
    $login ||= $class;
    my $user = $class->result_source->resultset->get_user($login);
    return ( $user ? 0 : 1 );
}

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
