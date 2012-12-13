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


sub _build_plugin_system {
    #log this to ensure that we're not re-making Plugin::Tiny all over again
    #don't register plugins from within _build_plugin_system -> deep recursion
    $_[0]->log(__PACKAGE__ . "_build_plugin_system !!!!!!!!!!");
    Plugin::Tiny->new(
        prefix => 'File::Dedupe::Plugin::',
        role   => 'File::Dedupe::Role::Plugin'
    );
}


sub BUILD {
    my $self = shift;
    #don't register inside of _build_plugin_system to avoid deep recursion

    #currently i have to load the default plugins
    #later i have to load plugins from the current profile
    #Anyways, should I unregister defaults?
    #Would be more elegant if load defaults only if profile doesn't
    #specify an alternative
    $self->plugin_system->register(
        phase  => 'Scan',
        plugin => 'ScanDefault',
        core   => $self,               #or plugin_system, config, logger
    );

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

    my $scan_bundle = $self->plugin_system->get_plugin('Scan')
      or confess 'Cannot get plugin';

    #return $scan_bundle->do();

    return 1;

}


#
# PRIVATE
#


1;

