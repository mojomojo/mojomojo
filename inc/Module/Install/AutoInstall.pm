#line 1 "inc/Module/Install/AutoInstall.pm - /usr/local/lib/perl5/site_perl/5.8.5/Module/Install/AutoInstall.pm"
package Module::Install::AutoInstall;
use Module::Install::Base; @ISA = qw(Module::Install::Base);

sub AutoInstall { $_[0] }

sub run {
    my $self = shift;
    $self->auto_install_now(@_);
}

sub write {
    my $self = shift;
    $self->auto_install(@_);
}

sub auto_install {
    my $self = shift;
    return if $self->{done}++;

    # Flatten array of arrays into a single array
    my @core = map @$_, map @$_, grep ref,
               $self->build_requires, $self->requires;

    while ( @core and @_ > 1 and $_[0] =~ /^-\w+$/ ) {
        push @core, splice(@_, 0, 2);
    }

    # We'll need ExtUtils::AutoInstall
    $self->include('ExtUtils::AutoInstall');
    require ExtUtils::AutoInstall;

    ExtUtils::AutoInstall->import(
        (@core ? (-core => \@core) : ()), @_, $self->features
    );

    $self->makemaker_args( ExtUtils::AutoInstall::_make_args() );

    my $class = ref($self);
    $self->postamble(
        "# --- $class section:\n" .
        ExtUtils::AutoInstall::postamble()
    );
}

sub auto_install_now {
    my $self = shift;
    $self->auto_install;
    ExtUtils::AutoInstall::do_install();
}

1;
