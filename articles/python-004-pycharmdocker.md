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



# 雛形作るよ

## プロジェクト作成
次のコマンドで、任意のプロジェクト用ディレクトリを作成します。

``` shell
mkdir fastapi_template
cd fastapi_template
```

次のコマンドでPythonプロジェクトを作成します。

`Compatible Python versions`は任意のPythonのバージョンを指定ください。
それ以外は、とりあえずそのままで大丈夫です。

``` shell
poetry init

# Package name [fastapi_template]:
# Version [0.1.0]:
# Description []:
# Author [yourname <yourname@example.com>, n to skip]:
# License []:
# Compatible Python versions [^3.8]
```

## パッケージ追加
まずは、fastapi関連のパッケージを追加する。

``` shell
poetry add fastapi
poetry add uvicorn
```

開発支援パッケージを追加する。

``` shell
poetry add -D black  # 自動コードフォーマッタ
poetry add -D isort  # 自動インポート文フォーマッタ
poetry add -D flake8  # pep8に基づくコードチェッカー
poetry add -D mypy  # 型チェッカー
```

パッケージ追加時に仮想環境が作成されるが、今回はdockerを利用するので削除する。

``` shell
# パッケージ追加時に次のようなメッセージが出力されているので、そのディレクトリを指定
# Creating virtualenv <project_name> in /home/user_name/PycharmProjects/<project_name>/.venv
rm -rf xxxxx
```

poetry.lockで追加したパッケージをrequirements.txtとして出力する。

``` shell
# poetry.lockを、requirements.txtの形式の、requirements.txtを出力する
poetry export -f requirements.txt > requirements.txt
```

## dockerfile作成

``` shell
cat <<EOS > Dockerfile
FROM python:3.8

RUN apt-get update
RUN apt-get install -y vim

RUN pip3 install -U pip && pip3 install --no-cache-dir poetry

RUN poetry config virtualenvs.create false && \
    poetry config virtualenvs.in-project false

WORKDIR /app/
COPY ./pyproject.toml /
COPY ./poetry.lock* /

RUN poetry install

EXPOSE 8080

EOS
```

``` shell
cat <<EOS > docker-compose.yml
version: '3'
services:
  fastapi:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
    volumes:
      - .:/app:rw
EOS
```

## アプリケーションコード

``` shell
cat <<EOS > main.py
from fastapi import FastAPI

app = FastAPI()

if __name__ == "__main__":
  import uvicorn
  uvicorn.run("main:app", host="0.0.0.0", port=8080, reload=True)

EOS
```

## docker build

``` shell
docker-compose up -d --build
```

## pycharmを開く
- projectinterpreterにdocker-composeを指定
- configurationでデバッグ設定を行う

Services -> Log でコンテナのログを見れるぞ

## 起動

mainをデバッグ実行

- [http://0.0.0.0:8080/docs#/](http://0.0.0.0:8080/docs#/)

## リロードをためそう
ローカルのターミナルでソースコードを修正すると、変更を検知してサーバが再起動するのでF5で画面を更新してみよう。


``` shell
cat <<EOS > main.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/hello")
def get_hello():
    return "hello"

if __name__ == "__main__":
  import uvicorn
  uvicorn.run("main:app", host="0.0.0.0", port=8080, reload=True)

EOS
```

コンテナに入って、コンテナのターミナルからソースを修正してみよう。
サーバが再起動した上に、ストレージがマウントされているのでローカル側のファイルも修正されるはずです。

``` shell
cat <<EOS > main.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/hello")
def get_hello():
    return "hello"

if __name__ == "__main__":
  import uvicorn
  uvicorn.run("main:app", host="0.0.0.0", port=8080, reload=True)

EOS
```

## デバッグしてみよう
ブレークポイントを貼って、止まることを確認する。










# VSCodeによる開発

- 仮想環境
- docker

# 概要

- 拡張機能のインストール
- コードの実行
- アプリ実行
- デバッグ（ブレークポイント）
- docker実行

# 参考サイト

- [](https://code.visualstudio.com/docs/python/python-tutorial)

# 必要な拡張機能

- Python
- Python for VSCode
- Remote-Containers

## Python for VSCode
Pythonのシンタックスハイライトを支援します。

Supports syntax highlighting, snippets and linting (see requirements below). Linting can be customised with a .pylintrc(pyLint) or setup.cfg(flake8) file in the root of the current working directory

## DjangoまたはFlaskアプリでホットリロードを有効にする方法
https://code.visualstudio.com/docs/containers/debug-python#_how-to-enable-hot-reloading-in-django-or-flask-apps


## デバッグするには
画面左にデバッグアイコンがある。
実行とデバッグから任意の実行方式を選択する。

### launch.jsonとは
実行を方法を詳しく定義するには、launch.jsonを作成する。
.vscodeフォルダ内に作成される。



## Pytestするには

