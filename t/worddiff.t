#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 6;


BEGIN {
    use_ok('MojoMojo::WordDiff');   
}

sub test_diff {
    my ($in1, $in2, $expected) = (shift, shift, shift);
    is(word_diff($in1, $in2), $expected, scalar(@_) ? $_[0] : undef);
}

test_diff('Perl is great', 'MojoMojo is great', "<del>Perl</del><ins>MojoMojo</ins> is great", "normal word change");
test_diff("V&aring;re norske tegn b&oslash;r &#230res", "V&aring;re norske tegn b&oslash;r &#230res", "V&aring;re norske tegn b&oslash;r &aelig;res", "encoded characters");
test_diff('<div>foo</div>', '<div>bar</div>', '<div><del>foo</del><ins>bar</ins></div>', "word change inside of tags");
test_diff('<div class="a">foo</div>', '<div>foo</div>', '<del><div class="a"></del><ins><div></ins>foo</div>', "change of tags attributes");
test_diff('Once upon a time in a country called the United States, there was a programmer named Ryan.', 'Once upon a time in a country called Canada, there was a programmer named Jon.', 'Once upon a time in a country called <del>the United States</del><ins>Canada</ins>, there was a programmer named <del>Ryan</del><ins>Jon</ins>.', "multiple word changes");
