---
title: "pythonで使うテクニック集"
emoji: "😸" # アイキャッチとして使われる絵文字（1文字だけ）
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["python"]
published: false
---


# コンソールに進捗を表示する

ファイル送受信など重たい処理などで、「どこまで処理が進んでいるか」「どれくらい時間がかかった」などが分かると親切です。

ここでは、それをコンソールに表示する方法を紹介します。

<!-- :::message
これから紹介する方法は実行環境により上手く表示されないことがあります

- thread/multiprocess/eventloop上での実行

::: -->

```
from tqdm import tqdm
from concurrent.futures import ThreadPoolExecutor
import time


def func1():
    for i in tqdm(range(10), position=0):
        time.sleep(1)


def func2():
    for i in tqdm(range(20), position=1):
        time.sleep(1)


with ThreadPoolExecutor(max_workers=2) as th:
    r1 = th.submit(func1)
    r2 = th.submit(func2)
```
