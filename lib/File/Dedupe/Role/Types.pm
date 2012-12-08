package File::Dedupe::Role::Types;
use Moose::Role;
use Moose::Util::TypeConstraints;

subtype 'FileExists',
  as 'Str',
  where { -f $_ },
  message {"The file $_ does not exist"};

1;
