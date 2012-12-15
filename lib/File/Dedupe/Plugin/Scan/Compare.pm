package File::Dedupe::Plugin::Scan::Compare;
use strict;
use warnings;
use Carp 'confess';
use Moose;
with 'File::Dedupe::Role::Plugin';
use Data::Dumper;    #debugging

#use Cwd qw(realpath);
#use Scalar::Util qw(blessed);

=head1 SYNOPSIS

    #register plugin somewhere (probably in bundle plugin)
    my $sc=$plugin_system->get_plugin('ScanCompare');
    $sc->check ($file);

=head1 DESCRIPTION

The plugin Scan::Compare is intended for the phase ScanCompare. It is part of 
the Scan::Default plugin bundle.

It gets called on every file the Scan::Monitor plugin encounters. It checks if
store knows about this file already and saves a new description of this file if
necessary.

New file description is necessary if 
-store has no description for this file
-we're using a different checksum type than before
-existing description is outdated 
  for big files: changed mtime or size?
  for small files: changed checksum?

=method $sc->check ($file_path);

If description is updated, C<see> it returns the new description; otherwise 
undef.

=cut

#
# METHODS
#

sub BUILD {
}

has 'store' => (
    is       => 'ro',
    isa      => 'Object',
    default  => sub { $_[0]->core->plugin_system->get_plugin('Store') },
    init_arg => undef,
);

sub check {
    my $self = shift;
    my $path = shift or return;    #absolute or relative is both fine
    print "discovered $path\n";
    my $desc = $self->store->read($path);
    if ($desc) {
        my $size          = (stat($path))[7];
        my $mtime         = (stat(_))[9];
        my $checksum_type = $self->core->config->{main}{checksum_type};
        $self->store->update($path)
          if ( $size != $desc->size
            or $mtime != $desc->mtime
            or $checksum_type ne $desc->checksum_type);
    }
    else { $self->store->create($path) }
}

#
# PRIVATE
#

1;
