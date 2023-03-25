---
title: "Pythonのlogging"
emoji: "😸" # アイキャッチとして使われる絵文字（1文字だけ）
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["python", "python3"]
published: false
---


# 概要

Pythonの`logging`モジュールは、アプリケーションの開発や運用において、アプリケーションの状態を知るための非常に便利なモジュールです。
一方で、`logging`モジュールは挙動に癖があり、使いこなすのが少し難しい側面があります。

この記事では、`logging`モジュールの基礎教養とセットアップ方法や癖を紹介します。


# 公式ドキュメント

最新の仕様や正確な仕様の理解には、公式ドキュメントを参照ください。

https://docs.python.org/ja/3/library/logging.html


# ロギングの基礎

## ログレベル

|  レベル名  |  数値  |  備考  |
| ---- | ---- | ---- |
|  CRITICAL  |  50  |  致命的なエラーログ  |
|  ERROR  |  40  |  エラーログ  |
|  WARNING  |  30  |  警告  |
|  SUCCESS  |  25  |  成功ログ。`logure`ライブラリ（後述）の拡張レベルで、`logging`モジュールには含まれない  |
|  INFO  |  20  |  情報ログ  |
|  DEBUG  |  10  |  デバッグログ  |
|  TRACE  |  5  |  デバッグより詳細なログ。`logure`ライブラリ（後述）の拡張レベルで、`logging`モジュールには含まれない   |
|  NOTSET  |  0  |  基本的に使用しない  |


表示されるレベル名は次のようにカスタマイズ可能です。

``` python
for level, name in {logging.CRITICAL: "FATAL", logging.WARNING: "WARN"}.items():
    logging.addLevelName(level, name)
```


## ロガー

## フォーマッタ


``` python
import logging

fmt = logging.Formatter(
    "%(asctime)s %(levelname).5s %(name)s  %(filename)s:%(lineno)s %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)

logging.basicConfig(format="%(asctime)s %(levelname).5s %(name)s %(filename)s:%(lineno)s %(message)s", datefmt="%Y-%m-%d %H:%M:%S")
```

## ハンドラー

https://docs.python.org/ja/3.11/howto/logging.html#useful-handlers



## フィルター

人類には早いので使わない。


# `logging`の使用

## 使用方法

## ロギングの罠

`logging`モジュールを使用する上で、癖を理解する必要があります。
`logging`モジュール初学者の方は、この章は読み飛ばして、理解が深まったところで戻ってきてください。

まず、以下のコードをご覧ください。

```
import logging
from logging import getLogger, StreamHandler, Formatter

# セットアップ
formatter = Formatter(
    "%(asctime)s %(name)s %(levelname)s %(filename)s:%(lineno)s %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)

sh = StreamHandler()
sh.setLevel(logging.INFO)
sh.setFormatter(formatter)

mylogger = getLogger("mylogger")
mylogger.setLevel(logging.INFO)
mylogger.addHandler(sh)


# 動作検証
print(logging.getLevelName(logging.root.level))
print(logging.root.handlers)
mylogger.info("hello 1")
logging.info("hello 2")
mylogger.info("hello 3")
print(logging.root.handlers)
```

実行結果は次のようになります。

```
WARNING
[]
2023-03-22 01:07:51 mylogger INFO aaa.py:20 hello 1
2023-03-22 01:07:51 mylogger INFO aaa.py:22 hello 3
INFO:mylogger:hello 3
[<StreamHandler <stderr> (NOTSET)>]
```


## 簡単な概念

- ロガー（`getLogger("mylogger")`）: ログを出力するための任意の名前を持つオブジェクト
- ルートロガー（`logging.root`）: 全ての親となるロガー。
- ハンドラー群（`logging.root.handlers`）: ロガーは、複数のハンドラーを持つ
- ハンドラー（`StreamHandler`）: ディスクリプタ（標準出力やファイル）にメッセージを出力する。StreamHandlerは、標準出力にメッセージを出力するハンドラー
- フォーマッタ（`Formatter（...）`）: どのようにメッセージを出力するか形式を決める
- ログレベル（`logging.INFO`）: ログのレベル。`INFO`や`WARNING`などにログを分類するためのもの。ハンドラーは、ハンドラー自身に設定されたログレベル以上のログを出力する
- 出力（`mylogger.info`など）: ログレベルとメッセージをハンドラーに渡す


ちなみに、ルートロガーは`logging.root`、あるいは、`logging.getLogger()`で取得します。

```
import logging

print(logging.root is logging.getLogger())
print(logging.root is logging.getLogger("root"))  # root という名前で取得したロガーはルートロガーではない

# True
# False
```


## 実行結果における違和感

おそらく、実行結果に次の違和感を覚えたのではないでしょうか？

1. なぜ、`logging.root.handlers`の状態が変わっているのだろうか
2. なぜ、`"hello 3"`が２回出力されるのだろうか


違和感 1. は、`logging.info("hello 2")`が関係しています。

[cpython](https://github.com/python/cpython/blob/3.11/Lib/logging/__init__.py#L2140) で、次のようにコードが書かれています。

``` python
def info(msg, *args, **kwargs):
    if len(root.handlers) == 0:
        basicConfig()
    root.info(msg, *args, **kwargs)
```

`logging`モジュールは、シングルトンでルートロガーを持ち、`logging.info`などを呼び出した際に、ハンドラーが未設定な場合、`basicConfig`（明示的に引数を指定しない場合はデフォルトハンドラーとデフォルトフォーマッタが適用されます）が呼び出されます。
これにより、デフォルトハンドラー（`<StreamHandler <stderr> (NOTSET)>`）が設定され、ルートロガーの状態が変わります。



`logging.info`は使うな！！！!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
NullHandlerとかロガーを明示的に指定しておけ！！！
root_logger = logging.getLogger()



違和感 2. は、ロガーは親子関係を持つことと、ハンドラーのログレベルが関係しています。

全てのロガーは、ルートロガーの子となり、子ロガーに与えたログはルートロガーに伝搬し、次のような結果となります。

- `2023-03-22 01:07:51 mylogger INFO aaa.py:22 hello 3`: `mylogger`のハンドラから出力されたログ
- `INFO:mylogger:hello 3`: `mylogger`のログがルートロガーへ伝搬され、ルートロガーのハンドラから出力されたログ


公式ドキュメントでは、次のように述べられています。

https://docs.python.org/ja/3.11/howto/logging.html#logging-levels

> ロガーに直接関連付けられたハンドラに加えて、ロガーの上位にあるロガーすべてに関連付けられたハンドラ がメッセージを処理する際に呼び出されます (ただしロガーの propagate フラグが false 値にセットされている場合を除きます。その場合は、祖先ハンドラへの伝搬はそこで止まります)。


この部分を次のコードで確認してみましょう。

``` python
import logging

logging.basicConfig(level=logging.WARNING)

root = logging.getLogger()

sh = logging.StreamHandler()
sh.setLevel(logging.INFO)

child = logging.getLogger("child")
child.setLevel(logging.INFO)
child.addHandler(sh)


root.warning("a")
# INFO:child:a

root.info("b")
# 何も出力されない

child.warning("c")
# c
# INFO:child:c

child.info("d")
# d
# INFO:child:d

child.debug("e")
# 何も出力されない
```

`WARNING`レベルのルートロガーと、`INFO`レベルの`child`ロガーを作成し、ログの出力を確認しました。

`child.info("d")`の部分に違和感を感じませんか？

`child`ロガーは`INFO`レベルですが、`root`ロガーは`WARNING`レベルです。
ですので、`root`ロガーに`INFO`レベルのログが伝搬されても、そのログは無視されるように思えませんか？


答えは、`root`ハンドラーのログレベルにあります。

``` python
import logging

logging.basicConfig(level=logging.WARNING)

root = logging.getLogger()
print(root.handlers)
# [<StreamHandler <stderr> (NOTSET)>]
```

明示的に、デフォルトハンドラーのログレベルを設定しない場合、`NOTSET`（全てのログを出力する）となります。

また、

> ロガーの上位にあるロガーすべてに関連付けられたハンドラ がメッセージを処理する際に呼び出されます

ことから、ロガー自身のレベルでなく、ハンドラーのレベルが参照されるため、このような挙動になるわけです。


私は、ルートロガーが嫌いなので、`NullHandler`（全てのログを無視するハンドラー）を使用して、次のようにして無効化しています。

`logging.basicConfig(handlers=[logging.NullHandler()])`

ルートロガーを使用する場合は、`basicConfig`などの挙動に注意しましょう。


ちなみに、次のようにすると親ロガーへの伝搬を無効化できます（私は使用しませんが）。

``` python
from logging import getLogger

child = getLogger("child")
child.propagate = False
```


# `warnings`の使用

`warnings`モジュールは、警告を出力するためのモジュールです。

最新の仕様や正確な仕様の理解には、公式ドキュメントを参照ください。

https://docs.python.org/ja/3/library/warnings.html


警告レベルのログは、`logger.warning`で出力できますが、アプリケーションの警告レベルとは区別したいことがあります。

例えば、アプリケーション内部で使用している将来的に廃止される非推奨な関数が呼び出された場合に、警告レベルを開発者のみに通知したい場合などです。


## 使用方法

`warnings`モジュールは、次のように使用します。

``` python
import warnings
warngins.warn("deprecated")
```

`warnings`で発せられた警告は、標準出力に出力されます。

また、`captureWarnings` を使用すると、ロギングシステムにリダイレクトされるようになります。具体的には、警告が`warnings.formatwarning()` でフォーマット化され、結果の文字列が 'py.warnings' という名のロガーに、 `WARNING` の重大度でロギングされるようになります。

``` python
import logging
logging.captureWarnings(True)
```


## 警告カテゴリ

警告は、カテゴリに分類することができます。

次にいくつかのカテゴリを紹介します。

|  レベル名  |  備考  |
| ---- | ---- |
|  `UserWarning`  |  デフォルトのカテゴリです  |
|  `DeprecationWarning`  |  非推奨であることを示すカテゴリです  |
|  `FutureWarning`  |  まだ、実験的な機能であることを示すカテゴリです  |


警告にカテゴリを適用するには次のようにします。

``` python
import warnings
warngins.warn("deprecated", DeprecationWarning)
```

パッケージを提供する開発者は、カテゴリを適切に使用した方がいいかもしれませんが、多くの場合はデフォルトのカテゴリで十分です。


## 警告フィルタ

警告が気になる場合、警告フィルタを使用し、警告の出力を制御することができます。

|  警告フィルタ  |  備考  |
| ---- | ---- |
|  default  |  デフォルトのカテゴリです  |
|  error  |  非推奨であることを示すカテゴリです  |
|  ignore  |  まだ、実験的な機能であることを示すカテゴリです  |
|  always  |  まだ、実験的な機能であることを示すカテゴリです  |
|  module  |  まだ、実験的な機能であることを示すカテゴリです  |
|  once  |  まだ、実験的な機能であることを示すカテゴリです  |


警告フィルタは、次のように適用します。

``` python
warnings.filterwarnings('ignore')
```


# `tqdm`の使用



# 高度なロギング

## 同期・非同期化でのロギング

## マルチプロセス化でのロギング



# まとめ

ロガーは、次の挙動に気をつけて使用する。

- ルートロガーのハンドラー設定されていない場合、ルートロガーのハンドラーが初期化（`basicConfig`が実行）されることがある
- ロガーのデフォルトログレベルは`WARNING`
- ハンドラーのデフォルトログレベルは`NOTSET`
- ロガーは、自身に関連付けられた全てのハンドラーを呼び出す
- ハンドラーは、上位のロガーに関連付けられた全てのハンドラーを呼び出す
- `basicConfig` は ルートロガーにハンドラーが設定されていれば、何もしない（`force`オプションで強制的に適用可能）
- ライブラリ開発者は、ルートロガーを使用しないでください。
- ライブラリ開発者がユーザーに警告をしたい場合は、`warnings`モジュールを使用する。

ルートロガーを無効化したい場合に次のようにする。

``` python
logging.basicConfig(handlers=[logging.NullHandler()])
```


# その他ロギングに関するライブラリやモジュールの紹介

- `warnings`
- `logure`
- `sentry`
- `tqdm`

