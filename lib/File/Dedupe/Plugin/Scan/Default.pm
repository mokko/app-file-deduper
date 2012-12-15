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

#
# This is a plugin bundle, i.e. a plugin which calls other plugins
# It's also a default plugin, so it gets called unless you overwride
# it somewhere in your configuration file (todo)
#

sub BUILD {
    my $self = shift;
    my $ps   = $self->core->plugin_system;
    
    my $bundle = {
        'Store::One' => {
            phase  => 'Store',
            role   => undef,
            logger => $self->core->logger,
            dbfile => $self->core->config->{main}{dbfile},
        },
        'Scan::Monitor' => {core => $self->core},
        'Scan::Compare' => {core => $self->core},
        'Scan::Wipe'    => {core => $self->core},
    };

    $ps->register_bundle($bundle);
    
    #shortcut for store; 
    #store should implement an interface role... todo
    #N.B. attribute store has small letter while respective phase has capital
    $self->{store} = $self->core->plugin_system->get_plugin('Store')
      or confess "Need store!";
}


sub start {
    my $self    = shift;
    my $monitor = $self->core->plugin_system->get_plugin('ScanMonitor')
      or confess "Need monitor";
    $monitor->scan;
}

1;
