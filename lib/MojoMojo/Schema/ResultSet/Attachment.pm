package MojoMojo::Schema::ResultSet::Attachment;

use strict;
use warnings;
use parent qw/MojoMojo::Schema::Base::ResultSet/;
use Archive::Zip qw(:ERROR_CODES);
use File::MMagic;
use FileHandle;
use File::Copy;
use File::Temp qw/tempfile/;
use Imager;

=head1 NAME

MojoMojo::Schema::ResultSet::Attachment - resulset methods on attachments

=head1 METHODS

=cut

=head2 create_from_file (page, filename, storage_callback)

Create an instance from a given file. Takes a page to attach to, the
client-supplied filename, and the actual file.

=cut

sub create_from_file {
    my ( $class, $page, $filename, $file ) = @_;
    my $mm = File::MMagic->new();
    #if ( $mm->checktype_filename($filename) eq 'application/zip' ) {
        # TODO: the file type returned for a ZIP is 'application/x-zip' (not 'application-zip'),
        # so this has never actually worked. It also never worked because $filename is
        # the client-supplied filename, not the actually uploaded file.
        # Anyway, unpacking the ZIP willy-nilly is a silly idea.
        # Commented out until a UI option to unpack uploaded ZIP(s) is added.
        # --dandv
        #my $zip;
        #$zip = Archive::Zip->new($file);
        #return unless $zip;
        #my @atts;
        #foreach my $member ( $zip->members ) {
        #    next if $member->isDirectory;
        #    my $tmpfile = tempfile;
        #    $member->extractToFileNamed($tmpfile);
        #    push @atts, $class->create_from_file( $page, $member->fileName, $tmpfile );
        #}
        #return @atts;
    #}

    my $self = $class->create({
        name => $filename,
        page => $page->id
    });
    die "Could not attach $filename to $page" if not $self;

    # copy the passed $file (usually from the temporary upload directory), to the attachments directory,
    # with the filename set to MojoMojo Schema::Result::Attachment->filename (currently the row id)
    File::Copy::copy( $file, $self->filename );

    my $fh = FileHandle->new( $self->filename . '' );
    $self->contenttype( $mm->checktype_filehandle($fh) );
    $self->size( -s $self->filename );
    $self->update();
    $self->make_photo if ( $self->contenttype =~ m|^image/| );
    return $self;
}

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
