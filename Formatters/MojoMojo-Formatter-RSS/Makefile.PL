use inc::Module::Install;

name 'MojoMojo-Formatter-RSS';
all_from 'lib/MojoMojo/Formatter/RSS.pm';

requires (
	'MojoMojo'    => 0,
	'LWP::Simple' => 0,
	'URI::Fetch'  => 0,
	'XML::Feed'   => 0,
);


tests ( join ' ', ( glob('t/*.t'), glob('t/*/*.t') ) );

auto_install;
WriteAll;
