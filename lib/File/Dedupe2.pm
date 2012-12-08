#ABSTRACT: programmatic low-lewel interface for File::Dedupe
package File::Dedupe2;
use strict;
use warnings;
use Data::Dumper;    #debugging
use Plugin::Simple qw(scan);
use Moose;
with 'File::Dedupe::Role::Config';


=head1 SYNOPSIS

    use File::Dedupe;

    #receives all the config that's necessary
    my $deduper=File::Dedupe->new (%args); 

    #not necessary, can be read from config file 
    #assemble items (dir/file) to work on
    $deduper->scan_input; #dies or report error on failure? 

    #update description in db for given input
    $deduper->scan() or die "Warning"; 

    #forgot what wipe does
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

    #builder=>scan_input
);


has 'plugin_system' => (
    is      => 'ro',
    isa     => 'Plugin::Simple',
    lazy    => 1,
    builder => '_build_plugin_system',
);


sub _build_plugin_system {
    my $self = shift;
    my $ps = Plugin::Simple->new(phases => ['scan']);

    #currently i have to load the default plugins
    #later i have to load plugins from the current profile
    #Anyways, should I unregister defaults?
    #Would be more elegant if load defaults only if profile doesn't
    #specify an alternative

    $self->log('Register File::Dedupe::Plugin::Scan::Default');
    $ps->register('File::Dedupe::Plugin::Scan::Default');
    return $ps;
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

    #cant handover input only since it's an arrayRef
    my @p = $self->plugin_system->execute('scan', $self->active_config);
    foreach my $plugin (@p) {
        my ($obj, $ret) = $self->plugin_system->return_value($plugin);
        $self->{filelist}=$ret;
    }
    print Dumper $self->filelist;
    return 1;

}


#
# PRIVATE
#


1;

