AccessCounter
=============

Perlで作ったアクセスカウンター

# 対象 #

アプリとかサイトとかにアクセスカウンターを埋め込むときに

# 中身 #

* lib/
    * AccessCounter.pm 本体
* t/ テストスクリプト
* LICENSE ライセンス
* README.md これ

# 設定 #

```perl
{
    saveFile => undef, # 保存/読み込み先のファイルハンドラ もしくはファイル名
    saveTotal => 1, # 合計カウントを保存するかどうか
    saveCount => 2, # 何日分(最新)を保存するか
    countInterval => 0 # カウントする日の間隔 0で毎日 1で1日おきにカウント
}
```

ファイルハンドラを開く時は"+<"形式で開いてください  
