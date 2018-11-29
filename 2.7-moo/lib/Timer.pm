package Timer;
use strictures 2;
use Types::Standard qw/Int Str/;

use Moo;
use namespace::clean;

sub BUILD {
    my ($self, $args) = @_;
    $self->stop(defined $args->{stop} ? $args->{stop} : time);
}

has start    => (is => 'rw',  isa => Int, default => sub {time});
has activity => (is => 'rw',  isa => Str, default => sub {''});
has duration => (is => 'rwp', isa => Int, default => sub {0});

sub stop {
    my ($self, $stop) = @_;

    if (defined $stop) {
        $self->{stop} = $stop;

        ## trigger
        $self->_set_duration($self->stop - $self->start);
    }

    return $self->{stop};
}

sub to_csv {
    my $self = shift;
    join ',' => $self->start, $self->stop, $self->activity;
}

1;
