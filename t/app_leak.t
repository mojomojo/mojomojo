#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

my ( $URL, $REQUEST_COUNT, %tolerance, $expected_leaks );
my $leaks = 0;

=head1 Methods

=head2 BEGIN

See if we have modules necessary for testing.  Set arguments.

=cut

sub BEGIN {
    $URL           = $ARGV[0] || '/';
    $REQUEST_COUNT = $ARGV[1] || 1;
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';

    eval 'use Devel::LeakGuard::Object qw(leakguard leakstate)';
    plan skip_all => 'need Devel::LeakGuard::Object' if $@;

    eval "use Catalyst::Test 'MojoMojo'";
    plan skip_all => 'need Catalyst::Test' if $@;

    plan tests => 2;
}

=head2 Class Tolerance Threshold Hash

This is the Control Interface as to what we will tolerate.
The key is a class name and the value represents the 
maximum number of objects you allow to leak from the class.

=cut

%tolerance = (
    'MojoMojo::I18N::i_default' => 1,
    'MojoMojo::I18N::en'        => 1,
);

=pod

Build a proper data structure for C<expect> which takes a range.
An example is:

    'MojoMojo::I18N::en'        => [ 0, 1 ]

This says we'll tolerate between 0 and 1 objects leaking 
from the class MojoMojo::I18N::en.  

=cut

foreach my $class (keys %tolerance) {
    my $tolerance_range         = [0]; # start at zero
    $tolerance_range->[1]       = $tolerance{$class};
    $expected_leaks->{$class}   = $tolerance_range;    
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

expect => $expected_leaks;


=head2 on_leak

When there is a object memory leak this anonymous sub will be run.
Would like to use on_leak(), but when I combined it with expect I got:

  Useless use of a constant in void context
  Useless use of reference constructor in void context
  
An alternative approach using C<leakstate()> has been implemented.  
  
=cut

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
