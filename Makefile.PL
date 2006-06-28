use inc::Module::Install;

name            ('MojoMojo');
abstract        ('wiki on speed');
author          ('Marcus Ramberg <marcus@thefeed.no>');
version_from    ('lib/MojoMojo.pm');
include	    ('ExtUtils::AutoInstall');
license         ('perl');

requires        (
	'Algorithm::Diff' => '1.1901',
	'Archive::Zip' => '1.14',

# We are developing MojoMojo on Catalyst trunk,
# so relying on the version number below may be
# problematic. We recommend installing the latest
# Catalyst from svn. We plan to stbilize this after
# the release of 5.5 

	'Catalyst' => '5.49_2',

	'Catalyst::Model::DBIC::Schema'		    => '0.01',
	'Catalyst::Plugin::Authentication'	            => '0.07',
	'Catalyst::Plugin::Authentication::Store::DBIC' => '0',
	'Catalyst::Plugin::Cache::FileCache'	    => 0,
	'Catalyst::Plugin::Email'			    => 0,
	'Catalyst::Plugin::FillInForm'		    => '0.04',
	'Catalyst::Plugin::DefaultEnd'		    => '0.02',
	'Catalyst::Plugin::FormValidator'		    => '0.02',
	'Catalyst::Plugin::Prototype'		    => '0.01',
	'Catalyst::Plugin::Session::Store::File', => 0,
	'Catalyst::Plugin::Session::State::Cookie' =>0,
	'Catalyst::Plugin::Singleton'		    => '0.02',
	'Catalyst::Plugin::Static::Simple'		    => '0.07',
	'Catalyst::Plugin::SubRequest'		    => '0.09',
	'Catalyst::Plugin::Unicode'		    => '0.1',
	'Catalyst::Plugin::UploadProgress'          => 0,
	'Catalyst::Model::Search::Plucene'             => 0,
	'DateTime::Format::Mail'			    => 0,
	'HTML::Prototype::Useful'			    => '0.01',
	'Plucene::Plugin::Analyzer::SnowballAnalyzer'  => '1.1',
	'Module::Pluggable::Ordered'		    => '1.4',
	'Catalyst::View::TT'  => 0 ,
	'Catalyst::View::TT'   => '0.23',
	'Data::Page'	    => '2.00',
	'DateTime'		    => '0.28',
	'DBD::SQLite'	    => '1.08',
	'Exception::Class'	    => 0,
	'File::MimeInfo'	    => '0.11',
	'File::Slurp'	    => '9999.07',
	'HTML::Strip'	    => '1.04',
	'HTML::Scrubber'	    => 0,
	'HTML::TagCloud'	    => 0,
	'Image::EXIF'	    => 0,
	'Imager'		    => 0,
	'IO::Scalar'	    => 0,
	'LWP::Simple'	    => 0,
	'Pod::Simple::HTML'    => '3.01',
	'Pod::Tree'	    => '1.11',
	'Text::Context'	    => '3.5',     
	'Time::Piece'	    => '1.08',
	'URI'		    => '1.35',
	'XML::Clean'	    => 0,
	'YAML'		    => '0.36',
	'URI::Fetch'	    => 0,
	);
build_requires  ('Test::More');
recommends      ('Test::Pod' => 0.0);
recommends      ('Test::PodCoverage' => 0.0);
tests	    ( join ' ', ( glob('t/*.t'), glob('t/*/*.t') ) );


# -- You'll likely only want one of the below --
# auto_bundle();       # bundle run-time dependencies
# auto_include();      # include build-time dependencies
# auto_include_deps(); # same as above, plus recursive dependencies
auto_install();      # auto-install all dependencies from CPAN

&WriteAll;


