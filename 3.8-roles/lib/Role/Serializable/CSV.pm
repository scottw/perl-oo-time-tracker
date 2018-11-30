package Role::Serializable::CSV;
use Moo::Role;
use strictures 2;

requires 'pack', 'unpack';

sub freeze {
    my $self = shift;
    my $ref  = $self->pack;
    join ',' => map {"$_=$ref->{$_}"} sort keys %$ref;
}

sub thaw {
    my ($class, $data) = @_;
    my $rec = scalar { map { split /=/ } split /,/ => $data };
    $class->unpack($rec);
}

1;
