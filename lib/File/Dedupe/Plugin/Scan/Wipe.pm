package File::Dedupe::Plugin::Scan::Wipe;
use strict;
use warnings;
use Data::Dumper;    #debugging
use Carp 'confess';
use File::Dedupe::FileDescription;

#use Cwd qw(realpath);
#use Scalar::Util qw(blessed);
use Moose;
with 'File::Dedupe::Role::Plugin';

=head1 SYNOPSIS

    #register plugin somewhere (probably in bundle plugin)
    my $wiper=$plugin_system->get_plugin('ScanWipe');

    #delete descriptions which no longer have file in monitored directories
    $wipe->wipe;

=head1 DESCRIPTION

The plugin Scan::Wipe is intended for the phase ScanWipe. It is part of the 
Scan::Default plugin bundle.

It gets called at the end of every scan from Scan::Monitor when all monitored 
items have been processed. The wiper goes thru the descriptions in the store
and removes those which are no longer in the monitored directories on the 
harddisk.

This wiper does file checks on each and every item in store.

=cut


sub BUILD {
}

sub wipe {
    my $self  = shift;
    my $store = $self->core->plugin_system->get_plugin('Store')
      or confess "Need store";
    $store->iterate(
        sub {
            my $file = $_;

            #print Dumper $file;
            if (!-f $file->path) {
                print "\n... delete from store " . $file->path . "\n";
                $store->delete($file->path);
            }
        }
    );
}

1;
