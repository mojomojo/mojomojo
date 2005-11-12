package MojoMojo::M::Core::Person;

=head1 NAME

MojoMojo::M::Core::Person - MojoMojo User class

=head1 DESCRIPTION

=head1 METHODS

=over 4

=cut

__PACKAGE__->columns(Essential=>qw/login pass active/);
MojoMojo::M::Core::Person->has_many( 'comments' => 'MojoMojo::M::Core::Comment' );
MojoMojo::M::Core::Person->has_many( 'contents' => 'MojoMojo::M::Core::Content' );
MojoMojo::M::Core::Person->has_many( 'entries' => 'MojoMojo::M::Core::Entry' );
MojoMojo::M::Core::Person->has_many( 'pageversions' => 'MojoMojo::M::Core::PageVersion' );
MojoMojo::M::Core::Person->has_many( 'rolemembers' => 'MojoMojo::M::Core::RoleMember' );
MojoMojo::M::Core::Person->has_many( 'tags' => 'MojoMojo::M::Core::Tag' );

__PACKAGE__->has_a(
    registered => 'DateTime',
    inflate => sub {
        DateTime->from_epoch(epoch=>shift);
    },
    deflate => 'epoch'
);


__PACKAGE__->has_a(
    born => 'DateTime',
    inflate => sub {
        DateTime->from_epoch(epoch=>shift);
    },
    deflate => 'epoch'
);

=item get_user <user>

Takes a username, returns a Person object.

=cut

sub get_user {
    my ( $class, $login) = @_;
    $login ||=$class;
    my $user= __PACKAGE__->search( login => $login )->next;
    return $user ;
}

sub user_free {
    my ( $class, $login) = @_;
    $login ||=$class;
    my $user= __PACKAGE__->get_user( $login );
    return ( $user ? 0 : 1 ) ;
}

=item is_admin

returns true if user is in admin list, false otherwise.

=cut

sub is_admin {  
    my $self   =shift;
    my $admins = MojoMojo->pref('admins');
    my $user   = $self->login;
    return 1 if $user && $admins =~m/\b$user\b/ ;
    return 0;
}

=item link

Link to user page/profile.

=cut

sub link {
   my ($self) = @_;
   #FIXME: Link to profile here? 
   return lc "/".($self->login || MojoMojo->pref('anonymous_user'));
}

=item registration_profile

returns a L<Data::FormValidator> profile for registration.

=cut

sub registration_profile { 
    return { 
         email => { constraint => 'email',
                    name       => 'Invalid format'},
         login =>[{ constraint => qr/^\w{3,10}$/,
                    name       => 'only letters, 3-10 chars'},
                  { constraint => \&user_free,
                    name       => 'Username taken'}],
         name  => { constraint => qr/^\S+\s+\S+/,
                    name       => 'Full name please'},
      pass     => { constraint => \&pass_matches,
                     params    => [ qw( pass confirm)],
                     name      => "Password doesn't match"}
   };
}

=item user_exists

returns 1 if user exists, or 0 otherwise.

=cut

=item pass_matches <pass1> <pass2>

Returns true if pass1 eq pass2. For
validation

=cut

sub pass_matches {
    return 1 if ($_[0] eq $_[1]);
    return 0
}

=item  valid_pass <password>

check password against database.

=cut

sub valid_pass {
    my ( $self,$pass )=@_;
    return 1 if $self->pass eq $pass;
    return 0;
}

=item can_edit <path>

Checks if a user has rights to edit a given path.

=cut

sub can_edit {
    my ( $self, $page ) = @_;
    return 0 unless $self->active;
     # allow admins, and users editing their pages
    return 1 if $self->is_admin;
    $link=$self->link;
    return 1 if $page =~ m|^$link\b|i; 
    return 0;
}

=back

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>
David Naughton C<naughton@umn.edu>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
