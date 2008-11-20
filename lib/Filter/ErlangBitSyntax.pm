package Filter::ErlangBitSyntax;
use strict;
use warnings;

our $VERSION = '0.01';

use Filter::Util::Call;

sub import {
    my($type) = @_;
    my $ref = {};
    filter_add(bless $ref);
}

=head1 NAME

Filter::ErlangBitSyntax - Module abstract (<= 44 characters) goes here

=head1 SYNOPSIS

  use Filter::ErlangBitSyntax;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.

=head1 METHODS

=cut

sub filter {
    my($self) = @_;
    my $status = filter_read();

    if (/.*?<<.*?>>.*/) {
        my $line = $_;
        my $output = '';
        my($pre_bitsyntax, $bitsyntax, $post_bitsyntax);
        while ($line =~ /(.*?)<<(.*?)>>(.*)/) {
            $pre_bitsyntax = $1;
            $bitsyntax = $2;
            $post_bitsyntax = $3;
            $output .= $1;
            my @elements = split /,/, $bitsyntax;
            $output .= join '', map {$self->parse_element($_)} @elements;
            $line = $post_bitsyntax;
        }
        $output .= $post_bitsyntax if($post_bitsyntax);
        warn "MOD# $output";
        $_ = $output;
    }

    $status;
}

sub parse_element {
    my($self, $bitsyntax) = @_;
    my $result = '';

    my $default = {
        endian => 'big',
        sign => 'unsigned',
        type => 'integer',
        unit => {
            integer => 1,
            float => 1,
            binary => 8,
        },
        size => {
            integer => 8,
            float => 64,
            binary => 0,
        },
    };
    my($endian, $sign, $type, $unit, $size)
        = ($default->{endian},
           $default->{size},
           $default->{type},
           $default->{unit}->{$default->{type}},
           $default->{size}->{$default->{type}});

    if ($bitsyntax =~ m!^(.*?)/(.*)$!) {
        my $type_specifier_list = $2;
        $bitsyntax = $1;
        my %keys = split /-/, lc($type_specifier_list);
        my $tsl = {
            endian => {
                little => 0,
                big => 0,
                native => 0,
            },
            sign => {
                signed => 0,
                unsigned => 0,
            },
            type => {
                integer => 0,
                float => 0,
                binary => 0,
            },
        };
        $endian = $default->{endian};
        for my $k (keys %{$tsl->{endian}}) {
            if ($keys{$k}) {
                $endian = $k;
                last;
            }
        }
        $sign = $default->{sign};
        for my $k (keys %{$tsl->{sign}}) {
            if ($keys{$k}) {
                $sign = $k;
                last;
            }
        }
        $type = $default->{type};
        for my $k (keys %{$tsl->{type}}) {
            if ($keys{$k}) {
                $type = $k;
                last;
            }
        }
    }
    if ($bitsyntax =~ m!^(.*?):(.*)$!) {
        $size = $2;
        $bitsyntax = $1;
    }
    warn join(', ', $endian, $sign, $type, $unit, $size);

    if ($bitsyntax =~ /^(\d)+$/) {
        $result .= $bitsyntax;
    } elsif ($bitsyntax =~ /^(\d+)\#([0-9A-Fa-f]+)$/) {
        my $trans = {
            2 => {
                template => 'B*',
                pad => sub {
                    $self->_pad(shift, 8);
                },
            },
            10 => {
                template => 'C*',
                pad => sub {shift},
            },
            16 => {
                template => 'H*',
                pad => sub {
                    $self->_pad(shift, 2);
                },
            },
        };
        my $padded = $trans->{$1}->{pad}->($2);
        warn $padded;
        my @digits = unpack('C*', pack($trans->{$1}->{template}, $padded));
        my $value = 0;
        my $len = scalar(@digits);
        for (my $i=0; $i < $len; $i++) {
            $value += $digits[$i] * 256 ** ($len - $i - 1);
        }
        $result .= $value;
    }
    $result;
}

sub _pad {
    my($self, $string_value, $digit) = @_;
    my $pad = length($string_value) % $digit;
    return $string_value if ($pad == 0);
    $pad = $digit - $pad;
    my $string_pad = '';
    while ($pad) {
        $string_pad .= '0';
        $pad--;
    }
    $string_pad . $string_value;
}



=head1 AUTHOR

Tsutomu KOYACHI <rtk2106@gmail.com>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;
