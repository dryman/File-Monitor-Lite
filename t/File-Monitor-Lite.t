# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl File-Monitor-Lite.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 2;
use Cwd;
use lib 'lib';

subtest 'test object init'=> sub{
    plan tests =>9;
    use_ok 'File::Monitor::Lite' ;
    note 'different init test';
    new_ok File::Monitor::Lite => [name=> '*.test', in => '.',];
    new_ok File::Monitor::Lite => [name=> qr/.+\.haml/, in => '.',];
    new_ok File::Monitor::Lite => [name=> ['*.html',qr/.+\.tt$/,], in => '.',];
    my $m1 = File::Monitor::Lite->new( name => ['*.test'], in => '.',);
    foreach $meth (qw(check modified created deleted observed)){
        can_ok $m1, $meth;
    }
};
subtest 'test behavior' => sub{
    plan tests => 15;

    `rm t.test` if -f 't.test';
    my $m = File::Monitor::Lite->new( name => ['*.test'], in => '.',);
    `touch t.test`;

    sleep 1;
    note 'create t.test';
    ok $m->check, 'check done';
    is_deeply [$m->created], [getcwd.'/t.test'], 't.test created';
    is_deeply [$m->deleted], [] , 'nothing deleted';
    is_deeply [$m->modified], [] , 'nothing modified';
    is_deeply [$m->observed], [getcwd.'/t.test'], 'observing t.test';

#    `echo 'hello' >> t.test`;
#    ok $m->monitor->scan, 'internal modify detected';
    `echo 'again' >> t.test`;

    note 'modify t.test';
    ok $m->check, 'check done';
    is_deeply [$m->created], [], 'nothing created';
    is_deeply [$m->deleted], [] , 'nothing deleted';
    is_deeply [$m->modified], [getcwd.'/t.test'] , 't.test modified';
    is_deeply [$m->observed], [getcwd.'/t.test'], 'observing t.test';

    `rm t.test`;

    sleep 1;
    note 'delete t.test';
    ok $m->check, 'check done';
    is_deeply [$m->created], [], 'nothing created';
    is_deeply [$m->deleted], [getcwd.'/t.test'] , 't.test deleted';
    is_deeply [$m->modified], [] , 'nothing modified';
    is_deeply [$m->observed], [], 'observing nothing';
};
