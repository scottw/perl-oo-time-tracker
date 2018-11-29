#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Timer;
use Benchmark;

timethis(
    200_000,
    sub {
        my $t = Timer->new();
        $t->start(time - 100);
        $t->stop(time);
        $t->activity('something');
        return $t->to_csv;
    },
);

exit;
