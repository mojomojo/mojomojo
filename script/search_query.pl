#!/usr/bin/perl
#
# Test program to query the index
# Try queries like:
# marcus
# tags:car
# marcus OR cv

use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use MojoMojo::Search::Plucene;
use Data::Dumper;

my $index = "$FindBin::Bin/../plucene";
my $p = MojoMojo::Search::Plucene->open($index) or die "Unable to open index $index";

my $query = shift;
if ($query) {
    print "Search results for $query:\n";
    my @results = $p->search($query);
    print Dumper( \@results );
}
