package WWW::Modbot::Test;

use warnings;
use strict;

=head1 NAME

WWW::Modbot::Test - a convenient module to organize spamminess tests for forum posts.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

=head1 FUNCTIONS

=head2 list_tests

The C<list_tests> function returns a list of the specific test modules known to the system.

=cut

sub list_tests {
   my ($classname, $bot) = @_;

   my $list = {};
   opendir D, "$bot->{module}/Test";
   my @mods = grep /\.pm$/, readdir (D);
   closedir D;

   foreach my $m (@mods) {
      my $d;
      $m =~ s/\.pm$//;
      eval 'use WWW::Modbot::Test::' . $m . '; $d = WWW::Modbot::Test::' . $m . '->describe();';
      warn $@ if $@;
      $list->{$m} = $d;
   }

   opendir D, "lib/Test/";
   @mods = grep /\.pm$/, readdir (D);
   closedir D;

   foreach my $m (@mods) {
      my $d;
      $m =~ s/\.pm$//;
      eval 'use Test::' . $m . '; $d = Test::' . $m . '->describe();';
      warn $@ if $@;
      $list->{$m} = $d;
   }

   return $list;
}

=head2 new

The C<new> function, of course, instantiates a new test object for the current bot.  Like the
Server interface modules, Test modules can reside either in the local 'lib/Test' directory or
be installed in the module's own directory.  This allows custom tests and a test/production
setup, as locally defined test modules override the system-wide definitions.

=cut

sub new {
   my ($classname, $bot, $test) = @_;

   my $self;
   if (-e "lib/Test/$test.pm") {
      eval 'use Test::' . $test . '; $self = Test::'. $test . '->new();';
      if ($@) {
         warn "Unable to load custom test module '$test': $@";
         return undef;
      }
   }
   if (not defined $self and -e "$bot->{module}/Test/$test.pm") {
      eval 'use WWW::Modbot::Test::' . $test . '; $self = WWW::Modbot::Test::' . $test . '->new();';
      if ($@) {
         warn "Unable to load standard test module '$test': $@";
         return undef;
      }
   }
   if (not defined $self) {
      warn "No test module '$test' found.\n";
      return undef;
   }
   $self->{bot} = $bot;
   $bot->{tests}->{$test} = $self;
   return $self;
}


=head2 describe

The C<describe> function must be overridden by each test implementation, and returns a string
describing the function for use in the shell.

=cut

sub describe { "no description" }

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
