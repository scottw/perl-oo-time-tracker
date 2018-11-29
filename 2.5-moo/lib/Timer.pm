package Timer;
use strictures 2;
use Scalar::Util 'looks_like_number';

use Moo;
use namespace::clean;

sub BUILD {
    my ($self, $args) = @_;
    $self->start(defined $args->{start} ? $args->{start} : time);
    $self->activity(defined $args->{activity} ? $args->{activity} : '');
    $self->stop(defined $args->{stop} ? $args->{stop} : time);
}

sub start {
    my ($self, $start) = @_;

    if (defined $start) {
        die "Type error: integer expecte for 'start' value\n"
          unless looks_like_number($start);

        $self->{start} = $start;
    }

    $self->{start};
}

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
