package WWW::Modbot::Archive::HTTP;

use warnings;
use strict;
use base qw(WWW::Modbot::Archive);
use WWW::Modbot::Post;
use LWP;

=head1 NAME

WWW::Modbot::Archive::HTTP - implements a spam archive as an HTTP POST URL.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

This class implements a specific archive type for the modbot.  See L<WWW::Modbot> for more information and L<WWW::Modbot::Archive> for the
API to be implemented.

=cut

sub new {
   my ($classname, $bot) = @_;

   my $self = {};
   bless ($self, $classname);
   $self->{ua} = LWP::UserAgent->new;
   $self->{ua}->agent("modbot: Archive::HTTP");
   $self->{bot} = $bot;
   $self->{url} = $self->{bot}->{config}->get('archive_url');

   return $self;
}

sub archive {
   my ($self, $p, $score) = @_;
   my $post = $p->{post};
   my $key;

   my %form;
   $form{'spam'} = "board: $p->{server}->{name}\n";
   foreach $key ('id', 'subject', 'poster', 'email', 'date', 'ip') {
      $post->{$key} = '' unless defined $post->{$key};

      $form{'spam'} .= "$key: $$post{$key}\n";
   }
   foreach $key (sort keys %$post) {
      unless (grep {$key eq $_} ('id', 'subject', 'poster', 'email', 'date', 'ip', 'post', 'valid')) {
         $form{'spam'} .= "$key: $$post{$key}\n";
      }
   }
   $form{'spam'} .= "score: $score\n";
   $form{'spam'} .= "\n";
   $form{'spam'} .= $$post{'post'};
   $form{'spam'} .= "\n";

   $self->{ua}->post($self->{url}, \%form);
}


=head1 AUTHOR

Michael Roberts, C<< <michael at despammed.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Vivtek, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of WWW::Modbot::Archive::HTTP
