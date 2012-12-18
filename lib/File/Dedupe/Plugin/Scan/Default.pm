#ABSTRACT: Scans monitored directories and updates store
package File::Dedupe::Plugin::Scan::Default;
use strict;
use warnings;
use Data::Dumper;    #debugging
use Carp 'confess';
use Cwd qw(realpath);
use Plugin::Tiny;
use Moose;
with 'File::Dedupe::Role::Plugin';    #requires core...

#use Scalar::Util qw(blessed);

=head1 DESCRIPTION

This is a plugin bundle, i.e. a plugin which calls other plugins. It is also a 
default plugin that gets called for the phase 'Scan' unless you overwrite that 
phase with a different plugin in your configuration file. 

=method BUILD

In the build phase modules and config are loaded and logger is initialized, but
nothing is really done. For action see C<start>.

=cut

sub BUILD {
    my $self = shift;
    my $ps   = $self->core->plugin_system;

    #registers in no particular order
    $ps->register_bundle($self->bundle);    

    #perhaps we load store when needed and not preemptively?
    #shortcut for store;
    #store should implement an interface role... todo
    #N.B. attribute store has small letter while respective phase has capital
    #$self->{store} = $self->core->plugin_system->get_plugin('Store')
    #  or confess "Need store!";
}

=method bundle

returns a hashref describing a bundle. It's separated out in a method so you
can easily extend it using this package as a base class.

=cut

sub bundle {  
    my $self=shift;
    return {   'Store::One' => {
            phase  => 'Store',
            role   => undef,
            logger => $self->core->logger,
            dbfile => $self->core->config->{main}{dbfile},
        },
        'Scan::Monitor' => {core => $self->core},
        'Scan::Wipe'    => {core => $self->core},
    };
}


=method start

Initiates the scanning of the monitored directories.

gets called from File::Dedupe without any arguments. Returns the return

=cut


sub start {
    my $self    = shift;
    my $monitor = $self->core->plugin_system->get_plugin('ScanMonitor')
      or confess "Need monitor";
    $monitor->scan;
    my $wiper = $self->core->plugin_system->get_plugin('ScanWipe')
      or confess "Need wiper";
    $wiper->wipe;
}

1;
