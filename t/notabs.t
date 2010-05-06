#!/usr/bin/env perl
use Test::More;

BEGIN {
    eval 'use Test::NoTabs';
    if ($@) {
        plan skip_all => "need Test::NoTabs to run this test\n";
    }
}
all_perl_files_ok('lib', 'script', 't');

