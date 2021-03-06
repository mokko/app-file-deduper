#ABSTRACT: Define profiles in the config file
package File::Dedupe::Profile;

our $spec = {
    #what to do with duplicates
    action => {    
        allow    => ['delete', 'link'],
        required => 1,
    },
    #plain text describing the profile for humans
    description => {    
        required => 0,
    },

    #directories and files which will be scanned for duplicates
    #dir: recursive directories
    #single_dir: dir non-recursively
    #file: single file
    input => {
        required => 1,
        allow    => [
            sub {
                my $var = shift;
                foreach my $hash (@{$var}) {
                    my %hash = %{$hash};
                    die "unrecognized input type: '" . (keys %hash)[0] . "'"
                      unless ($hash{dir} or $hash{single_dir} or $hash{file});
                }
                return 1;
            },
            $_
        ],
    },
    #which file in a set of duplicates survives
    selectmajor => {    
        allow   => ['lastModified', 'newest', 'oldest'],
        default => 'lastModified',
    },
    #todo. I could look for directories which are identical
    strategy => {       
        allow => ['file', 'dir'],    #optional, default 'file'
        default => 'file',
    }
};

=head1 PROFILE FORMAT

The profile is in YAML format, see L<http://www.yaml.org/>.

Each profile has a unique label that identifies it. Look into source for 
details. I tried to provide self-explaining comments.

1;
