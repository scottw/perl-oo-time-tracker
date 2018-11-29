package Tracker;
use strict;
use warnings;
use Timer;

sub new {
    my $class = shift;
    my $self  = {};
    my %args  = @_;

    bless $self => $class;

    $self->ledger_file($args{ledger_file});

    $self;
}

sub ledger_file {
    my ($self, $ledger_file) = @_;

    if (defined $ledger_file) {
        $self->{ledger_file} = $ledger_file;
    }

    return $self->{ledger_file};
}

sub append_event {
    my ($self, $timer) = @_;

    open my $log, ">>", $self->ledger_file or die "Could not open '" . $self->ledger_file . "': $!\n";
    print $log $timer->to_csv . "\n";
    close $log;
}

sub summary {
    my $self = shift;

    my %summary = ();

    open my $log, '<', $self->ledger_file or die "Could not open '" . $self->ledger_file . "': $!\n";
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
