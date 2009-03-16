#!/usr/bin/perl -w
# Attempt to automatically convert Textile to Markdown through HTML.
# See the bug list at http://rt.cpan.org/Public/Dist/Display.html?Name=HTML-WikiConverter-Markdown
use strict;

use HTML::WikiConverter;
use Text::Textile;

my $textile_engine = new Text::Textile;
my $wc_engine = new HTML::WikiConverter( dialect => 'Markdown' );

if (not @ARGV) {
    die "USAGE: $0 <textile_files>
For each Textile input file, will output a Markdown file with the same name and a .markdown extension

WARNING: see http://rt.cpan.org/Public/Dist/Display.html?Name=HTML-WikiConverter-Markdown for bugs:

* backticks and underscored in code sections are incorrectly/uselessly backslash-escaped
* code blocks (bc.) are converted to multi-line `code\ncode` instead of 4-space indented code
* angle brackets are needlessly HTML-escaped
";
}

for my $filename (@ARGV) {
    open my $file_in, '<', $filename or die $!;
    my $textile_text = do {local $/; <$file_in>};
    my $html = $textile_engine->process($textile_text);

    my $markdown_text = $wc_engine->html2wiki(
        html => $html,
        link_style => 'inline',
    );

    my ($filename_out) = $filename =~ /^(.*?) ((?<=.)\.[^.\/:\\]+)?$/x;  # basename (path+file) and extension

    # open my $file_out, '>', "$filename_out.html" or die $!;
    # print $file_out $html or die $!;

    open my $file_out, '>', "$filename_out.markdown" or die $!;
    print $file_out $markdown_text or die $!;
}
