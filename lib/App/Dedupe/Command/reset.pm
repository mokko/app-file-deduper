#ABSTRACT: drops the database for current profile
package App::Dedupe::Command::reset;
use strict;
use warnings;
use App::Dedupe -command;
use Pod::Usage;

sub validate_args{};
sub execute {

    #system "perldoc $0"
    pod2usage(
        {   -exitval => 1,
            -verbose => 2,
        }
    );
}

sub _description {}
1;
