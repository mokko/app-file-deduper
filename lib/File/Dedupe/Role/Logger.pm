# ABSTRACT: Logger for File::Dedupe
package File::Dedupe::Role::Logger;
use strict;
use warnings;
use File::Spec;
use Log::Dispatchouli;
use Moose::Role;
use Time::HiRes 'gettimeofday', 'tv_interval';

#use Data::Dumper;
#starts timer only when Role::Logger is applied, but who cares...
our $start_time = [gettimeofday()];

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

A thin wrapper around Log::Dispatchouli.  

=attr debug

a read-only boolean which defaults to 0. 

If you need to change the debug setting during
runtime use $self->{logger}->set_debug ($bool) instead.

=cut

has 'debug' => (is => 'ro', isa => 'Bool', default => 0);

=attr logfile

Full path to logfile as an array. First item contains directory, second
the base filename, so that together it's a complete path. Defaults to

    $ENV{HOME}/.dedupe/dedupe.log 

The separator is specific for your OS.

=cut

has 'logfile' => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 0,
    default  => sub {
        [path($ENV{HOME}, '.dedupe'), 'dedupe.log'];
    }
);

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

has '_caller' => (is => 'ro', isa => 'ArrayRef', init_arg => undef);
before 'log' => sub {
    $_[0]->{_caller} = [caller(2)]; #not good!
};


sub _build_logger {
    my $self = shift;

    #log_path etc. should be defined elsewhere, of course
    #or perhaps be changed later, but there is a chicken egg problem:
    #I want debug messages while loading the config, and I need a
    #config value to setup logging...
    #what is a clean solution?
    #a) Keep logging info out of configuration file
    #b) allow to configure path when logger is loaded by using attr
    my $args = {
        ident   => __PACKAGE__,    #not sure about package
        log_pid => 0,
    };

    if ($self->logfile) {
        $args->{to_file}  = 1;
        $args->{log_path} = @{$self->logfile}[0];
        $args->{log_file} = @{$self->logfile}[1];
    }

    if ($self->{debug}) {
        $args->{debug}     = 1;
        $args->{to_stdout} = 1;
    }

    my $logger = Log::Dispatchouli->new($args);
    $logger->set_prefix(
        sub {
            if ($self->_caller) {
                return
                    _interval() . ' '
                  . $self->_caller->[0]
                  . ' (line '
                  . $self->_caller->[2] . '): '
                  . $_[0];
            }
            return _interval() . ' ' . $_[0];
        }
    );
    return $logger;
}

#
# METHODS
#

#Logger role seems not the right place, but not sure where to put it
sub path {    #function!
    File::Spec->catfile(@_);
}

#
# PRIVATE
#

#shamelessly from Dancer::Timer. Thanks!
sub _interval {    #function
    my $now = [gettimeofday()];
    my $delay = tv_interval($start_time, $now);
    return sprintf('%0f', $delay);
}


1;
