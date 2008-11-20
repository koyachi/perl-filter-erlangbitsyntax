use strict;
#use Test::More tests => 1;
use Test::Base;
use Filter::ErlangBitSyntax;


plan tests => 11; #1 * blocks() + 1;

=head2

filters {
    input    => [qw/chomp/],
    expected => [qw/chomp/],
};

run {
    my($block) = @_;
    is($block->input, $block->expected);
};

=cut

is(<<1>>, 1);
is(<<2#11>>, 3);
is(<<2#10000000>>, 128);
is(<<2#110000000>>, 384);
is(<<16#deadbeaf>>, 3735928495);
is(<<16#dead>>, 57005);
is(<<16#e>>, 14);
is(<<16#10e>>, 270);
is(<<10#8>>, 8);
is(<<10#11>>, 11);
is(<<10#111>>, 111);
is(<<1:4, 1:4>>, 9);


__END__

=== test01
--- input
<<1>>
--- expected
1

=== test02
--- input
<<16#deadbeaf>>
--- expected
3735928495
