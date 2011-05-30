# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl File-Monitor-Lite.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 12;
use File::Monitor::Lite;
use Cwd;
use lib 'lib';


`rm t.test` if -f 't.test';
my $m = new File::Monitor::Lite(in=> getcwd, name=>'t.test');

`touch t.test`;
$m->check;
is_deeply [$m->created], [getcwd.'/t.test'], 't.test created';
is_deeply [$m->deleted], [] , 'nothing deleted';
is_deeply [$m->modified], [] , 'nothing modified';
is_deeply [$m->observed], [getcwd.'/t.test'], 'observing t.test';

`echo 'again' >> t.test`;
$m->check;
is_deeply [$m->created], [], 'nothing created';
is_deeply [$m->deleted], [] , 'nothing deleted';
is_deeply [$m->modified], [getcwd.'/t.test'] , 't.test modified';
is_deeply [$m->observed], [getcwd.'/t.test'], 'observing t.test';

`rm t.test`;
$m->check;
is_deeply [$m->created], [], 'nothing created';
is_deeply [$m->deleted], [getcwd.'/t.test'] , 't.test deleted';
is_deeply [$m->modified], [] , 'nothing modified';
is_deeply [$m->observed], [], 'observing nothing';
