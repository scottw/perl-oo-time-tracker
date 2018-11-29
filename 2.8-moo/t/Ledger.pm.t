#!perl
use strict;
use warnings;
use Test::More;
use Ledger::Memory;

use_ok 'Ledger::Memory';

my $ledger = Ledger::Memory->new;
is_deeply $ledger->ledger, [], "empty ledger";

$ledger->append('foo');
is_deeply $ledger->ledger, ['foo'], "one item";

$ledger->append('bar');
is_deeply $ledger->ledger, ['foo', 'bar'], "two items";

my @list = ();
$ledger->scan(sub { push @list, shift });
is_deeply $ledger->ledger, \@list, "scan copy";

done_testing();
