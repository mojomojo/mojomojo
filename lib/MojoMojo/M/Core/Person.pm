package MojoMojo::M::Core::Person;

sub get_user {
    my ( $class, $user ) = @_;
    return __PACKAGE__->search( login => $user )->next;
}

1;
