package OX::Types;
BEGIN {
  $OX::Types::AUTHORITY = 'cpan:STEVAN';
}
{
  $OX::Types::VERSION = '0.10';
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
