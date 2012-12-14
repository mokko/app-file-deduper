package File::Dedupe::Plugin::Scan::Default;
use strict;
use warnings;
use Data::Dumper;    #debugging
use Carp 'confess';
use Cwd qw(realpath);
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

    $ps->register(    #doesn't log now, because it doesn't use the role...
        phase  => 'Store',
        plugin => 'Store::One',
        role   => undef,
        dbfile => $self->core->config->{main}{dbfile},
    );

    $ps->register(
        plugin => 'Scan::Monitor',
        core   => $self->core
    );
    $ps->register(
        plugin => 'Scan::Compare',
        core   => $self->core
    );
    $ps->register(
        plugin => 'Scan::Wipe',
        core   => $self->core
    );

    #shortcut for store; store should implement an interface role... todo
    #N.B. attribute store has small letter while respective phase has capital.
    $self->{store} = $self->core->plugin_system->get_plugin('Store')
      or confess "Need store!";

}


sub start {
    my $self=shift;
    my $monitor=$self->core->plugin_system->get_plugin('ScanMonitor') or confess "Need monitor";
    $monitor->scan;
}

1;
