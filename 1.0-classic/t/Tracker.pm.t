#!perl
use strict;
use warnings;
use Test::More;

use Timer;

use_ok 'Tracker';

unlink 'ledger.txt';
my $tracker = Tracker->new(ledger_file => 'ledger.txt');

my $time = time;

$tracker->append_event(Timer->new(start => $time-1200, activity => 'working', stop => $time-720));
$tracker->append_event(Timer->new(start => $time-720, activity => 'smoking', stop => $time-600));
$tracker->append_event(Timer->new(start => $time-600, activity => 'working', stop => $time-120));
$tracker->append_event(Timer->new(start => $time-120, activity => 'smoking', stop => $time));

is $tracker->summary->{smoking}, 240, "smoking summary";
is $tracker->summary->{working}, 960, "working summary";

done_testing();
exit;
