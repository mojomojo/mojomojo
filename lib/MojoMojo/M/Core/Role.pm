package Role;

MojoMojo::M::Core::Role->has_many( 'rolemembers' => 'MojoMojo::M::Core::RoleMember' );
MojoMojo::M::Core::Role->has_many( 'roleprivileges' => 'MojoMojo::M::Core::RolePrivilege' );

1;
