#!/usr/bin/perl
#ABSTRACT: CLI Frontend for App::Dedupe
#PODNAME: dedupe
use strict;
use warnings;
use App::Dedupe;
App::Dedupe->run;
print __FILE__." loaded\n";

=head1 SYNOPSIS

    #If no profile is specified, 'default' is assumed.
    dedupe <command> [-short --long_options arguments] <profile>

    #more info
    dedupe command         #list available commands
    dedupe man             #manual; same as 'perldoc dedupe'
    dedupe help <command>  #short info on each command

    #important commands
    dedupe status #see where you are
    dedupe scan   #scan monitored directories
    dedupe plan   #show planned actions
    dedupe do     #carry out plan



=head1 GLOBAL OPTIONS

Use 'dedupe help <command>' for more complete info on all available options.

(Options work only where they make sense, so technically they not quite 
global.)

=over 

=item -c | --config config.yml 

Path to alternative configuration file.

=item -v | --verbose

Print more info on what you're doing to STDOUT.

=back



=head1 PROFILES

Dedupe looks for a configuration file in L<YAML> format with info on profiles 
at $HOME/.dedupe/config.yml.

Alternatively, use the option '--config path/to/config.yml' option to 
specify a different file.
    
Each profile contains the 
information on a set of files and/or directories which will be scanned for
duplicates. The configuration may contain multiple profiles. 

See example configuration 'profiles.yml' and the profile specification at
lib/App/Dedupe/ProfileDefinition.pm for more details.


=head1 TODO

Too many todos at this time to list them all. This is a random selection.

=over

=item Different identities

There should be a way to choose the algorithm which determins identity.
I like identity based on checksums, but name, date etc. can be useful on 
occasion.

=back

