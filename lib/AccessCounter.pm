package AccessCounter;

use Carp;
use JSON::XS qw/encode_json decode_json/;

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
  # 何回分保存するか
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
 $data->{updateTime}=int(time()/86400);
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
  $data={
   updateTime=>time()
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
 my $interval=int(time/86400) - $data->{updateTime};
 my $histnum=int($interval/($countInterval+1));
 for(my $i=0;$i<$histnum;$i++){
  unshift(@{$data->{day}},0);
 }
 splice(@{$data->{day}},$this->{saveCount});
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
