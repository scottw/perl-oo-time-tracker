#!perl
use strict;
use warnings;
use Test::More;
use Data::Dumper;

use_ok 'Tracker';

{
    package LedgerMemory;
    use strict;
    use warnings;
    sub new { bless { ledger => [] } => shift }
    sub ledger { shift->{ledger} }
    sub append { push @{shift->ledger}, @_ }
    sub scan {
        my ($self, $sub) = @_;
        $sub->($_) for @{$self->ledger}
    }
}

package main;

my $tracker = Tracker->new(ledger => LedgerMemory->new);

my $time = time;

$tracker->append_event(Timer->new(start => $time-1200, activity => 'working', stop => $time-720));
$tracker->append_event(Timer->new(start => $time-720, activity => 'smoking', stop => $time-600));
$tracker->append_event(Timer->new(start => $time-600, activity => 'working', stop => $time-120));
$tracker->append_event(Timer->new(start => $time-120, activity => 'smoking', stop => $time));

is $tracker->summary->{smoking}, 240, "smoking summary";
is $tracker->summary->{working}, 960, "working summary";

done_testing();
exit;
