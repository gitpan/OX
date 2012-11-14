
use strict;
use warnings;

use 5.010;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "the hardest working two letters in Perl",
  "AUTHOR" => "Stevan Little <stevan.little at iinteractive.com>, Jesse Luehrs <doy at cpan dot org>",
  "BUILD_REQUIRES" => {
    "File::Find" => 0,
    "File::Temp" => 0,
    "HTTP::Request" => 0,
    "HTTP::Request::Common" => 0,
    "Path::Router" => 0,
    "Plack::App::Path::Router::PSGI" => 0,
    "Plack::Component" => 0,
    "Plack::Middleware" => 0,
    "Plack::Test" => 0,
    "Test::Fatal" => 0,
    "Test::More" => "0.88",
    "Test::Path::Router" => 0,
    "Test::Requires" => 0,
    "utf8" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "OX",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "OX",
  "PREREQ_PM" => {
    "Bread::Board" => 0,
    "Bread::Board::Container" => 0,
    "Bread::Board::Declare" => "0.11",
    "Bread::Board::LifeCycle::Singleton" => 0,
    "Carp" => 0,
    "Class::Load" => "0.10",
    "List::MoreUtils" => 0,
    "Moose" => "2.0200",
    "Moose::Exporter" => 0,
    "Moose::Role" => 0,
    "Moose::Util" => 0,
    "Moose::Util::TypeConstraints" => 0,
    "Plack" => "1.0012",
    "Plack::App::Path::Router::Custom" => "0.05",
    "Plack::App::URLMap" => 0,
    "Plack::Middleware::Conditional" => 0,
    "Plack::Middleware::HTTPExceptions" => 0,
    "Plack::Util" => 0,
    "Scalar::Util" => 0,
    "Try::Tiny" => 0,
    "Web::Request" => "0.05",
    "Web::Response" => 0,
    "namespace::autoclean" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.07",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



