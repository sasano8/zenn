---
title: "pythonの辞書マージ操作を極める"
emoji: "😸" # アイキャッチとして使われる絵文字（1文字だけ）
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["markdown", "python"]
published: false
---

# はじめに
pythonにおいて辞書のマージ操作は基礎的な操作です。しかし、著者は泥臭いマージをしていたり、マージの挙動について理解が足りていないと感じるシーンが多かったため、理解を整理するために本記事を執筆しました。

# 検証環境
- python3.9.0

# 用語
本記事では以下の挙動を区別し、執筆しています。（これらの概念の正式名称があれば教えていただけると幸いです。）

## 結合
２つの辞書を１つにする操作。

## マージ
２つの辞書を合成し、かつ、コンフリクトするキーは合成する辞書の値で合成元の値で上書きされることを想定する。

## 合成
２つの辞書を合成し、かつ、コンフリクトするキーが存在する場合、合成が許可されないことを想定する。

# 辞書の取り扱い

## ソース辞書
合成対象の辞書として、以下２つ辞書をソースとして利用します。
```
dic1 = {"name": "bob", "age": 20}
dic2 = {"name": "mary"}
```

## 辞書の作成
辞書作成時に複数の辞書から

-----
``` python
{**dic1, **dic2}
# => {"name": "mary", "age": 20}
```
コンフリクトは右辺で上書きされる。マージしたいのか、合成したいのか意図が明確でないため好みではない。Python3.5以上でしか使えない模様。

-----
``` python
dict(**dic1, **dic2)
# => TypeError: func() got multiple values for keyword argument 'name'
```
コンフリクトは許容されない。意図は明確でないが、意図せずマージされてしまうことはない。

-----
``` python
def func(**kwargs):
  ...

func(**dic1, **dic2)
# => TypeError: func() got multiple values for keyword argument 'name'
```
コンフリクトは許容されない。意図は明確でないが、意図せずマージされてしまうことはない。


-----
``` python
def func(name, age, **kwargs):
  ...

func(**dic1, **dic2)
# => TypeError: func() got multiple values for keyword argument 'name'
```
コンフリクトは許容されない。重複したキーが、可変長キーワード引数に渡ってくる心配をする必要はない。

-----
``` python
dict(dic1, **dic2)
# => {"name": "mary", "age": 20}
```
コンフリクトは右辺で上書きされる。dic1のソースが変更されることはない。

-----
``` python
dic1 | dic2
# => {"name": "mary", "age": 20}
```
コンフリクトは右辺で上書きされる。和集合演算子で意図は伝わりやすいので積極的に使いたい。

## 辞書の更新
１つ目の辞書を２つ目の辞書で更新したい場合は、以下の方法を用いる。
破壊的な変更の副作用を考慮したくない場合は、新たな辞書を作成し、新たな変数に格納する方法を用いる。

-----
``` python
dic1.update(dic2)
# => {"name": "mary", "age": 20}
```
dic1に対して、dic2の値で上書き合成する。

-----
``` python
dic1 |= dic2
# => {"name": "mary", "age": 20}
```
コンフリクトは右辺で上書きされる。dic1のソースが変更される。

# まとめ
最後に検証結果と、python3.9以上の環境でどの方法を用いるか個人的ルールをまとめる。

|      | 利用可能バージョン | コード | 結果 | 備考 |
| ---- | ---- | ---- | ---- |
| 作成 | 3.5~ | {\**dic1, \**dic2} | {"name": "mary", "age": 20} | 使うな |
| 作成 | ? | dict(\**dic1, \**dic2) | TypeError: func() got multiple values for keyword argument 'name' | 常用的に用いる |
| 作成 | ? | func(\**dic1, \**dic2) | TypeError: func() got multiple values for keyword argument 'name' | 常用的に用いる |
| 作成 | ? | dict(dic1, \**dic2) | {"name": "mary", "age": 20} | 使うな |
| 作成 | 3.9~ | dic1 \| dic2 | {"name": "mary", "age": 20} | マージしたい時に意識的に用いる |
| 更新 | ? | dic1.update(dic2) | {"name": "mary", "age": 20} | 使うな |
| 更新 | 3.9~ | dic1 \|= dic2 | {"name": "mary", "age": 20} | マージしたい時に意識的に用いる |
