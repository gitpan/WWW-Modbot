use strict;
use warnings;
use ExtUtils::MakeMaker;

my @bin = ('bin/modbot');

WriteMakefile(
    NAME                => 'WWW::Modbot',
    AUTHOR              => 'Michael Roberts <michael@despammed.com>',
    VERSION_FROM        => 'lib/WWW/Modbot.pm',
    ABSTRACT_FROM       => 'lib/WWW/Modbot.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    EXE_FILES => \@bin,
    PREREQ_PM => {
        'Test::More' => 0,
        'AppConfig' => 0,
        'Term::Shell' => 0,    # This really wouldn't *have* to be required, but I would need to code around its absence if it weren't.
        'Scalar::Util' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WWW-Modbot-*' },
);
