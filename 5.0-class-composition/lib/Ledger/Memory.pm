package Ledger::Memory;
use strictures 2;
use Types::Standard qw(ArrayRef);

use Moo;
use namespace::clean;

with 'Role::Ledger';

has ledger => (is => 'ro', isa => ArrayRef, default => sub { [] });

sub append {
    push @{shift->ledger}, @_;
}

sub scan {
    my ($self, $sub) = @_;
    $sub->($_) for @{$self->ledger};
}

1;
