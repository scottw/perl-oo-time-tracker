package Role::Serializable::CSV;
use Moo::Role;
use strictures 2;

sub to_csv {
    my $self = shift;
    join ',' => $self->start, $self->stop, $self->activity;
}

1;
