#ABSTRACT: scan monitored directories
package App::Dedupe::Command::scan;
use strict;
use warnings;
use App::Dedupe -command;
use File::Representation::Deduper;
use Data::Dumper;
use Carp qw(confess);

#print __PACKAGE__." loaded\n";

#App::Dedupe::Auto::global_opt_specs looks for local_opt_spec
#sub local_opt_spec {
#    return (
#        ["test|t",  "test"],
#    );
#}

sub opt_spec {
    my $self = shift;
    return ["test|t", "test"];
}

sub validate_args {
    print "validate args\n";
}

sub execute {
    my ($self, $opts, $args) = @_;
    print "scan execute $opts $args\n";

    #$self->init($opts, $args);
    #print Dumper $self;
    #print Dumper $self->app->global_options;
    exit;

    #my $files=File::Representation::Deduper->new ();
    #my $files->scan;
}


sub description {
    <<EOF;
scans monitored directories
1) monitored directories are defined in the profile (input: dir/single).
2) walks over file system and updates the db-representation of the files 
   internally, so that after the scan the filesystem and db have the same
   status.

A scan is necessary to plan and carry out actions.
EOF
}

#load profile file

1;
