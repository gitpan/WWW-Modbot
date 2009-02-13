package WWW::Modbot::Server::Scoop;

use warnings;
use strict;
use base qw(WWW::Modbot::Server);
use WWW::Modbot::Post;
use DBI;
#use DBD::mysql;

=head1 NAME

WWW::Modbot::Server::Scoop - implementation of a Scoop server

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

This class implements a specific server type for the modbot.  See L<WWW::Modbot> for more information and L<WWW::Modbot::Server> for the
API to be implemented.

=cut

sub new {
   my ($classname) = @_;

   my $self = {};
   bless ($self, $classname);
   return $self;
}

sub connect {
   my ($self, $bot, $name) = @_;

   $self->{bot} = $bot;
   $self->{name} = $name;

   print "Connecting $name\n";
   $self->{db} = DBI->connect ("DBI:mysql:database=" . $self->get_config("host"),
                                                       $self->get_config("userid"),
                                                       $self->get_config("password"));
}

sub scan_pending {
   my ($self) = @_;

   my $ret = {};
   my $limit = $self->get_config("limit");
   $limit = 100 unless $limit;

   my $q = $self->{db}->prepare ("select sid, cid, subject from comments where left(commentip,1) != '+' limit $limit");
   $q->execute();
   my ($sid, $cid, $subject);
   $q->bind_columns(\$sid, \$cid, \$subject);

   while ($q->fetch()) {
      $ret->{"$sid-$cid"} = $subject;
   }

   return $ret;
}

sub get {
   my ($self, $post) = @_;

   my $ret = {'id'=>$post};
   $$ret{'id'} = $post;
   $$ret{'valid'} = 0;

   my ($sid, $cid) = split (/-/, $post);
   my $q = $self->{db}->prepare ("select date, subject, comment, commentip, uid from comments where sid='$sid' and cid='$cid'");
   $q->execute();

   my ($date, $subject, $comment, $commentip, $uid);
   $q->bind_columns (\$date, \$subject, \$comment, \$commentip, \$uid);

   unless ($q->fetch()) {
      return $ret;
   }
   $$ret{'valid'} = 1;

   $$ret{'subject'} = $subject;
   $$ret{'poster'} = $uid;
   $$ret{'email'} = '';
   $$ret{'date'} = $date;
   $$ret{'post'} = $comment;
   $$ret{'ip'} = $commentip;

   return $ret;
}

sub get_post {
   my ($self, $post) = @_;

   return WWW::Modbot::Post->new($self, $post);
}

sub server_can {
   my ($self, $post) = @_;

   my ($sid, $cid) = split (/-/, $post);
   my $q = $self->{db}->prepare ("delete from comments where sid='$sid' and cid='$cid'");
   $q->execute();
};

sub approve {
   my ($self, $post) = @_;

   my ($sid, $cid) = split (/-/, $post);
   my $q = $self->{db}->prepare ("update comments set commentip = concat('+', commentip) where sid='$sid' and cid='$cid'");
   $q->execute();
};


=head1 AUTHOR

Michael Roberts, C<< <michael at despammed.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Vivtek, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of WWW::Modbot::Server::Scoop
