#ABSTRACT: Identify and deal with duplicate files from the command line
package App::Dedupe;
use strict;
use warnings;
use App::Cmd::Setup -app;

#print __PACKAGE__." loaded\n";

#verbose is not available here...
sub usage_desc {

    #print "usage_desc\n";
    my $self = shift;
    my $name = $self->arg0;
    return "$name <command>  [-short --long-options arguments] <profile>";
}



#global_opt_specs is defined in App::Cmd::Auto
sub global_opt_specs {
    return
      ["verbose|v",  "log additional output"],
      ["config|c:s", "alternative profiles file"];
}


1;
