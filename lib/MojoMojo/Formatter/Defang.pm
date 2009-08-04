package MojoMojo::Formatter::Defang;
use strict;
use warnings;
use parent qw/MojoMojo::Formatter/;
use HTML::Declaw;
use URI;

=head1 NAME

MojoMojo::Formatter::Defang - Scrub user HTML and XSS

=head1 DESCRIPTION

This formatter makes sure only a safe range of tags are
allowed, using L<HTML::Defang>; It also tries to remove XSS attempts.

=head1 METHODS

=head2 format_content_order

Format order can be 1-99. The Defang formatter runs on 16, just after the main
formatter, in order to catch direct user input. Defang trusts the main formatter
and all subsequently ran plugins to not output unsafe HTML.

=cut

sub format_content_order { 16 }

=head2 defang_tags_callback

Callback for custom handling specific HTML tags

=cut

sub defang_tags_callback {
    my (
        $c,           $defang,     $open_angle,
        $lc_tag,      $is_end_tag, $attribute_hash,
        $close_angle, $html_r,     $out_r
    ) = @_;

    # Explicitly whitelist this tag, although unsafe
    return 0 if $lc_tag eq 'embed';
    return 0 if $lc_tag eq 'object';
    return 0 if $lc_tag eq 'param';
    return 0 if $lc_tag eq 'pre';

    # I am not sure what to do with this tag, so process as
    # HTML::Defang normally would
    #return 2 if $lc_tag eq 'img';
}

=head2 defang_url_callback

Callback for custom handling URLs in HTML attributes as well as
styletag/attribute declarations

=cut

sub defang_url_callback {
    my ( $c, $defang, $lc_tag, $lc_attr_key, $attr_val_r, $attribute_hash,
        $html_r )
      = @_;

    # Explicitly allow this URL in tag attributes or stylesheets
    return 0 if $$attr_val_r =~ /youtube.com/i;

    # Explicitly defang this URL in tag attributes or stylesheets
    return 1 if $$attr_val_r =~ /youporn.com/i;
}

=head2 defang_css_callback

Callback for custom handling style tags/attributes.

=cut

sub defang_css_callback {
    my ( $c, $defang, $selectors, $selector_rules, $tag, $is_attr ) = @_;
    my $i = 0;
    foreach (@$selectors) {
        my $selector_rule = $$selector_rules[$i];
        foreach my $key_value_rules (@$selector_rule) {
            foreach my $key_value_rule (@$key_value_rules) {
                my ( $key, $value ) = @$key_value_rule;

                # Comment out any ’!important’ directive
                $$key_value_rule[2] = 1 if $value =~ '!important';

                # Comment out any ’position=fixed;’ declaration
                $$key_value_rule[2] = 1
                  if $key =~ 'position' && $value =~ 'fixed';
            }
        }
        $i++;
    }
}

=head2

Callback for custom handling HTML tag attributes.

=cut

sub defang_attribs_callback {
    my ( $c, $defang, $lc_tag, $lc_attr_key, $attr_val_r, $html_r ) = @_;

    # if $lc_attr_key eq 'value';
    # Initial Defang effort on attributes applies specifically to 'src'
    if ( $lc_attr_key eq 'src' ) {
        my $src_uri_object = URI->new($$attr_val_r);

        # Allow src URI's from configuration.
        my @allowed_src_regex;
        # Tests may not have a $c
        if ( defined $c ) {

            if ( exists $c->stash->{allowed_src_regexes} ) {
                @allowed_src_regex = @{ $c->stash->{allowed_src_regexes} };
            }
            else {
                my $allowed_src = $c->config->{allowed}{src};
                my @allowed_src =
                  ref $allowed_src ? @{$allowed_src} : ($allowed_src);
                @allowed_src_regex = map { qr/$_/ } @allowed_src  if $allowed_src[0];

                # TODO: Shouldn't this be using pref cache?
                $c->stash->{allowed_src_regexes} = \@allowed_src_regex;
            }
        }
        for my $allowed_src_regex (@allowed_src_regex) {
            if ( $$attr_val_r =~ $allowed_src_regex ) {
                return 0;
            }

        }

        # When $c and src uri authority are defined we want to make sure
        # it matches the server of the img src.  i.e. we allow images from the
        # local server whether the URI is relative or absolute..
        if ( defined $c && defined $src_uri_object->authority ) {
            if ( $c->request->uri->authority eq $src_uri_object->authority ) {
                return 2;
            }
            else {
                return 1;
            }
        }
        # We have an authority but no context.
        # Probably means we're testing with just the Defang formatter
        # instead of the Full formatter chain.
        # We will defang any src's left with an authority (defang_src)
        # since the approved ones were already allowed in above.
        elsif ( defined $src_uri_object->authority ) {
            return 1;
        }
        else {
            return 2;
        }
    }

    return 0;
}

=head2 format_content

Calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ( $self, $content, $c ) = @_;

    my $defang = HTML::Declaw->new(
        context             => $c,
        fix_mismatched_tags => 1,
        tags_to_callback    => [qw/br embed object param img/],
        tags_callback       => \&defang_tags_callback,
        url_callback        => \&defang_url_callback,
        css_callback        => \&defang_css_callback,
        attribs_to_callback => [qw(src value)],
        attribs_callback    => \&defang_attribs_callback,
    );

    $$content = $defang->defang($$content);
    return;
}

=head1 SEE ALSO

L<MojoMojo>, L<Module::Pluggable::Ordered>, L<HTML::Defang>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
