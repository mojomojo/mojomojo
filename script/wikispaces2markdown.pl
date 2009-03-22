#!/usr/bin/perl -w
# Attempt to automatically convert Wikispaces.com markup to Markdown
# Very crude attempt (regexp search/replace)
# Author: Dan Dascalescu (dandv), http://dandascalescu.com
use strict;
use FindBin '$Bin';
use lib "$Bin/../lib";
use Text::Wikispaces2Markdown;

if (not @ARGV) {
    die "USAGE: $0 <textile_files>
For each Wikispaces input file, will output a Markdown file with the same name and a .markdown extension
";
}

for my $filename (@ARGV) {
    open my $file_in, '<', $filename or die $!;
    my $text = do {local $/; <$file_in>};

    my ($filename_out) = $filename =~ /^(.*?) ((?<=.)\.[^.\/:\\]+)?$/x;  # basename (path+file) and extension

    open my $file_out, '>', "$filename_out.markdown" or die $!;
    print $file_out Text::Wikispaces2Markdown::convert($text) or die $!;
}
