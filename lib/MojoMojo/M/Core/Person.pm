package MojoMojo::M::Core::Person;

sub get_user {
    my ( $class, $user ) = @_;
    return __PACKAGE__->search( login => $user )->next;
}

sub link {
   my ($self) = @_;
   return "/".$self->login;
}

1;
