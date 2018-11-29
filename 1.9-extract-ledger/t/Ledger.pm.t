#!perl
use strict;
use warnings;
use Test::More;
use Ledger::File;

use_ok 'Ledger::File';

unlink 'ledger.txt';
my $ledger = Ledger::File->new(ledger_file => 'ledger.txt');

$ledger->append('foo');
$ledger->append('bar');

my @list = ();
$ledger->scan(sub { push @list, shift });
is_deeply \@list,  ['foo', 'bar'], "scan ledger";

done_testing();
