package File::Dedupe::Plugin::ScanDefault;
use strict;
use warnings;
use Data::Dumper;    #debugging
use Carp 'confess';
use Cwd qw(realpath);
use Moose;
with 'File::Dedupe::Role::Plugin'; #requires core...
#use Scalar::Util qw(blessed);

#
# This is a plugin bundle, i.e. a plugin which calls other plugins
# It's also a default plugin, so it gets called unless you overwride
# it somewhere in your configuration file (todo)
#

sub BUILD {
    my $self = shift;
    my $ps = $self->core->plugin_system;

    #will be in some other plugin eventually
    my $dbfile=$self->core->config->{main}{dbfile};


    $ps->register(plugin => 'ScanMonitored', core=>$self->core);
    $ps->register(plugin => 'ScanCompare', core=>$self->core);
    $ps->register(plugin => 'Store::One', dbfile=>$dbfile);
    $ps->register(plugin => 'ScanWipe', core=>$self->core);

    #shortcut for store; store should implement an interface role... todo
    #N.B. attribute store has small letter while respective phase has capital.
    $self->{store} = $self->plugin_system->get_plugin('Store')
      or confess "Need store!";


    #perhaps I don't need to do any methods?
}


1;
