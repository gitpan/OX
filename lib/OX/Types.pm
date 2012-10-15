package OX::Types;
BEGIN {
  $OX::Types::AUTHORITY = 'cpan:STEVAN';
}
{
  $OX::Types::VERSION = '0.05';
}
use strict;
use warnings;

use Class::Load 'load_class';
use Moose::Util::TypeConstraints;

class_type('Plack::Middleware');
subtype 'OX::Types::MiddlewareClass',
     as 'Str',
     where { load_class($_); $_->isa('Plack::Middleware') };
subtype 'OX::Types::Middleware',
     as 'CodeRef|OX::Types::MiddlewareClass|Plack::Middleware';

1;

__END__
=pod

=head1 NAME

OX::Types

=head1 VERSION

version 0.05

=head1 AUTHORS

=over 4

=item *

Stevan Little <stevan.little at iinteractive.com>

=item *

Jesse Luehrs <doy at cpan dot org>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Infinity Interactive.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

