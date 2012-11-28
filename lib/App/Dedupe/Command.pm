#ABSTRACT: Abstract base class for App::Dedupe commands
package App::Dedupe::Command;
use strict;
use warnings;
use parent 'App::Cmd::Auto'; #needs to be before 'use App::Cmd::Setup -command';
use App::Cmd::Setup -command;
use App::Dedupe::ProfileDefinition;
use Data::Dumper;            #debugging
use YAML::Any qw(LoadFile);
use Params::Check qw(check last_error);

#print __PACKAGE__." loaded\n";

#this validate_args will be called in all commands unless locally overriden
sub validate_args {
    my ($self, $opts, $args) = @_;
    print "validate_args (and opts)\n";

    #show me what you got
    foreach my $opt (keys %{$opts}) {
        printf "  opt '%s': %s\n", $opt, $opts->{$opt};
    }

    #show me what you got
    my $msg = 'An argument begins with a dash. Unrecognized option?';
    foreach my $arg (@{$args}) {
        printf "  arg: %s\n", $arg;
        if ($arg =~ /^-/) {
            $self->error($msg);
        }
    }

    #$self->check_args($args);
    $self->{active_profiles} = $args;

}




#sub default_args {
#    return 'default', 'ree';
#}


#right now I call this from every command's execute which seems clumsy
sub init {
    my ($self, $opts, $args) = @_;
    print "Command init\n";
    foreach my $opt (keys %{$opts}) {
        printf "opt '%s': %s\n", $opt, $opts->{$opt};
    }

    #$self->loadConfig($opts, $args);
}


sub loadConfig {
    my ($self, $opts, $args) = @_;

    #default location of profile file
    my $profileFN = File::Spec->catfile($ENV{HOME}, '.deduper', 'profiles.yml');

    #overwrite location of profile file
    if ($opts->{config}) {
        $profileFN = $opts->{config};
    }

    #$self->verbose("Looking for config file at $profileFN");

    if (!-e $profileFN) {
        $self->error("Config file not found at '$profileFN'");
    }

    #verbose "About to load profile file $profileFN";
    my $profiles = LoadFile($profileFN);    #doesn't fail on error

    if (!$profiles) {
        $self->error("Problem loading profile");
    }

    #$self->verbose('Profile loaded');
    $Params::Check::ONLY_ALLOW_DEFINED = 1;

    foreach my $profileName (keys %{$profiles}) {

        my $specification = $App::Dedupe::ProfileDefinition::requiredDirectives;

        my $msg = "Config file does not validate at profile '$profileName'! ";
        check($specification, $profiles->{$profileName})
          or $self->error($msg . last_error());
    }
    $self->verbose("Profiles loaded and validated");

    my @aps = @{$self->{active_profile}};
    foreach my $ap (@aps) {
        my $msg = "Current profile '$ap' not found in configuration!";
        $self->error($msg) if (!$profiles->{$ap});
    }
    return $profiles;
}


1;
