use strict;
use warnings;

use Test::More tests => 9;
use Test::MockTime qw(:all);
use File::Temp qw/tempfile/;
use AccessCounter;

my ($tempfile,$tempfilename)=tempfile();

set_fixed_time(0);
# よくある昨日, 今日, 合計のカウンター
my $accessCounter=AccessCounter->new({
  saveFile => $tempfile,
  saveCount => 2
 });

ok(defined $accessCounter , "AccessCounter->new returned something");
ok($accessCounter ->isa('AccessCounter')," and it's AccessCounter Class");

ok(defined($accessCounter->{saveFile}),"savefile is defined");
is($accessCounter->{saveTotal} , 1,"saveTotal must be 1 because it is default");

subtest 'first Read Data Test' => sub{
 my $data=$accessCounter->readData();
 ok($data->{total} == 0,"total counter must be 0");
 ok($data->{day}->[0] == 0,"today counter must be 0");
 ok($data->{day}->[1] == 0,"yesterday counter must be 0");
};

set_fixed_time(50);
$accessCounter->addCount();
subtest 'first Day add count Test' => sub{
 my $data=$accessCounter->readData();

 is($data->{total}, 1,"total counter must be 1");
 is($data->{day}->[0] , 1,"today counter must be 1");
 is($data->{day}->[1] , 0,"yesterday counter must be 0");
 is($data->{updateTime},int(time()/86400),"updateTime must be today but not now");
};

set_fixed_time(86400);
subtest '2nd Day read Test (with reflesh)' => sub{
 my $data=$accessCounter->refleshData();

 is($data->{total}, 1,"total counter must be 1");
 is($data->{day}->[0] , 0,"today counter must be 0");
 is($data->{day}->[1] , 1,"yesterday counter must be 1");
 is($data->{updateTime},int(time()/86400-1),"updateTime must be yesterday");
};

$accessCounter->addCount();
$accessCounter->addCount();
subtest '2nd Day add 2 count Test' => sub{
 my $data=$accessCounter->refleshData();

 is($data->{total}, 3,"total counter must be 3");
 is($data->{day}->[0] , 2,"today counter must be 2");
 is($data->{day}->[1] , 1,"yesterday counter must be 1");
 is($data->{updateTime},int(time()/86400),"updateTime must be today");
};

# delete and recreate
undef($accessCounter);
close($tempfile);

undef($accessCounter);
set_fixed_time(86400*2);

subtest '3rd read Test when reopened (open by file name)' => sub{
 my $accessCounter=new_ok(AccessCounter => [{
    saveFile => $tempfilename,
    saveCount => 2
   }]);
 my $data=$accessCounter->refleshData();

 is($data->{total}, 3,"total counter must be 3");
 is($data->{day}->[0] , 0,"today counter must be 0");
 is($data->{day}->[1] , 2,"yesterday counter must be 2");
 is($data->{updateTime},int(time()/86400 -1),"updateTime must be yesterday");
};

close($tempfile);
