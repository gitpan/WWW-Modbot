package WWW::Modbot::Server;

use warnings;
use strict;

use lib './lib'; # Locally defined server types can be added here.

=head1 NAME

WWW::Modbot::Server - models a server for the modbot

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

The C<WWW::Modbot::Server> object is largely a parent class for the specific server types.  It provides an API the modbot
uses when talking to a server.  Note that a physical server may very well have more than one "spam server" if there are multiple
tables containing spam-like substances.  For instance, the Scoop community server's primary spam source is comments, but story
submissions can also be spam, and there are even spam-like story tags.  So a Scoop server is modeled as three separate modbot
servers, sharing a single underlying database connection.

=head1 FUNCTIONS

=head2 new

Connects to a configured server.  Yes, this means that only configured servers can be connected to.  However, nobody says you
have to get your configuration from the modbot.conf file; you simply have to make sure that the C<$bot->{config}> hash has
the server defined and any variables defined that the server's specific type will need to establish the connection.

This looks for an implementation module in the local 'lib' directory first (under 'lib/Server') and, failing that, tries the
module's own list.  This lets you implement test environments and move server interface modules into production at will.
The local library overrides the system definition for this very reason.

=cut

sub new {
   my ($classname, $bot, $server) = @_;
   my $servertype = $bot->{config}->get("${server}_type");

   my $self;
   if (-e "lib/Server/$servertype.pm") {
      eval 'use Server::' . $servertype . '; $self = Server::'. $servertype . '->new();';
      if ($@) {
         warn "Unable to load custom server module '$servertype': $@";
         return undef;
      }
   }
   if (not defined $self and -e "$bot->{module}/Server/$servertype.pm") {
      eval 'use WWW::Modbot::Server::' . $servertype . '; $self = WWW::Modbot::Server::' . $servertype . '->new();';
      if ($@) {
         warn "Unable to load standard server module '$servertype': $@";
         return undef;
      }
   }
   if (not defined $self) {
      warn "No server module '$servertype' found.\n";
      return undef;
   }
   $self->connect($bot, $server);
   $bot->{servers}->{$server} = $self;
   return $self;
}

=head2 connect

C<connect> does nothing in this parent class, but it's used in the specific types to carry out the actual connection.

=cut

sub connect {
   print "Connecting dummy type\n";
}

=head2 get_config

C<get_config> gets the proper configuration value for the server in question.

=cut

sub get_config {
   my ($self, $key, $default) = @_;

   my $sname = $self->{name} . "_" . $key;

   my %varhash = $self->{bot}->{config}->varlist("^$sname\$");
   return $varhash{$sname} if defined $varhash{$sname};
   %varhash = $self->{bot}->{config}->varlist("^key\$");
   return $varhash{$key} if defined $varhash{$key};
   return $default;
}

=head2 scan_pending

C<scan_pending> scans the server for pending messages (whether spam or not).  It returns a hash reference, the keys of which
are the unique post IDs and the values of which are a descriptive string arbitrarily assigned by the server module.

=cut

sub scan_pending { return {}; }

=head2 get and get_post

C<get> retrieves a single post from a server given the post's unique ID.  It returns a hash reference.

C<get_post> does the same, but returns a L<WWW::Modbot::Post> object containing that hash reference.

=cut

sub get { return {}; }
sub get_post { return {}; }

=head2 can

C<can> is implemented in a normal server as C<server_can>, leaving C<can> defined here at the class level to ensure that
the semantics of canning spam include sending it to the archive configured for the bot.  Before archival, a post is
retrieved and C<judge> is called to calculate a score.

=cut

sub can {
   my ($self, $id) = @_;

   my $post = $self->get_post($id);
   my $score = $self->{bot}->judge($post);

   $self->{bot}->archive($post, $score);

   $self->server_can ($id);
}

=head2 scan

C<scan> is another helpful shell around specific server functionality.  It scans the pending posts on the server,
asks the bot to judge each one, and cans the spam above the configured threshold and approves it below the configured
approval threshold.  Anything left is left on the queue.

This is the workhorse function of the entire module, of course.

=cut

sub scan {
   my ($self) = @_;

   my $pending = $self->scan_pending();
   foreach my $id (keys %$pending) {
      my $post = $self->get_post($id);
      my $score = $self->{bot}->judge($post);

      if ($score > $self->get_config('threshold', 5)) {
         $self->{bot}->archive($post, $score);
         $self->server_can ($id);
         delete $$pending{$id};
      } elsif ($score < $self->get_config('approval_threshold', 0)) {
         $self->approve ($id);
         delete $$pending{$id};
      }
   }

   return $pending;
}

=head1 AUTHOR

Michael Roberts, C<< <michael at despammed.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-modbot at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Modbot>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Modbot


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Modbot>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Modbot>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Modbot>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Modbot/>

=back



=head1 COPYRIGHT & LICENSE

Copyright 2008 Vivtek, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of WWW::Modbot
