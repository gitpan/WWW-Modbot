package WWW::Modbot::Test::RussianChars;

use warnings;
use strict;
use base qw(WWW::Modbot::Test);

=head1 NAME

WWW::Modbot::Test::RussianChars - check for high bits set in characters in a field.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

The C<WWW::Modbot::Test::RussianChars> module is a L<WWW::Modbot::Test> implementation which looks at a text
field and flags too high a number of 8-bit ASCII characters.  See the W::M::Test module for more information about the API.

Clearly, if your forum actually has Russian posts or posts in other languages which predominantly use high-bit characters
(those with ASCII values greater than 127) then you'll want to disable this test.  But given the popularity of Xrumer, Web
spam is especially vulnerable to Russian-language spam, and this test can be pretty effective in screening it out.

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

   my $d = $$post{$field};
   $d =~ s/<.*?>//g;
   $d =~ s/[a-zA-Z]/a/g;
   $d =~ s/[\xc0-\xff]/r/g;
   $d =~ s/[0-9]/9/g;

   my %chars;
   $chars{'a'} = 0;
   $chars{'r'} = 0;
   $d =~ s/(.)/$chars{$1}++;$1/eg;

   $$post{"$field-russian"} = sprintf ("%3.2f", $chars{'r'} + $chars{'a'} ? ($chars{'r'} * 1.0) / ($chars{'r'} + $chars{'a'}) : 0.0);

   return ("$field-russian");
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

1; # End of WWW::Modbot::Test::RussianChars
