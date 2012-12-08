#ABSTRACT: programmatic low-lewel interface for File::Dedupe
package File::Dedupe2;
use strict;
use warnings;
use Data::Dumper;    #debugging
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

has 'file_list' => (
    is   => 'rw',
    isa  => 'HashRef',
    #builder=>scan_input
);


sub scan_input {
    my $self = shift;
    print "scan_input!!!!!!!\n";
    print Dumper $self->active_config;
    #my $input = $self->active_config->{input} or $self->log_fatal('Input missing');
    #foreach


}


1;

