package Role::Serializable;
use Moo::Role;
use strictures 2;
use Carp 'croak';

requires qw(freeze thaw);

with 'Role::Packable';

1;
