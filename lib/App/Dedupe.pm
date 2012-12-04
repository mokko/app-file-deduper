#ABSTRACT: Identify and deal with duplicate files from the command line
package App::Dedupe;
use strict;
use warnings;
use App::Cmd::Setup -app;
use Data::Dumper; #debugging
print __PACKAGE__. " loaded\n";

#verbose is not available here...
sub usage_desc {
    my $self=shift;
    print "usage_desc $self\n";

    #my $self   = shift;
    return "%c <command> %o <profile>";
}

=method global_opt_spec

App::Cmd allows you to set global_opt_spec for global options. But it doesn't
allow you to access them in validate_args ($self,$opts,$args). Instead it seems
to require you to use $self->app->global_options. Let's use the existing
App::Cmd mechanism instead of making our own. Just saying.

  package YourApp::Command::Init;
  sub validate_args {
      my ($self,$local_opts,$args)=@_;
      my $global_opts=$self->app->global_options;
      
      if ($global_opts->{verbose}) {
          #do something
      }
  } 

=cut

sub global_opt_spec {
    print "global_opt_spec\n";
    #my $self = shift;
    #my $gopts= $self->global_options; #not yet available
    
    return
      ["verbose|v",  "print additional output to STDOUT"],
      ["config|c:s", "alternative profiles file"];

}
1;
