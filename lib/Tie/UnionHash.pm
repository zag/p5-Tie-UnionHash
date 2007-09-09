package Tie::UnionHash;

=head1 NAME

 Tie::UnionHash -  Union hashes.

=head1 SYNOPSIS

    use Tie::UnionHash;

   tie %hashu, 'Tie::UnionHash', \%hash1ro,\%hash2ro, \%hash2rw;

=head1 DESCRIPTION

 
 
=cut

use strict;
use warnings;
use strict;
use Carp;
use Data::Dumper;
require Tie::Hash;
use Objects::Collection::Base;
@Tie::UnionHash::ISA = qw(Tie::StdHash);
$Tie::UnionHash::VERSION = '0.01';

attributes qw( _orig_hashes _for_write __temp_array);


sub Init {
    my ( $self, @hashes ) = @_;
    $self->_for_write($hashes[ -1 ]);
    $self->_orig_hashes(\@hashes);
    return 1;
}




sub _init {
    my $self = shift;
    return $self->Init(@_);
}

#delete keys only from _for_write hashe!
sub DELETE {
    my ( $self, $key ) = @_;
    delete $self->_for_write->{ $key };
}

sub STORE {
    my ( $self, $key, $val ) = @_;
    my $hashes = $self->_orig_hashes;
    foreach my $hash ( @$hashes) {
        next unless exists $hash->{$key};
        return $hash->{$key} = $val;
    }
    $self->_for_write->{ $key } =$val;
    
}

sub FETCH {
    my ( $self, $key ) = @_;
    my $hashes = $self->_orig_hashes;
    foreach my $hash ( @$hashes) {
        next unless exists $hash->{$key};
        return $hash->{$key};
    }
    return 
}


sub GetKeys {
    my $self = shift;
    my $hashes = $self->_orig_hashes;
    my %uniq;
    foreach my $hash ( @$hashes) {
        $uniq{$_}++ for keys %$hash;   
    }

    return [ keys %uniq ];
}


sub TIEHASH {return Objects::Collection::Base::new(@_) }

sub FIRSTKEY {
    my ($self) = @_;
    $self->__temp_array( [ sort { $a cmp $b } @{ $self->GetKeys() } ] );
    shift( @{ $self->__temp_array() } );
}

sub NEXTKEY {
    my ( $self, $key ) = @_;
    shift( @{ $self->__temp_array() } );
}

sub EXISTS {
    my ( $self, $key ) = @_;
    my $hashes = $self->_orig_hashes;
    my %uniq;
    foreach my $hash ( @$hashes) {
        $uniq{$_}++ for keys %$hash;   
    }
    return exists $uniq{$key};
}

sub CLEAR {
    my $self = shift;
    %{ $self->_for_write } = ()
}

1;
__END__


=head1 SEE ALSO

Tie::StdHash

=head1 AUTHOR

Zahatski Aliaksandr, <zag@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005-2006 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

