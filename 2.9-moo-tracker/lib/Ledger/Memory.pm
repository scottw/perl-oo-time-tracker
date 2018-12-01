package Ledger::Memory;
use strict;
use warnings;

sub new { bless { ledger => [] } => shift }
sub _ledger { shift->{ledger} }
sub append { push @{shift->_ledger}, @_ }
sub scan {
    my ($self, $sub) = @_;
    $sub->($_) for @{$self->_ledger};
}

1;
