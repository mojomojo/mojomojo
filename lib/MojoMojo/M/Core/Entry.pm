package MojoMojo::M::Core::Entry;

MojoMojo::M::Core::Entry->has_a( 'journal' => 'MojoMojo::M::Core::Journal' );
MojoMojo::M::Core::Entry->has_a( 'author' => 'MojoMojo::M::Core::Person' );


1;
