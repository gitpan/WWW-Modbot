package WWW::Modbot::Server::WebBBS_fs;

use warnings;
use strict;
use base qw(WWW::Modbot::Server);
use WWW::Modbot::Post;
use POSIX qw(strftime);
#use DBD::mysql;

=head1 NAME

WWW::Modbot::Server::WebBBS_fs - implementation of a WebBBS server through the file system

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
   $self->{msgdir} = $self->get_config('msgdir');
}

# Expects: data directory --> $modbot_msgdir
# Under WebBBS, files with all-digit names are posts; anything else can and should be disregarded.
sub scan_pending {
   my ($self) = @_;

   opendir L, $self->{msgdir};
   my @ret = sort { $a <=> $b } grep { $_ } map {if (-e "$self->{msgdir}/ok_$_") { 0 } else { $_ }} grep /^\d+$/, readdir (L);
   closedir L;
   my $ret = {};
   foreach my $m (@ret) {
      my $f = $self->get ($m);
      $$ret{$m} = $f->{subject} . " (" . $f->{poster} . ")"; 
   }

   return $ret;
}

# A WebBBS post (in full)
#SUBJECT>WYDAUsSzfG
#POSTER>Mkosiegj
#EMAIL>razer22@yahoo.com
#DATE>1210540171
#EMAILNOTICES>no
#IP_ADDRESS>85.214.51.251
#PREVIOUS>
#NEXT>
#IMAGE>http://groups.google.us/group/o-hotsexmovies
#LINKNAME>http://groups.google.us/group/o-hotsexmovies
#LINKURL>http://groups.google.us/group/o-hotsexmovies
#<P>perfect design thanks <a href=" http://groups.google.us/group/o-hotsexmovies ">asian rape porn</a> =OOO


sub get {
   my ($self, $post) = @_;

   my $ret = {'id'=>$post};
   $$ret{'id'} = $post;
   $$ret{'valid'} = 0;

   open P, "$self->{msgdir}/$post" or return ($ret);
   $$ret{'valid'} = 1;
   $$ret{'post'} = '';

   while (<P>) {
      if ($$ret{'post'}) {
         $$ret{'post'} .= $_;
      } else {
         chomp;
         my ($field, $value) = split (/>/, $_, 2);
         if ($field eq '<P') {
            $$ret{'post'} = "$value\n";
         } elsif ($field eq 'SUBJECT') {
            $$ret{'subject'} = $value;
         } elsif ($field eq 'POSTER') {
            $$ret{'poster'} = $value;
         } elsif ($field eq 'EMAIL') {
            $$ret{'email'} = $value;
         } elsif ($field eq 'DATE') {
            $$ret{'date'} = strftime ('%Y-%m-%d %H:%M:%S', localtime($value));
         } elsif ($field eq 'IP_ADDRESS') {
            $$ret{'ip'} = $value;
         } elsif ($field eq 'LINKURL') {
            $$ret{'link'} = $value;
         } elsif ($field eq 'LINKNAME') {
            $$ret{'linktitle'} = $value;
         } elsif ($field eq 'IMAGE') {
            $$ret{'image'} = $value;
         }
      }
   }
   close P;

   return $ret;
}

sub get_post {
   my ($self, $post) = @_;

   return WWW::Modbot::Post->new($self, $post);
}

sub server_can {
   my ($self, $post) = @_;

   system "rm $self->{msgdir}/$post";
   system "rm $self->{msgdir}/ok_$post" if -e "$self->{msgdir}/ok_$post";
   system "rm $self->{msgdir}/messages.idx" if -e "$self->{msgdir}/messages.idx";
};

sub approve {
   my ($self, $post) = @_;

   open OK, ">$self->{msgdir}/ok_$post";
   print OK "ok\n";
   close OK;
};


=head1 AUTHOR

Michael Roberts, C<< <michael at despammed.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Vivtek, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of WWW::Modbot::Server::Scoop
