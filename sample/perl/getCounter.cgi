#!/usr/bin/env perl

use lib qw(../../lib/);
use AccessCounter;
use JSON::XS;

print "Content-type: application/json\n";
print "\n";


my $counter=AccessCounter->new({
  saveFile => "./counter.dat", # 保存/読み込み先のファイルハンドラ もしくはファイル名
  saveTotal => 1, # 合計カウントを保存するかどうか
  saveCount => 2, # 何日分(最新)を保存するか
  countInterval => 0 # カウントする日の間隔 0で毎日 1で1日おきにカウント
 });

print encode_json($counter->addCount());
