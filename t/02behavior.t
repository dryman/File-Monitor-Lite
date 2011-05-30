use Test::More tests => 15;
use File::Monitor::Lite;
use Cwd;
use lib 'lib';

`rm t.test` if -f 't.test';
my $m = File::Monitor::Lite->new( name => ['*.test'], in => '.',);

note 'create t.test';
`touch t.test`;
ok $m->check, 'check done';
is_deeply [$m->created], [getcwd.'/t.test'], 't.test created';
is_deeply [$m->deleted], [] , 'nothing deleted';
is_deeply [$m->modified], [] , 'nothing modified';
is_deeply [$m->observed], [getcwd.'/t.test'], 'observing t.test';

note 'modify t.test';
`echo 'again' >> t.test`;
ok $m->check, 'check done';
is_deeply [$m->created], [], 'nothing created';
is_deeply [$m->deleted], [] , 'nothing deleted';
is_deeply [$m->modified], [getcwd.'/t.test'] , 't.test modified';
is_deeply [$m->observed], [getcwd.'/t.test'], 'observing t.test';

note 'delete t.test';
`rm t.test`;
ok $m->check, 'check done';
is_deeply [$m->created], [], 'nothing created';
is_deeply [$m->deleted], [getcwd.'/t.test'] , 't.test deleted';
is_deeply [$m->modified], [] , 'nothing modified';
is_deeply [$m->observed], [], 'observing nothing';
