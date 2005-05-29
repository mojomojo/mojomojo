package MojoMojo::C::Admin;

use strict;
use base 'Catalyst::Base';

=head1 NAME

MojoMojo::C::Admin - Catalyst component

=head1 DESCRIPTION

Catalyst admin controller

=head1 METHODS

=over 4

=item auto

=cut

sub auto : Private {
    my ( $self, $c ) = @_;
    # FIXME - need to identify administrators
    my $user = $c->req->{user};
    my $admins = $c->pref('admins');
    unless ( $user && $admins =~m/\b$user\b/ ) {
        $c->stash->{message}='sorry bubba, gotta be admin';
        $c->stash->{template}='message.tt';
        $c->log->info('admins are '.$admins);
        return 0;
    }
    $admins =~s/$user//g;
    $c->stash->{admins} = $admins;
    return 1;
}

sub settings : Global {
    my ( $self, $c ) = @_;
    $c->stash->{template}='settings.tt';
}

sub setting_name : Path('/settings/name') {
    my ( $self, $c ) = @_;
    $c->form(required=>'name');
    $c->pref('name',$c->form->valid('name'))
      unless ($c->form->has_missing ||$c->form->has_invalid); 
    $c->res->body($c->pref('name'));
}

sub setting_admins : Path('/settings/admins') {
    my ( $self, $c ) = @_;
    $c->form(required=>'admins');
    unless ($c->form->has_missing ||$c->form->has_invalid) {
      my @users =  split(m/\s+/,$c->form->valid('admins'));
      foreach my $user ( @users ) {
        return $c->res->body('Not valid: '.$user)
          unless (MojoMojo::M::Core::Person->get_user($user)); 
      }
      $c->res->body('Updated');
      $c->pref('admins',join(' ',@users,$c->req->{user}));
  }
}

=back


=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;
