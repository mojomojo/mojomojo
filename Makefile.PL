use inc::Module::Install;

name 'MojoMojo';
all_from 'lib/MojoMojo.pm';

requires(
    'Algorithm::Diff'                              => '1.1901',
    'Algorithm::Merge'                             => 0,
    'Algorithm::IncludeExclude'                    => 0,
    'Archive::Zip'                                 => '1.14',
    'MRO::Compat'                                  => '0.10',
    'Cache::FastMmap'                              => 1.31,  # deleted /tmp/sharefile-* when MM is killed
    'Catalyst'                                     => '5.71001',
    'Catalyst::Action::RenderView'                 => '0.07',
    'Catalyst::Authentication::Store::DBIx::Class' => '0.101',
    'Catalyst::Controller::HTML::FormFu'           => '0.03007',
    'Catalyst::Model::DBIC::Schema'                => '0.01',
    'Catalyst::Plugin::Authentication'             => '0.10005',
    'Catalyst::Plugin::Cache'                      => 0.08,
    'Catalyst::Plugin::ConfigLoader'               => '0.13',
    'Catalyst::Plugin::I18N'                       => 0,
    'Catalyst::Plugin::SubRequest'                 => '0.13',
    'Catalyst::Plugin::Session::State::Cookie'     => 0.11,
    'Catalyst::Plugin::Session::Store::Cache'      => '0',
    'Catalyst::Plugin::Setenv'                     => 0,
    'Catalyst::Plugin::Static::Simple'             => '0.07',
    'Catalyst::Plugin::Unicode'                    => '0.8',
    'Catalyst::View::TT'                           => '0.23',
    'Catalyst::View::JSON'                         => 0,
    'Catalyst::View::Email::Template'              => 0,
    'Config::General'                              => 0,
    'Config::JFDI'                                 => 0,
    'Crypt::CBC'                                   => '2.12',    # FormFu
    'Data::FormValidator::Constraints::DateTime'   => 0,
    'Data::Page'                                   => '2.00',
    'DateTime'                                     => '0.28',
    'DateTime::Format::Mail'                       => 0,
    'DBD::SQLite'                                  => '1.08',
    'DBIx::Class'                                  => '0.08',
    'DBIx::Class::DateTime::Epoch'                 => '0.04',
    'DBIx::Class::EncodedColumn'                   => 0,
    'DBIx::Class::TimeStamp'                       => '0.11',
    'Encode'                                       => '2.31',
    'File::Copy::Recursive'                        => 0,
    'File::MMagic'                                 => '1.27',
    'File::Slurp'                                  => '9999.13', # Markdown
    'HTML::Entities'                               => '3.60',    # Pod::Simple
    'HTML::FormFu'                                 => '0.02000', # min version with string renderer
    'HTML::FormFu::Model::DBIC'                    => 0,
    'HTML::Strip'                                  => '1.04',
    'HTML::TagCloud'                               => 0,
    'Image::ExifTool'                              => 0,
    'Imager'                                       => 0,
    'Image::Math::Constrain'                       => 0,
    'IO::Scalar'                                   => 0,
    'IO::File'                                     => '1.14',
    'KinoSearch'                                   => '0.165',
    'Module::Pluggable::Ordered'                   => '1.4',
    'Moose'                                        => 0,
    'Number::Format'                               => 0,
    'Catalyst::Plugin::PageCache'                  => '0.21',
    'parent'                                       => 0,
    'String::Diff'                                 => 0,
    'Template'                                     => '2.20',
    'Template::Plugin::JavaScript'                 => 0,
    'Text::Context'                                => '3.5',
    'Text::Password::Pronounceable'                => 0,
    'URI'                                          => '1.37',
    'YAML'                                         => '0.36',
    'Text::Textile'                                => 0,
    'Term::Prompt'                                 => 0,
);

feature 'Automatic deployment', 'SQL::Translator' => '0.09006';
feature 'Markdown Formatter', 'Text::MultiMarkdown', '1.0.17';
# XML::LibXSLT depends on the following libraries: libxslt-dev, libgcrypt11-dev (for `lgcrypt`), libgdbm3-dev (for `lgdbm`) and possibly libxml2-dev
feature 'DocBook formatter', 'XML::LibXSLT' => '1.66',
                             'XML::LibXML'  => '1.66';
feature 'Table Of Contents Generator','HTML::Toc' => '1.10';
feature 'POD formatter', 'Pod::Simple::HTML' => '3.01';
feature 'Syntax Highlighter', 'Syntax::Highlight::Engine::Kate' => 0;
feature 'Transclusion support','LWP::Simple' => 0,
        'URI::Fetch'                         => 0;
feature 'Amazon boxes', 'Net::Amazon' => 0;
feature 'RSS Formatter', 'XML::Feed';
feature 'Emoticons', 'Text::Emoticon::MSN' => 0;


test_requires 'Test::More' => '0.82';
test_requires 'Email::Send::Test';
test_requires 'WWW::Mechanize' => '1.54';
test_requires 'Test::WWW::Mechanize::Catalyst'   =>  '0.51 ',;

tests( join ' ', ( glob('t/*.t'), glob('t/*/*.t') ) );

catalyst;
catalyst_par_script('script/mojomojo_server.pl');

install_script glob('script/*.pl');
auto_install;
WriteAll;
