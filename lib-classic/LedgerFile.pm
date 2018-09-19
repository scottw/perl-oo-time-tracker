package LedgerFile;
use strict;
use warnings;

sub new {
    my $class = shift;
    my $self  = {};
    my %args  = @_;

    bless $self => $class;

    die "Required attribute 'log_file' missing\n" unless $args{log_file};

    $self->log_file($args{log_file});

    $self;
}

sub log_file {
    my ($self, $log_file) = @_;

    if (defined $log_file) {
        $self->{log_file} = $log_file;
    }

    $self->{log_file};
}

sub append {
    my ($self, $string) = @_;

    open my $fh, ">>", $self->log_file or die "Unable to open '" . $self->log_file . "' for append: $!\n";
    chomp $string;
    print $fh $string . "\n";

    close $fh;
}

sub scan {
    my ($self, $sub) = @_;

    open my $fh, "<", $self->log_file or die "Unable to open '" . $self->log_file ."' for read: $!\n";
    while (my $line = <$fh>) {
        $sub->($line);
    }
    close $fh;
}

1;
