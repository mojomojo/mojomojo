package MojoMojo::Formatter::DocBook::Colorize;

#--------------------------------------------------------------------#
# Transform XML Docbook in XHTML (colorized programlisting|screen )
# 'lang' is lost in 'transformation xslt' step then:
# mark lang -> transformation xslt -> colorize && unmark lang
#--------------------------------------------------------------------#

use strict;
eval "use Syntax::Highlight::Engine::Kate;";
my $eval_res = $@;
sub module_loaded { $eval_res ? 0 : 1 }

my $hl_node="programlisting|screen";
my $hl_attrib="lang";
my $marklang=0;
my $colorize=0;
my $tomark;
my $tocolorize;
my $lang;
my $doc;
my $step;
my $debug;


sub new {
    my $type = shift;
    $debug = shift;

    my $self = ( $#_ == 0 ) ? shift : { @_ };

    return bless $self, $type;
}


sub step{
    my $self = shift;
    $step = shift;
}


sub start_document{
    print STDERR "start_document\n" if $debug;
}


sub end_document{
    my $result=$doc;
    $doc="";

    print STDERR "end_document\n" if $debug;
    return $result;
}


sub start_element{
    my $self = shift;
    my $el = shift;

    my @Attributes = keys %{$el->{Attributes}};
    my $name = $el->{Name};

    print STDERR "[$step]start_element: $name\n" if $debug;

    $doc .= "<$name";
    foreach my $att (@Attributes) {
        my $val = $el->{Attributes}->{$att}->{Value};

        $att =~ s/^\{\}//;

        # Uppercase fisrt letter of lang
        $val =~ s/\b(\w)/\U$1/g if (( $att eq "lang" )&&($el->{Name} =~ /$hl_node/));

        # Bug  XML::SAX::ParserFactory (???)
        # It add {http://www.w3.org/XML/1998/namespace} before lang="fr"
        #  if attrib class=article|section
        if ( $att eq "{http://www.w3.org/XML/1998/namespace}lang") {
            next;
        }

        # to be conform to xhtml 1.1
        if (( $name eq "div" ) && ( $att eq "lang" )) {
            $att = "xml:lang";
        }

        $doc .= " $att=\"$val\"";

        print STDERR "  $att=\"$val\"\n" if $debug;

        if (( $step eq 'marklang') && ( $att =~ /$hl_attrib/i )&&($el->{Name} =~ /$hl_node/ )) {
            $lang = $val;
            $marklang=1;
        } elsif (( $step eq 'colorize' ) && ($el->{Name} eq 'pre' )&&($val =~ /$hl_node/i)) {
            $colorize=1;
        }
    }

    $doc .= ">";
}


sub end_element{
    my $self = shift;
    my $el = shift;

    my $name = $el->{Name};

    print STDERR "[$step]end_element: $name\n" if $debug;

    # Mark language
    if (( $el->{Name} =~ /$hl_node/ ) && ($marklang eq 1 )) {

        #$tomark =~ s/</&lt;/g;
        #$tomark =~ s/>/&gt;/g;

        $doc .= "[lang=$lang\]\n${tomark}\n\[\/lang\]";

        print STDERR " => MARK LANG\n" if $debug;

        $marklang=0;
        $lang="";
        $tomark="";
    }
    # Colorize
    elsif (( $el->{Name} =~ /pre/ ) && ($colorize eq 1 )) {

        print STDERR " => COLORIZE\n" if $debug;
        $doc .= ColorizeCode($tocolorize);
        $colorize=0;
        $tocolorize="";
    }

    if ( ! $lang ){ $doc =~ s/\n$// }

    $doc .= "</$name>";
}


sub characters{
    my $self = shift;
    my $el = shift;

    print STDERR "[$step]characters: " . $el->{Data} . "\n" if $debug;

    if ( $marklang ) {
        $tomark .= $el->{Data};
    } elsif (  $colorize ) {
        $tocolorize .= $el->{Data};
    } else {
        $doc .= $el->{Data} if ( defined $el->{Data} );
    }
}


sub ColorizeCode{
    my $code = shift;

    $code =~ m/\[lang=(.*)\]/;
    my $lang=$1;

    $code =~ s/^\n//;
    $code =~ s/\[lang=\w*\]\n//g;
    $code =~ s/\[\/lang\]\s*//;
    $code =~ s/\n\s*$//;

    if ( $debug ) {
        print STDERR "lang=$lang\ncode=$code\n" . "-"x60 . "\n";
    }

    return $code if ( ! $lang );
    return $code unless __PACKAGE__->module_loaded;


    my $hl = Syntax::Highlight::Engine::Kate->new(
        language      => 'Perl',
        substitutions => {
            "&"  => "&amp;",
            " "  => "&nbsp;",
            "\t" => "&nbsp;&nbsp;&nbsp;",
            "\n" => "\n",
        },
        format_table => {
            Alert        => [ q{<span class="kateAlert">},           "</span>" ],
            BaseN        => [ q{<span class="kateBaseN">},           "</span>" ],
            BString      => [ q{<span class="kateBString">},         "</span>" ],
            Char         => [ q{<span class="kateChar">},            "</span>" ],
            Comment      => [ q{<span class="kateComment"><i>},      "</i></span>" ],
            DataType     => [ q{<span class="kateDataType">},        "</span>" ],
            DecVal       => [ q{<span class="kateDecVal">},          "</span>" ],
            Error        => [ q{<span class="kateError"><b><i>},     "</i></b></span>" ],
            Float        => [ q{<span class="kateFloat">},           "</span>" ],
            Function     => [ q{<span class="kateFunction">},        "</span>" ],
            IString      => [ q{<span class="kateIString">},         "" ],
            Keyword      => [ q{<b>},                            "</b>" ],
            Normal       => [ q{},                               "" ],
            Operator     => [ q{<span class="kateOperator">},        "</span>" ],
            Others       => [ q{<span class="kateOthers">},          "</span>" ],
            RegionMarker => [ q{<span class="kateRegionMarker"><i>}, "</i></span>" ],
            Reserved     => [ q{<span class="kateReserved"><b>},     "</b></span>" ],
            String       => [ q{<span class="kateString">},          "</span>" ],
            Variable     => [ q{<span class="kateVariable"><b>},     "</b></span>" ],
            Warning      => [ q{<span class="kateWarning"><b><i>},   "</b></i></span>" ],
        },
    );


    my @LANGS=$hl->languageList;

    # check lang
    my @goodlang = grep(/$lang/i, @LANGS );
    if ( ! $goodlang[0]  ) {
        return "{<span class=\"kateError\">Language '$lang' unknown !!! in :\n". "-"x80 . "\n${code}\n" ."-"x80 . "\n" . "Authorized languages : @LANGS</span>";
    }

    $hl->language($goodlang[0]);
    my $result = $hl->highlightText($code);

    return $result;
}


1;

__END__

=head1 NAME

ColorizeDbk - syntax-highlight docbook

=head1 FUNCTIONS

I think these are all internal.

=head2 new

=head2 start_tag

=head2 end_tag

=head2 ColorizeCode

=head2 characters

=head2 end_document

=head2 end_element

=head2 start_document

=head2 start_element

=head2 step

=head1 AUTHORS

Daniel Brosseau <dab@catapulse.org>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut
