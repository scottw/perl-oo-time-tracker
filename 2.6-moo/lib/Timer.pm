package Timer;
use strictures 2;
use Types::Standard qw/Int/;

use Moo;
use namespace::clean;

sub BUILD {
    my ($self, $args) = @_;
    $self->activity(defined $args->{activity} ? $args->{activity} : '');
    $self->stop(defined $args->{stop} ? $args->{stop} : time);
}

has start => (is => 'rw', isa => Int, default => sub {time});

sub stop {
    my ($self, $stop) = @_;

    if (defined $stop) {
        $self->{stop} = $stop;

        ## trigger
        $self->duration($self->stop - $self->start);
    }

    return $self->{stop};
}

sub duration {
    my ($self, $duration) = @_;

    if (defined $duration) {
        $self->{duration} = $duration;
    }

    $self->{duration};
}

sub activity {
    my ($self, $activity) = @_;

    if (defined $activity) {
        $self->{activity} = $activity;
    }

    $self->{activity};
}

sub to_csv {
    my $self = shift;
    join ',' => $self->start, $self->stop, $self->activity;
}

1;
