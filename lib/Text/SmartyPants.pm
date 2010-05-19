package Text::SmartyPants;
use strict;
use vars qw($VERSION);
$VERSION = "1.3";

# Configurable variables:
my $smartypants_attr = "1";

#  1 =>  "--" for em-dashes; no en-dash support
#  2 =>  "---" for em-dashes; "--" for en-dashes
#  3 =>  "--" for em-dashes; "---" for en-dashes
#  See docs for more configuration options.

# Globals:
my $tags_to_skip = qr!<(/?)(?:pre|code|kbd|script)[\s>]!;

=head1 Methods

=head2 process

Do the bulk of the conversion work.

=cut

sub process {
    shift if ( $_[0] eq __PACKAGE__ );    # oops, called in OOP fashion.

    # Paramaters:
    my $text = shift;                     # text to be parsed

    # value of the smart_quotes="" attribute. Default to 'everything on'
    my $attr = shift || '1';

    # Options to specify which transformations to make:
    my ( $do_quotes, $do_backticks, $do_dashes, $do_ellipses, $do_stupefy );

    # should we translate &quot; entities into normal quotes?
    my $convert_quot = 0;

    # Parse attributes:
    # 0 : do nothing
    # 1 : set all
    # 2 : set all, using old school en- and em- dash shortcuts
    # 3 : set all, using inverted old school en and em- dash shortcuts
    #
    # q : quotes
    # b : backtick quotes (``double'' only)
    # B : backtick quotes (``double'' and `single')
    # d : dashes
    # D : old school dashes
    # i : inverted old school dashes
    # e : ellipses
    # w : convert &quot; entities to " for Dreamweaver users

    if ( $attr eq "0" ) {

        # Do nothing.
        return $text;
    }
    elsif ( $attr eq "1" ) {

        # Do everything, turn all options on.
        $do_quotes    = 1;
        $do_backticks = 1;
        $do_dashes    = 1;
        $do_ellipses  = 1;
    }
    elsif ( $attr eq "2" ) {

        # Do everything, turn all options on, use old school dash shorthand.
        $do_quotes    = 1;
        $do_backticks = 1;
        $do_dashes    = 2;
        $do_ellipses  = 1;
    }
    elsif ( $attr eq "3" ) {

        # Do everything, turn all options on, use inverted old school dash shorthand.
        $do_quotes    = 1;
        $do_backticks = 1;
        $do_dashes    = 3;
        $do_ellipses  = 1;
    }
    elsif ( $attr eq "-1" ) {

        # Special "stupefy" mode.
        $do_stupefy = 1;
    }
    else {
        my @chars = split( //, $attr );
        foreach my $c (@chars) {
            if    ( $c eq "q" ) { $do_quotes    = 1; }
            elsif ( $c eq "b" ) { $do_backticks = 1; }
            elsif ( $c eq "B" ) { $do_backticks = 2; }
            elsif ( $c eq "d" ) { $do_dashes    = 1; }
            elsif ( $c eq "D" ) { $do_dashes    = 2; }
            elsif ( $c eq "i" ) { $do_dashes    = 3; }
            elsif ( $c eq "e" ) { $do_ellipses  = 1; }
            elsif ( $c eq "w" ) { $convert_quot = 1; }
            else {

                # Unknown attribute option, ignore.
            }
        }
    }

    my $tokens ||= _tokenize($text);
    my $result = '';
    my $in_pre = 0;    # Keep track of when we're inside <pre> or <code> tags.

    my $prev_token_last_char = "";    # This is a cheat, used to get some context
                                      # for one-character tokens that consist of
                                      # just a quote char. What we do is remember
                                      # the last character of the previous text
                                      # token, to use as context to curl single-
                                      # character quote tokens correctly.

    foreach my $cur_token (@$tokens) {
        if ( $cur_token->[0] eq "tag" ) {

            # Don't mess with quotes inside tags.
            $result .= $cur_token->[1];
            if ( $cur_token->[1] =~ m/$tags_to_skip/ ) {
                $in_pre = defined $1 && $1 eq '/' ? 0 : 1;
            }
        }
        else {
            my $t = $cur_token->[1];
            my $last_char = substr( $t, -1 );    # Remember last char of this token before processing.
            if ( !$in_pre ) {
                $t = ProcessEscapes($t);

                if ($convert_quot) {
                    $t =~ s/&quot;/"/g;
                }

                if ($do_dashes) {
                    $t = EducateDashes($t)                  if ( $do_dashes == 1 );
                    $t = EducateDashesOldSchool($t)         if ( $do_dashes == 2 );
                    $t = EducateDashesOldSchoolInverted($t) if ( $do_dashes == 3 );
                }

                $t = EducateEllipses($t) if $do_ellipses;

                # Notes: backticks need to be processed before quotes.
                if ($do_backticks) {
                    $t = EducateBackticks($t);
                    $t = EducateSingleBackticks($t) if ( $do_backticks == 2 );
                }

                if ($do_quotes) {
                    if ( $t eq q/'/ ) {

                        # Special case: single-character ' token
                        if ( $prev_token_last_char =~ m/\S/ ) {
                            $t = "&#8217;";
                        }
                        else {
                            $t = "&#8216;";
                        }
                    }
                    elsif ( $t eq q/"/ ) {

                        # Special case: single-character " token
                        if ( $prev_token_last_char =~ m/\S/ ) {
                            $t = "&#8221;";
                        }
                        else {
                            $t = "&#8220;";
                        }
                    }
                    else {

                        # Normal case:
                        $t = EducateQuotes($t);
                    }
                }

                $t = StupefyEntities($t) if $do_stupefy;
            }
            $prev_token_last_char = $last_char;
            $result .= $t;
        }
    }

    return $result;
}

=head2 SmartQuotes

Quotes to entities.

=cut

sub SmartQuotes {

    # Paramaters:
    my $text = shift;    # text to be parsed
    my $attr = shift;    # value of the smart_quotes="" attribute

    my $do_backticks;    # should we educate ``backticks'' -style quotes?

    if ( $attr == 0 ) {

        # do nothing;
        return $text;
    }
    elsif ( $attr == 2 ) {

        # smarten ``backticks'' -style quotes
        $do_backticks = 1;
    }
    else {
        $do_backticks = 0;
    }

    # Special case to handle quotes at the very end of $text when preceded by
    # an HTML tag. Add a space to give the quote education algorithm a bit of
    # context, so that it can guess correctly that it's a closing quote:
    my $add_extra_space = 0;
    if ( $text =~ m/>['"]\z/ ) {
        $add_extra_space = 1;    # Remember, so we can trim the extra space later.
        $text .= " ";
    }

    my $tokens ||= _tokenize($text);
    my $result = '';
    my $in_pre = 0;              # Keep track of when we're inside <pre> or <code> tags

    my $prev_token_last_char = "";    # This is a cheat, used to get some context
                                      # for one-character tokens that consist of
                                      # just a quote char. What we do is remember
                                      # the last character of the previous text
                                      # token, to use as context to curl single-
                                      # character quote tokens correctly.

    foreach my $cur_token (@$tokens) {
        if ( $cur_token->[0] eq "tag" ) {

            # Don't mess with quotes inside tags
            $result .= $cur_token->[1];
            if ( $cur_token->[1] =~ m/$tags_to_skip/ ) {
                $in_pre = defined $1 && $1 eq '/' ? 0 : 1;
            }
        }
        else {
            my $t = $cur_token->[1];
            my $last_char = substr( $t, -1 );    # Remember last char of this token before processing.
            if ( !$in_pre ) {
                $t = ProcessEscapes($t);
                if ($do_backticks) {
                    $t = EducateBackticks($t);
                }

                if ( $t eq q/'/ ) {

                    # Special case: single-character ' token
                    if ( $prev_token_last_char =~ m/\S/ ) {
                        $t = "&#8217;";
                    }
                    else {
                        $t = "&#8216;";
                    }
                }
                elsif ( $t eq q/"/ ) {

                    # Special case: single-character " token
                    if ( $prev_token_last_char =~ m/\S/ ) {
                        $t = "&#8221;";
                    }
                    else {
                        $t = "&#8220;";
                    }
                }
                else {

                    # Normal case:
                    $t = EducateQuotes($t);
                }

            }
            $prev_token_last_char = $last_char;
            $result .= $t;
        }
    }

    if ($add_extra_space) {
        $result =~ s/ \z//;    # Trim trailing space if we added one earlier.
    }
    return $result;
}

=head2 SmartDashes

Call the individual dash conversion to entities functions.

=cut

sub SmartDashes {

    # Paramaters:
    my $text = shift;          # text to be parsed
    my $attr = shift;          # value of the smart_dashes="" attribute

    # reference to the subroutine to use for dash education, default to EducateDashes:
    my $dash_sub_ref = \&EducateDashes;

    if ( $attr == 0 ) {

        # do nothing;
        return $text;
    }
    elsif ( $attr == 2 ) {

        # use old smart dash shortcuts, "--" for en, "---" for em
        $dash_sub_ref = \&EducateDashesOldSchool;
    }
    elsif ( $attr == 3 ) {

        # inverse of 2, "--" for em, "---" for en
        $dash_sub_ref = \&EducateDashesOldSchoolInverted;
    }

    my $tokens;
    $tokens ||= _tokenize($text);

    my $result = '';
    my $in_pre = 0;    # Keep track of when we're inside <pre> or <code> tags
    foreach my $cur_token (@$tokens) {
        if ( $cur_token->[0] eq "tag" ) {

            # Don't mess with quotes inside tags
            $result .= $cur_token->[1];
            if ( $cur_token->[1] =~ m/$tags_to_skip/ ) {
                $in_pre = defined $1 && $1 eq '/' ? 0 : 1;
            }
        }
        else {
            my $t = $cur_token->[1];
            if ( !$in_pre ) {
                $t = ProcessEscapes($t);
                $t = $dash_sub_ref->($t);
            }
            $result .= $t;
        }
    }
    return $result;
}

=head2 SmartEllipses

Call the individual ellipse conversion to entities functions.

=cut

sub SmartEllipses {

    # Paramaters:
    my $text = shift;    # text to be parsed
    my $attr = shift;    # value of the smart_ellipses="" attribute

    if ( $attr == 0 ) {

        # do nothing;
        return $text;
    }

    my $tokens;
    $tokens ||= _tokenize($text);

    my $result = '';
    my $in_pre = 0;      # Keep track of when we're inside <pre> or <code> tags
    foreach my $cur_token (@$tokens) {
        if ( $cur_token->[0] eq "tag" ) {

            # Don't mess with quotes inside tags
            $result .= $cur_token->[1];
            if ( $cur_token->[1] =~ m/$tags_to_skip/ ) {
                $in_pre = defined $1 && $1 eq '/' ? 0 : 1;
            }
        }
        else {
            my $t = $cur_token->[1];
            if ( !$in_pre ) {
                $t = ProcessEscapes($t);
                $t = EducateEllipses($t);
            }
            $result .= $t;
        }
    }
    return $result;
}

=head2 EducateQuotes

   Parameter:  String.

   Returns:    The string, with "educated" curly quote HTML entities.

   Example input:  "Isn't this fun?"
   Example output: &#8220;Isn&#8217;t this fun?&#8221;

=cut

sub EducateQuotes {
    local $_ = shift;

    # Tell perl not to gripe when we use $1 in substitutions,
    # even when it's undefined. Use $^W instead of "no warnings"
    # for compatibility with Perl 5.005:
    local $^W = 0;

    # Make our own "punctuation" character class, because the POSIX-style
    # [:PUNCT:] is only available in Perl 5.6 or later:
    my $punct_class = qr/[!"#\$\%'()*+,-.\/:;<=>?\@\[\\\]\^_`{|}~]/;

    # Special case if the very first character is a quote
    # followed by punctuation at a non-word-break. Close the quotes by brute force:
    s/^'(?=$punct_class\B)/&#8217;/;
    s/^"(?=$punct_class\B)/&#8221;/;

    # Special case for double sets of quotes, e.g.:
    #   <p>He said, "'Quoted' words in a larger quote."</p>
    s/"'(?=\w)/&#8220;&#8216;/g;
    s/'"(?=\w)/&#8216;&#8220;/g;

    my $close_class = qr![^\ \t\r\n\[\{\(]!;

    # Single closing quotes:
    s {
        ($close_class)?
        '
        (?(1)|          # If $1 captured, then do nothing;
          (?=\s | s\b)  # otherwise, positive lookahead for a whitespace
        )               # char or an 's' at a word ending position. This
                        # is a special case to handle something like:
                        # "<i>Custer</i>'s Last Stand."
    } {$1&#8217;}xgi;

    # Single opening quotes:
    s/'/&#8216;/g;

    # Double closing quotes:
    s {
        ($close_class)?
        "
        (?(1)|(?=\s))   # If $1 captured, then do nothing;
                           # if not, then make sure the next char is whitespace.
    } {$1&#8221;}xg;

    # Double opening quotes:
    s/"/&#8220;/g;

    return $_;
}

=head2 EducateBackticks

Replace double (back)ticks w/ HTML entities.

=cut

sub EducateBackticks {

    #
    #   Parameter:  String.
    #   Returns:    The string, with ``backticks'' -style double quotes
    #               translated into HTML curly quote entities.
    #
    #   Example input:  ``Isn't this fun?''
    #   Example output: &#8220;Isn't this fun?&#8221;
    #

    local $_ = shift;
    s/``/&#8220;/g;
    s/''/&#8221;/g;
    return $_;
}

=head2 EducateSingleBackticks

Replace single (back)ticks w/ HTML entities.

=cut

sub EducateSingleBackticks {

    #
    #   Parameter:  String.
    #   Returns:    The string, with `backticks' -style single quotes
    #               translated into HTML curly quote entities.
    #
    #   Example input:  `Isn't this fun?'
    #   Example output: &#8216;Isn&#8217;t this fun?&#8217;
    #

    local $_ = shift;
    s/`/&#8216;/g;
    s/'/&#8217;/g;
    return $_;
}

=head2 EducateDashes

Dashes to HTML entity

   Parameter:  String.

   Returns:    The string, with each instance of "--" translated to
               an em-dash HTML entity.

=cut

sub EducateDashes {

    local $_ = shift;
    s/--/&#8212;/g;
    return $_;
}

=head2 EducateDashesOldSchool

Dashes to entities.


   Parameter:  String.

   Returns:    The string, with each instance of "--" translated to
               an en-dash HTML entity, and each "---" translated to
               an em-dash HTML entity.


=cut

sub EducateDashesOldSchool {

    local $_ = shift;
    s/---/&#8212;/g;    # em
    s/--/&#8211;/g;     # en
    return $_;
}

=head2 EducateDashesOldSchoolInverted


   Parameter:  String.

   Returns:    The string, with each instance of "--" translated to
               an em-dash HTML entity, and each "---" translated to
               an en-dash HTML entity. Two reasons why: First, unlike the
               en- and em-dash syntax supported by
               EducateDashesOldSchool(), it's compatible with existing
               entries written before SmartyPants 1.1, back when "--" was
               only used for em-dashes.  Second, em-dashes are more
               common than en-dashes, and so it sort of makes sense that
               the shortcut should be shorter to type. (Thanks to Aaron
               Swartz for the idea.)

    
=cut

sub EducateDashesOldSchoolInverted {

    local $_ = shift;
    s/---/&#8211;/g;    # en
    s/--/&#8212;/g;     # em
    return $_;
}

=head2 EducateEllipses

   Parameter:  String.
   Returns:    The string, with each instance of "..." translated to
               an ellipsis HTML entity.

   Example input:  Huh...?
   Example output: Huh&#8230;?

=cut

sub EducateEllipses {

    local $_ = shift;
    s/\.\.\./&#8230;/g;
    return $_;
}

=head2 StupefyEntities

   Parameter:  String.
   Returns:    The string, with each SmartyPants HTML entity translated to
               its ASCII counterpart.

   Example input:  &#8220;Hello &#8212; world.&#8221;
   Example output: "Hello -- world."

=cut

sub StupefyEntities {

    local $_ = shift;

    s/&#8211;/-/g;     # en-dash
    s/&#8212;/--/g;    # em-dash

    s/&#8216;/'/g;     # open single quote
    s/&#8217;/'/g;     # close single quote

    s/&#8220;/"/g;     # open double quote
    s/&#8221;/"/g;     # close double quote

    s/&#8230;/.../g;   # ellipsis

    return $_;
}

=head2 SmartyPantsVersion

Return the version of SmartyPants.

=cut

sub SmartyPantsVersion {
    return $VERSION;
}

=head2 ProcessEscapes

   Parameter:  String.
   Returns:    The string, with after processing the following backslash
               escape sequences. This is useful if you want to force a "dumb"
               quote or other character to appear.

               Escape  Value
               ------  -----
               \\      &#92;
               \"      &#34;
               \'      &#39;
               \.      &#46;
               \-      &#45;
               \`      &#96;

=cut

sub ProcessEscapes {

    local $_ = shift;

    s! \\\\ !&#92;!gx;
    s! \\"  !&#34;!gx;
    s! \\'  !&#39;!gx;
    s! \\\. !&#46;!gx;
    s! \\-  !&#45;!gx;
    s! \\`  !&#96;!gx;

    return $_;
}

sub _tokenize {

    #
    #   Parameter:  String containing HTML markup.
    #   Returns:    Reference to an array of the tokens comprising the input
    #               string. Each token is either a tag (possibly with nested,
    #               tags contained therein, such as <a href="<MTFoo>">, or a
    #               run of text between tags. Each element of the array is a
    #               two-element array; the first is either 'tag' or 'text';
    #               the second is the actual value.
    #
    #
    #   Based on the _tokenize() subroutine from Brad Choate's MTRegex plugin.
    #       <http://www.bradchoate.com/past/mtregex.php>
    #

    my $str = shift;

    my $pos = 0;
    my $len = length $str;
    my @tokens;

    # pattern to match balanced nested <> pairs, up to two levels deep:
    my $nested_angles = qr/<(?:[^<>]|<[^<>]*>)*>/;

    while ( $str =~ m/($nested_angles)/gs ) {
        my $whole_tag = $1;
        my $sec_start = pos $str;
        my $tag_start = $sec_start - length $whole_tag;
        if ( $pos < $tag_start ) {
            push @tokens, [ 'text', substr( $str, $pos, $tag_start - $pos ) ];
        }
        push @tokens, [ 'tag', $whole_tag ];
        $pos = pos $str;
    }
    push @tokens, [ 'text', substr( $str, $pos, $len - $pos ) ] if $pos < $len;
    \@tokens;
}

1;
__END__


=pod

=head1 Name

Text::SmartyPants - cute little punctuation assistant

=head1 Synopsis

SmartyPants is a free web publishing plug-in for Movable Type, Blosxom,
and BBEdit that easily translates plain ASCII punctuation characters
into "smart" typographic punctuation HTML entities.


=head1 Description

SmartyPants can perform the following transformations:

=over 4

=item *

Straight quotes ( " and ' ) into "curly" quote HTML entities

=item *

Backticks-style quotes (``like this'') into "curly" quote HTML entities

=item *

Dashes (C<--> and C<--->) into en- and em-dash entities

=item *

Three consecutive dots (C<...>) into an ellipsis entity

=back

This means you can write, edit, and save your posts using plain old
ASCII straight quotes, plain dashes, and plain dots, but your published
posts (and final HTML output) will appear with smart quotes, em-dashes,
and proper ellipses.

SmartyPants is a combination plug-in -- the same file works with Movable
Type, Blosxom, and BBEdit. It can also be used from a Unix-style
command-line. Version requirements and installation instructions for
each of these tools can be found in the corresponding sub-section under
"Installation", below.

SmartyPants does not modify characters within C<< <pre> >>, C<< <code>
>>, C<< <kbd> >>, or C<< <script> >> tag blocks. Typically, these tags
are used to display text where smart quotes and other "smart
punctuation" would not be appropriate, such as source code or example
markup.


=head2 Backslash Escapes

If you need to use literal straight quotes (or plain hyphens and
periods), SmartyPants accepts the following backslash escape sequences
to force non-smart punctuation. It does so by transforming the escape
sequence into a decimal-encoded HTML entity:

              Escape  Value  Character
              ------  -----  ---------
                \\    &#92;    \
                \"    &#34;    "
                \'    &#39;    '
                \.    &#46;    .
                \-    &#45;    -
                \`    &#96;    `

This is useful, for example, when you want to use straight quotes as
foot and inch marks: 6'2" tall; a 17" iMac.


=head2 MT-Textile Integration

Movable Type users should also note that SmartyPants can work in
conjunction with Brad Choate's MT-Textile plug-in:

    http://bradchoate.com/past/mttextile.php

MT-Textile is a port of Dean Allen's original Textile project to Perl
and Movable Type. MT-Textile by itself only translates Textile markup
to HTML. However, if SmartyPants is also installed, MT-Textile will
call on SmartyPants to educate quotes, dashes, and ellipses,
automatically. Using SmartyPants in conjunction with MT-Textile
requires no modifications to your Movable Type templates.

Textile is Dean Allen's "humane web text generator", an easy-to-write
and easy-to-read shorthand for writing text for the web. An online
Textile web application is available at Mr. Allen's site:

    http://textism.com/tools/textile/


=head1 Installation

=head2 Movable Type

SmartyPants works with Movable Type version 2.5 or later.

=over 4

=item 1.

Copy the "SmartyPants.pl" file into your Movable Type "plugins" directory.
The "plugins" directory should be in the same directory as "mt.cgi"; if it
doesn't already exist, use your FTP program to create it. Your
installation should look like this:

    (mt home)/plugins/SmartyPants.pl

=item 2.

If you're using SmartyPants with Brad Choate's MT-Textile, you're done.

If not, to activate SmartyPants on your weblog, you need to edit your MT
templates. The easiest way is to add the C<smarty_pants> attribute to
each MT template tag whose contents you wish to apply SmartyPants'
transformations. Obvious tags would include C<MTEntryTitle>,
C<MTEntryBody>, and C<MTEntryMore>. SmartyPants should work within any
MT content tag.


For example, to apply SmartyPants to your entry titles:

    <$MTEntryTitle smarty_pants="1"$>

The value passed to C<smarty_pants> specifies the way SmartyPants works.
See "Options", below, for full details on all of the supported options.

=back


=head2 Blosxom

SmartyPants works with Blosxom version 2.0 or later.

=over 4

=item 1.

Rename the "SmartyPants.pl" plug-in to "SmartyPants" (case is
important). Movable Type requires plug-ins to have a ".pl" extension;
Blosxom forbids it (at least as of this writing).

=item 2.

Copy the "SmartyPants" plug-in file to your Blosxom plug-ins folder. If
you're not sure where your Blosxom plug-ins folder is, see the Blosxom
documentation for information.

=item 3.

That's it. The entries in your weblog should now automatically have
SmartyPants' default transformations applied.

=item 4.

If you wish to configure SmartyPants' behavior, open the "SmartyPants"
plug-in, and edit the value of the C<$smartypants_attr> configuration
variable, located near the top of the script. The default value is 1;
see "Options", below, for the full list of supported values.

=back


=head2 BBEdit

SmartyPants works with BBEdit 6.1 or later on Mac OS X; and BBEdit 5.1
or later on Mac OS 9 or earlier (provided you have MacPerl
installed).

=over 4

=item 1.

Copy the "SmartyPants.pl" file to appropriate filters folder in your
"BBEdit Support" folder. On Mac OS X, this should be:

    BBEdit Support:Unix Support:Unix Filters:

On Mac OS 9 or earlier, this should be:

    BBEdit Support:MacPerl Support: Perl Filters:

See the BBEdit documentation for more details on the location of these
folders.

You can rename "SmartyPants.pl" to whatever you wish.

=item 2.

That's it. To use SmartyPants, select some text in a BBEdit document,
then choose SmartyPants from the Filters sub-menu or the Filters
floating palette. On Mac OS 9, the Filters sub-menu is in the "Camel"
menu; on Mac OS X, it is in the "#!" menu.

=item 3.

If you wish to configure SmartyPants' behavior, open the SmartyPants
file and edit the value of the C<$smartypants_attr> configuration
variable, located near the top of the script. The default value is 1;
see "Options", below, for the full list of supported values.

=back


=head1 Options

=head2 smarty_pants

For MT users, the C<smarty_pants> template tag attribute is where you
specify configuration options. For Blosxom and BBEdit users, settings
are specified by editing the value of the C<$smartypants_attr> variable
in the script itself.

Numeric values are the easiest way to configure SmartyPants' behavior:

=over 4

=item B<"0">

Suppress all transformations. (Do nothing.)

=item B<"1"> 

Performs default SmartyPants transformations: quotes (including
``backticks'' -style), em-dashes, and ellipses. "--" (dash dash) is used
to signify an em-dash; there is no support for en-dashes.

=item B<"2"> 

Same as smarty_pants="1", except that it uses the old-school typewriter
shorthand for dashes:  "--" (dash dash) for en-dashes, "---" (dash dash dash)
for em-dashes.

=item B<"3"> 

Same as smarty_pants="2", but inverts the shorthand for dashes:  "--"
(dash dash) for em-dashes, and "---" (dash dash dash) for en-dashes.

=item B<"-1"> 

Stupefy mode. Reverses the SmartyPants transformation process, turning the
HTML entities produced by SmartyPants into their ASCII equivalents. E.g.
"&#8220;" is turned into a simple double-quote ("), "&#8212;" is turned
into two dashes, etc. This is useful if you are using SmartyPants from
Brad Choate's MT-Textile text filter, but wish to suppress smart
punctuation in specific MT templates, such as RSS feeds. Text filters do
their work before templates are processed; but you can use
smarty_pants="-1" to reverse the transformations in specific templates.

=back


The following single-character attribute values can be combined to toggle
individual transformations from within the smarty_pants attribute. For
example, to educate normal quotes and em-dashes, but not ellipses or
``backticks'' -style quotes:

    <$MTFoo smarty_pants="qd"$>

=over 4

=item B<"q">

Educates normal quote characters: (") and (').

=item B<"b">

Educates ``backticks'' -style double quotes.

=item B<"B">

Educates ``backticks'' -style double quotes and `single' quotes.

=item B<"d">

Educates em-dashes.

=item B<"D">

Educates em-dashes and en-dashes, using old-school typewriter shorthand:
(dash dash) for en-dashes, (dash dash dash) for em-dashes.

=item B<"i">

Educates em-dashes and en-dashes, using inverted old-school typewriter
shorthand: (dash dash) for em-dashes, (dash dash dash) for en-dashes.

=item B<"e">

Educates ellipses.

=item B<"w">

Translates any instance of C<&quot;> into a normal double-quote character.
This should be of no interest to most people, but of particular interest
to anyone who writes their posts using Dreamweaver, as Dreamweaver
inexplicably uses this entity to represent a literal double-quote
character. SmartyPants only educates normal quotes, not entities (because
ordinarily, entities are used for the explicit purpose of representing the
specific character they represent). The "w" option must be used in
conjunction with one (or both) of the other quote options ("q" or "b").
Thus, if you wish to apply all SmartyPants transformations (quotes, en-
and em-dashes, and ellipses) and also translate C<&quot;> entities into
regular quotes so SmartyPants can educate them, you should pass the
following to the smarty_pants attribute:

    <$MTFoo smarty_pants="qDew"$>

For Blosxom and BBEdit users, set:

    my $smartypants_attr = "qDew";

=back


=head2 Deprecated MT Attributes

The following Movable Type attributes are supported only for
compatibility with older versions of SmartyPants. They are obsoleted by
the C<smarty_pants> attribute, which offers more control than these
individual attributes. If you're setting up SmartyPants for the first
time, you should use the C<SmartyPants> attribute instead.

Blosxom and BBEdit users should simply ignore this section.

=head3 smart_quotes

The smart_quotes attribute accepts the following values:

=over 4

=item B<"0">

Suppress all quote education. (Do nothing.)

=item B<"1"> 

Default behavior. Educates normal quote characters: (") and (').

=item B<"2">

Educate ``backticks'' -style double quotes (in addition to educating
regular quotes). Transforms each instance of two consecutive backtick
characters (C<``>) into an opening double-quote, and each instance of two
consecutive apostrophes (C<''>) into a closing double-quote.

=back


=head3 smart_dashes

The smart_dashes attribute accepts the following values:

=over 4

=item B<"0">

Suppress dash education. (Do nothing.)

=item B<"1"> 

Default behavior. Transforms each instance of "--" (dash dash) into an
HTML entity-encoded em-dash.

=item B<"2">

Educates both en- and em-dashes, using the old-school typewriter
shorthand for dashes. Each instance of "--" (dash dash) is turned into
an HTML entity-encoded en-dash; each instance of "---" (dash dash dash)
is turned into an em-dash.

=item B<"3"> 

Same as smart_dashes="2", but inverts the shorthand, using "--" (dash
dash) for em-dashes, and "---" (dash dash dash) for en-dashes. Although
somewhat counterintuitive in that the longer shortcut is used for the
shorter dash, this syntax is backwards compatible with SmartyPants 1.0's
original syntax, which used (dash dash) for em-dashes.


=back


=head3 smart_ellipses

The smart_ellipses attribute accepts the following values:

=over 4

=item B<"0">

Suppress ellipsis education. (Do nothing.)

=item B<"1"> 

Default behavior. Transforms each instance of "..." (dot dot dot) into
an HTML entity-encoded ellipsis. If there are four consecutive dots,
SmartyPants assumes this means "full stop" followed by "ellipsis".

=back


=head2 Version Info Tag

If you include this tag in a Movable Type template:

    <$MTSmartyPantsVersion$>

it will be replaced with a string representing the version number of the
installed version of SmartyPants, e.g. "1.2".


=head1 Caveats

=head2 Why You Might Not Want to Use Smart Quotes in Your Weblog

For one thing, you might not care.

Most normal, mentally stable individuals do not take notice of proper
typographic punctuation. Many design and typography nerds, however, break
out in a nasty rash when they encounter, say, a restaurant sign that uses
a straight apostrophe to spell "Joe's".

If you're the sort of person who just doesn't care, you might well want to
continue not caring. Using straight quotes -- and sticking to the 7-bit
ASCII character set in general -- is certainly a simpler way to live.

Even if you I<do> care about accurate typography, you still might want to
think twice before educating the quote characters in your weblog. One side
effect of publishing curly quote HTML entities is that it makes your
weblog a bit harder for others to quote from using copy-and-paste. What
happens is that when someone copies text from your blog, the copied text
contains the 8-bit curly quote characters (as well as the 8-bit characters
for em-dashes and ellipses, if you use these options). These characters
are not standard across different text encoding methods, which is why they
need to be encoded as HTML entities.

People copying text from your weblog, however, may not notice that you're
using curly quotes, and they'll go ahead and paste the unencoded 8-bit
characters copied from their browser into an email message or their own
weblog. When pasted as raw "smart quotes", these characters are likely to
get mangled beyond recognition.

That said, my own opinion is that any decent text editor or email client
makes it easy to stupefy smart quote characters into their 7-bit
equivalents, and I don't consider it my problem if you're using an
indecent text editor or email client.


=head2 Algorithmic Shortcomings

One situation in which quotes will get curled the wrong way is when
apostrophes are used at the start of leading contractions. For example:

    the '80s
    'Twas the night before Christmas.

In both cases above, SmartyPants will turn the apostrophes into opening
single-quotes, when in fact they should be closing ones. I don't think
this problem can be solved in the general case -- every word processor
I've tried gets this wrong as well. In such cases, it's best to use the
proper HTML entity for closing single-quotes (C<&#8217;>) by hand.

(I should also note that my personal style is to abbreviate decades like
this:

    the 80's

so admittedly, I'm not all that interested in solving this problem.)


=head1 Bugs

To file bug reports or feature requests (other than topics listed in the
Caveats section above) please send email to:

    smartypants@daringfireball.net

If the bug involves quotes being curled the wrong way, please send example
text to illustrate.


=head1 See Also

This plug-in effectively obsoletes the technique documented here:

    http://daringfireball.net/2002/08/movable_type_smart_quote_devilry.html

However, the above instructions may still be of interest if for some
reason you are still running an older version of Movable Type.


=head1 Version History

    1.0: Wed Nov 13, 2002

        Initial release.


    1.1: Wed Feb 5, 2003

    +   The smart_dashes template attribute now offers an option to
        use "--" for *en* dashes, and "---" for *em* dashes.

    +   The default smart_dashes behavior now simply translates "--"
        (dash dash) into an em-dash. Previously, it would look for
        " -- " (space dash dash space), which was dumb, since many
        people do not use spaces around their em dashes.

    +   Using the smarty_pants attribute with a value of "2" will
        do the same thing as smarty_pants="1", with one difference:
        it will use the new shortcuts for en- and em-dashes.

    +   Closing quotes (single and double) were incorrectly curled in
        situations like this:
            "<a>foo</a>",
        where the comma could be just about any punctuation character.
        Fixed.

    +   Added <kbd> to the list of tags in which text shouldn't be
        educated.


    1.2: Thu Feb 27, 2003

    +   SmartyPants is now a combination plug-in, supporting both
        Movable Type (2.5 or later) and Blosxom (2.0 or later).
        It also works as a BBEdit text filter and standalone
        command-line Perl program. Thanks to Rael Dornfest for the
        initial Blosxom port (and for the excellent Blosxom plug-in
        API).

    +   SmartyPants now accepts the following backslash escapes,
        to force non-smart punctuation. It does so by transforming
        the escape sequence into a decimal-encoded HTML entity: 

              Escape  Value  Character
              ------  -----  ---------
                \\    &#92;    \
                \"    &#34;    "
                \'    &#39;    '
                \.    &#46;    .
                \-    &#45;    -
                \`    &#96;    `

        Note that this could produce different results than previous
        versions of SmartyPants, if for some reason you have an article
        containing one or more of these sequences. (Thanks to Charles
        Wiltgen for the suggestion.)

    +   Added a new option to support inverted en- and em-dash notation:
        "--" for em-dashes, "---" for en-dashes. This is compatible with
        SmartyPants' original "--" syntax for em-dashes, but also allows
        you to specify en-dashes. It can be invoked by using
        smart_dashes="3", smarty_pants="3", or smarty_pants="i". 
        (Suggested by Aaron Swartz.)

    +   Added a new option to automatically convert &quot; entities into
        regular double-quotes before sending text to EducateQuotes() for
        processing. This is mainly for the benefit of people who write
        posts using Dreamweaver, which substitutes this entity for any
        literal quote char. The one and only way to invoke this option
        is to use the letter shortcuts for the smarty_pants attribute;
        the shortcut for this option is "w" (for Dream_w_eaver).
        (Suggested by Jonathon Delacour.)

    +   Added <script> to the list of tags in which SmartyPants doesn't
        touch the contents.

    +   Fixed a very subtle bug that would occur if a quote was the very
        last character in a body of text, preceded immediately by a tag.
        Lacking any context, previous versions of SmartyPants would turn
        this into an opening quote mark. It's now correctly turned into
        a closing one.

    +   Opening quotes were being curled the wrong way when the
        subsequent character was punctuation. E.g.: "a '.foo' file".
        Fixed.

    +   New MT global template tag: <$MTSmartyPantsVersion$>
        Prints the version number of SmartyPants, e.g. "1.2".


    1.2.1: Mon Mar 10, 2003

    +   New "stupefy mode" for smarty_pants attribute. If you set

            smarty_pants="-1"

        SmartyPants will perform reverse transformations, turning HTML
        entities into plain ASCII equivalents. E.g. "&#8220;" is turned
        into a simple double-quote ("), "&#8212;" is turned into two
        dashes, etc. This is useful if you are using SmartyPants from Brad
        Choate's MT-Textile text filter, but wish to suppress smart
        punctuation in specific MT templates, such as RSS feeds. Text
        filters do their work before templates are processed; but you can
        use smarty_pants="-1" to reverse the transformations in specific
        templates.

    +   Replaced the POSIX-style regex character class [:punct:] with an
        ugly hard-coded normal character class of all punctuation; POSIX
        classes require Perl 5.6 or later, but SmartyPants still supports
        back to 5.005.

    +   Several small changes to allow SmartyPants to work when Blosxom
        is running in static mode.


    1.2.2: Thu Mar 13, 2003

    +   1.2.1 contained a boneheaded addition which prevented SmartyPants
        from compiling under Perl 5.005. This has been remedied, and is
        the only change from 1.2.1.


    1.3: Tue 13 May 2003

    +   Plugged the biggest hole in SmartyPants's smart quotes algorithm.
        Previous versions were hopelessly confused by single-character
        quote tokens, such as:

            <p>"<i>Tricky!</i>"</p>

        The problem was that the EducateQuotes() function works on each
        token separately, with no means of getting surrounding context
        from the previous or next tokens. The solution is to curl these
        single-character quote tokens as a special case, *before* calling
        EducateQuotes().

    +   New single-quotes backtick mode for smarty_pants attribute.
        The only way to turn it on is to include "B" in the configuration
        string, e.g. to translate backtick quotes, dashes, and ellipses:

            smarty_pants="Bde"

    +   Fixed a bug where an opening quote would get curled the wrong way
        if the quote started with three dots, e.g.:

            <p>"...meanwhile"</p>

    +   Fixed a bug where opening quotes would get curled the wrong way
        if there were double sets of quotes within each other, e.g.:

            <p>"'Some' people."</p>

    +   Due to popular demand, four consecutive dots (....) will now be
        turned into an ellipsis followed by a period. Previous versions
        would turn this into a period followed by an ellipsis. If you
        really want a period-then-ellipsis sequence, escape the first
        period with a backslash: \....

    +   Removed "&" from our home-grown punctuation class, since it
        denotes an entity, not a literal ampersand punctuation
        character. This fixes a bug where SmartyPants would mis-curl
        the opening quote in something like this:

            "&#8230;whatever"

    +   SmartyPants has always had a special case where it looks for
        "'s" in situations like this:

            <i>Custer</i>'s Last Stand

        This special case is now case-insensitive.


=head1 Author

    John Gruber
    http://daringfireball.net


=head1 Additional Credits

Portions of this plug-in are based on Brad Choate's nifty MTRegex plug-in.
Brad Choate also contributed a few bits of source code to this plug-in.
Brad Choate is a fine hacker indeed. (http://bradchoate.com/)

Jeremy Hedley (http://antipixel.com/) and Charles Wiltgen
(http://playbacktime.com/) deserve mention for exemplary beta testing.

Rael Dornfest (http://raelity.org/) ported SmartyPants to Blosxom.


=head1 Copyright and License

    Copyright (c) 2003 John Gruber
    (http://daringfireball.net/)
    All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

*   Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.

*   Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.

*   Neither the name "SmartyPants" nor the names of its contributors may
    be used to endorse or promote products derived from this software
    without specific prior written permission.

This software is provided by the copyright holders and contributors "as is"
and any express or implied warranties, including, but not limited to, the 
implied warranties of merchantability and fitness for a particular purpose 
are disclaimed. In no event shall the copyright owner or contributors be 
liable for any direct, indirect, incidental, special, exemplary, or 
consequential damages (including, but not limited to, procurement of 
substitute goods or services; loss of use, data, or profits; or business 
interruption) however caused and on any theory of liability, whether in 
contract, strict liability, or tort (including negligence or otherwise) 
arising in any way out of the use of this software, even if advised of the
possibility of such damage.

=cut
