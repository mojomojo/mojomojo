use inc::Module::Install;

name 'MojoMojo';
all_from 'lib/MojoMojo.pm';

requires (
        'Algorithm::Diff'                               => '1.1901',
        'Archive::Zip'                                  => '1.14',
        'Catalyst'                                      => '5.7000',
        'Catalyst::Action::RenderView'                  => '0.07',
        'Catalyst::Controller::HTML::FormFu'            => '0.02000',
        'Catalyst::Model::DBIC::Schema'                 => '0.01',      
        'KinoSearch'                                    => 0,
        'Catalyst::Plugin::Authentication'              => '0.10005',
        'Catalyst::Authentication::Store::DBIx::Class'  => '0.101',
        'Catalyst::Plugin::Cache::Store::Memory'        => 0,
        'Catalyst::Plugin::Email'                       => 0,
        'Catalyst::Plugin::ConfigLoader'                => '0.13',
        'Catalyst::Plugin::Session::Store::File'        => 0,
        'Catalyst::Plugin::Session::State::Cookie'      => 0,
        'Catalyst::Plugin::Singleton'                   => '0.02',
        'Catalyst::Plugin::Static::Simple'              => '0.07',
        'Catalyst::Plugin::SubRequest'                  => '0.09',
        'Catalyst::Plugin::Unicode'                     => '0.8',
        'Catalyst::View::TT'                            => '0.23',
        'Cache::Memory'                                 => 0,
        'Config::General'                               => 0,
        'Data::FormValidator::Constraints::DateTime'    => 0,
        'DateTime::Format::Mail'                        => 0,
        'DBIx::Class::DateTime::Epoch'                  => 0,
        'DBIx::Class::HTML::FormFu'                     => 0,
	'HTML::FormFu::Model::DBIC'			=> 0,  # User->prefs
        'DBIx::Class::EncodedColumn'                    => 0,
        'Module::Pluggable::Ordered'                    => '1.4',
        'Data::Page'                                    => '2.00',
        'DateTime'                                      => '0.28',
        'DBD::SQLite'                                   => '1.08',
        'File::MMagic'                                  => '1.27',
	'HTML::GenToc'                                  => 0,
        'HTML::Strip'                                   => '1.04',
        'HTML::Scrubber'                                => 0,
        'HTML::TagCloud'                                => 0,
        'Image::ExifTool'                               => 0,
        'Image::Math::Constrain'                        => 0,    
        'Imager'                                        => 0,
        'IO::Scalar'                                    => 0,
        'LWP::Simple'                                   => 0,
        'Moose'                                         => 0,
        'Pod::Simple::HTML'                             => '3.01',
	    'String::Diff'				                	=> 0,
	    'Template::Plugin::JavaScript'                  => 0,
        'Text::Context'                                 => '3.5',
        'URI'                                           => '1.35',
        'XML::Clean'                                    => 0,
        'YAML'                                          => '0.36',
        'URI::Fetch'                                    => 0,
        'Text::Password::Pronounceable'                 => 0,
        'DBIx::Class'                                   => '0.08',
);

feature 'Automatic deployment', 'SQL::Translator';
feature 'Markdown Formatter', 'Text::MultiMarkdown', '1.0.17';

tests ( join ' ', ( glob('t/*.t'), glob('t/*/*.t') ) );

catalyst;
catalyst_par_script('mojomojo_server.pl');

install_script glob('script/*.pl');
auto_install;
WriteAll;
