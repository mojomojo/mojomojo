package MojoMojo::M::Core::User;


sub get_user {
    my ($class,$user) = @_;
    return __PACKAGE__->search(login=>$user)->next;
}

1;
