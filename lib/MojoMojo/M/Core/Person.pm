package MojoMojo::M::Core::Person;


__PACKAGE__->columns(Essential=>qw/login pass active/);
MojoMojo::M::Core::Person->has_many( 'comments' => 'MojoMojo::M::Core::Comment' );
MojoMojo::M::Core::Person->has_many( 'contents' => 'MojoMojo::M::Core::Content' );
MojoMojo::M::Core::Person->has_many( 'entries' => 'MojoMojo::M::Core::Entry' );
MojoMojo::M::Core::Person->has_many( 'pageversions' => 'MojoMojo::M::Core::PageVersion' );
MojoMojo::M::Core::Person->has_many( 'rolemembers' => 'MojoMojo::M::Core::RoleMember' );
MojoMojo::M::Core::Person->has_many( 'tags' => 'MojoMojo::M::Core::Tag' );

sub get_user {
    my ( $class, $user ) = @_;
    return __PACKAGE__->search( login => $user )->next;
}

sub is_admin {  
    my $self=shift;
    my $admins = MojoMojo->pref('admins');
    my $user=$self->login;
    return 1 if $user && $admins =~m/\b$user\b/ ;
    return 0;
}

sub link {
   my ($self) = @_;
   
   return "/".($self->login || '/no_login');
}

sub registration_profile { 
    return { 
         email => { constraint => 'email',
                    name       => 'Invalid format'},
         login =>[{ constraint => qr/^\w{3,10}$/,
                    name       => 'only letters, 3-10 chars'},
                  { constraint => \&user_exists,
                    name       => 'Username taken'}],
         name  => { constraint => qr/^\S+\s+\S+/,
                    name       => 'Full name please'},
      pass     => { constraint => \&pass_matches,
                     params    => [ qw( pass confirm)],
                     name      => "Password doesn't match"}
   };
}

sub user_exists {
    return 0 if MojoMojo::M::Core::Person->get_user(shift);
    return 1;
}

sub pass_matches {
    return 1 if ($_[0] eq $_[1]);
    return 0
}

sub valid_pass {
    my ( $self,$pass )=@_;
    return 1 if $self->pass eq $pass;
    return 0;
}

sub can_edit {
    my ( $self, $page ) = @_;
    return 0 unless $self->active;
     # allow admins, and users editing their pages
    return 1 if $self->is_admin;
    $link=$self->link;
    return 1 if $page->path =~ m|^$link\b|i; 
    return 0;
}

1;
