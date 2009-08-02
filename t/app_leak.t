#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

my ( $APP, $URL, $REQUEST_COUNT, $leaks );

=head1 Methods

=head2 BEGIN

See if we have modules necessary for testing.  Set arguments.

=cut

sub BEGIN {
    $APP           = $ARGV[0] || 'MojoMojo';
    $URL           = $ARGV[1] || '/';
    $REQUEST_COUNT = $ARGV[2] || 1;
    $leaks         = 0;
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';

    eval "use Devel::LeakGuard::Object qw(leakguard leakstate)";
    my $leakguard = !$@;

    #    print "leakguard: ", $@, "\n";
    eval "use Catalyst::Test '$APP'";
    my $catalyst_test = !$@;

    #    print "catalyst test: ", $@, "\n";

    plan $leakguard && $catalyst_test
      ? ( tests => 2 )
      : (
        skip_all => 'Devel::LeakGuard::Object and Catalyst::Test 
           are neeed for this test'
      );
}

=pod

Make first request.  Things like Moose will have objects persist
for the duration of the process.  Get those into the memory space
before testing for leaks.

=cut

ok( request($URL)->is_success, 'First Request' );

=pod

Here is where we wrap the code to be tested with the leakguard method.

=cut

leakguard {
    request($URL) for 1 .. $REQUEST_COUNT;
}

#exclude => 'MojoMojo::I18N*';
# TODO: remove sync requirements of expect and tolerance (build expect from tolerance)
expect => {
    'MojoMojo::I18N::i_default' => [ 0, 1 ],
    'MojoMojo::I18N::en'        => [ 0, 1 ],
};
my %tolerance = (
    'MojoMojo::I18N::i_default' => 1,
    'MojoMojo::I18N::en'        => 1,
);

=head2 on_leak

When there is a object memory leak this anonymous sub will be run.
Would like to use on_leak, but when I combined it with expect I got:
  Useless use of a constant in void context at t/app_leak.t line 72.
  Useless use of reference constructor in void context at t/app_leak.t line 72.
Just warnings, yes I don't really like warnings from other people's 
modules when building tests.  Using leakstate() API gift to get at 
the leak report by parsing the class, object count hash. 

=cut

#on_leak => sub {
#    my $report = shift;
#    print "We got some memory leaks: \n";
#    for my $pkg ( sort keys %$report ) {
#        printf "%s %d %d\n", $pkg, @{ $report->{$pkg} };
#    }
#    $leaks++;
#};

my %nonzero_report;
my %report_hash = %{ leakstate() };
foreach my $class ( keys %report_hash ) {

    # Do we have non-zero objects reported for a class
    if ( my $object_count = $report_hash{$class} > 0 ) {

        # Do we care if there are non-zero objects of smaller values.
        if ( $object_count > $tolerance{$class} ) {
            $nonzero_report{$class} = $report_hash{$class};
            $leaks++;
        }
    }
}
use Data::Dumper;
print Dumper %nonzero_report;

is( $leaks, 0, 'Object Memory Management' );
