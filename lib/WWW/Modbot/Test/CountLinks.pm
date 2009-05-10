package WWW::Modbot::Test::CountLinks;

use warnings;
use strict;
use base qw(WWW::Modbot::Test);
use Net::DNS;



=head1 NAME

WWW::Modbot::Test::CountLinks - count link-like text in a given field.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.02';


=head1 SYNOPSIS

The C<WWW::Modbot::Test::CountLinks> module is a L<WWW::Modbot::Test> implementation which looks at a text
field and counts the things in it that look like links.  See the W::M::Test module for more information about the API.

It knows about HTML, simple text http: links, and [url]-type links.

=head1 FUNCTIONS

=head2 new

The C<new> function doesn't really do anything, but if we don't provide one, Test.pm will try to call itself.

=cut

sub new {
   my ($classname) = @_;
   my $self = {};
   bless ($self, $classname);

   $self->{dns} = Net::DNS::Resolver->new(recurse=>1, tcp_timeout=>5, udp_timeout=>5);
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
   $field = 'post' unless $field;

   my $field_spec = '';
   if ($field =~ /^!/) {
      $field =~ s/^!//;
      $field_spec = $field . "-";
   }

   my @return_fields = ($field_spec . 'word_count',    $field_spec . 'link_count', $field_spec . 'nxdomains',
                        $field_spec . 'mixed_links', $field_spec . 'link_bait');

   my @l;

   my $fixed = $$post{$field};
   $fixed =~ s/%3c/</ig;
   $fixed =~ s/%3d/=/ig;
   $fixed =~ s/%3e/>/ig;
   $fixed =~ s/%3a/:/ig;
   $fixed =~ s/%2f/\//ig;
   $fixed =~ s/%2d/-/ig;

   $$post{$field_spec . 'word_count'} = scalar (@l = split / /, $fixed);
   $fixed .= ' ';
   my $link = $$post{'link'} || '';
   $link =~ s/\\/\\\\/g;
   $link =~ s/\[/\\[/g;
   $link =~ s/\+/\\+/g; # 2009-02-08 - oops.  Isn't there a regexp quoter?  TODO: look for that.

   if (defined $$post{'link'}) {
      $$post{$field_spec . 'link_in_body'} = 0;  $$post{$field_spec . 'link_in_body'} = 1 if $$post{'link'} && $fixed =~ /$link/;
      push @return_fields, $field_spec . 'link_in_body';
   }
   if (defined $$post{'image'} || defined $$post{'link'}) {
      $$post{$field_spec . 'image_is_link'} = 0; $$post{$field_spec . 'image_is_link'} = 1 if $$post{'image'} && ($$post{'image'} eq $$post{'link'});
      push @return_fields, $field_spec . 'image_is_link';
   }

   my $b = scalar (@l = split /\[\/url\]/, $fixed) - 1;
   my $h = scalar (@l = split /http:\/\//, $fixed) - 1;
   my $l = scalar (@l = split /\[link .*?\]/, $fixed) - 1;
   my $a = scalar (@l = split /<\/a>/, $fixed) - 1;

   $l = $a if $a > $l;
   $l = $b if $b > $l;
   $l = $h if $h > $l;

   if ($b > 0 && $a > 0) { $$post{$field_spec . 'mixed_links'} = 1; } else { $$post{$field_spec . 'mixed_links'} = 0; }

   $$post{$field_spec . 'link_count'} = $l;

   $$post{$field_spec . 'link_bait'} = 0;
   if ($a) {
      $fixed =~ s/<a .*?\/a>//g;
      my $words;
      if ($fixed eq '') {
         $words = 0;
      } else {
         $words = scalar (@l = split / /, $fixed);
      }
      if ($words < 2 || $words < $l * 2) {
         $$post{$field_spec . 'link_bait'} = 1;
      }
   }
   $$post{$field_spec . 'link_bait'} = 1 if $$post{$field_spec . 'link_count'} and
                                            $$post{$field_spec . 'word_count'} < $$post{$field_spec . 'link_count'} + 1;

   $$post{$field_spec . 'nxdomains'} = 0;
   foreach $link ($fixed =~ /(http:\/\/[^ \n]*)/) {
      my $domain = $1;
      $domain =~ s/^http:\/\///;
      $domain =~ s/\/.*$//;
      my $dnsq = $self->{dns}->search($domain);
      if (not $dnsq) {
         $$post{$field_spec . 'nxdomains'} += 1 if ($self->{dns}->errorstring eq 'NXDOMAIN');
      }
   }
   if ($$post{$field_spec . 'nxdomains'}) {
      $$post{$field_spec . 'nxdomains'} = $$post{$field_spec . 'nxdomains'} * 1.0 / $$post{$field_spec . 'link_count'};
   }

   return (@return_fields);
}

sub describe { "count link-like things in a text field" }

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

1; # End of WWW::Modbot::Test::CountLinks
