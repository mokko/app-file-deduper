#ABSTRACT: programmatic low-lewel interface for File::Dedupe
package File::Dedupe2;
use strict;
use warnings;
use Data::Dumper;    #debugging
use Plugin::Tiny;
use Moose;
with 'File::Dedupe::Role::Config';


=head1 SYNOPSIS

    use File::Dedupe;
    my $deduper=File::Dedupe->new (
        config=>$config,            #all the config that's necessary
        config_file=>$config_file,  #or: file with configuration
        logfile=>[$logdir, $logfile]#optional
    );     
    
    #preliminary
    $deduper->scan_input; #dies or report error on failure? 

    #update description in db for given input
    $deduper->scan() or die "Warning"; 

    #forgot what wipe does; might be
    $deduper->wipe()

    #make and show a plan
    my $tdl=$deduper->plan ();  #make a plan

    #carry out the plan
    my $deduper->do();
    
=attr file_list

stores a list of files encountered during the scan. Stored as a hash to sort 
out duplicates on this level. This is populated during scan_input.

=cut

has 'filelist' => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { {} },

);

has 'plugin_system' => (
    is      => 'ro',
    isa     => 'Plugin::Tiny',
    lazy    => 1,
    builder => '_build_plugin_system',
);

has 'store' => (
    is            => 'ro',
    isa           => 'Object',
    documentation => 'store implemented by plugin during BUILD',
    init_arg      => undef,
);

sub _build_plugin_system {

    #log this to ensure that we're not re-making Plugin::Tiny all over again
    #don't register plugins from within _build_plugin_system -> deep recursion
    $_[0]->log("Only ONCE!");
    Plugin::Tiny->new(
        prefix => 'File::Dedupe::Plugin::',
        role   => 'File::Dedupe::Role::Plugin',
        debug =>0,
    );
}


sub BUILD {
    my $self = shift;

    #don't register inside of _build_plugin_system to avoid deep recursion

    #plugin defaults
    my %plugins = (
        'Scan' => 'Scan::Default', #bundle
    );

    #load plugins from configuration, overwrite defaults
    if ($self->config->{main}{plugins}) {
        foreach my $pair (@{$self->config->{main}{plugins}}) {
            map { $plugins{$_} = $pair->{$_} } (keys %{$pair});
        }
    }
    foreach my $phase (keys %plugins) {
        $self->plugin_system->register(
            phase  => $phase,
            plugin => $plugins{$phase},
            core   => $self,
        );
        #my $class = $self->plugin_system->prefix . $plugins{$phase};
        #this logs only top level of plugins, not plugins called from plugins
        #$self->log_debug("registered '$class' for phase '$phase'");
    }

}

#
# METHODS
#


=method $filelist=$self->scan_input;

Takes as input the active_config and its input values and saves all files
in input directories in $self->{filelist}; also returns filelist. Croaks
on failure.

=cut

sub scan_input {
    my $self  = shift;
    my $input = $self->active_config('input')
      or $self->log_fatal('Input missing');

    #can't handover input only since it's an arrayRef
    #currently, plugin has everything,so doesn't matter

    my $scan = $self->plugin_system->get_plugin('Scan')
      or confess 'Cannot get plugin';

    $scan->start();
    return 1;
}


#
# PRIVATE
#


1;

