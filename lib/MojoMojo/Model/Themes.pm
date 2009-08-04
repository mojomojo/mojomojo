package MojoMojo::Model::Themes;

use strict;

use parent 'Catalyst::Model';

=head1 NAME

MojoMojo::Model::Themes

=head1 ACTIONS

=head2 list

List available themes.

=cut

sub list {
    my $self       = shift;
    my $theme_dir  = MojoMojo->path_to('root', 'static', 'themes');
    my @themes;
    opendir TDH, $theme_dir;
    while (my $theme = readdir TDH){
        next if $theme =~ /^\.{1,2}/;
        push @themes, $theme;
    }
    closedir TDH;
    MojoMojo->log->info("Available themes in " . $theme_dir . ": @themes")
        if MojoMojo->debug;
    return @themes
}

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
