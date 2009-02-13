package WWW::Modbot::Test::TextPlausibility;

use warnings;
use strict;
use base qw(WWW::Modbot::Test);

=head1 NAME

WWW::Modbot::Test::TextPlausibility - score a post and field based on some text plausbility metrics.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

The C<WWW::Modbot::Test::TextPlausibility> module is a L<WWW::Modbot::Test> implementation which looks at a text
field and rates the probability that it is text.  See the W::M::Test module for more information about the API.

The plausibility check might detect titles of the nature wXuDFeSzwCF (I'm sure you've seen a few) by looking at the
number of spaces and vowels in a word, the number of case shifts (upper to lower or back), and letter frequency.
Obviously, it will work best with English words, but any alphabetic language should meet the criteria it likes.

You might have to disable it if your forum is in Chinese or Japanese.  I'd be interested in any input.

In actuality, it's currently just looking at case switches.  This might still be a problem with the DBCS languages,
but I don't actually know.  It works well in English, though.

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

In the case of C<TextPlausbility>, the field named is the one evaluated, and the return value is C<$field-casesw>.
More could be done (in particular, letter frequency should be a valuable consideration) but even looking at
case switches only turned out to be pretty effective against the titles being used last time I looked at the
statistics.

=cut

sub test {
   my ($self, $post, $field) = @_;

   my @letters = split //, $$post{$field};

   my $uc = 0.5;
   my $ct = 0;
   my $letters = 0;
   my $minletters = 1000;
   my $max = 0;
   my $words = 1;
   foreach my $letter (@letters) {
      if ($letter =~ /[A-Za-z]/) {
         $letters += 1;
         if ($letter eq lc($letter)) {
            if ($uc) {
               $uc = 0;
               $ct += 1;
               $max = $ct if $ct > $max;
            }
         } else {
            if (!$uc) {
               $uc = 1;
               $ct += 1;
               $max = $ct if $ct > $max;
            }
         }
      } elsif ($ct) {
         $minletters = $letters if $letters < $minletters;
         $uc = 0.5; $ct = 0; $words += 1; $letters = 0;
      }
   }
   $minletters = $letters if $letters < $minletters;

   $$post{"$field-casesw"} = $max;

   return ("$field-casesw");
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
