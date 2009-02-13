package WWW::Modbot::Test::GoogleCount;

use warnings;
use strict;
use base qw(WWW::Modbot::Test);
use LWP;



=head1 NAME

WWW::Modbot::Test::GoogleCount - look up an IP on Google to see if it turns up suspiciously often.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

The C<WWW::Modbot::Test::GoogleCount> module is a L<WWW::Modbot::Test> implementation which looks at a text
field and looks it up on Google to see if it appears too often.  See the W::M::Test module for more information about the API.

A great deal of forum spam is posted using proxies or botnet zombies.  These IPs, since they are used to post vast amounts of
forum spam, often appear on Google with hit counts of thousands of pages.  This is a very useful metric for spam discovery.

=head1 FUNCTIONS

=head2 new

The C<new> function doesn't really do anything, but if we don't provide one, Test.pm will try to call itself.

=cut

sub new {
   my ($classname) = @_;
   my $self = {};
   bless ($self, $classname);
   $self->{ua} = LWP::UserAgent->new;
   $self->{ua}->agent("modbot: GoogleCount");
   return $self;
}

=head2 test

All Test modules have only one function, C<test>.  It's passed a hashref containing the fields of the post, and
a field name which need not be used.  The function sets one or more fields in the hashref which are then
evaluated by the ruleset to arrive at a score.  The return value is a list of the fields set by the function
(this makes testing of modules easier).

=cut

sub test {
   my ($self, $post, $field) = @_;
   $field = 'ip' unless $field;

   $$post{'google_count'} = '' unless $$post{$field};
   my $req = HTTP::Request->new(GET => "http://www.vivtek.com/google_count?p=$$post{$field}");
   my $res = $self->{ua}->request($req);

   if ($res->is_success) {
      foreach my $line (split /\n/, $res->content) {
         if ($line =~ /count: (\d+)/) {
            $$post{'google_count'} = $1;
            #print "$$post{'ip'} -> $$post{'google_count'}\n";
            return ('google_count');
         }
      }
   }

   $$post{'google_count'} = '';

   return ('google_count');
}

sub describe { "look up an IP on Google to check whether it appears suspiciously often" }

=head1 AUTHOR

Michael Roberts, C<< <michael at despammed.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-modbot at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Modbot>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2008 Vivtek, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of WWW::Modbot::Test::TextPlausibility
