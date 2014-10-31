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
* sample/ 設置例

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

# メソッド #

* addCount(); カウントを更新して加算してファイルに保存 カウント後のデータを返す
* readData(); カウントを更新せず読み出しだけ行う
* refleshData([data]); dataのデータを更新する(もしなければファイルからデータを読み込む) 更新したものを返す
* writeData(data); dataをファイルに書き出す

# 保存するデータ形式 #
JSON形式で保存しています．時差の考慮はrefleshData実行時に行います．

```json
{
 "total":合計カウント,
 "updateTime":更新した時刻(UTC),
 "day":[0日目,1日目,...]
}
```


# 使用したモジュール #

* Carp
* JSON::XS

# その他 #

* サンプルを動かすにはjQueryが必要です(CDNを使っています)
* 簡単に設置したい人はeasyを見てください
