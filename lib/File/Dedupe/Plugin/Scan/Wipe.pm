package File::Dedupe::Plugin::Scan::Wipe;
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

This wiper does file checks on each every item in store.

=cut



sub BUILD {
}

1;