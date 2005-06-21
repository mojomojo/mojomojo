package RoleMember;

MojoMojo::M::Core::RoleMember->has_a( 'role' => 'MojoMojo::M::Core::Role' );
MojoMojo::M::Core::RoleMember->has_a( 'person' => 'MojoMojo::M::Core::Person' );

1;
