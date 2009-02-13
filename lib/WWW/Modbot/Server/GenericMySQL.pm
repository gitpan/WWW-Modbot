package WWW::Modbot::Server::GenericMySQL;

use warnings;
use strict;
use base qw(WWW::Modbot::Server);
use WWW::Modbot::Post;
use DBI;
#use DBD::mysql;

=head1 NAME

WWW::Modbot::Server::GenericMySQL - generic MySQL spam source

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

   $self->{table} = $self->get_config("table", 'comments');
   foreach my $f ('id', 'subject', 'spam_ok', 'post', 'poster', 'email', 'ip', 'date') {
      $self->{$f} = $self->get_config($f . '_col', $f);
   }
   my @ec = split /[, ]+/, $self->get_config ('extra_columns');
   $self->{extra_columns} = \@ec;
   $self->{can_action} = $self->get_config('can_action', 'delete');
}

sub scan_pending {
   my ($self) = @_;

   my $ret = {};
   my $limit = $self->get_config("limit");
   $limit = 100 unless $limit;

   my $q = $self->{db}->prepare ("select $self->{id}, $self->{subject} from $self->{table} where $self->{spam_ok}=0 limit $limit");
   $q->execute();
   my ($id, $subject);
   $q->bind_columns(\$id, \$subject);

   while ($q->fetch()) {
      $ret->{$id} = $subject;
   }

   return $ret;
}

sub get {
   my ($self, $post) = @_;

   my $ret = {'id'=>$post};
   $$ret{'id'} = $post;
   $$ret{'valid'} = 0;

   my @columns = ();
   foreach my $f ('subject', 'post', 'poster', 'email', 'date') {
      push @columns, $self->{$f};
   }
   foreach my $f (@{$self->{extra_columns}}) {
      push @columns, $f;
   }
   my $q = $self->{db}->prepare ("select " . join (', ', @columns) . " from $self->{table} where $self->{id}=?");
   $q->execute($post);

   my $rec = $q->fetchrow_hashref();
   unless ($rec) {
      return $ret;
   }
   $$ret{'valid'} = 1;

   foreach my $f ('subject', 'poster', 'email', 'date', 'post', 'ip') {
      $$ret{$f} = $$rec{$self->{$f}};
      $$ret{$f} = '' unless defined $$ret{$f};
   }
   foreach my $f (@{$self->{extra_columns}}) {
      $$ret{$f} = $$rec{$f};
      $$ret{$f} = '' unless defined $$ret{$f};
      $$ret{$f} =~ s/\n/~m~/g;
   }

   return $ret;
}

sub get_post {
   my ($self, $post) = @_;

   return WWW::Modbot::Post->new($self, $post);
}

sub server_can {
   my ($self, $post) = @_;

   my $q;
   if ($self->{can_action} eq 'delete') {
      $q = $self->{db}->prepare ("delete from $self->{table} where $self->{id}=?");
      $q->execute($post);
   } else {
      $q = $self->{db}->prepare ("update $self->{table} set $self->{spam_ok}=? where $self->{id}=?");
      $q->execute($self->{can_action}, $post);
   }
};

sub approve {
   my ($self, $post) = @_;

   my $q = $self->{db}->prepare ("update $self->{table} set $self->{spam_ok}=1 where $self->{id}=?");
   $q->execute($post);
};


=head1 AUTHOR

Michael Roberts, C<< <michael at despammed.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Vivtek, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of WWW::Modbot::Server::Scoop
