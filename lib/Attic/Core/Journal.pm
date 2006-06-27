package MojoMojo::M::Core::Journal;

MojoMojo::M::Core::Journal->has_many( 'entries' => 'MojoMojo::M::Core::Entry' );
MojoMojo::M::Core::Journal->has_a( 'pageid' => 'MojoMojo::M::Core::Page' );


1;
