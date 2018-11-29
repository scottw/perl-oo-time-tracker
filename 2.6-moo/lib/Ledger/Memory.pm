package Ledger::Memory;
use strict;
use warnings;

sub new { bless { ledger => [] } => shift }
sub ledger { shift->{ledger} }
sub append { push @{shift->ledger}, @_ }
sub scan {
    my ($self, $sub) = @_;
    $sub->($_) for @{$self->ledger};
}

1;
