package OX::Application::Role::Sugar;
BEGIN {
  $OX::Application::Role::Sugar::AUTHORITY = 'cpan:STEVAN';
}
{
  $OX::Application::Role::Sugar::VERSION = '0.04';
}
use Moose::Role;
use namespace::autoclean;

use Bread::Board;
use Plack::App::URLMap;

sub BUILD { }
after BUILD => sub {
    my $self = shift;

    my $manual_router_config = $self->has_service('RouterConfig')
        ? $self->resolve(service => 'RouterConfig')
        : {};
    my $sugar_router_config = $self->meta->router_config;

    container $self => as {
        service RouterConfig => {
            %$manual_router_config,
            %$sugar_router_config,
        };
    };
};

around build_middleware => sub {
    my $orig = shift;
    my $self = shift;

    my @middleware = map { $self->_resolve_middleware($_) }
                         $self->meta->middleware;

    return [
        @{ $self->$orig(@_) },
        @middleware,
    ];
};

sub _resolve_middleware {
    my $self = shift;
    my ($mw_spec) = @_;

    my ($mw, $deps) = ($mw_spec->{middleware}, $mw_spec->{deps});

    my %common = (
        name   => '__ANON__',
        parent => $self,
    );
    my $mw_service;
    if (!ref($mw)) {
        $mw_service = Bread::Board::ConstructorInjection->new(
            %common,
            class        => $mw,
            dependencies => $deps,
        );
    }
    elsif (blessed($mw)) {
        $mw_service = Bread::Board::Literal->new(
            %common,
            value => $mw,
        );
    }
    else {
        $mw_service = Bread::Board::BlockInjection->new(
            %common,
            block        => sub {
                my $s = shift;
                return sub {
                    my $app = shift;
                    return $mw->($app, $s);
                };
            },
            dependencies => $deps,
        );
    }

    return $mw_service->get;
}

around build_app => sub {
    my $orig = shift;
    my $self = shift;

    my $app = $self->$orig(@_);
    return $app unless $self->meta->has_mounts;

    my $urlmap = Plack::App::URLMap->new;

    for my $mount ($self->meta->mounts) {
        if (exists $mount->{app}) {
            $urlmap->map($mount->{path} => $mount->{app});
        }
        elsif (exists $mount->{class}) {
            my $class = $mount->{class};
            my %deps = %{ $mount->{dependencies} };

            my $service = Bread::Board::ConstructorInjection->new(
                name         => '__ANON__',
                class        => $mount->{class},
                dependencies => $mount->{dependencies},
                parent       => $self,
            );
            my $app = $service->get;
            $urlmap->map($mount->{path} => $app->to_app);
        }
        else {
            die "Unknown mount spec for path $mount->{path}";
        }
    }

    $urlmap->map('/' => $app)
        unless $self->meta->has_mount_for('/');

    return $urlmap->to_app;
};

around to_app => sub {
    my $orig = shift;
    my $self = shift;

    return $self->$orig(@_)
        unless $self->meta->has_middleware_dependencies;

    # need to re-resolve for every request, to ensure that middleware
    # dependencies are correct - otherwise, a middleware that depends on a
    # service in an app will only resolve it once, at to_app time
    return sub {
        my ($env) = @_;
        $self->$orig(@_)->($env);
    };
};


1;

__END__
=pod

=head1 NAME

OX::Application::Role::Sugar

=head1 VERSION

version 0.04

=for Pod::Coverage BUILD

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

