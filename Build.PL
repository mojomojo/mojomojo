use strict;
use Catalyst::Build;

my $build = Catalyst::Build->new(
    create_makefile_pl => 'passthrough',
    license            => 'perl',
    module_name        => 'MojoMojo',
    requires           => { 
        Catalyst => '5.10',
        'Catalyst::Plugin::FillInForm' => 0.04,
        'Catalyst::Plugin::Prototype' => 0.01,
        'Plucene::Simple' => 1.04,
    },
    create_makefile_pl => 'passthrough',
    script_files       => [ glob('script/*') ],
    test_files         => [ glob('t/*.t'), glob('t/*/*.t') ]
);
$build->create_build_script;

