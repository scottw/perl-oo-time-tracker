package Tracker;
use strict;
use warnings;
use Timer;

my $log_file = 'log.txt';

sub new {
    my $class = shift;
    my $self  = {};
    my %args  = @_;

    bless $self => $class;

    $self->log_file($args{log_file});

    $self;
}

sub log_file {
    my ($self, $log_file) = @_;

    if (defined $log_file) {
        $self->{log_file} = $log_file;
    }

    return $self->{log_file};
}

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
