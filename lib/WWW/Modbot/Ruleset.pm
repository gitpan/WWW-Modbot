package WWW::Modbot::Ruleset;

use warnings;
use strict;

=head1 NAME

WWW::Modbot::Ruleset - a class for ruleset functionality (calls successive tests and returns a composite score)

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS


=head1 FUNCTIONS

=head2 new

C<new> takes a reference to the bot and the name of a ruleset.  It loads the text of the ruleset from the configuration
structure, then returns.

=cut

sub new {
   my ($classname, $bot, $name) = @_;

   my $self = {};
   bless ($self, $classname);
   $self->{bot} = $bot;
   $self->{name} = $name;
   $name .= '_ruleset' if $name;
   $name = 'ruleset' unless $name;
   $self->{rules} = $bot->{config}->get($name);
   return $self;
}

=head2 judge

C<judge> runs the specified series of tests against a post (a hashref of fields) and returns the score calculated.

=cut

sub judge {
   my ($self, $post) = @_;

   my $spam = 0;
   # Apply rules, in order.
   foreach my $rule (split /\n/, $self->{rules}) {
      my $this = $rule;
      if ($rule =~ /^!/) { # Tool application
         $this =~ s/^! *//;
         my ($test, $rest) = split / *: */, $this;
         $self->{bot}->test ($post, $test, $rest);
      } elsif ($rule =~ /^\?/) { # Value test
         $this =~ s/^\? *//;
         my ($comp1, $action) = split / *: */, $this;
         my ($field, $comp, $value) = split / +/, $comp1;
         my $take_action = 0;
         if ($comp eq ">") {
            $post->{post}->{$field} = 0 unless $post->{post}->{$field};
            if ($post->{post}->{$field} > $value) { $take_action = 1; }
         } elsif ($comp eq "<") {
            if (not defined ($post->{post}->{$field}) or ($post->{post}->{$field} < $value)) { $take_action = 1; }
         }

         my $multiplier = 1;
         if ($take_action) {
            if ($action =~ /\*/) {
               $multiplier = $post->{post}->{$field};
            }
            if ($action =~ /\+ *(\d+)/) {
               $spam += $1 * $multiplier;
            } elsif ($action =~ /- *(\d+)/) {
               $spam -= $1 * $multiplier;
            }
         }
      }
   }

   return $spam;
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
