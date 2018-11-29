package Tracker;
use strict;
use warnings;
use Timer;

sub new {
    my $class = shift;
    my $self  = {};
    my %args  = @_;

    bless $self => $class;

    $self->ledger($args{ledger});  ## something that 'does' ledger-ing

    $self;
}

sub ledger {
    my ($self, $ledger) = @_;

    if (defined $ledger) {
        $self->{ledger} = $ledger;
    }

    $self->{ledger};
}

sub append_event {
    my ($self, $timer) = @_;

    $self->ledger->append($timer->to_csv);
}

sub summary {
    my $self = shift;

    my %summary = ();

    $self->ledger->scan(
        sub {
            my $entry = shift;
            my %rec  = ();
            @rec{qw/start stop activity/} = split /,/ => $entry;
            my $timer = Timer->new(%rec);

            $summary{$timer->activity} ||= 0;
            $summary{$timer->activity} += $timer->duration;
        }
    );

    return \%summary;
}

1;
