---
title: "PyCharm　＋　docker　＋ fastapi環境上で快適な開発をしたい"
emoji: "😸" # アイキャッチとして使われる絵文字（1文字だけ）
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["markdown", "python"]
published: false
---


# 対象読者
- PyCharm + docker　＋ fastapiで開発をしたい方
- Pycharm利用ユーザー（VS Codeの方がdockerの扱いは優れているようです。それでもPyCharmでdockerを使いたい方が対象です。）
- fastapiに関する教養がある程度ある方
- Dockerに関する教養がある程度ある方

# 筆者開発環境
筆者の開発環境は以下の通りです。（Windows Mac等の動作は検証していません。）

- ubuntu 20.04
- PyCharm x.x.x
- fastapi
- pytest

# 解決したい問題
PyCharmでは、dockerを利用した開発をサポートしていますが、以下のような不憫な点がいくつかあります。

- docker環境上に追加されたpackageを自動認識できない（dockerイメージの再ビルドが必要。VS Codeでは再ビルドは必要ないようです。）
- docker環境上でファイルを追加すると、ホスト上と異なるユーザーでファイルが作成され、ホスト上で権限が欠落する
- デバッグやpytest実行時、pycharmがdockerイメージを再起動するため起動時間がストレスになる

このような問題があり、dockerを利用した開発を諦めた方もいると思います。
本記事では、上記のような不憫な点を解決できるように努めています。

# 解決していない問題

## docker環境上で追加されたpackageを自動認識できない
ホスト上のpythonの仮想環境を参照し、dockerコンテナのディレクトリと同期すれば何とかなりそうですが、労力が大きそうなので今回は見送りしましたm(_ _)m

## PyCharmのjupyter notebookに関する機能が利用できない
現状、PyCharmはリモートインタプリタ上でjupyter notebookを利用できないため、jupyter notebook本体の機能を利用してください。

# 結局どういう開発環境が構築できるの？

- アプリケーションコードのホットリロード
- [swagger-ui](https://swagger.io/tools/swagger-ui/)を利用した機能検
- dockerイメージを再ビルドせずにpytestを起動・デバッグ
- jupyterによる機能検証
- (おまけ)frontendで利用するapi clientの自動生成

# 開発環境の構築
- dockerイメージ作成・権限設定
- プロジェクトインタープリタの設定
- プロジェクトとdocker環境上のファイル同期
- サンプルアプリケーションの作成
- ホットリロードでサンプルアプリケーションを起動（シェル経由だと、pycharmがpythonコードを捕捉できないため、スクリプトから実行する）


# 開発環境の利用方法
- ブレークポイントの利用
- pytestの実行
- コンテナへの入り方
- パッケージ追加時（）
- jupyter環境の構築・補完有効化オプション

```
sudo jupyter contrib nbextension install
sudo jupyter nbextensions_configurator enable
```


```
# sudo jupyter notebook --ip=0.0.0.0 --allow-root --notebook-dir jupyter
sudo jupyter notebook --ip=0.0.0.0 --allow-root --notebook-dir=jupyter --NotebookApp.token='' --NotebookApp.password=''
```

これが最強だと思います。

