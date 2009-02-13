package WWW::Modbot::Test::KnownUser;

use warnings;
use strict;
use base qw(WWW::Modbot::Test);

=head1 NAME

WWW::Modbot::Test::KnownUser - check a list of known users to see if this one appears there.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

The C<WWW::Modbot::Test::KnownUser> module is a L<WWW::Modbot::Test> implementation which can help support
anonymous posting on a forum.  See the W::M::Test module for more information about the API.

For a forum which allows entry of a username but doesn't require signon, the KnownUser test can be used
to relax the rules a little for posts which claim to be from a user we know.  This doesn't scale terribly
well, but it's a great way to preserve a small, informal forum without burying it under heaps of spam.

=head1 FUNCTIONS

=head2 new

The C<new> function doesn't really do anything, but if we don't provide one, Test.pm will try to call itself.

=cut

sub new {
   my ($classname) = @_;
   my $self = {};
   bless ($self, $classname);
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

   my $user = $self->{bot}->get_user ($$post{$field}, $post);

   $$post{'known_user'} = 1 if $user;

   return ("known_user");
}

sub describe { "test a specific field for plausible case changes" }

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
