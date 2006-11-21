use inc::Module::Install;

name 'MojoMojo-Formatter-Emote';
all_from 'lib/MojoMojo/Formatter/Emote.pm';

requires (
	'MojoMojo'    => 0,
	'Text::Emoticon::MSN' => 0,
);


tests ( join ' ', ( glob('t/*.t'), glob('t/*/*.t') ) );

auto_install;
WriteAll;
