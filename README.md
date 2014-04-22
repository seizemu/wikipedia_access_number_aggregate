#Wikipedia Access Number Aggregate
これはwikipediaのアクセスデータから前日のアクセス数をデータベースに保存し、アクセスのランキングを集計するRubyスクリプトです。

##設定ファイル(config.yml)の変更
設定ファイルはYAML記法で記述されています。各項目に任意の値を設定してからスクリプトを実行してください。

    wikiperank:
      read_data_number: 100
      number_of_rank_to_be_output: 10
      base_url: http://dumps.wikimedia.org/other/pagecounts-raw/year/year-month/

設定ファイルの各項目の説明

`read_data_number:` ダウンロードされたアクセスデータの各ファイルからデータベースに取り込むデータ数。

`number_of_rank_to_be_output:` 出力されるアクセスランキングに何項出力するか。

##使い方
このスクリプトはRubyで書かれているので、Rubyの実行環境を用意して使用してください。

必要なgemのインストール

* bundlerが導入されている場合 `bundle install`

* bundlerが導入されていない場合  `gem install nokogiri sqlite3 activerecord`

実行

    ruby downloader.rb




##このプログラムを使う時の注意点
このプログラムはエラー処理を大雑把に飛ばしてます。使用時には以下の点に注意してください。

* my_func.rbのaccess_analysisメソッドにおいてデータをデータベース読み込み時にUTF-8以外の文字コードで記述されているデータは読み込んでいません。

* downloader.rbの131行目にある条件分岐でUTF-8と他の文字コードが混在しているデータを配列へ代入していません。

