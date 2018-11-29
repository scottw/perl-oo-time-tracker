package Tracker;
use strictures 2;
use Timer;
use Types::Standard qw(Object);

use Moo;
use namespace::clean;

has ledger => (is => 'ro', isa => Object, required => 1);

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
