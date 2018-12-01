package Ledger::File;
use strict;
use warnings;

sub new {
    my $class = shift;
    my $self  = {};
    my %args  = @_;

    bless $self => $class;

    die "Required attribute 'ledger_file' missing\n" unless $args{ledger_file};

    $self->ledger_file($args{ledger_file});

    $self;
}

sub ledger_file {
    my ($self, $ledger_file) = @_;

    if (defined $ledger_file) {
        $self->{ledger_file} = $ledger_file;
    }

    $self->{ledger_file};
}

sub append {
    my ($self, $string) = @_;

    open my $fh, ">>", $self->ledger_file
      or die "Unable to open '" . $self->ledger_file . "' for append: $!\n";
    chomp $string;
    print $fh $string . "\n";

    close $fh;
}

sub scan {
    my ($self, $sub) = @_;

    open my $fh, "<", $self->ledger_file
      or die "Unable to open '" . $self->ledger_file . "' for read: $!\n";
    while (my $line = <$fh>) {
        chomp $line;
        $sub->($line);
    }
    close $fh;
}

1;
