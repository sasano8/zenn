---
title: "exceptions"
emoji: "😸" # アイキャッチとして使われる絵文字（1文字だけ）
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["markdown", "python"]
published: false
---


# 例外処理


# エラーをキャッチしてそのままraiseしたい
次のように、例外を捕捉後に任意の処理を挟んで同じ例外を発生させることができる。

``` python
try:
    raise Exception()
except Exception as e:
    print(e)
    raise
```


# エラーメッセージを変更して表示したい
対応方法の見当がついている場合など、次のようにスタックトレースを引き継いで、新たな例外を発生させることができる。

``` python
try:
    raise RuntimeError()
except RuntimeError as e:
    import sys

    type, value, traceback = sys.exc_info()
    raise Exception("このエラーはテストなので気にしないでね").with_traceback(traceback)
```

# トレースバックを文字列で取得したい
``` python
import traceback

try:
    1/0
except Exception as e:
    tb = "".join(traceback.TracebackException.from_exception(e).format())
    print(tb)
```

# ログ出力時の情報でなく、例外発生位置を出力する。
``` python
try:
    raise Exception()
except Exception as e:
    logger.info(e, exc_info=True)
```

# トレースバック情報を出力する
この方法が一番綺麗に出力してくれる感じがする

``` python
import traceback

try:
    raise Exception()
except Exception as e:
    logger.critical(traceback.format_exc())
```