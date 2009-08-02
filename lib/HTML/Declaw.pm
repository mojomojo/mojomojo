package HTML::Declaw;

=head1 NAME

HTML::Declaw - Cleans HTML as well as CSS of scripting and other executable contents, and neutralises XSS attacks.
Derived from HTML::Defang version 1.01.

=head1 SYNOPSIS

  my $InputHtml = "<html><body></body></html>";

  my $Defang = HTML::Declaw->new(
    context => $Self,
    fix_mismatched_tags => 1,
    tags_to_callback => [ br embed img ],
    tags_callback => \&DefangTagsCallback,
    url_callback => \&DefangUrlCallback,
    css_callback => \&DefangCssCallback,
    attribs_to_callback => [ qw(border src) ],
    attribs_callback => \&DefangAttribsCallback
  );

  my $SanitizedHtml = $Defang->defang($InputHtml);

  # Callback for custom handling specific HTML tags
  sub DefangTagsCallback {
    my ($Self, $Defang, $OpenAngle, $lcTag, $IsEndTag, $AttributeHash, $CloseAngle, $HtmlR, $OutR) = @_;
    return 1 if $lcTag eq 'br';    # Explicitly defang this tag, eventhough safe
    return 0 if $lcTag eq 'embed'; # Explicitly whitelist this tag, eventhough unsafe
    return 2 if $lcTag eq 'img';   # I am not sure what to do with this tag, so process as HTML::Defang normally would
  }

  # Callback for custom handling URLs in HTML attributes as well as style tag/attribute declarations
  sub DefangUrlCallback {
    my ($Self, $Defang, $lcTag, $lcAttrKey, $AttrValR, $AttributeHash, $HtmlR) = @_;
    return 0 if $$AttrValR =~ /safesite.com/i; # Explicitly allow this URL in tag attributes or stylesheets
    return 1 if $$AttrValR =~ /evilsite.com/i; # Explicitly defang this URL in tag attributes or stylesheets
  }

  # Callback for custom handling style tags/attributes
  sub DefangCssCallback {
    my ($Self, $Defang, $Selectors, $SelectorRules, $Tag, $IsAttr) = @_;
    my $i = 0;
    foreach (@$Selectors) {
      my $SelectorRule = $$SelectorRules[$i];
      foreach my $KeyValueRules (@$SelectorRule) {
        foreach my $KeyValueRule (@$KeyValueRules) {
          my ($Key, $Value) = @$KeyValueRule;
          $$KeyValueRule[2] = 1 if $Value =~ '!important';                  # Comment out any '!important' directive
          $$KeyValueRule[2] = 1 if $Key =~ 'position' && $Value =~ 'fixed'; # Comment out any 'position=fixed;' declaration
        }
      }
      $i++;
    }
  }

  # Callback for custom handling HTML tag attributes
  sub DefangAttribsCallback {
    my ($Self, $Defang, $lcTag, $lcAttrKey, $AttrValR, $HtmlR) = @_;
    $$AttrValR = '0' if $lcAttrKey eq 'border';  # Change all 'border' attribute values to zero.
    return 1 if $lcAttrKey eq 'src';             # Defang all 'src' attributes
    return 0;
  }

=head1 DESCRIPTION

This module accepts an input HTML and/or CSS string and removes any executable code including scripting, embedded objects, applets, etc., and neutralises any XSS attacks. A whitelist based approach is used which means only HTML known to be safe is allowed through.

HTML::Defang uses a custom html tag parser. The parser has been designed and tested to work with nasty real world html and to try and emulate as close as possible what browsers actually do with strange looking constructs. The test suite has been built based on examples from a range of sources such as http://ha.ckers.org/xss.html and http://imfo.ru/csstest/css_hacks/import.php to ensure that as many as possible XSS attack scenarios have been dealt with.

HTML::Defang can make callbacks to client code when it encounters the following:

=over 4

=item *

When a specified tag is parsed

=item *

When a specified attribute is parsed

=item *

When a URL is parsed as part of an HTML attribute, or CSS property value.

=item *

When style data is parsed, as part of an HTML style attribute, or as part of an HTML <style> tag.

=back

The callbacks include details about the current tag/attribute that is being parsed, and also gives a scalar reference to the input HTML. Querying pos() on the input HTML should indicate where the module is with parsing. This gives the client code flexibility in working with HTML::Declaw.

HTML::Declaw can defang whole tags, any attribute in a tag, any URL that appear as an attribute or style property, or any CSS declaration in a declaration block in a style rule. This helps to precisely block the most specific unwanted elements in the contents(for example, block just an offending attribute instead of the whole tag), while retaining any safe HTML/CSS.

=cut

use Exporter;
our @ISA = ('Exporter');
%EXPORT_TAGS = ( all => [qw(@FormTags)] );
Exporter::export_ok_tags('all');

use strict;
use warnings;

our $VERSION = 1.01;

use Encode;

my $HasScalarReadonly = 0;

BEGIN {
    eval "use Scalar::Readonly qw(readonly_on);" && ( $HasScalarReadonly = 1 );
}

our @FormTags =
  qw(form input textarea select option button fieldset label legend multicol nextid optgroup);

# Some regexps for matching HTML tags + key=value attributes
my $AttrKeyStartLineRE = qr/[^=<>\s\/\\]{1,}/;
my $AttrKeyRE          = qr/(?<=[\s'"\/])$AttrKeyStartLineRE/;
my $AttrValRE =
  qr/[^>\s'"`][^>\s]*|'[^']{0,2000}?'|"[^"]{0,2000}?"|`[^`]{0,2000}?`/;
my $AttributesRE = qr/(?:(?:$AttrKeyRE\s*)?(?:=\s*$AttrValRE\s*)?)*/;
my $TagNameRE    = qr/[A-Za-z][A-Za-z0-9\#\&\;\:\!_-]*/;

my $Selectors  = qr/[^{]*?/;
my $StyleKey   = qr/[^:}]+?/;
my $StyleValue = qr/[^;}]+|.*$/;

my $Fonts = qr/"?([A-Za-z0-9\s-]+)"?/;
my $Alignments =
qr/(absbottom|absmiddle|all|autocentre|baseline|bottom|center|justify|left|middle|none|right|texttop|top)/;

my $Executables =
    '([^@]\.com|'
  . '.*\.(exe|cmd|bat|pif|scr|sys|sct|lnk|dll'
  . '|vbs?|vbe|hta|shb|shs|hlp|chm|eml|wsf|wsh|js'
  . '|asx|wm.|mdb|mht|msi|msp|cpl|lib|reg))';
my $SrcBanStd =
qr/^([A-Za-z]*script|.*\&{|mocha|about|opera|mailto:|hcp:|\/(dev|proc)|\\|file|smb|cid:${Executables}(@|\?|$))/i;

my %Rules = (

    # Disallow unknown tags by default
    "_unknown"  => qr/.*/,
    "align"     => qr/^${Alignments}$/i,
    "alnum"     => qr/^[A-Za-z0-9_.-]+$/,
    "boolean"   => qr/^(0|1|true|yes|no|false)$/,
    "charset"   => qr/^[A-Za-z0-9_][A-Za-z0-9_.-]*$/,
    "class"     => qr/^[A-Za-z0-9_.:\s-]*$/,
    "color"     => qr/^#?[0-9A-Z]+$/i,
    "coords"    => qr/^(\d+,)+\d+$/i,
    "datetime"  => qr/^\d\d\d\d-\d\d-\d\d.{0,5}\d\d:\d\d:\d\d.{0,5}$/,
    "dir"       => qr/^(ltr|rtl)$/i,
    "eudora"    => qr/^(autourl)$/i,
    "font-face" => qr/^((${Fonts})[,\s]*)+$/i,
    "form-enctype" =>
      qr/^(application\/x-www-form-urlencoded|multipart\/form-data)$/i,
    "form-method" => qr/^(get|post)$/i,
    "frame"       => qr/^(void|above|below|hsides|vsides|lhs|rhs|box|border)$/i,

    # href: Not javascript, vbs or vbscript
    "href" => qr/^([A-Za-z]*script|.*\&{|mocha|hcp|opera|about|smb|\/dev\/)/i,
    "usemap-href" => qr/^#[A-Za-z0-9_.-]+$/, # this is not really a href at all!
    "input-size" =>
      qr/^(\d{1,4})$/,    # some browsers freak out with very large widgets
    "input-type" =>
qr/^(button|checkbox|file|hidden|image|password|radio|readonly|reset|submit|text)$/i,
    "integer" => qr/^(-|\+)?\d+$/,
    "number"  => qr/^(-|\+)?[\d.,]+$/,

    # language: Not javascript, vbs or vbscript
    "language" => qr/^(XML)$/i,
    "media"    => qr/^((screen|print|projection|braille|speech|all)[,\s]*)+$/i,
    "meta:name" =>
qr/^(author|progid|originator|generator|keywords|description|content-type|pragma|expires)$/i,

    # mime-type: Not javascript
    "mime-type" => qr/^(cite|text\/(plain|css|html|xml))$/i,
    "list-type" =>
qr/^(none,a,i,upper-alpha,lower-alpha,upper-roman,lower-roman,decimal,disc,square,circle,round)$/i,

    # "rel"          => qr/^((copyright|author|stylesheet)\s*)+$/i,
    "rel" => qr/^((copyright|author)\s*)+$/i
    ,    # XXX external stylesheets can contain scripting, so kill them
    "rules" => qr/^(none|groups|rows|cols|all)$/i,
    "scope" => qr/^(row|col|rowgroup|colgroup)$/i,
    "shape" => qr/^(rect|rectangle|circ|circle|poly|polygon)$/i,

    # The following two are for URLs we expect to be auto-loaded by the browser,
    # because they are within a frame, image or something like that.
    # "src"          => qr/^([a-z]+):|^[\w\.\/\%]+$/i,
    "src" => qr/^https?:\/\/|^[\w.\/%]+$/i,

# "style"        => qr/^([A-Za-z0-9_-]+\\s*:\\s*(yes|no)|text-align\\s*:\\s*$alignments|((background|(background-|font-)?color)\\s*:\\s*(\\#?[A-Z0-9]+)?|((margin|padding|border)-(right|left)|tab-interval|height|width)\\s*:\\s*[\\d\\.]+(pt|px)|font(-family|-size|-weight|)\\s*:(\\s*[\\d\\.]+(pt|px)|\\s*$fonts)+)[;\\s]*)+\$/i,
#  "style"        => qr/expression|eval|script:|mocha:|\&{|\@import|(?<!background-)position:|background-image/i, # XXX there are probably a million more ways to cause trouble with css!
    "style" => qr/^.*$/s,

#kc In addition to this, we could strip all 'javascript:|expression|' etc. from all attributes(in attribute_cleanup())
    "stylesheet" => qr/expression|eval|script:|mocha:|\&{|\@import/i
    , # stylesheets are forbidden if Embedded => 1.  css positioning can be allowed in an iframe.
      # NB see also `process_stylesheet' below
    "style-type"   => qr/script|mocha/i,
    "size"         => qr/^[\d.]+(px|%)?$/i,
    "target"       => qr/^[A-Za-z0-9_][A-Za-z0-9_.-]*$/,
    "base-href"    => qr/^https?:\/\/[\w.\/]+$/,
    "anything"     => qr/^.*$/,                            #[ 0, 0 ],
    "meta:content" => [ 0, 0 ],
);

my %CommonAttributes = (

    # Core attributes
    "class"     => "class",
    "id"        => "alnum",
    "name"      => "alnum",
    "style"     => "style",
    "accesskey" => "alnum",
    "tabindex"  => "integer",
    "title"     => "anything",

    # Language attributes
    "dir"      => "dir",
    "lang"     => "alnum",
    "language" => "language",
    "longdesc" => "anything",

    # Height, width, alignment, etc.
    #-mxy allow more flexible values for align
    # "align"      => "align",
    "align"        => "alnum",
    "bgcolor"      => "color",
    "bottommargin" => "size",
    "clear"        => "align",
    "color"        => "color",
    "height"       => "size",
    "leftmargin"   => "size",
    "marginheight" => "size",
    "marginwidth"  => "size",
    "nowrap"       => "anything",
    "rightmargin"  => "size",
    "scroll"       => "boolean",
    "scrolling"    => "boolean",
    "topmargin"    => "size",
    "valign"       => "align",
    "width"        => "size",

    # youtube embedded objects
    "value"             => "anything",
    "type"              => "anything",
    "allowscriptaccess" => 'alnum',
    "allowfullscreen"   => "boolean",
    "src"               => "src",
);

my %ListAttributes = (
    "compact" => "anything",
    "start"   => "integer",
    "type"    => "list-type",
);

my %TableAttributes = (
    "axis"             => "alnum",
    "background"       => "src",
    "border"           => "number",
    "bordercolor"      => "color",
    "bordercolordark"  => "color",
    "bordercolorlight" => "color",
    "padding"          => "integer",
    "spacing"          => "integer",
    "cellpadding"      => "integer",
    "cellspacing"      => "integer",
    "cols"             => "anything",
    "colspan"          => "integer",
    "char"             => "alnum",
    "charoff"          => "integer",
    "datapagesize"     => "integer",
    "frame"            => "frame",
    "frameborder"      => "boolean",
    "framespacing"     => "integer",
    "headers"          => "anything",
    "rows"             => "anything",
    "rowspan"          => "size",
    "rules"            => "rules",
    "scope"            => "scope",
    "span"             => "integer",
    "summary"          => "anything"
);

my %UrlRules = (
    "src"       => 1,
    "href"      => 1,
    "base-href" => 1,

    #  cite        => 1,
    #  action      => 1,
);

my %Tags = (
    script => \&defang_script,
    style  => \&defang_style,
    "html" => 100,

    #
    # Safe elements commonly found in the <head> block follow.
    #
    "head" => 2,
    "base" => {
        "href"   => "base-href",
        "target" => "target",
    },

    # TODO: Deal with link below later
    #"link" => \$r_link,
    #      {
    #          "rel"     => "rel",
    #          "rev"     => "rel",
    #          "src"     => "src",
    #          "href"    => "src",       # Might be auto-loaded by the browser!!
    #          "charset" => "charset",
    #          "media"   => "media",
    #          "target"  => "target",
    #          "type"    => "mime-type",
    #      },
    "meta" => {
        "_score"     => 2,
        "content"    => "meta:content",
        "http-equiv" => "meta:name",
        "name"       => "meta:name",
        "charset"    => "charset",
    },
    "title" => 2,

    #
    # Safe elements commonly found in the <body> block follow.
    #
    "body" => {
        "_score"     => 2,
        "link"       => "color",
        "alink"      => "color",
        "vlink"      => "color",
        "background" => "src",
        "nowrap"     => "boolean",
        "text"       => "color",
        "vlink"      => "color",
    },
    "a" => {
        "charset" => "charset",
        "coords"  => "coords",
        "href"    => "href",
        "shape"   => "shape",
        "target"  => "target",
        "type"    => "mime-type",
        "eudora"  => "eudora",
        "notrack" => "anything",
    },
    "address" => 1,
    "area"    => {
        "alt"    => "anything",
        "coords" => "coords",
        "href"   => "href",
        "nohref" => "anything",
        "shape"  => "shape",
        "target" => "target",
    },
    "applet"   => 0,
    "basefont" => {
        "face"   => "font-face",
        "family" => "font-face",
        "back"   => "color",
        "size"   => "number",
        "ptsize" => "number",
    },
    "bdo"     => 1,
    "bgsound" => {
        "balance" => "integer",
        "delay"   => "integer",
        "loop"    => "alnum",
        "src"     => "src",
        "volume"  => "integer",
    },
    "blockquote" => {
        "cite" => "href",
        "type" => "mime-type",
    },
    "br" => 1,
    "button" =>    # FORM
      {
        "type"     => "input-type",
        "disabled" => "anything",
        "value"    => "anything",
        "tabindex" => "number",
      },
    "caption"  => 1,
    "center"   => 1,
    "col"      => \%TableAttributes,
    "colgroup" => \%TableAttributes,
    "comment"  => 1,
    "dd"       => 1,
    "del"      => {
        "cite"     => "href",
        "datetime" => "datetime",
    },
    "dir"      => \%ListAttributes,
    "div"      => 1,
    "dl"       => \%ListAttributes,
    "dt"       => 1,
    "embed"    => 0,
    "fieldset" => 1,                  # FORM
    "font"     => {
        "face"   => "font-face",
        "family" => "font-face",
        "back"   => "color",
        "size"   => "number",
        "ptsize" => "number",
    },
    "form" =>                         # FORM
      {
        "method"         => "form-method",
        "action"         => "href",
        "enctype"        => "form-enctype",
        "accept"         => "anything",
        "accept-charset" => "anything",
      },
    "hr" => {
        "size"    => "number",
        "noshade" => "anything",
    },
    "h1"     => 1,
    "h2"     => 1,
    "h3"     => 1,
    "h4"     => 1,
    "h5"     => 1,
    "h6"     => 1,
    "iframe" => 0,
    "ilayer" => 0,
    "img"    => {
        "alt"    => "anything",
        "border" => "size",
        "dynsrc" => "src",
        "hspace" => "size",
        "ismap"  => "anything",
        "loop"   => "alnum",
        "lowsrc" => "src",
        "nosend" => "alnum",
        "src"    => "src",
        "start"  => "alnum",
        "usemap" => "usemap-href",
        "vspace" => "size",
    },
    "inlineinput" => 0,
    "input" =>    # FORM
      {
        "type"      => "input-type",
        "disabled"  => "anything",
        "value"     => "anything",
        "maxlength" => "input-size",
        "size"      => "input-size",
        "readonly"  => "anything",
        "tabindex"  => "number",
        "checked"   => "anything",
        "accept"    => "anything",

        # for type "image":
        "alt"    => "anything",
        "border" => "size",
        "dynsrc" => "src",
        "hspace" => "size",
        "ismap"  => "anything",
        "loop"   => "alnum",
        "lowsrc" => "src",
        "nosend" => "alnum",
        "src"    => "src",
        "start"  => "alnum",
        "usemap" => "usemap-href",
        "vspace" => "size",
      },
    "ins" => {
        "cite"     => "href",
        "datetime" => "datetime",
    },
    "isindex" => 0,
    "keygen"  => 0,
    "label" =>    # FORM
      { "for" => "alnum", },
    "layer"    => 0,
    "legend"   => 1,                           # FORM
    "li"       => { "value" => "integer", },
    "listing"  => 0,
    "map"      => 1,
    "marquee"  => 0,
    "menu"     => \%ListAttributes,
    "multicol" => 0,
    "nextid"   => 0,
    "nobr"     => 0,
    "noembed"  => 1,
    "nolayer"  => 1,
    "noscript" => 1,
    "noembed"  => 1,
    "object"   => 0,
    "ol"       => \%ListAttributes,
    "optgroup" =>                              # FORM
      {
        "disabled" => "anything",
        "label"    => "anything",
      },
    "option" =>                                # FORM
      {
        "disabled" => "anything",
        "label"    => "anything",
        "selected" => "anything",
        "value"    => "anything",
      },
    "o:p"       => 1,
    "p"         => 1,
    "param"     => 0,
    "plaintext" => 0,
    "pre"       => 1,
    "rt"        => 0,
    "ruby"      => 0,
    "select" =>    # FORM
      {
        "disabled" => "anything",
        "multiple" => "anything",
        "size"     => "input-size",
        "tabindex" => "number",
      },
    "spacer" => 0,
    "span"   => 1,
    "spell"  => 0,
    "sound"  => {
        "delay" => "number",
        "loop"  => "integer",
        "src"   => "src",
    },
    "table" => \%TableAttributes,
    "tbody" => \%TableAttributes,
    "textarea" =>    # FORM
      {
        "cols"     => "input-size",
        "rows"     => "input-size",
        "disabled" => "anything",
        "readonly" => "anything",
        "tabindex" => "number",
        "wrap"     => "anything",
      },
    "td"       => \%TableAttributes,
    "tfoot"    => \%TableAttributes,
    "th"       => \%TableAttributes,
    "thead"    => \%TableAttributes,
    "tr"       => \%TableAttributes,
    "ul"       => \%ListAttributes,
    "wbr"      => 1,
    "xml"      => 0,
    "xmp"      => 0,
    "x-html"   => 0,
    "x-tab"    => 1,
    "x-sigsep" => 1,

    # Character formatting
    "abbr"    => 1,
    "acronym" => 1,
    "big"     => 1,
    "blink"   => 0,
    "b"       => 1,
    "cite"    => 1,
    "code"    => 1,
    "dfn"     => 1,
    "em"      => 1,
    "i"       => 1,
    "kbd"     => 1,
    "q"       => 1,
    "s"       => 1,
    "samp"    => 1,
    "small"   => 1,
    "strike"  => 1,
    "strong"  => 1,
    "sub"     => 1,
    "sup"     => 1,
    "tt"      => 1,
    "u"       => 1,
    "var"     => 1,

    #
    # Safe elements commonly found in the <frameset> block follow.
    #
    "frameset" => 0,
    "frame"    => 0,
    "noframes" => 1,
);

# Some entity conversions for attributes
my %EntityToChar =
  ( quot => '"', apos => "'", amp => '&', 'lt' => '<', 'gt' => '>' );
my %CharToEntity = reverse %EntityToChar;
my %QuoteRe = ( '"' => qr/(["&<>])/, "'" => qr/(['&<>])/, "" => qr/(["&<>])/ );

# Default list of mismatched tags to track
my %MismatchedTags =
  map { $_ => 1 } qw(table tbody thead tr td th font div span pre center);

# When fixing mismatched tags, sometimes a close tag
#  shouldn't close all the way out
# For example, consider:
#   <table><tr><td><table><tr></td>
# A naive version would see the ending </td>, and thus
#  try to fix the mismatched tags by doing:
#   <table><tr><td><table><tr></tr></table></td>
# This is not what a browser does. So given a tag, we
#  give a list of closing tags which cause us to stop
#  and not close any more
my %MismatchedTagNest = (
    table => [qw(tbody thead tfoot tr th td colgroup)],
    tbody => [qw(tr th td)],
    tr    => [qw(th td)],
    font  => [''],
);

# Convert to hash of hashes
$_ = { map { $_ => 1 } @$_ } for values %MismatchedTagNest;

# If we see a table, we should expect to see a tbody
#  next. If not, we need to add it because the browser
#  will implicitly open it!
my %ImplicitOpenTags = (
    table => [qw(tbody tr thead tfoot caption colgroup col)],
    thead => [qw(tr)],
    tbody => [qw(tr)],
    tr    => [qw(td th)],
);

# Convert to hash of hashes
$_ = { default => $_->[0], map { $_ => 1 } @$_ } for values %ImplicitOpenTags;

=head1 CONSTRUCTOR

=over 4

=cut

=item I<HTML::Declaw-E<gt>new(%Options)>

Constructs a new HTML::Declaw object. The following options are supported:

=over 4

=item B<Options>

=over 4

=item B<tags_to_callback>

Array reference of tags for which a call back should be made. If a tag in this array is parsed, the subroutine tags_callback() is invoked.

=item B<attribs_to_callback>

Array reference of tag attributes for which a call back should be made. If an attribute in this array is parsed, the subroutine attribs_callback() is invoked.

=item B<tags_callback>

Subroutine reference to be invoked when a tag listed in @$tags_to_callback is parsed.

=item B<attribs_callback>

Subroutine reference to be invoked when an attribute listed in @$attribs_to_callback is parsed.

=item B<url_callback>

Subroutine reference to be invoked when a URL is detected in an HTML tag attribute or a CSS property.

=item B<css_callback>

Subroutine reference to be invoked when CSS data is found either as the contents of a 'style' attribute in an HTML tag, or as the contents of a <style> HTML tag.

=item B<fix_mismatched_tags>

This property, if set, fixes mismatched tags in the HTML input. By default, tags present in the default %mismatched_tags_to_fix hash are fixed. This set of tags can be overridden by passing in an array reference $mismatched_tags_to_fix to the constructor. Any opened tags in the set are automatically closed if no corresponding closing tag is found. If an unbalanced closing tag is found, that is commented out.

=item B<mismatched_tags_to_fix>

Array reference of tags for which the code would check for matching opening and closing tags. See the property $fix_mismatched_tags.

=item B<context>

You can pass an arbitrary scalar as a 'context' value that's then passed as the first parameter to all callback functions. Most commonly this is something like '$Self'

=item B<Debug>

If set, prints debugging output.

=back

=back

=back

=cut

sub new {
    my $Proto = shift;
    my $Class = ref($Proto) || $Proto;

    my %Opts = @_;

    #  my $Context = shift;

    my ( $tags_to_callback, $attribs_to_callback ) =
      ( $Opts{"tags_to_callback"}, $Opts{"attribs_to_callback"} );
    my %tags_to_callback = map { $_ => 1 } @$tags_to_callback
      if $tags_to_callback;
    my %attribs_to_callback = map { $_ => 1 } @$attribs_to_callback
      if $attribs_to_callback;
    my %mismatched_tags_to_fix = %MismatchedTags;
    %mismatched_tags_to_fix =
      map { $_ => 1 } @{ $Opts{'mismatched_tags_to_fix'} }
      if $Opts{'mismatched_tags_to_fix'};

    my $Self = {
        DefangString           => 'defang_',
        tags_to_callback       => \%tags_to_callback,
        tags_callback          => $Opts{tags_callback},
        attribs_to_callback    => \%attribs_to_callback,
        attribs_callback       => $Opts{attribs_callback},
        url_callback           => $Opts{url_callback},
        css_callback           => $Opts{css_callback},
        mismatched_tags_to_fix => \%mismatched_tags_to_fix,
        fix_mismatched_tags    => $Opts{fix_mismatched_tags},
        context                => $Opts{context},
        OpenedTags             => [],
        OpenedTagsCount        => {},
        ImplicitTags           => [],
        Debug                  => $Opts{Debug},
    };

    bless( $Self, $Class );
    return $Self;
}

=head1 CALLBACK METHODS

=over 4

=cut

=item B<COMMON PARAMETERS>

A number of the callbacks share the same parameters. These common parameters are documented here. Certain variables may have specific meanings in certain callbacks, so be sure to check the documentation for that method first before referring this section.

=over 4

=item I<$context>

You can pass an arbitrary scalar as a 'context' value that's then passed as the first parameter to all callback functions. Most commonly this is something like '$Self'

=item I<$Defang>

Current HTML::Declaw instance

=item I<$OpenAngle>

Opening angle(<) sign of the current tag.

=item I<$lcTag>

Lower case version of the HTML tag that is currently being parsed.

=item I<$IsEndTag>

Has the value '/' if the current tag is a closing tag.

=item I<$AttributeHash>

A reference to a hash containing the attributes of the current tag and
their values. Each value is a scalar reference to the value, rather
than just a scalar value. You can add attributes (remember to make it a
scalar ref, eg $AttributeHash{"newattr"} = \"newval"), delete attributes,
or modify attribute values in this hash, and any changes you make will
be incorporated into the output HTML stream.

The attribute values will have any entity references decoded before
being passed to you, and any unsafe values we be re-encoded back into
the HTML stream.

So for instance, the tag:

  <div title="&lt;&quot;Hi there &#x003C;">

Will have the attribute hash:

  { title => \q[<"Hi there <] }

And will be turned back into the HTML on output:

  <div title="&lt;&quot;Hi there &lt;">

=item I<$CloseAngle>

Anything after the end of last attribute including the closing HTML angle(>)

=item I<$HtmlR>

A scalar reference to the input HTML. The input HTML is parsed using
m/\G$SomeRegex/c constructs, so to continue from where HTML:Defang left,
clients can use m/\G$SomeRegex/c for further processing on the input. This
will resume parsing from where HTML::Declaw left. One can also use the
pos() function to determine where HTML::Declaw left off. This combined
with the add_to_output() method should give reasonable flexibility for
the client to process the input.

=item I<$OutR>

A scalar reference to the processed output HTML so far.

=back

=item I<tags_callback($context, $Defang, $OpenAngle, $lcTag, $IsEndTag, $AttributeHash, $CloseAngle, $HtmlR, $OutR)>

If $Defang->{tags_callback} exists, and HTML::Declaw has parsed a tag preset in $Defang->{tags_to_callback}, the above callback is made to the client code. The return value of this method determines whether the tag is defanged or not. More details below.

=over 4

=item B<Return values>

=over 4

=item 0

The current tag will not be defanged.

=item 1

The current tag will be defanged.

=item 2

The current tag will be processed normally by HTML:Defang as if there was no callback method specified.

=back

=back

=item I<attribs_callback($context, $Defang, $lcTag, $lcAttrKey, $AttrVal, $HtmlR, $OutR)>

If $Defang->{attribs_callback} exists, and HTML::Declaw has parsed an attribute present in $Defang->{attribs_to_callback}, the above callback is made to the client code. The return value of this method determines whether the attribute is defanged or not. More details below.

=over 4

=item B<Method parameters>

=over 4

=item I<$lcAttrKey>

Lower case version of the HTML attribute that is currently being parsed.

=item I<$AttrVal>

Reference to the HTML attribute value that is currently being parsed.

See $AttributeHash for details of decoding.

=back

=item B<Return values>

=over 4

=item 0

The current attribute will not be defanged.

=item 1

The current attribute will be defanged.

=item 2

The current attribute will be processed normally by HTML:Defang as if there was no callback method specified.

=back

=back

=item I<url_callback($context, $Defang, $lcTag, $lcAttrKey, $AttrVal, $AttributeHash, $HtmlR, $OutR)>

If $Defang->{url_callback} exists, and HTML::Declaw has parsed a URL, the above callback is made to the client code. The return value of this method determines whether the attribute containing the URL is defanged or not. URL callbacks can be made from <style> tags as well style attributes, in which case the particular style declaration will be commented out. More details below.

=over 4

=item B<Method parameters>

=over 4

=item I<$lcAttrKey>

Lower case version of the HTML attribute that is currently being parsed. However if this callback is made as a result of parsing a URL in a style attribute, $lcAttrKey will be set to the string I<style>, or will be set to I<undef> if this callback is made as a result of parsing a URL inside a style tag.

=item I<$AttrVal>

Reference to the URL value that is currently being parsed.

=item I<$AttributeHash>

A reference to a hash containing the attributes of the current tag and their values. Each value is a scalar reference to the value,
rather than just a scalar value. You can add attributes (remember to make it a scalar ref, eg $AttributeHash{"newattr"} = \"newval"), delete attributes, or modify attribute values in this hash, and any changes you make will be incorporated into the output HTML stream. Will be set to I<undef> if the callback is made due to URL in a <style> tag or attribute.

=back

=item B<Return values>

=over 4

=item 0

The current URL will not be defanged.

=item 1

The current URL will be defanged.

=item 2

The current URL will be processed normally by HTML:Defang as if there was no callback method specified.

=back

=back

=item I<css_callback($context, $Defang, $Selectors, $SelectorRules, $lcTag, $IsAttr, $OutR)>

If $Defang->{css_callback} exists, and HTML::Declaw has parsed a <style> tag or style attribtue, the above callback is made to the client code. The return value of this method determines whether a particular declaration in the style rules is defanged or not. More details below.

=over 4

=item B<Method parameters>

=over 4

=item I<$Selectors>

Reference to an array containing the selectors in a style tag or attribute.

=item I<$SelectorRules>

Reference to an array containing the style declaration blocks of all selectors in a style tag or attribute. Consider the below CSS:

  a { b:c; d:e}
  j { k:l; m:n}

The declaration blocks will get parsed into the following data structure:

  [
    [
      [ "b", "c", 2],
      [ "d", "e", 2]
    ],
    [
      [ "k", "l", 2],
      [ "m", "n", 2]
    ]
  ]

So, generally each property:value pair in a declaration is parsed into an array of the form

  ["property", "value", X]

where X can be 0, 1 or 2, and 2 the default value. A client can manipulate this value to instruct HTML::Declaw to defang this property:value pair.

0 - Do not defang

1 - Defang the style:property value

2 - Process this as if there is no callback specified

=item I<$IsAttr>

True if the currently processed item is a style attribute. False if the currently processed item is a style tag.

=back

=back

=back

=cut

=head1 METHODS

=over 4

=item B<PUBLIC METHODS>

=over 4

=item I<defang($InputHtml)>

Cleans up $InputHtml of any executable code including scripting, embedded objects, applets, etc., and defang any XSS attacks.

=over 4

=item B<Method parameters>

=over 4

=item I<$InputHtml>

The input HTML string that needs to be sanitized.

=back

=back

Returns the cleaned HTML. If fix_mismatched_tags is set, any tags that appear in @$mismatched_tags_to_fix that are unbalanced are automatically commented or closed.

=cut

sub defang {
    my $Self = shift;

    my $I = shift;

    my $Debug = $Self->{Debug};

    my $HeaderCharset = shift;
    warn("defang HeaderCharset=$HeaderCharset") if $Debug;
    my $FallbackCharset = shift;
    warn("defang FallbackCharset=$FallbackCharset") if $Debug;

    $Self->{Reentrant}++;

# Get encoded characters
#  $Self->{Charset} = $Self->get_applicable_charset($_, $HeaderCharset, $FallbackCharset);
#  warn("defang Charset=$Self->{Charset}") if $Self->{Debug};

    #  if ($Self->{Charset}) {
    #    $I =~ s/(.)/chr(ord($1) & 127)/ge if $Self->{Charset} eq "US-ASCII";
    #    my $Encoder = Encode::Encoder->new($I, $Self->{Charset});
    #    $I = $Encoder->bytes($Self->{Charset});
    #  }

    # We pass a ref to $I to each callback. It should
    #  never be modified because we use a m/\G.../gc loop
    #  on it. If possible, stop people modifying it
    readonly_on($I) if $HasScalarReadonly;

    # It seems regexp matching on perl unicode strings can be *way*
    #  slower than byte string (defang 1M email = 100 seconds unicode,
    #  5 seconds bytes).
    # So we're going to do a bit of a hack. Engaged "use bytes" to do
    #  byte matching everywhere, but since we know we'll be matching
    #  on correct boundaries to make up full code points in utf-8, we'll
    #  turn on the magic utf-8 flag again for those values
    my $UTF8Input = Encode::is_utf8($I);

    # Force byte matching everywhere (see above)
    use bytes;

    # Strip all NUL chars
    $I =~ s/\0//g;

    # Output buffer
    my $O = '';

    # This parser uses standard /\G.../gc matching, so have to be careful
    #  to not reset pos() on the string
    #
    # Previously we tried an "eating" parser (s/^.../, or /^.../ + substr),
    #  which in theory should be fast with perls internal string offset
    #  feature, but it seems offset doesn't work on unicode strings,
    #  so you end up with a slow parser because of string reallocations

    while (1) {

    # walk to next < (testing in 5.8.8 shows .*? is faster than [^<]* or [^<]*?)
        if ( $I =~ m{\G(.*?)<}gcso ) {

            # Everything before tag goes into the output
            $O .= $1;

            # All tags default to open/close with </>
            my ( $OpenAngle, $CloseAngle ) = ( '<', '>' );
            my $IsEndTag = $I =~ m{\G/}gcso ? '/' : '';

            # It's a standard tag
            if ( $I =~ m{\G($TagNameRE)}gcso ) {

                my $Tag = $1;
                my $TagTrail = $I =~ m{\G([\s/]+)}gcso ? $1 : '';

                warn "defang IsEndTag=$IsEndTag Tag=$Tag" if $Debug;

                # Skip attribute parsing if none
                my @Attributes;
                goto NoParseAttributes if $I =~ m{\G>}gcso;

                # Pull off any trailing component after the tag
                # Now match all key=value attributes
                while ( $I =~
m{\G(?:($AttrKeyStartLineRE)(\s*))?(?:(=\s*)($AttrValRE)(\s*))?}gcso
                  )
                {

                    last if !defined($1) && !defined($4);
                    my (
                        $Attribute, $AttrTrail, $Equals,
                        $AttrVal,   $AttrValTrail
                    ) = ( $1, $2, $3, $4, $5 );
                    my ( $AttrQuote, $AttrValWithoutQuote ) = '';
                    if ( defined($4) && $4 =~ /^([`"']?)(.*)\1$/s ) {

                        # IE supports `, but nothing else does, turn it into "
                        $AttrQuote = $1 eq '`' ? '"' : $1;
                        $AttrValWithoutQuote = $2;
                    }

                    # Turn on utf-8 for things that might be
                    Encode::_utf8_on($Attribute)           if $UTF8Input;
                    Encode::_utf8_on($AttrValWithoutQuote) if $UTF8Input;

                    push @Attributes,
                      [
                        $Attribute,           $AttrTrail,
                        $Equals,              $AttrQuote,
                        $AttrValWithoutQuote, $AttrQuote,
                        $AttrValTrail
                      ];
                    warn
"defang AttributeKey=$1 AttrQuote=$AttrQuote AttributeValue=$Attribute"
                      if $Debug;
                }

                # Better be at end of attributes, or attach our own ending tag
                if ( $I =~ m{\G(?:(\s*[/\\]*\s*(?:--)?\s*)?>|([\s/-]*))}gcs ) {
                    $CloseAngle = $1 ? $1 . '>' : ( $2 ? $2 . '>' : '>' );
                }

              NoParseAttributes:
                my $Defang = 1;

                my $TagOps = $Tags{ lc $Tag };

                # Process this tag
                if ( ref $TagOps eq "CODE" ) {

                    warn "process_tag Found CODE reference" if $Debug;
                    $Defang = $Self ->${TagOps}(
                        \$O,         \$I,          $TagOps,
                        \$OpenAngle, $IsEndTag,    $Tag,
                        $TagTrail,   \@Attributes, \$CloseAngle
                    );

                }
                else {

                    warn "process_tag Found regular tag" if $Debug;
                    $Defang = $Self->defang_attributes(
                        \$O,         \$I,          $TagOps,
                        \$OpenAngle, $IsEndTag,    $Tag,
                        $TagTrail,   \@Attributes, \$CloseAngle
                    );

                }
                die "Callback reset pos on Tag=$Tag IsEndTag=$IsEndTag"
                  if !defined pos($I);
                warn "defang Defang=$Defang" if $Debug;

                # defang unknown tags
                if ($Defang) {
                    warn "defang Defanging $Tag" if $Debug;
                    $Tag = $Self->{DefangString} . $Tag;
                    $OpenAngle  =~ s/</<!--/;
                    $CloseAngle =~ s/>/-->/;
                }

                # And put it all back together into the output string
                $O .=
                    $OpenAngle
                  . $IsEndTag
                  . $Tag
                  . $TagTrail
                  . join( "", grep { defined } map { @$_ } @Attributes )
                  . $CloseAngle;

# It's a comment of some sort. We are looking for regular HTML comment, XML CDATA section and
# IE conditional comments
# Refer http://msdn.microsoft.com/en-us/library/ms537512.aspx for IE conditional comment information
            }
            elsif ( $I =~ m{\G(!)((?:\[CDATA\[|(?:--)?\[if|--)?)}gcis ) {

                my ( $Comment, $CommentDelim ) = ( $1, $2 );
                warn "defang Comment=$Comment CommentDelim=$CommentDelim"
                  if $Debug;

                # Find the appropriate closing delimiter
                my $IsCDATA = $CommentDelim eq "[CDATA[";
                my $ClosingCommentDelim = $IsCDATA ? "]]" : $CommentDelim;

                my $EndRestartCommentsText = '';

# Handle IE conditionals specially. We can have <![if ...]>, <!--[if ...]> and <!--[if ...]-->
#  for the third case, we just want to immediately match the -->
                if ( $CommentDelim =~ /((?:--)?)\[if/ ) {
                    my $ConditionalDelim = $1;
                    $EndRestartCommentsText = '--' if $ConditionalDelim eq '';
                    $ClosingCommentDelim = $CommentDelim;
                    if ( $I !~ m{\G[^\]]*\]-->}gcis ) {
                        $ClosingCommentDelim = "<![endif]$ConditionalDelim";
                    }
                }

                warn "defang ClosingCommentDelim=$ClosingCommentDelim"
                  if $Debug;

                my ( $CommentStartText, $CommentEndText ) =
                  ( "--/*SC*/", "/*EC*/--" );

                # Convert to regular HTML comment
                $O .= $OpenAngle . $Comment . $CommentStartText;

                # Find closing comment
                if (   $I =~ m{\G(.*?)(\Q${ClosingCommentDelim}\E!?\s*)(>)}gcis
                    || $I =~ m{\G(.*?)(--)(>)}gcis )
                {

                    my ( $StartTag, $CommentData, $ClosingTag, $CloseAngle ) =
                      ( $CommentDelim, $1, $2, $3 );

                    if (   $EndRestartCommentsText
                        && $CommentData =~ s/^(.*?)(>.*)$/$2/s )
                    {
                        $StartTag .= $1;
                    }

                    # Strip all HTML comment markers
                    $StartTag    =~ s/--//g;
                    $CommentData =~ s/--//g;
                    $ClosingTag  =~ s/--//g;

                    $StartTag .= $EndRestartCommentsText if $CommentData;
                    $ClosingTag =~ s{^(<!)}{$1$EndRestartCommentsText}
                      if $CommentData;

                    # Put it all into the output
                    $O .= $StartTag
                      . (
                          $EndRestartCommentsText
                        ? $Self->defang($CommentData)
                        : $CommentData
                      )
                      . $ClosingTag
                      . $CommentEndText
                      . $CloseAngle;

                    # No closing comment, so we add that
                }
                else {

                    $I =~ m/\G(.*)$/gcs || die "Remainder of line match failed";

                    my $Data = $1;
                    $Data =~ s/--//g;

                    # Output
                    $O .= $Data . $CommentEndText . ">";

                }

                # XML processing instruction
            }
            elsif ( $I =~ m{\G(\?)}gcs ) {
                my ($Processing) = ($1);
                warn "defang XML processing instruction" if $Debug;

                my $Data;
                if ( $I =~ m{\G(.*?\??)>}gcs ) {    # || goto OutputRemainder;
                    $Data = $1;
                }
                else {
                    $I =~ m{\G(.*)$}gcs;
                    $Data = $1;
                }

                $Data =~ s{--}{}g;

                $O .= $OpenAngle . '!--' . $Processing . $Data . '-->';

            }

            # Some other thing starting with <, keep looking

            if ( exists $Self->{AppendOutput} ) {
                $O .= delete $Self->{AppendOutput};
            }
            next;
        }

      OutputRemainder:

        # No tag found, just copy rest
        warn "defang OutputRemainder" if $Debug;
        $I =~ m/\G(.*)$/gcs;

        $O .= $1 if $1;

        # Exit if we got here
        last;
    }

    # If not a recursive call, close mismatched tags
    if ( $Self->{Reentrant} <= 1 ) {
        my $RemainingClosingTags = '';

        my ( $OpenedTags, $OpenedTagsCount ) =
          @$Self{qw(OpenedTags OpenedTagsCount)};
        while ( my $PreviousOpenedTag = pop @$OpenedTags ) {
            $RemainingClosingTags .=
              "<!-- close mismatch --></$PreviousOpenedTag>";
            $OpenedTagsCount->{$PreviousOpenedTag}--;
        }
        $O .= $RemainingClosingTags;

        # Also clear implicit tags
        $Self->{ImplicitTags} = [];

        if ($Debug) {
            warn "Check all tags closed and counts zeroed";
            warn "Not all tags closed"
              if grep { $_ > 0 } values %$OpenedTagsCount;
        }
    }

    $Self->{Reentrant}--;

    # Turn on utf-8 flag again
    Encode::_utf8_on($O) if $UTF8Input;

    return $O;
}

=item I<add_to_output($String)>

Appends $String to the output after the current parsed tag ends. Can be used by client code in callback methods to add HTML text to the processed output. If the HTML text needs to be defanged, client code can safely call HTML::Declaw->defang() recursively from within the callback.

=over 4

=item B<Method parameters>

=over 4

=item I<$String>

The string that is added after the current parsed tag ends.

=back

=back

=back

=cut

# Callbacks call this method
sub add_to_output {
    my $Self = shift;
    $Self->{AppendOutput} = shift;
}

sub defang_and_add_to_output {
    my $Self = shift;
    $Self->add_to_output( $Self->defang(shift) );
}

=item B<INTERNAL METHODS>

Generally these methods never need to be called by users of the class, because they'll be called internally as the appropriate tags are
encountered, but they may be useful for some users in some cases.

=over 4

=item I<defang_script($OutR, $HtmlR, $TagOps, $OpenAngle, $IsEndTag, $Tag, $TagTrail, $Attributes, $CloseAngle)>

This method is invoked when a <script> tag is parsed. Defangs the <script> opening tag, and any closing tag. Any scripting content is also commented out, so browsers don't display them.

Returns 1 to indicate that the <script> tag must be defanged.

=over 4

=item B<Method parameters>

=over 4

=item I<$OutR>

A reference to the processed output HTML before the tag that is currently being parsed.

=item I<$HtmlR>

A scalar reference to the input HTML.

=item I<$TagOps>

Indicates what operation should be done on a tag. Can be undefined, integer or code reference. Undefined indicates an unknown tag to HTML::Declaw, 1 indicates a known safe tag, 0 indicates a known unsafe tag, and a code reference indicates a subroutine that should be called to parse the current tag. For example, <style> and <script> tags are parsed by dedicated subroutines.

=item I<$OpenAngle>

Opening angle(<) sign of the current tag.

=item I<$IsEndTag>

Has the value '/' if the current tag is a closing tag.

=item I<$Tag>

The HTML tag that is currently being parsed.

=item I<$TagTrail>

Any space after the tag, but before attributes.

=item I<$Attributes>

A reference to an array of the attributes and their values, including any surrouding spaces. Each element of the array is added by 'push' calls like below.

  push @$Attributes, [ $AttributeName, $SpaceBeforeEquals, $EqualsAndSubsequentSpace, $QuoteChar, $AttributeValue, $QuoteChar, $SpaceAfterAtributeValue ];

=item I<$CloseAngle>

Anything after the end of last attribute including the closing HTML angle(>)

=back

=back

=cut

sub defang_script {
    my $Self = shift;
    my (
        $OutR, $HtmlR,    $TagOps,     $OpenAngle, $IsEndTag,
        $Tag,  $TagTrail, $Attributes, $CloseAngle
    ) = @_;
    warn "defang_script Processing <script> tag" if $Self->{Debug};

    if ( !$IsEndTag ) {

       # If we just parsed a starting <script> tag, code better be commented. If
       #  not, we attach comments around the code.
        if ( $$HtmlR =~ m{\G(.*?)(?=</script\b)}gcsi ) {
            my $ScriptTagContents = $1;
            warn "defang_script ScriptTagContents $ScriptTagContents"
              if $Self->{Debug};
            $ScriptTagContents =~
              s/^(\s*)(<!--)?(.*?)(-->)?(\s*)$/$1<!-- $3 -->$5/s;
            $Self->{AppendOutput} .= $ScriptTagContents;

        }
    }

    # Also defang tag
    return 1;

}

=item I<defang_style($OutR, $HtmlR, $TagOps, $OpenAngle, $IsEndTag, $Tag, $TagTrail, $Attributes, $CloseAngle, $IsAttr)>

Builds a list of selectors and declarations from HTML style tags as well as style attributes in HTML tags and calls defang_stylerule() to do the actual defanging.

Returns 0 to indicate that style tags must not be defanged.

=over 4

=item B<Method parameters>

=over 4

=item I<$IsAttr>

Whether we are currently parsing a style attribute or style tag. $IsAttr will be true if we are currently parsing a style attribute.

=back

For a description of other parameters, see documentation of defang_script() method

=back

=cut

sub defang_style {

    my (
        $Self,       $OutR,       $HtmlR, $TagOps,
        $OpenAngle,  $IsEndTag,   $Tag,   $TagTrail,
        $Attributes, $CloseAngle, $IsAttr
    ) = @_;
    my $lcTag = lc $Tag;

    warn "defang_style Tag=$Tag IsEndTag=$IsEndTag IsAttr=$IsAttr"
      if $Self->{Debug};

    # Nothing to do if end tag
    return 0 if !$IsAttr && $IsEndTag;

    my $Content                = '';
    my $ClosingStyleTagPresent = 1;

    for ($$HtmlR) {

        if ( !$IsAttr ) {
            if (m{\G(.*?)(?=</style\b)}gcis) {
                $Content = $1;

                # No ending style tag
            }
            elsif (m{\G([^<]*)}gcis) {
                $Content                = $1;
                $ClosingStyleTagPresent = 0;
            }

            # Its a style attribute
        }
        else {

            # Avoid undef warning for style tag with no value. eg <tag style>
            $Content = defined($_) ? $_ : '';
        }
    }

    # Clean up all comments, expand character escapes and such
    $Self->cleanup_style($Content);

    # Handle any wrapping HTML comments. If no comments, we add
    my ( $OpeningHtmlComment, $ClosingHtmlComment ) = ( '', '' );
    if ( !$IsAttr ) {
        $Content =~ s{^(\s*<!--)?(.*?)(-->\s*)?$}{$2}s;
        ( $OpeningHtmlComment, $ClosingHtmlComment ) =
          ( $1 || "<!--", $3 || "-->" );
    }

# Style attributes can optionally have selector type elements, so we check whether we
# have a '{' in $Content: if yes, its style data with selector type elements
    my $Naked = $Content !~ m/\{/;
    my $StyleRule =
qr/\s*$StyleKey\s*:\s*$StyleValue\s*(?:;\s*$StyleKey\s*:\s*$StyleValue\s*)*;?\s*/o;
    warn "defang_style Naked=$Naked" if $Self->{Debug};

    # And suitably change the regex to match the data
    my $SelectorRuleRE =
      $Naked
      ? qr/(\s*)()()()($StyleRule)()(\s*)/o
      : qr/(\s*)((?:$Selectors))(\s*)(\{)($StyleRule)(\})(\s*)/o;

    my ( @Selectors, @SelectorRules, %ExtraData );

    # Now we parse the selectors and declarations
    while ( $Content =~ s{$SelectorRuleRE}{} ) {
        my ( $Selector, $SelectorRule ) = ( $2, $5 );
        push @Selectors,     $Selector;
        push @SelectorRules, $SelectorRule;
        warn "defang_style Selector=$Selector"         if $Self->{Debug};
        warn "defang_style SelectorRule=$SelectorRule" if $Self->{Debug};
        $ExtraData{$Selector} = [ $1, $3, $4, $6, $7 ];
    }

    # Check declaration elements for defanging
    $Self->defang_stylerule( \@Selectors, \@SelectorRules, $lcTag, $IsAttr,
        $HtmlR, $OutR );

    my $StyleOut = "";

    # Re-create the style data
    foreach my $Selector (@Selectors) {

        my $SelectorRule = shift @SelectorRules;
        my $Spaces       = $ExtraData{$Selector};
        my (
            $BeforeSelector, $AfterSelector, $OpenBrace,
            $CloseBrace,     $AfterRule
          )
          = @$Spaces
          if $Spaces;
        ( $BeforeSelector, $AfterSelector, $AfterRule ) = ( "", " ", "\n" )
          unless $ExtraData{$Selector};
        ( $OpenBrace, $CloseBrace ) = ( "{", "}" ) if !$Spaces && !$IsAttr;

        # Put back the rule together
        if ( defined($Selector) ) {
            $StyleOut .= $BeforeSelector if defined($BeforeSelector);
            $StyleOut .= $Selector;
            $StyleOut .= $AfterSelector  if defined($AfterSelector);
            $StyleOut .= $OpenBrace      if defined($OpenBrace);
            $StyleOut .= $SelectorRule   if defined($SelectorRule);
            $StyleOut .= $CloseBrace     if defined($CloseBrace);
            $StyleOut .= $AfterRule      if defined($AfterRule);
        }

    }

    warn "defang_style StyleOut=$StyleOut" if $Self->{Debug};

    if ($IsAttr) {
        $$HtmlR = $StyleOut;

    }
    else {
        $Self->{AppendOutput} .=
          $OpeningHtmlComment . $StyleOut . $ClosingHtmlComment;
        $Self->{AppendOutput} .= "</style>" if !$ClosingStyleTagPresent;
    }

    # We don't want <style> tags to be defanged
    return 0;

}

=item I<cleanup_style($StyleString)>

Helper function to clean up CSS data. This function directly operates on the input string without taking a copy.

=over 4

=item B<Method parameters>

=over 4

=item I<$StyleString>

The input style string that is cleaned.

=back

=back

=cut

sub cleanup_style {
    my $Self = shift;

    for ( $_[0] ) {

        # Expand escapes
        s/(?:&x|\\)(0?[\da-f]{1,6});?/defined($1) ? chr(hex($1)) : ""/egi;
        s/(?:&#)([\d]{1,7});?/defined($1) ? chr($1) : ""/egi;

# Remove all remaining invalid escapes TODO This probably is not correct. Backslashes are required to be left alone by the CSS syntax
        s/\\//g;

        # Remove all CSS comments
        s{/\*.*?\*/}{}sg;

        # Remove any CSS imports
        s{(\@import[^;]+;?)}{}sg;

        warn "cleanup_style Content=$_" if $Self->{Debug};
    }

}

=item I<defang_stylerule($SelectorsIn, $StyleRules, $lcTag, $IsAttr, $HtmlR, $OutR)>

Defangs style data.

=over 4

=item B<Method parameters>

=over 4

=item I<$SelectorsIn>

An array reference to the selectors in the style tag/attribute contents.

=item I<$StyleRules>

An array reference to the declaration blocks in the style tag/attribute contents.

=item I<$lcTag>

Lower case version of the HTML tag that is currently being parsed.

=item I<$IsAttr>

Whether we are currently parsing a style attribute or style tag. $IsAttr will be true if we are currently parsing a style attribute.

=item I<$HtmlR>

A scalar reference to the input HTML.

=item I<$OutR>

A scalar reference to the processed output so far.

=back

=back

=cut

sub defang_stylerule {

    my ( $Self, $SelectorsIn, $StyleRules, $lcTag, $IsAttr, $HtmlR, $OutR ) =
      @_;

    my ( @SelectorStyleKeyValues, %SelectorStyleKeyExtraData );

    my ( @Selectors, @SelectorRules );

    foreach my $Selector (@$SelectorsIn) {

        warn "defang_stylerule Selector=$Selector" if $Self->{Debug};
        my $Rule = shift @$StyleRules;
        my ( @SelectorRule, @KeyValueRules, %StyleKeyExtraData );

        # Split style declaration to basic elements
        while ( $Rule =~
            s{^(\{?\s*)([^:]+?)(\s*:\s*)((?:)?)([^;\}]+)()?(\s*;?)(\s*\}?)}{} )
        {
            my (
                $KeyPilot, $Key,      $Separator, $QuoteStart,
                $Value,    $QuoteEnd, $ValueEnd,  $ValueTrail
            ) = ( $1, $2, $3, $4, $5, $6, $7, $8 );

            warn
"defang_stylerule Key=$Key Value=$Value Separator=$Separator ValueEnd=$ValueEnd"
              if $Self->{Debug};

            # Store everything except style property and value in a hash
            $StyleKeyExtraData{ lc $Key } = [
                $KeyPilot, $Separator, $QuoteStart,
                $QuoteEnd, $ValueEnd,  $ValueTrail
            ];
            my $DefangStyleRule = 2;

# If the style value has a URL in it and URL callback has been supplied, make a url_callback
            if (   $Self->{url_callback}
                && $Value =~ m/\s*url\(\s*((?:['"])?)(.*?)\1\s*\)/i )
            {
                my ( $UrlOrig, $Url ) = ( $2, $2 ) if $2;
                warn
                  "defang_stylerule Url found in style property value. Url=$Url"
                  if $Self->{Debug};
                my $lcAttrKey = $IsAttr ? "style" : undef;
                $DefangStyleRule = $Self->{url_callback}->(
                    $Self->{context}, $Self, $lcTag, $lcAttrKey, \$Url, undef,
                    $HtmlR, $OutR
                ) if $Url;

                # Save back any changes
                warn
"defang_stylerule After URL callback, Value=$Value DefangStyleRule=$DefangStyleRule"
                  if $Self->{Debug};
                $Value =~ s{\Q$UrlOrig\E}{$Url} if $UrlOrig;
            }

            # Save the style property, value and defang flag
            push @KeyValueRules, [ $Key, $Value, $DefangStyleRule ];
            warn
"defang_stylerule Key=$Key Value=$Value DefangStyleRule=$DefangStyleRule"
              if $Self->{Debug};

        }

        push( @SelectorRule,  \@KeyValueRules );
        push( @Selectors,     $Selector );
        push( @SelectorRules, \@SelectorRule );
        $SelectorStyleKeyExtraData{$Selector} = \%StyleKeyExtraData;

    }

    # If a CSS callback is supplied, we call that
    $Self->{css_callback}->(
        $Self->{context}, $Self, \@Selectors, \@SelectorRules, $lcTag, $IsAttr,
        $OutR
    ) if $Self->{css_callback};

    warn
"defang_stylerule More selectors($#Selectors) than selector rules($#SelectorRules)"
      if $Self->{Debug}
          && $#Selectors > $#SelectorRules;

    my $Counter = 0;
    foreach my $Selector (@Selectors) {

        my $SelectorRule = $SelectorRules[$Counter];
        my $ExtraData    = $SelectorStyleKeyExtraData{$Selector};
        my $Rule;

        for ( my $j = 0 ; $j <= $#$SelectorRule ; $j++ ) {
            my $KeyValueRules = $$SelectorRule[$j];

            for ( my $k = 0 ; $k <= $#$KeyValueRules ; $k++ ) {
                my $KeyValueRule = $$KeyValueRules[$k];
                my ( $Key, $Value, $Defang ) = @$KeyValueRule;
                my @v = $$ExtraData{ lc $Key };
                my (
                    $KeyPilot, $Separator, $QuoteStart,
                    $QuoteEnd, $ValueEnd,  $ValueTrail
                  )
                  = @{ $v[0] }
                  if $$ExtraData{ lc $Key };

# If an intermediate style property-value pair doesn't have a terminating semi-colon, add it
                if ( $k > 0 && !$$ExtraData{ lc $Key } ) {
                    my $PreviousRule = $KeyValueRules->[ $k - 1 ];
                    my $PreviousKey  = $PreviousRule->[0];
                    my @PrevExtra    = $ExtraData->{ lc $PreviousKey };
                    $ExtraData->{ lc $PreviousKey }->[4] .= ";"
                      if defined( $PrevExtra[0]->[4] )
                          && $PrevExtra[0]->[4] !~ m/;/;
                    $ExtraData->{ lc $Key }->[1] = ":";
                }

            }

        }

        $Counter++;
    }

    $Counter = 0;
    foreach my $Selector (@Selectors) {

        $SelectorsIn->[$Counter] = $Selector
          if $SelectorsIn->[$Counter] && !$IsAttr;
        my $SelectorRule = $SelectorRules[$Counter];
        my $ExtraData    = $SelectorStyleKeyExtraData{$Selector};
        my $Rule;

        foreach my $KeyRules (@$SelectorRule) {

            foreach my $KeyValueRule (@$KeyRules) {

                my ( $Key, $Value, $Defang ) = @$KeyValueRule;
                my @v = $$ExtraData{ lc $Key };
                my (
                    $KeyPilot, $Separator, $QuoteStart,
                    $QuoteEnd, $ValueEnd,  $ValueTrail
                  )
                  = @{ $v[0] }
                  if $ExtraData->{ lc $Key };
                ( $Separator, $ValueEnd, $ValueTrail ) = ( ":", ";", " " )
                  unless $ExtraData->{ lc $Key };

              # Flag to defang if a url, expression or unallowed character found
                if ( $Defang == 2 ) {
                    $Defang =
                      $Value =~ m{^\s*[a-z0-9%!"'`:()#\s.,\/+-]+\s*;?\s*$}i
                      ? 0
                      : 1;
                    $Defang = $Value =~ m{^\s*url\s*\(}i        ? 1 : $Defang;
                    $Defang = $Value =~ m{^\s*expression\s*\(}i ? 1 : $Defang;
                }

                # Comment out the style property-value pair if $Defang
                $Key      = $Defang ? "/*" . $Key      : $Key;
                $ValueEnd = $Defang ? $ValueEnd . "*/" : $ValueEnd;

                # Put the rule together back
                if ( defined($Key) ) {
                    $Rule .= $KeyPilot   if defined($KeyPilot);
                    $Rule .= $Key;
                    $Rule .= $Separator  if defined($Separator);
                    $Rule .= $QuoteStart if defined($QuoteStart);
                    $Rule .= $Value      if defined($Value);
                    $Rule .= $QuoteEnd   if defined($QuoteEnd);
                    $Rule .= $ValueEnd   if defined($ValueEnd);
                    $Rule .= $ValueTrail if defined($ValueTrail);
                }

                warn "defang_stylerule Rule=$Rule" if $Self->{Debug};

            }

        }

        # Modify the original array
        $StyleRules->[$Counter] = $Rule;
        $Counter++;
    }

}

=item I<defang_attributes($OutR, $HtmlR, $TagOps, $OpenAngle, $IsEndTag, $Tag, $TagTrail, $Attributes, $CloseAngle)>

Defangs attributes, defangs tags, does tag, attrib, css and url callbacks.

=over 4

=item B<Method parameters>

For a description of the method parameters, see documentation of defang_script() method

=back

=cut

sub defang_attributes {
    my (
        $Self,     $OutR, $HtmlR,    $TagOps,     $OpenAngle,
        $IsEndTag, $Tag,  $TagTrail, $Attributes, $CloseAngle
    ) = @_;
    my $lcTag = lc $Tag;

    my $Debug = $Self->{Debug};

    # Create a key -> \value mapping of all attributes up front
    #  so we have a complete hash for each callback
    my %AttributeHash = map { lc( $_->[0] ) => \$_->[4] } @$Attributes;

    # Now process each attribute
    foreach my $Attr (@$Attributes) {

        # We get the key and value of the attribute
        my ( $AttrKey, $AttrValR ) = ( $Attr->[0], \$Attr->[4] );
        my $lcAttrKey = lc $AttrKey;
        warn "defang_attributes Tag=$Tag AttrKey=$AttrKey AttrVal=$$AttrValR"
          if $Debug;

        # Get the attribute value cleaned up
        ( $$AttrValR, my $AttrValStripped ) =
          $Self->cleanup_attribute( $Attr, $AttrKey, $$AttrValR );
        warn "defang_attributes AttrValStripped=$AttrValStripped" if $Debug;

        my $AttribRule = "";
        if ( ref( $Tags{$lcTag} ) ) {
            $AttribRule = $Tags{$lcTag}{$lcAttrKey};
        }

        my $DefangAttrib = 2;

        $AttribRule = $CommonAttributes{$lcAttrKey} unless $AttribRule;
        warn "defang_attributes AttribRule=$AttribRule" if $Debug;

# If this is a URL type $AttrKey and URL callback method is supplied, make a url_callback
        if (   $Self->{url_callback}
            && $AttribRule
            && exists( $UrlRules{$AttribRule} ) )
        {
            warn "defang_attributes Making URL callback" if $Debug;
            $DefangAttrib = $Self->{url_callback}->(
                $Self->{context}, $Self, $lcTag, $lcAttrKey, $AttrValR,
                \%AttributeHash, $HtmlR, $OutR
            );
            die "url_callback reset" if !defined pos($$HtmlR);
        }

        # We have a style attribute, so we call defang_style
        if ( $lcAttrKey eq "style" ) {
            warn "defang_attributes Found style attribute, calling defang_style"
              if $Debug;
            $Self->defang_style(
                $OutR,       $AttrValR, $TagOps,   $OpenAngle,
                $IsEndTag,   $lcTag,    $TagTrail, $Attributes,
                $CloseAngle, 1
            );
        }

# If a attribute callback is supplied and its interested in this attribute, we make a attribs_callback
        if ( $Self->{attribs_callback}
            && exists( $Self->{attribs_to_callback}->{$lcAttrKey} ) )
        {
            warn
"defang_attributes Making attribute callback for Tag=$Tag AttrKey=$AttrKey"
              if $Debug;
            $DefangAttrib = $Self->{attribs_callback}->(
                $Self->{context}, $Self, $lcTag, $lcAttrKey, $AttrValR, $HtmlR,
                $OutR
            );
        }

        if ( ( $DefangAttrib == 2 ) && $AttribRule ) {
            my $Rule = $Rules{$AttribRule};
            warn "defang_attributes AttribRule=$AttribRule Rule=$Rule"
              if $Debug;

            # We whitelist the attribute if the value matches the rule
            if ( ref($Rule) eq "Regexp" && $AttrValStripped =~ $Rule ) {
                $DefangAttrib = 0;
            }

            # Defang all scripts in attributes
            $DefangAttrib =
              $AttrValStripped =~ /^(javascript:|livescript:|mocha:|vbscript:)/i
              ? 1
              : $DefangAttrib;

        }
        elsif ( !$AttribRule ) {
            $DefangAttrib = 1;
        }

        warn "defang_attributes DefangAttrib=$DefangAttrib" if $Debug;

        # Store the attribute defang flag
        push @$Attr, $DefangAttrib if $DefangAttrib;

    }

    my $DefangTag = 2;

    # Callback if the tag is in @$tags_to_callback
    if ( exists( $Self->{tags_to_callback}->{$lcTag} ) ) {
        warn "defang_attributes Calling tags_callback for $Tag" if $Debug;
        $DefangTag = $Self->{tags_callback}->(
            $Self->{context}, $Self,     $OpenAngle,
            $lcTag,           $IsEndTag, \%AttributeHash,
            $CloseAngle,      $HtmlR,    $OutR
        );
    }

    my @OutputAttributes;

    foreach my $Attr (@$Attributes) {

        my $lcAttr = lc $Attr->[0];

        # If the attribute is deleted don't output it
        unless ( $AttributeHash{$lcAttr} ) {
            warn "defang_attributes Marking attribute $Attr->[0] for deletion"
              if $Debug;
            next;
        }

     # And we attach the defang string here, if the attribute should be defanged
     # (attribute could be undef for buggy html, eg <ahref=blah>)
        $Attr->[0] = $Self->{DefangString} . ( $Attr->[0] || '' ) if $Attr->[7];

        # Set this to undef, or this value will appear in the output
        $Attr->[7] = undef;

        # Requote specials in attribute value
        my $QuoteRe = $QuoteRe{ $Attr->[3] } || $QuoteRe{""};
        $Attr->[4] =~ s/$QuoteRe/'&'.$CharToEntity{$1}.';'/eg
          if defined( $Attr->[4] );

        # Add to attributes to output
        push @OutputAttributes, $Attr;

# Remove all processed attributes in the hash, so we can track ones that we added
        delete $AttributeHash{$lcAttr};
    }

# Append all remaining attribute keys (which must have been newly added attributes by
# the callback)and values in no particular order
    while ( my ( $Key, $Value ) = each %AttributeHash ) {
        my $Attr = [ " " . $Key, "", "=", '"', $$Value, '"', "" ];
        if ( defined $Attr->[4] ) {
            $Attr->[4] =~ s/(['"<>&])/$CharToEntity{$1}/eg;
        }
        else {
            @$Attr[ 2 .. 6 ] = (undef) x 5;
        }
        push @OutputAttributes, $Attr;
    }

    # Replace attributes array with just the ones we want to output
    @$Attributes = @OutputAttributes;

    # If its a known tag, we whitelist it
    if ( $DefangTag == 2 && ( my $TagOps = $Tags{$lcTag} ) ) {
        $DefangTag = 0;
    }

    if ( $Self->{fix_mismatched_tags}
        && ( $DefangTag == 2 || $DefangTag == 0 ) )
    {
        my ( $OpenedTags, $OpenedTagsCount ) =
          @$Self{qw(OpenedTags OpenedTagsCount)};

        # Check for correctly nest closing tags
        if ( $IsEndTag && $Self->{mismatched_tags_to_fix}->{$lcTag} ) {
            my ( $Found, $ClosingTags ) = ( 0, '' );

            # Tag not even open, just defang it
            return 1 if !$OpenedTagsCount->{$lcTag};

            # Check tag stack up to find mismatches
            for my $PreviousOpenedTag ( reverse @$OpenedTags ) {

                if ( $PreviousOpenedTag eq $lcTag && !$ClosingTags ) {

                    # Common case for correctly matched tags should pop tag
                    pop @$OpenedTags;
                    $OpenedTagsCount->{$lcTag}--;
                    $Found = 1;
                    last;
                }

                # Check for tags that don't break out further
                if ( my $NestList = $MismatchedTagNest{$PreviousOpenedTag} ) {
                    last if $NestList->{""} || $NestList->{$lcTag};
                }

                $ClosingTags .=
                  "<!-- close mismatched tag --></$PreviousOpenedTag>";
            }

         # Attach closing tags to the processed output (but call defang on them)
            $$OutR .= $Self->defang($ClosingTags) if $ClosingTags;

          # If we had $ClosingTags, defanging should have popped stack correctly
            if (   $ClosingTags
                && @$OpenedTags
                && $lcTag eq $OpenedTags->[ @$OpenedTags - 1 ] )
            {
                pop @$OpenedTags;
                $OpenedTagsCount->{$lcTag}--;
            }

            return 1 if !$Found;
        }

        # Track browser implicitly opened tags
        if ( !$IsEndTag && @$OpenedTags ) {

            # Are we expecting a particular tag based on last open tag?
            if ( my $ImplicitTags =
                $ImplicitOpenTags{ $OpenedTags->[ @$OpenedTags - 1 ] } )
            {

        # We didn't get a tag we were expecting (eg <table><div> rather
        #  than <table><tbody><tr><td><div>), so insert opening tags recursively
                my $lastTag = $lcTag;
                while ( $ImplicitTags && !$ImplicitTags->{$lastTag} ) {
                    my $Tag = $ImplicitTags->{default};
                    $$OutR .=
                      "<!-- $Tag implicit open due to $lastTag --><$Tag>";
                    if ( $Self->{mismatched_tags_to_fix}->{$Tag} ) {
                        push @$OpenedTags, $Tag;
                        $OpenedTagsCount->{$Tag}++;
                    }
                    $ImplicitTags = $ImplicitOpenTags{$Tag};
                    $lastTag      = $Tag;
                }
            }
        }

        # Track this tag that was opened
        if ( !$IsEndTag && $Self->{mismatched_tags_to_fix}->{$lcTag} ) {
            push @$OpenedTags, $lcTag;
            $OpenedTagsCount->{$lcTag}++;
        }

    }

    return $DefangTag;

}

=item I<cleanup_attribute($AttributeString)>

Helper function to cleanup attributes

=over 4

=item B<Method parameters>

=over 4

=item I<$AttributeString>

The value of the attribute.

=back

=back

=back

=back

=cut

sub cleanup_attribute {
    my ( $Self, $Attr, $AttrKey, $AttrVal ) = @_;

    return ( undef, '' ) unless defined($AttrVal);

# Create a "stripped" attribute value which removes all embedded whitespace and control characters

    # Substitute character entities with actual characters
    # (avoid invalid chars + surrogate pairs)
    $AttrVal =~
s/(?:&#x|\\[xu]|%)(0?[\da-f]{1,6});?/defined($1) && hex($1) < 1_114_111 && hex($1) != 65535 && !(hex($1) > 55295 && hex($1) < 57344) ? chr(hex($1)) : ""/egi;
    $AttrVal =~
s/(?:&#)([\d]{1,7});?/defined($1) && $1 < 1_114_111 && $1 != 65535 && !($1 > 55295 && $1 < 57344)? chr($1) : ""/egi;
    $AttrVal =~
s/(?:&)(quot|apos|amp|lt|gt);?/$EntityToChar{lc($1)} || warn "no entity for: $1"/egi;

    my $AttrValStripped = $AttrVal;
    $AttrValStripped =~ s/[\x00-\x19]*//g;
    $AttrValStripped =~
      s/^\x20*//g;    # http://ha.ckers.org/xss.html#XSS_Spaces_meta_chars

    warn "cleanup_attribute AttrValStripped=$AttrVal" if $Self->{Debug};
    return ( $AttrVal, $AttrValStripped );
}

sub get_applicable_charset {

    my $Self = shift;
    local $_ = shift;
    my $Charset = shift;

    if ( !$Charset ) {

        # Look for <meta> tags
        my @MetaAttrs = /<meta[\s\/]+(${AttributesRE})/gi;

        for (@MetaAttrs) {
            my %Attrs;

            # Get attributes and their values
            while (
s/(?:($AttrKeyStartLineRE)(\s*))?(?:(=\s*)($AttrValRE)(\s*))?//so
              )
            {
                last if !defined($1) && !defined($4);
                $Attrs{ lc $1 } = $4;
            }

            # Look for charset information
            if ( $Attrs{"content"} ) {
                $Charset =
                    $Attrs{"content"} =~ m/charset\s*=\s*([^\s;'"`]+)[\s;'"`]*/i
                  ? $1
                  : $Charset;
            }
        }
    }

    # Return fallback charset if no header or meta charset found
    return $Charset ? $Charset : shift;

}

=head1 SEE ALSO

I<HTML::Defang>, L<http://mailtools.anomy.net/>, L<http://htmlcleaner.sourceforge.net/>, I<HTML::StripScripts>, I<HTML::Detoxifier>, I<HTML::Sanitizer>, I<HTML::Scrubber>

=cut

=head1 AUTHOR

Kurian Jose Aerthail E<lt>cpan@kurianja.fastmail.fmE<gt>. Thanks to Rob Mueller E<lt>cpan@robm.fastmail.fmE<gt> for initial code, guidance and support and bug fixes.

=cut

=head1 COPYRIGHT AND LICENSE

HTML::Declaw is a modifed version of HTML::Defang which has the following license:

Copyright (C) 2003-2009 by The FastMail Partnership

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
