package File::Dedupe::Plugin::Scan::Compare;
use strict;
use warnings;
use Data::Dumper; #debugging
use Carp 'confess';
#use Cwd qw(realpath);
#use Scalar::Util qw(blessed);
use Moose;
with 'File::Dedupe::Role::Plugin';

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

=method $sc->check ($file);

If description is updated, C<see> it returns the new description; otherwise 
undef.

=cut

sub check {
    my $self=shift;
    my $file=shift;
    print "discovered $file\n";
}

sub BUILD {
    
}

1;