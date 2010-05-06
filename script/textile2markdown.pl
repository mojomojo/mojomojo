#!/usr/bin/env perl
use strict;

use HTML::WikiConverter;
use HTML::WikiConverter::Markdown 0.05;  # Version 0.05 fixed four bugs I reported. See http://rt.cpan.org/Public/Dist/Display.html?Status=Resolved&Name=HTML-WikiConverter-Markdown
use Text::Textile;

my $textile_engine = new Text::Textile;
my $wc_engine = new HTML::WikiConverter( dialect => 'Markdown' );

if (not @ARGV) {
    die "USAGE: $0 <textile_files>
For each Textile input file, will output a Markdown file with the same name and a .markdown extension
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

=head1 NAME

textile2markdown.pl - rough draft of converting textile to markdown

=head1 AUTHOR

Dan Dascalescu (dandv), http://dandascalescu.com

=cut
