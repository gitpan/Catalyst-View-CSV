use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Catalyst::View::CSV',
    AUTHOR              => 'Travis Chase <gaudeon@cpan.org>',
    VERSION_FROM        => 'lib/Catalyst/View/CSV.pm',
    ABSTRACT_FROM       => 'lib/Catalyst/View/CSV.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'Text::CSV' => '1.00',
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Catalyst-View-CSV-*' },
);
