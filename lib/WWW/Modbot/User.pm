package WWW::Modbot;

use warnings;
use strict;

=head1 NAME

WWW::Modbot - tools to moderate Web-based spam

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

The modbot project is (yet another) attempt to collect heuristics for judging the spamminess of posts made through the Web, and to provide an easy-to-use
metric and reporting tool for posts.

The WWW::Modbot module packages this into a generally accessible point of call, while the modbot.pl script can be scheduled from the command line
to perform periodic scans of post lists which have not been written with the modbot in mind.


    use WWW::Modbot;

    my $foo = WWW::Modbot->new();
    ...

=head1 FUNCTIONS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
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
