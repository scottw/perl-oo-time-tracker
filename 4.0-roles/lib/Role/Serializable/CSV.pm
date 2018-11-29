package Role::Serializable::CSV;
use Moo::Role;
use strictures 2;

with 'Role::Serializable';

sub freeze {
    my $self = shift;
    my $obj  = $self->pack;
    join ',' => map {"$_=$obj->{$_}"} sort keys %$obj;
}

sub thaw {
    my ($class, $data) = @_;
    my $rec = scalar { map { split /=/ } split /,/ => $data };
    $class->unpack($rec);
}

1;