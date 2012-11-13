package OX::Util;
BEGIN {
  $OX::Util::AUTHORITY = 'cpan:STEVAN';
}
{
  $OX::Util::VERSION = '0.06';
}
use strict;
use warnings;

# move to Path::Router?
sub canonicalize_path {
    my ($path) = @_;
    return join '/', map { /^\??:/ ? ':' : $_ } split '/', $path, -1;
}

=for Pod::Coverage
  canonicalize_path

=cut

1;
