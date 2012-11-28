package App::Dedupe::ProfileDefinition;

#ABSTRACT: Define profiles in the config file

our $requiredDirectives = {
    action => {    #what to do with duplicates
        allow    => ['delete', 'link'],
        required => 1,
    },
    description => {    #a plain text description of the profile
        required => 0,
    },
    input => {          #either "dir" (recursive directories) or "single" for

        #non-recursive directories or files
        required => 1,
        allow    => [
            sub {
                my $var = shift;
                foreach my $hash (@{$var}) {
                    my %hash = %{$hash};
                    die "unrecognized input type: '" . (keys %hash)[0] . "'"
                      unless ($hash{dir} or $hash{single});
                }
                return 1;
            },
            $_
        ],
    },
    logger => {    #Todo. Specify log level. Defaults to "error"
        allow   => ['info', 'warn', 'error', 'debug', '...'],
        default => 'error',
    },
    selectmajor => {    #which file in a set of duplicates survives
        allow   => ['lastModified', 'newest', 'oldest'],
        default => 'lastModified',
    },
    strategy => {       #todo. I could look for directories which are identical

        # but presently I look only for identical files
        allow => ['file', 'dir'],    #optional, default 'file'
        default => 'file',
    }
};

=head1 PROFILE FORMAT

The profile is in YAML format, see L<http://www.yaml.org/>.

Each profile has a unique label that identifies it. Look into source for 
details. I tried to provide self-explaining comments.

1;
