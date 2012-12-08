# ABSTRACT: Logger for File::Dedupe
package File::Dedupe::Role::Logger;
use strict;
use warnings;
use File::Spec;
use Log::Dispatchouli;
use Moose::Role;
#use Data::Dumper;

=head1 SYNOPSIS

    package TryLogger;
    use Moose;
    with 'File::Dedupe::Role::Logger';

    sub some_sub {
        my $self=shift;
        $self->log ('log this');
        $self->log_debug ('debug msg');
        $self->log_fatal ('log this and quit');
    }
    1;

    package main;
    my $tl = TryLogger->new(debug=>1); #default is 0
    $tl->log ('log this');
    $tl->log_debug ('debug msg');
    $tl->log_fatal ('log this and quit');


=head1 DESCRIPTION

We need comfortable logging on screen (STDOUT) and to file. Let's try and see 
if Log::Dispatchouli works in this case. 

Should this be a base class? Or a role, so that all our classes can use it?

=attr debug

debug is a read-only boolean which defaults to 0. 

If you need to change the debug setting during
runtime use $self->{logger}->set_debug ($bool) instead.

=cut

has 'debug' => (is => 'ro', isa => 'Bool', default => 0);

=attr logger

stores a Log::Dispatchouli object with default values and handles 
    log
    log_degug
    log_fatal

=cut

has 'logger' => (
    is      => 'ro',
    isa     => 'Log::Dispatchouli',
    builder => '_build_logger',
    lazy    => 1,
    handles => [qw(log log_debug log_fatal)],
);

sub _build_logger {

    #log_path etc. should be defined elsewhere, of course
    #or perhaps I can change it later?
    my $args = {
        ident     => __PACKAGE__,    #not sure about package yet...
        to_file   => 1,
        to_stdout => 1,
        log_path => File::Spec->catfile($ENV{HOME}, '/', '.dedupe'),
        log_file => 'dedupe.log',
    };

    $args->{debug} = 1 if ($_[0]->{debug});
    $_[0]->{logger} = Log::Dispatchouli->new($args);
}


1;
