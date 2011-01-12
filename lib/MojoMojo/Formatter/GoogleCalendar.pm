package MojoMojo::Formatter::GoogleCalendar;

#use strict;
use parent 'MojoMojo::Formatter';

#my $dependencies_installed = !$@;
#sub module_loaded { $dependencies_installed }

our $VERSION = '0.1';

=head1 NAME

MojoMojo::Formatter::GoogleCalendar - Embed Google Calendar

=head1 DESCRIPTION

Embed Goodle Calendar in wiki page {{gcal <url> <width>,<height> <alignment>}}.

=head1 METHODS

=head2 format_content_order

Format order can be 1-99. The Google Calendar formatter runs on 20.

=cut

sub format_content_order { 20 }

=head2 format_content

Calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ( $class, $content, $c ) = @_;
    my ( $width, $height, $align );
    my $default_width     = 600;
    my $default_height    = 400;
    my $default_alignment = 'center';
    my %alignment_style   = (
        'center' => 'margin:auto;width:70%',
        'right'  => 'float:right;width:70%',
        'left'   => 'float:left;width:70%'
    );
    my @lines = split /\n/, $$content;
    my $re = $class->gen_re(qr/gcal\s+(.*?)\s+(\d+),(\d+)\s+(\w+)/);
    $$content = "";
    $c->stash->{precompile_off} = 1;

    foreach my $line (@lines) {
        if ( $line =~ m/$re/ ) {
            !defined($2) ? $height = $default_height : $height = $2;
            !defined($3) ? $width  = $default_width  : $width  = $3;
            !defined($4)
              ? $align = $alignment_style{$default_alignment}
              : $align = $alignment_style{$4};
            $line =
"<div style='$align;border:1'><iframe src='$1' height='$height' width='$width' style='border-width:0; margin-left:auto; margin-right:auto' frameborder='0' scrolling='no'></iframe></div>";
        }
        $$content .= $line . "\n";
    }
    return $content;

}

=head1 SEE ALSO

L<MojoMojo>, L<Module::Pluggable::Ordered>, L<URI::Fetch>

=head1 AUTHORS

Jurnell Cockhren <jurnell.cockhren@vanderbilt.edu>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
