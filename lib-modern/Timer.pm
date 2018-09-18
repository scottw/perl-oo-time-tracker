package Timer;
use Moo;
use strictures 2;
use Types::Standard qw/Int Str/;

has start => (is => 'rw', isa => Int, default => sub { time });
has stop => (
    is      => 'rw',
    isa     => Int,
    trigger => sub {
        my $s = shift;
        $s->_set_duration($s->stop - $s->start);
    },
    default => sub { time }
);
has duration => (is => 'rwp', isa => Int, default => 0);
has activity => (is => 'rw', isa => Str, default => '');

sub to_csv {
    my $self = shift;
    join ',' => $self->start, $self->stop, $self->activity;
}

1;
