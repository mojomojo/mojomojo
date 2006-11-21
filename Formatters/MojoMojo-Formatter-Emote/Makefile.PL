use inc::Module::Install;

name 'MojoMojo-Formatter-Amazon';
all_from 'lib/MojoMojo/Formatter/Amazon.pm';

requires (
	'MojoMojo'    => 0,
	'Net::Amazon' => 0,
);


tests ( join ' ', ( glob('t/*.t'), glob('t/*/*.t') ) );

auto_install;
WriteAll;
