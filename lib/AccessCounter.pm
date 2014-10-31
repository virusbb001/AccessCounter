package AccessCounter;

use Carp;
use JSON::XS qw/encode_json decode_json/;
use Time::Local;

my $time_offset=timegm(localtime)-timegm(gmtime);

sub new{
 my $pkg=shift;
 # 設定に必要なもの
 # セーブ先ファイル(ハンドラ)
 # 合計カウントを保存するか
 # 何日おきにリセットするか
 # どのくらい保存するか
 my $config=shift;
 if(!defined($config->{saveFile})){
  croak("saveFile is not defined");
 }
 if(!ref($config->{saveFile})){
  my ($fh,$filename);
  $filename=$config->{saveFile};
   open($config->{saveFile},((-e $filename)?"+<":"+>"),$filename) or croak("File ${filename} cannot open ");
  $config->{saveFileName}=$filename;
 }
 my %defaultConfig=(
  # 合計カウントを別に保存するか
  saveTotal => 1,
  # n日分あけてカウントをする 
  # 0なら次の日に(デフォルトは0)
  # 1なら今日,明日でまとめて, 明後日,4日後にまとめてカウントをする
  countInterval => 0,
  # 何回分保存するか(2だったら今日の分とリセット直前の分)
  saveCount => 2
 );
 my %conf=(%defaultConfig,%$config);
 my $ref=\%conf;
 bless ( $ref,$pkg);
 return $ref;
}

# カウント追加
# データのリセットなどもここで行う
# 基本はこの関数だけ使う
sub addCount{
 my $this=shift;
 my $data=$this->readData();
 $this->refleshData($data);
 $data->{total}++;
 $data->{day}->[0]++;
 $data->{updateTime}=time;
 $this->writeData($data);
 return $data;
}

# データ読み込み
sub readData{
 my $this=shift;
 my $fh=$this->{saveFile};
 my (@text,$text);
 my $data;
 seek($fh,0,0);
 @text=<$fh>;
 $text=join("",@text);
 if(length($text)!=0){
  eval{
   $data=decode_json($text);
  };
  if($@){
   carp($text,$@);
  }
 }else{
  # 初期設定
  $data={
   updateTime=>time
  };
  if($this->{"saveTotal"} == 1){
   $data->{"total"}=0;
  }
  if($this->{"countInterval"} >= 0 ){
   $data->{"day"}=[];
   for(my $i=0; $i<$this->{"saveCount"};$i++){
    $data->{"day"}->[$i]=0;
   }
  }
  # 空の時にデータ初期化, 上書き

  $this->writeData($data);
 }

 return $data;
}

# データ書き出し
# 無理やり書き換えるときとか
sub writeData{
 my $this=shift;
 my $data=shift;
 my $text;
 my $fh=$this->{saveFile};
 seek($fh,0,0);
 truncate($fh,0);
 if(defined $data){
  $text=encode_json($data);
 }
 print $fh $text;
}

# データ更新
sub refleshData{
 my $this=shift;
 my $data=shift;
 if(!defined($data)){
  $data=$this->readData();
 }
 # 何日経過したか
 my $interval=int( (time+$time_offset)/86400) - int(($data->{updateTime}+$time_offset)/86400);
 my $histnum=int($interval/($countInterval+1));
 for(my $i=0;$i<$histnum;$i++){
  # 先頭に追加
  unshift(@{$data->{day}},0);
 }
 # 削除処理
 splice(@{$data->{day}},$this->{saveCount});
 # 今日更新したことに
 $data->{updateTime}=time;
 return $data;
}

# デストラクタ
sub DESTROY{
 my $this=shift;
 if(defined($this->{saveFileName})){
  close($this->{saveFile});
 }
}

1;
