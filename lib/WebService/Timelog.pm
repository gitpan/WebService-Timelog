package WebService::Timelog;

use strict;
use warnings;
use Carp qw(croak);

use URI;
use LWP::UserAgent;
use XML::Simple qw(XMLin);

our $VERSION  = '0.02';

sub new {
    my ($class, %conf) = @_;

    croak('Both username and password required')
        if !$conf{username} || !$conf{password};

    my $self = bless {
        apiurl   => 'http://api.timelog.jp/',
        apihost  => 'api.timelog.jp:80',
        apirealm => 'This URI is required authentication',
        %conf,
    }, $class;

    my $ua = LWP::UserAgent->new(agent => __PACKAGE__ . "/$VERSION");
       $ua->credentials(@{$self}{qw(apihost apirealm username password)});

    $self->{ua} = $ua;
    return $self;
}

sub ua { shift->{ua} }

sub new_msg {
    my ($self, %args) = @_;
    return $self->_dispatch_request('post', 'new.asp', \%args);
}

sub update {
    my ($self, $text) = @_;
    return $self->new_msg(text => $text);
}

sub public_msg {
    my ($self, %args) = @_;
    return $self->_dispatch_request('get', 'public_msg.asp', { %args, fmt => 'xml' });
}

sub friends_msg {
    my ($self, %args) = @_;
    return $self->_dispatch_request('get', 'friends_msg.asp', { %args, fmt => 'xml' });
}

sub direct_msg {
    my ($self, %args) = @_;
    return $self->_dispatch_request('get', 'direct_msg.asp', { %args, fmt => 'xml' });
}

sub friends {
    my ($self, %args) = @_;
    return $self->_dispatch_request('get', 'friends.asp', { %args, fmt => 'xml' });
}

sub show {
    my $self = shift;
    return $self->_dispatch_request('get', 'show.asp', { fmt => 'xml' });
}

sub _dispatch_request {
    my ($self, $method, $path, $args) = @_;
    my $res = do {
        if ($method eq 'get') {
            my $uri = URI->new($self->{apiurl});
               $uri->path($path);
               $uri->query_form($args);

            $self->ua->get($uri);
        }
        elsif ($method eq 'post'){
            $self->ua->post($self->{apiurl} . $path, $args);
        }
    };

    croak(sprintf "%s: %s", $res->code, $res->message)
        if $res->is_error;

    return $method eq 'get' ? XMLin($res->content, ForceArray => [qw(entry)], KeyAttr => [qw(entry)])
                            : $res->content
                            ;
}

1;

__END__

=head1 NAME

WebService::Timelog - A Perl interface to Timelog API

=head1 SYNOPSIS

  use WebService::Timelog;

  my $timelog = WebService::Timelog->new(
      username => $username,
      password => $password,
  );

  # update status
  $timelog->new_msg(text => $text);

  # or you can do so like this
  $timelog->update($text);

  # retrieve public messages
  my $public_messages  = $timelog->public_msg(cnt => $count, since => $since);

  # retrieve friends' messages
  my $friends_messages = $timelog->friends_msg(cnt => $count, since => $since);

  # retrieve direct messages
  my $direct_messages  = $timelog->direct_msg(cnt => $count);

  # retrieve some information on you
  my $me               = $timelog->show();

  # retrieve some informtion on your friends
  my $friends          = $timelog->friends(cnt => $count);

=head1 DESCRIPTION

Timelog is one of so-called microblogs like Twitter. This module
provides an easy way to communicate with it.

B<NOTE>: The interfaces this module offers can be changed later along
with Timelog API's updates.

=head1 METHODS

=head2 new ( I<%conf> )

=over 4

  my $timelog = WebService::Timelog->new(
      username => $username,
      password => $password,
  );

Creates and returns a new WebService::Timelog object.

Both username and password are required. If not passed in, it will
croak immediately.

=back

=head2 new_msg ( I<%args> )

=over 4

  $timelog->new_msg(text => $text);

Updates your status.

Make sure that it will croak immediately, if request failed. It's also
applicable to the methods described below.

=back

=head2 update ( I<$text> )

=over 4

  $timelog->update($text);

This method is an alias for new_msg() described above, but the
argument takes a different form from new_msg(). It's to make
consistent with the same name one of L<Net::Twitter>.

=back

=head2 public_msg ( I<%args> )

=over 4

  my $public_messages = $timelog->public_msg(cnt => $count, since => 200705170900);

Retrieves Timelog messages in public. For more details, consult the
official documentation of Timelog API.

=back

=head2 friends_msg ( I<%args> )

=over 4

  my $friends_messages = $timelog->friends_msg(cnt => $count, since => 200705170900);

Retrieves your friends' messages.

=back

=head2 direct_msg ( I<%args> )

=over 4

  my $direct_messages = $timelog->direct_msg(cnt => $count);

Retrieves direct messages sent to you.

=back

=head2 show ()

=over 4

  my $me = $timelog->show();

Retrieve some information on you.

=back

=head2 friends ( I<%args> )

=over 4

  my $friends = $timelog->friends(cnt => $count);

Retrieve some information on your friends.

=back

=head2 ua ()

=over 4

  $timelog->ua(timeout => 10);

This method returns LWP::UserAgent object internally used in the
WebService::Timelog object. You can set some other options which are
specific to LWP::UserAgent via this method.

=back

=head1 SEE ALSO

=over 4

=item * Official Timelog API documentation

L<http://timelog.jp/api.asp>

=back

=head1 AUTHOR

Kentaro Kuribayashi E<lt>kentaro@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE (The MIT License)

Copyright (c) 2007, Kentaro Kuribayashi E<lt>kentaro@cpan.orgE<gt>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=cut
