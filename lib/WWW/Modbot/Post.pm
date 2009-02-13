package WWW::Modbot::Post;

use warnings;
use strict;

=head1 NAME

WWW::Modbot::Post - tools to moderate Web-based spam

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

The C<WWW::Modbot::Post> module encapsulates post-specific functionality for the modbot (primarily
display and testing).

=head1 FUNCTIONS

=head2 new

The C<new> function takes a reference to the server whose post this is, and the ID of the post.
We can also simply pass in a hash reference to work with posts that aren't using the regular
Modbot server mechanisms.

=cut

sub new {
   my ($classname, $server, $source) = @_;
   my $self = {};
   bless ($self, $classname);
   if (defined $source) {
      $self->{server} = $server;
      $self->{post} = $server->get($source);
   } else {
      $self->{server} = "none";
      $self->{post} = $server;
   }

   return $self;
}

=head2 test

C<test> runs a single test against the post.

=cut

sub test {
   my ($self, $test, $field) = @_;
   return $test->test($self->{post}, $field);
}

=head2 judge

C<judge> runs a ruleset against the post and assigns a spam score.

=cut

sub judge {
   my ($self, $ruleset) = @_;
   return $ruleset->judge($self);
}

=head2 as_text

C<as_text> returns a string containing a multi-line text representation of the post.

=cut

sub as_text {
   my ($self) = shift;

   my $text = "";
   foreach my $key ('id', 'subject', 'poster', 'email', 'date', 'ip') {
      $self->{post}->{$key} = '' unless defined $self->{post}->{$key};
   }
   $text .= "ID        : $self->{post}->{'id'}\n";
   $text .= "Subject   : $self->{post}->{'subject'}\n";
   $text .= "Poster    : $self->{post}->{'poster'}\n";
   $text .= "Email     : $self->{post}->{'email'}\n";
   $text .= "Date      : $self->{post}->{'date'}\n";
   $text .= "IP        : $self->{post}->{'ip'}\n";
   foreach my $key (sort keys %{$self->{post}}) {
      if ($key ne 'id' && $key ne 'subject' && $key ne 'poster' && $key ne 'email' && $key ne 'date' && $key ne 'ip' && $key ne 'post' && $key ne 'valid') {
         $text .= "$key : $self->{post}->{$key}\n" if $self->{post}->{$key} ne '';
      }
   }
   if (defined $self->{score}) {
      $text .= "score     : $self->{score}\n";
   } else {
      $text .= "score not calculated\n";
   }
   $text .= "\n";
   $text .= "$self->{post}->{'post'}\n";
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
