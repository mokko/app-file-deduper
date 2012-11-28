#ABSTRACT: automatize some things for App::Cmd applications
package App::Cmd::Auto;

use strict;
use warnings;
use Data::Dumper;

print __PACKAGE__. " loaded\n";

=head1 SYNOPSIS

    #inherit from this class to make methods available 
    package YourApp::Command; 
    use parent App::Cmd::Auto; #needs to be before the next line; 
    use App::Cmd::Setup -command 

    package YourApp::Command::init;
    #gives you a generic opt_spec method which gets global options specs and
    #calls local_opt_spec if you need something special in this command
    sub local_opt_spec{
        return 'foo'=>'bar';
    }

    #messages for convenience
    $self->error ($msg);   #alternative to usage_error without usage
    $self-internal_error($msg); #sets or returns $self->{error}
    $self->verbose ($msg);      #prints to STDOUT if $self->{verbose} is set

=method opt_spec

Provides a global method opt_spec that can be easily be inherited in each 
App::Cmd command. Of course, you can also override it. 

This version allows you to add command-specific option specifications if you
put a C<local_opt_spec> in your command:

  package YourApp;
  
  #attention quirk: don't use inbuilt global_opt_spec or bad things will happen!
  sub global_opt_specs {
      ['foo|f'=>'foo is bar'];
  }

  package YourApp::Command::init;
  
  sub local_opt_spec {
      'foo'=>'bar';
  }

=cut


sub opt_spec {
    my ($class, $app) = @_;

    #print "opt_spec\n";
    #not a typo: this is not App::Cmd's global_opt_spec
    my $call = \&{(ref $app) . '::global_opt_specs'};
    my @specs = defined &$call ? &$call : [];
    if ($class->can('local_opt_spec')) {
        push(@specs, $class->local_opt_spec($app));
    }
    return @specs;    #list of arrayref
}


#
# Convenience Messages
#

=method $self->internal_error($msg);

set or return internal error message (intended for programmer).

=cut

sub internal_error {
    my ($self, $msg) = @_;
    if ($msg) {
        $self->{error} = $msg;
    }
    else {
        return $self->{error};
    }
}


=method $self->error ($msg);

Prints error message for end user to STDOUT and exits with error. 
(Alternative to usage_error.)

Prepends 'Error: ' and ends with a newline.

=cut

sub error {
    my ($self, $msg) = @_;
    print "Error: $msg\n";
    exit 1;    #check
}


=method $self->verbose ($msg);

Prints messages to STDOUT in verbose mode. 

Adds a newline.

=cut

sub verbose {
    my ($self, $msg) = @_;
    if ($self->{verbose}) {
        my @caller = caller(1);
        print "$caller[3]\n  $msg\n\n";
    }
}


1;
