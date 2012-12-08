#ABSTRACT: Load and validate File::Dedupe config data
package File::Dedupe::Role::Config;

use strict;
use warnings;

#use Moose::Util::TypeConstraints;
use YAML::Any qw(LoadFile);
use Params::Check;
use File::Dedupe::Profile;
use Carp qw(confess);
use Moose::Role;
with 'File::Dedupe::Role::Logger';
with 'File::Dedupe::Role::Types';
use Data::Dumper;    #debugging


=head1 SYNOPSIS

    #in File::Dedupe or App::Dedupe
    use File::Dedupe::Config;
    my $config=File::Dedupe->new( #loads & validates config
        file=>$fn, debug=>1
    ); 


What should config do on failure? I can warn, croak, confess. I think this 
class shouldn't talk to the end user directly. So none of the above. It's a 
moose object, so it returns an object. Should we package an error inside the
object ($self->error)?
    
=attr file

    config file location, e.g /home/You/conf.yml 

=cut

has 'config_file' => (
    is       => 'ro',
    isa      => 'FileExists',
    required => 1
);

has 'config' => (
    is      => 'ro',
    isa     => 'HashRef',
    builder => '_build_config',
    lazy    => 1
);

sub _build_config {
    my $self = shift;

    #load config, check if it is good, and return it as object.
    my $config;
    if (!$self->{config_file}) {
        $self->log_fatal('Need a config file!');
    }
    $self->log_debug('About to load config file:' . $self->{config_file});
    $config = LoadFile($self->{config_file});

    if (!$config) {
        $self->log_fatal(
            ["Profile file '%s' wasn't loaded", $self->{config_file}]);
    }

    #validate each profile except main
    my $spec = $File::Dedupe::Profile::spec;
    foreach my $profile (keys %{$config}) {
        next if ($profile eq 'main');
        if (!Params::Check::check($spec, $config->{$profile}, 1)) {
            $self->log_fatal(["Profile file '%s' does not validate", $profile]);
        }
        $self->log_debug("profile '$profile' validates");
    }

    #$self->log(Dumper $config);

    #check if active profile is defined
    if (!defined $config->{$self->active_profile}) {
        $self->log_fatal(
            [   "active profile '%s' not included in configuration file",
                $self->active_profile
            ]
        );
    }
    return $config;    #builder needs return value
}

=attr active_profile

read-only attribute which describes the currently active (selected) profile. 
There can be only one profile active at a time. File::Dedupe will run only this
profile although it knows also the configuration of other profiles.    
    
=cut

has 'active_profile' => (
    is      => 'ro',
    isa     => 'Str',
    default => 'default',

#    required => 1,
);


=method my $href=$self->active_config;

Returns the config hashref for the currently defined profile.

=cut

sub active_config {
    return $_[0]->{config}{$_[0]->active_profile};
}

1;

