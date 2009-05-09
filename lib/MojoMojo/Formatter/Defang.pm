package MojoMojo::Formatter::Defang;

use base qw/MojoMojo::Formatter/;

use HTML::Defang;
use strict;
use warnings;

=head1 NAME

MojoMojo::Formatter::Defang - Scrub user HTML
1
=head1 DESCRIPTION

This formatter makes sure only a safe range of tags are
allowed, using L<HTML::Defang>; It also tries to remove XSS attempts.

=head1 METHODS

=over 4

=item format_content_order

Format order can be 1-99. The Defang formatter runs on 16, just after the main
formatter, in order to catch direct user input. Defang trusts the main formatter
and all subsequently ran plugins to not output unsafe HTML.

=cut

sub format_content_order { 16 }


=item defang_tags_callback

Callback for custom handling specific HTML tags

=cut 

sub defang_tags_callback {
    my ($self, $defang, $open_angle, $lc_tag, $is_end_tag, 
        $attribute_hash, $close_angle, $html_r, $out_r) = @_;
    # Explicitly whitelist this tag, eventhough unsafe
    return 0 if $lc_tag eq 'embed';
    return 0 if $lc_tag eq 'pre';
    # I am not sure what to do with this tag, so process as 
    # HTML::Defang normally would
    return 2 if $lc_tag eq 'img';
}

=item defang_url_callback

Callback for custom handling URLs in HTML attributes as well as 
styletag/attribute declarations

=cut

sub defang_url_callback {
    my ($self, $defang, $lc_tag, $lc_attr_key, $attr_val_r, 
        $attribute_hash, $html_r) = @_;
    # Explicitly allow this URL in tag attributes or stylesheets
    return 0 if $$attr_val_r =~ /youtube.com/i; 
    # Explicitly defang this URL in tag attributes or stylesheets
    return 1 if $$attr_val_r =~ /youporn.com/i; 
}


=item defang_css_callback

Callback for custom handling style tags/attributes

=cut

sub defang_css_callback {
    my ($self, $defang, $selectors, $selector_rules, $tag, $is_attr) = @_;
    my $i = 0;
    foreach (@$selectors) {
        my $selector_rule = $$selector_rules[$i];
        foreach my $key_value_rules (@$selector_rule) {
            foreach my $key_value_rule (@$key_value_rules) {
                my ($key, $value) = @$key_value_rule;
                # Comment out any ’!important’ directive
                $$key_value_rule[2] = 1 if $value =~ '!important';               
                # Comment out any ’position=fixed;’ declaration
                $$key_value_rule[2] = 1 if $key =~ 'position' && $value =~ 'fixed';
            }
        }
        $i++;
    }
}

=item

Callback for custom handling HTML tag attributes

=cut

sub defang_attribs_callback {
    my ($self, $defang, $lc_tag, $lc_attr_key, $attr_val_r, $html_r) = @_;
    # Change all ’border’ attribute values to zero.
    $$attr_val_r = '0' if $lc_attr_key eq 'border';  
    # Defang all ’src’ attributes
    return 1 if $lc_attr_key eq 'src';             
    return 0;
}


=item format_content

calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ( $class, $content, $c ) = @_;
    #return;
    my $defang = HTML::Defang->new(
        context             => $c,
        fix_mismatched_tags => 1,
        tags_to_callback    => [ qw/br embed img/ ],
        tags_callback       => \&defang_tags_callback,
        url_callback        => \&defang_url_callback,
        css_callback        => \&defang_css_callback,
        attribs_to_callback => [     qw(border src) ],
        attribs_callback    => \&defang_attribs_callback
        );
    
    $$content = $defang->defang($$content);
    return;
}

=back

=head1 SEE ALSO

L<MojoMojo>,L<Module::Pluggable::Ordered>,L<HTML::Defang>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut

1;
