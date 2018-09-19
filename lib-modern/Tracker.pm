package Tracker;
use Moo;
use strictures 2;
use Types::Standard qw/Int Object/;
use Timer;

has ledger => (is => 'ro', isa => Object, required => 1);

sub append_event {
    my ($self, $timer) = @_;

    $self->ledger->append($timer->to_csv);
}

sub summary {
    my $self = shift;

#    print STDERR "I AM BUILDING THE SUMMARY FOR YOU...\n";

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
