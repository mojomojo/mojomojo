package MojoMojo::M::Core::Link;

__PACKAGE__->has_a( 'from_page' => 'MojoMojo::M::Core::Page' );
__PACKAGE__->has_a( 'to_page'   => 'MojoMojo::M::Core::Page' );

1;
