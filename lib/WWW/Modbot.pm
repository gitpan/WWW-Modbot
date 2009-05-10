package WWW::Modbot;

use warnings;
use strict;
use AppConfig qw(:argcount);

=head1 NAME

WWW::Modbot - Tools to automoderate Web-based spam

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.02';
$WWW::Modbot::version = $VERSION;

use WWW::Modbot::Archive;
use WWW::Modbot::Server;
use WWW::Modbot::Test;
use WWW::Modbot::Ruleset;

=head1 SYNOPSIS

The modbot project is (yet another) attempt to collect heuristics for judging the spamminess of posts made through the Web, and to provide an easy-to-use
metric and reporting tool for posts.

The F<WWW::Modbot> module packages this into a generally accessible point of call to allow new code to judge posts for spamminess,
while the C<modbot> script can be scheduled from the command line to perform periodic scans of post lists which have not been written
with the modbot in mind.


    use WWW::Modbot;

    my $foo = WWW::Modbot->new();
    ...

=head1 FUNCTIONS

=head2 new

=cut

sub new {
   my $class_name = shift;
   my $self = {};
   bless $self, $class_name;

   # Init here.
   $self->{init_file} = shift || 'modbot.conf';
   if (-e $self->{init_file}) {
      $self->{config} = AppConfig->new({CREATE=>1, GLOBAL => { ARGCOUNT => ARGCOUNT_ONE }});
      $self->{config}->define ("servers=s\@");
      $self->{config}->file($self->{init_file});
      $self->{init} = 1;

      #my %varlist = $self->{config}->varlist('.*');
      #foreach (keys %varlist) {
      #   print "$_ " . $varlist{$_} . "\n";
      #}
   }

   $self->{rulesets} = {};
   my %ruleset_list = $self->{config}->varlist('ruleset$');
   foreach my $rs (keys %ruleset_list) {
      $rs =~ s/_*ruleset$//;
      $self->{rulesets}->{$rs} = WWW::Modbot::Ruleset->new($self, $rs);
   }
   $self->{rulesets}->{''} = '' unless $self->{rulesets}->{''};

   $self->{servers} = {};
   $self->{tests} = {};

   $self->{module} = $INC{'WWW/Modbot.pm'};
   $self->{module} =~ s/\.pm$//;

   $self->{archive} = WWW::Modbot::Archive->new($self, $self->{config}->get('archive_type'));

   return $self;
}

=head2 servers

C<servers> lists the servers configured for the present bot.

=cut

sub servers {
   my $self = shift;
   return @{$self->{config}->servers};
}

=head2 connect

C<connect> connects to a server configured for the bot.  If you supply an unknown name, it's an error.
C<connect> only connects once, and stores the connection.  If you ask for the connection again, you get
the stored connection.

=cut

sub connect {
   my ($self, $server) = @_;
   return 0 unless $self->{config}->get("${server}_type");
   return $self->{servers}->{$server} if $self->{servers}->{$server};
   return WWW::Modbot::Server->new ($self, $server);
}

=head2 list_tests

C<list_tests> returns a list of test names from the Test directory.  It just fronts for the same function in
the Test module.

=cut

sub list_tests {
   my ($self) = @_;
   return WWW::Modbot::Test->list_tests($self);
}

=head2 load_test

C<load_test> loads a test module and caches it to avoid duplication of effort.

=cut

sub load_test {
   my ($self, $test) = @_;
   return $self->{tests}->{$test} if $self->{tests}->{$test};
   return WWW::Modbot::Test->new ($self, $test);
}

=head2 test
C<test> calls a specific test by name on a Post object provided.

=cut

sub test {
   my ($self, $post, $testname, $field) = @_;
   my $test = $self->load_test($testname);
   return $post->test($test, $field);
}

=head2 get_user

C<get_user> retrieves a user record from the userbase associated with a given server.

=cut

sub get_user { return ''; }

=head2 ruleset

C<ruleset> retrieves the ruleset object for the server named.

=cut

sub ruleset {
   my ($self, $server) = @_;
   return $self->{rulesets}->{$server} if defined $self->{rulesets}->{$server};
   return $self->{rulesets}->{''};
}

=head2 judge

C<judge> takes a Post object, retrieves the ruleset appropriate to its server, and runs that ruleset against the post.

=cut

sub judge {
   my ($self, $post) = @_;
   my $ruleset = $self->ruleset($post->{server}->{name});
   return $post->judge($ruleset);
}

=head2 archive

C<archive> takes a post and a score, and archives the post to the archive configured for the bot.

=cut

sub archive {
   my ($self, $post, $score) = @_;
   return $self->{archive}->archive($post, $score);
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
