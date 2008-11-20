use inc::Module::Install;
name 'Filter-ErlangBitSyntax';
all_from 'lib/Filter/ErlangBitSyntax.pm';

test_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
