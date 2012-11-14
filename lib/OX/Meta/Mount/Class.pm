package OX::Meta::Mount::Class;
BEGIN {
  $OX::Meta::Mount::Class::AUTHORITY = 'cpan:STEVAN';
}
{
  $OX::Meta::Mount::Class::VERSION = '0.07';
}
use Moose;
use namespace::autoclean;

extends 'OX::Meta::Mount';

has class => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has dependencies => (
    is       => 'ro',
    isa      => 'HashRef',
    required => 1,
);

__PACKAGE__->meta->make_immutable;

1;