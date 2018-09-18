package Tracker;
use Moo;
use strictures 2;
use Types::Standard qw/Int Str/;
use Timer;

has log_file => (is => 'ro', isa => Str, required => 1);

sub append_event {
    my ($self, $timer) = @_;

    open my $log, ">>", $self->log_file or die "Could not open '" . $self->log_file . "': $!\n";
    print $log $timer->to_csv . "\n";
    close $log;
}

sub summary {
    my $self = shift;

#    print STDERR "I AM BUILDING THE SUMMARY FOR YOU...\n";

    my %summary = ();

    open my $log, '<', $self->log_file or die "Could not open '" . $self->log_file . "': $!\n";
    while (my $entry = <$log>) {
        chomp $entry;
        my %rec = ();
        @rec{qw/start stop activity/} = split /,/ => $entry;
        my $timer = Timer->new(%rec);

        $summary{$timer->activity} ||= 0;
        $summary{$timer->activity} += $timer->duration;
    }
    close $log;

    return \%summary;
}

1;
