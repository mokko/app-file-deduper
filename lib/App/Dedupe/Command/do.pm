#ABSTRACT: carries out the plan
package App::Dedupe::Command::do;
use strict;
use warnings;
use App::Dedupe -command;
use Data::Dumper;

sub validate_args { 
    my ($self, $opts, $args) = @_;
    print "do::validate_args:$opts\n";
    foreach my $opt (keys %{$opts}) {
        printf "  opt '%s': %s\n", $opt, $opts->{$opt};
    }
    
}

sub opt_spec {
    return (
        ["test|t",  "test"],
    );
}

sub execute {
    my ($self, $opts, $args) = @_;

    print "DUMPER(execute):".Dumper $opts . "\n";
    if ($opts->{verbose}) {
        print "verbose exists\n";
    }
    foreach my $opt (keys %{$opts}) {
        printf "  opt '%s': %s\n", $opt, $opts->{$opt};
    }

    my $msg = 'An argument begins with a dash. Unrecognized option?';
    foreach my $arg (@{$args}) {
        printf "  arg: %s\n", $arg;
        if ($arg =~ /^-/) {
            die ($msg);
        }
    }

}
1;
