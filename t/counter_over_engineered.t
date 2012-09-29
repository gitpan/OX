#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Path::Router;
use Plack::Test;
use Test::Requires 'Template', 'MooseX::Types::Path::Class', 'Path::Class';
use Path::Class;

BEGIN {
    use_ok('OX::Application');
}

use lib 't/apps/Counter-Over-Engineered/lib';

use Counter::Over::Engineered;

my $app = Counter::Over::Engineered->new;
isa_ok($app, 'Counter::Over::Engineered');
isa_ok($app, 'OX::Application');

#diag $app->_dump_bread_board;

my $root = $app->resolve( service => 'app_root' );
isa_ok($root, 'Path::Class::Dir');
is($root, file('t', 'apps', 'Counter-Over-Engineered')->stringify,
   '... got the right root dir');

my $router = $app->router;
isa_ok($router, 'Path::Router');

path_ok($router, $_, '... ' . $_ . ' is a valid path')
for qw[
    /
    /inc
    /dec
    /reset
    /set/10
];

routes_ok($router, {
    ''       => { controller => '/Controller/Root', action => 'index' },
    'inc'    => { controller => '/Controller/Root', action => 'inc'   },
    'dec'    => { controller => '/Controller/Root', action => 'dec'   },
    'reset'  => { controller => '/Controller/Root', action => 'reset' },
    'set/10' => { controller => '/Controller/Root', action => 'set',  number => 10 },
},
"... our routes are valid");

sub test_counter {
    my ($res, $count) = @_;

    ok($res->is_success)
        || diag($res->status_line . "\n" . $res->content);

    my $content = $res->content;

    like(
        $content,
        qr/<title>OX - Counter::Over::Engineered Example<\/title>/,
        "got the right title"
    );
    like(
        $content,
        qr/<h1>$count<\/h1>/,
        "got the right count"
    );

    my @paths = (
        '/inc',
        '/dec',
        '/reset',
        '/set/100',
        '/set/200',
        '/set/1000',
    );

    for my $path (@paths) {
        like(
            $content,
            qr{<a href="$path">},
            "link to $path exists"
        );
    }
}

test_psgi
      app    => $app->to_app,
      client => sub {
          my $cb = shift;
          {
              my $req = HTTP::Request->new(GET => "http://localhost");
              my $res = $cb->($req);
              test_counter($res, 0);
          }
          {
              my $req = HTTP::Request->new(GET => "http://localhost/inc");
              my $res = $cb->($req);
              test_counter($res, 1);
          }
          {
              my $req = HTTP::Request->new(GET => "http://localhost/inc");
              my $res = $cb->($req);
              test_counter($res, 2);
          }
          {
              my $req = HTTP::Request->new(GET => "http://localhost/dec");
              my $res = $cb->($req);
              test_counter($res, 1);
          }
          {
              my $req = HTTP::Request->new(GET => "http://localhost/reset");
              my $res = $cb->($req);
              test_counter($res, 0);
          }
          {
              my $req = HTTP::Request->new(GET => "http://localhost");
              my $res = $cb->($req);
              test_counter($res, 0);
          }
          {
              my $req = HTTP::Request->new(GET => "http://localhost/set/100");
              my $res = $cb->($req);
              test_counter($res, 100);
          }
          {
              my $req = HTTP::Request->new(GET => "http://localhost/dec");
              my $res = $cb->($req);
              test_counter($res, 99);
          }
          {
              my $req = HTTP::Request->new(GET => "http://localhost/set/foo");
              my $res = $cb->($req);
              is($res->code, 404, '... did not match, so got 404');
          }
      };


done_testing;
