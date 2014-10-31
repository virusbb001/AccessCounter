use strict;
use warnings;

use Test::More tests => 11;
use Test::MockTime qw(:all);

use File::Temp qw/tempfile/;
use Time::Local;

use AccessCounter;

my ($tempfile,$tempfilename)=tempfile();

# 時差
my $time_offset=timegm(localtime)-timegm(gmtime);

# UTC_TIME + $time_offset
set_fixed_time(0+$time_offset);
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


set_fixed_time(50+$time_offset);
$accessCounter->addCount();
subtest 'first Day add count Test' => sub{
 my $data=$accessCounter->readData();

 is($data->{total}, 1,"total counter must be 1");
 is($data->{day}->[0] , 1,"today counter must be 1");
 is($data->{day}->[1] , 0,"yesterday counter must be 0");
 is($data->{updateTime},time,"updateTime must now");
};

subtest 'Not changed day,reflesh test' => sub{
 my $data=$accessCounter->refleshData();
 is($data->{total}, 1,"total counter must be 1");
 is($data->{day}->[0] , 1,"today counter must be 1");
 is($data->{day}->[1] , 0,"yesterday counter must be 0");
 is($data->{updateTime},time,"updateTime must now");
};

set_fixed_time(86400+$time_offset);
subtest '2nd Day read Test (with reflesh)' => sub{
 my $data=$accessCounter->refleshData();

 is($data->{total}, 1,"total counter must be 1");
 is($data->{day}->[0] , 0,"today counter must be 0");
 is($data->{day}->[1] , 1,"yesterday counter must be 1");
 isnt($data->{updateTime},time-86400*1,"updateTime must not be yesterday");
};

subtest '2nd Day add 2 count Test' => sub{
 $accessCounter->addCount();
 my $data=$accessCounter->addCount();
 #my $data=$accessCounter->refleshData();

 is($data->{total}, 3,"total counter must be 3");
 is($data->{day}->[0] , 2,"today counter must be 2");
 is($data->{day}->[1] , 1,"yesterday counter must be 1");
 is($data->{updateTime},time ,"updateTime must be now");
};

# delete Object and close file
undef($accessCounter);
close($tempfile);

set_fixed_time(86400*2+$time_offset);

subtest '3rd read Test when reopened (open by file name)' => sub{
 my $accessCounter=new_ok(AccessCounter => [{
    saveFile => $tempfilename,
    saveCount => 2
   }]);
 my $data=$accessCounter->refleshData();

 is($data->{total}, 3,"total counter must be 3");
 is($data->{day}->[0] , 0,"today counter must be 0");
 is($data->{day}->[1] , 2,"yesterday counter must be 2");
 isnt($data->{updateTime},time - 86400 *1,"updateTime must not be yesterday's now");
};

subtest 'time offset test' => sub{
 set_fixed_time(timelocal(59,59,23,31,12-1,2000-1900));

 my $accessCounter=new_ok(AccessCounter=> [{
    saveFile => $tempfilename,
    saveCount => 2
   }]);
 my $tmpData=$accessCounter->addCount();
 my $yesterdaycount=$tmpData->{day}->[0];
 is($yesterdaycount,1,"2000/12/31's count is 1");
 # 2000年12月31日23時59分59秒
 set_fixed_time(timelocal(0,0,0,1,1-1,2001-1900));
 my $data=$accessCounter->refleshData();
 is($data->{day}->[1], $yesterdaycount,"2001/1/1's yesterday is 2000/12/31, so yesterday's count must be $yesterdaycount" );
 is($data->{day}->[0], 0,"2001/1/1's yesterday is 2000/12/31, so today's count must be 0" );
};

close($tempfile);
