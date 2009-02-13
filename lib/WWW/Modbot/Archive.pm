package WWW::Modbot::Archive;

use warnings;
use strict;

use lib './lib'; # Locally defined archive types can be added here.

=head1 NAME

WWW::Modbot::Archive - models a spam archive for the modbot

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

The C<WWW::Modbot::Archive> object is largely a parent class for the specific archive types.  It provides an API the modbot
uses when talking to a spam archive.  There is no generic spam archive; there are only subtypes (like the Test and Server
classes).

=head1 FUNCTIONS

=head2 new

Configures a spam archive.  This basically finds the type given and lets that class initialize itself.
=cut

sub new {
   my ($classname, $bot, $type) = @_;

   my $self;
   if (-e "lib/Archive/$type.pm") {
      eval 'use Archive::' . $type . '; $self = Archive::'. $type . '->new($bot);';
      if ($@) {
         warn "Unable to load custom archive module '$type': $@";
         return undef;
      }
   }
   if (not defined $self and -e "$bot->{module}/Archive/$type.pm") {
      eval 'use WWW::Modbot::Archive::' . $type . '; $self = WWW::Modbot::Archive::' . $type . '->new($bot);';
      if ($@) {
         warn "Unable to load standard archive module '$type': $@";
         return undef;
      }
   }
   if (not defined $self) {
      warn "No archive module '$type' found.\n";
      return undef;
   }
   return $self;
}


=head1 AUTHOR

Michael Roberts, C<< <michael at despammed.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-modbot at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Modbot>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 COPYRIGHT & LICENSE

Copyright 2009 Vivtek, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of WWW::Modbot::Archive
