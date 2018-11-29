package Role::Serializable::JSON;
use Moo::Role;
use strictures 2;
use JSON qw(encode_json decode_json);

requires 'pack', 'unpack';

sub freeze {
    my $self = shift;
    encode_json $self->pack;
}

sub thaw {
    my ($class, $json) = @_;
    $class->unpack(decode_json $json);
}

1;
