use strict;
use Catalyst::Build;

my $build = Catalyst::Build->new(
    create_makefile_pl => 'passthrough',
    license            => 'perl',
    module_name        => 'MojoMojo',
    requires           =>
    {
     'Algorithm::Diff' => '1.1901',
     'Archive::Zip' => '1.14',

     # We are developing MojoMojo on Catalyst trunk,
     # so relying on the version number below may be
     # problematic. We recommend installing the latest
     # Catalyst from svn. In particular, some revisions
     # prior to Catalyst revision 556 are known to
     # break MojoMojo.

     'Catalyst' => '5.20',

     'Catalyst::Plugin::Authentication::CDBI' => '0.08',
     'Catalyst::Plugin::FillInForm' => '0.04',
     'Catalyst::Plugin::FormValidator' => '0.02',
     'Catalyst::Plugin::Prototype' => '0.01',
     'Catalyst::Plugin::Session::FastMmap' => '0.09',
     'Catalyst::Plugin::Singleton' => '0.02',
     'Catalyst::Plugin::Static' => '0.07',
     'Catalyst::Plugin::SubRequest' => '0.04',
     'Catalyst::Plugin::Unicode' => '0.2',
     'Catalyst::View::TT' => '0.11',
     'Catalyst::Model::CDBI' => '0.08',
     'Class::DBI::SQLite' => '0.09',
     'Class::DBI::Loader' => '0.19',
     'Class::DBI::AbstractSearch' => '0.05',
     'Class::DBI::FromForm' => '0.01',
     'Class::DBI::Plugin::RetrieveAll' => '1.01',
	 'DBD::SQLite' => '1.08',
     'Data::Page' => '2.00',
     'DateTime' => 0,
     'File::MimeInfo' => '0.11',
     'File::Slurp' => '9999.07',
     'HTML::Strip' => '1.04',
     'IO::Scalar' => 0,
     'LWP::Simple' => 0,
     'Module::Pluggable::Ordered' => '1.4',
     'Plucene::Simple' => '1.04',
     'Plucene::Plugin::Analyzer::SnowballAnalyzer' => '1.1',
     'Pod::Simple::HTML' => '3.01',
     'Pod::Tree' => '1.11',
     'Text::Context' => '3.5',     
     'Text::Emoticon::MSN' => '0.01',
     'Time::Piece' => '1.08',
     URI => '1.35',
     YAML => '0.36',
    },
    create_makefile_pl => 'passthrough',
    script_files       => [ glob('script/*') ],
    test_files         => [ glob('t/*.t'), glob('t/*/*.t') ]
);
$build->create_build_script;

