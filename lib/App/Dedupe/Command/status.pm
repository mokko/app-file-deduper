#ABSTRACT: lists status of monitored directories
package App::Dedupe::Command::status;
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
1;
