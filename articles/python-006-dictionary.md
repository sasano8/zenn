---
title: "Pythonの辞書操作を極める"
emoji: "😸" # アイキャッチとして使われる絵文字（1文字だけ）
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["markdown", "Python"]
published: false
---

# 概要
本記事では、**一般的な辞書操作とそれらの細かい挙動に応じた使い分け**を紹介しています。

Python3.9がリリースされ、辞書に関する機能も新たにリリースされました。
この機会に、辞書に関するノウハウをアップデートしましょう。

本記事で紹介する辞書操作や挙動は、本記事[まとめ](#まとめ)の章でコンパクトにまとめました。本記事を一通りお読みいただいた後は、ガイドラインとしてまとめを活用いただければ幸いです。


# 検証環境
- Python3.9.0

読者のメインターゲットは、Python3.5以上のユーザーです。
検証環境は3.9ですが、Python3.5系以上の互換性は調査・考慮しています。

Python中級者以上の方は、目次とまとめを見て気になった章だけお読みください。

# 基礎編

## 辞書作成する
辞書を作成する方法を紹介します。
辞書リテラル`{}`か`dict`関数を用いて、辞書を作成できます。

``` Python
# 方法１
dic = {"key": "test"}

# 方法２
# {}に比べて性能が２倍以上落ちるため基本的には{}を用いた方がよい。ただし、挙動が異なる部分がある。※更に詳しい挙動はマージ編参照
dic = dict(key="test")
```

`dict`関数を使用する場合、以下のようなPython言語仕様上の制約があります。

``` Python
# 例外
dic = dict(from=0)  # fromは予約語のため、キーワード引数で用いることができない
dic = dict(1=0)  # 整数はキーワード引数で用いることができない
# => SyntaxError: invalid syntax
```

:::message
- `{}`は`dict`関数に比べ、性能が２倍以上優れます
- dict関数でキーワード引数を利用するとキーワード引数が要素（文字列キーと値）として定義されます。ただし、キーが予約語や整数などの場合、SyntaxErrorとなります
:::

## 要素（キーと値）を登録する
辞書に要素を登録する方法を紹介します。
同じキーに対して複数回値を登録しようとした場合は、上書きとなります。

``` Python
dic = {}
dic['key'] = "val"
```

要素を登録するために、`setdefault`も利用できます。

``` Python
dic = {}
# キーが存在していないので、新たなキーと値が登録されます
val = dic.setdefault('new', 0)
# => 0

# すでにキーが存在しているので第２引数は無視されます
val = dic.setdefault('new', 1)
# => 0

# 第２引数を省略するとNoneが登録されます
dic = {}
val = dic.setdefault('new')
# => None
```

なお、Python3.7から、辞書の順序は挿入順序であることが保証されています。
https://docs.python.org/3/library/stdtypes.html#dict-views

:::message
`setdefault`は、キーが登録されていない場合はデフォルト値を登録した上で、キーに対応する値を返します。
- 第１引数：　キー
- 第２引数：　キーが登録されていない場合に登録するデフォルト値。省略した場合は、Noneが登録されます。
:::

## キーに対応する値を取得する
キーに対応する値の取得方法を紹介します。

``` Python
# 方法１
# キーが存在しない場合は、KeyErrorが発生する
val = dic["name"]

# 方法２
# キーが存在しない場合は、Noneが返る
val = dic.get("name")

# 方法３
# キーが存在しない場合は、第２引数の値が返る
val = dic.get("name", None)

# 方法４
# キーが存在しない場合は、第２引数の値を登録した上で、その値を返す
val = dic.setdefault("name", None)
```

## 要素を削除する
要素を削除する方法を紹介します。

``` Python
# 方法１
# 性能が最も優れる
# キーが存在しない場合は、KeyErrorが発生する
del dic["name"]

# 方法２
# キーを削除しながら値を返す
# キーが存在しない場合は、KeyErrorが発生する
val = dic.pop("name")

# 方法３
# キーを削除しながら値を返す
# キーが存在しない場合は、第２引数の値を返す
val = dic.pop("a", None)

# 方法４
# 要素を一つ無作為に削除する
# どの要素が削除されるか不明。Python3.7からは辞書の要素順が保存されるようになり、最後の要素から削除されている模様だが、順序を期待した処理を書くべきではない
key_value = dic.popitem()
```

:::message
- 性能を気にする場合は、delを用いましょう
:::


複数の要素を削除したい場合の例を紹介します。
なお、delはリスト内包表記とともには利用できません。

``` Python
some_keys = ["key1", "key2"]

# 方法１
for key in some_keys:
  del dic[key]

# 方法２(パフォーマンス的には方法1を推奨)
[dic.pop(key, None) for key in some_keys]
```

## 全ての要素を削除する
全ての要素を削除する場合は、`clear`メソッドを用います。

``` Python
# 方法１
dic.clear()
# => {}
```

## キーを変更する
キーを変更する方法を紹介します。
専用のメソッドは用意されていませんが、`pop`を用いることで簡潔に実現できます。

``` Python
dic["new"] = dic.pop("old")
```

## 要素（キーや値）を列挙する
要素（キーや値）を列挙する方法を紹介します。

``` Python
# キーを列挙する
for key in dic:
  print(key)

# キーを列挙する
for key in dic.keys():
  print(key)

# 値を列挙する
for value in dic.values():
  print(value)

# 要素（キーと値のタプル）を列挙する
for key, value in dic.items():
  print(key, value)

# 要素（キーと値のタプル）を列挙する
# Python2系のみ
# Python3系ではiteritemsはitemsに統合されました。（2系ではiteritemsの性能はitemsより優れていました。）
for key, value in dic.iteritems():
  print(key, value)
```

## ビューオブジェクトについて
辞書が持っている列挙用メソッド`keys` `values` `items`が返すオブジェクトについて紹介します。

これらのメソッドはビューオブジェクトと呼ばれるオブジェクトを返します。

ビューオブジェクトは、辞書のように要素を追加できず、主に列挙に関する機能だけ提供します。
ビューオブジェクトはソース辞書を参照しているため、ソース辞書に要素を追加した場合は同期的に動作します。

``` Python
dic = {"a": 0}
keys = dic.keys()
# => dict_keys(['a'])

values = dic.values()
# => dict_values([0])

items = dic.items()
# => dict_items([('a', 0)])

# このように列挙処理が可能
for key, value in items:
  print(key, value)
```

## 要素数を調べる
辞書に登録された要素数を調べる方法を紹介します。

``` Python
dic = {}
len(dic)
# => 0
```

## キーの存在を確認する
辞書に指定したキーが登録されているか調べる方法を紹介します。

`in`を使うことで、キーが存在するか調べることができます。
`not`を使うことで、キーが存在していないことも調べることができます。

``` Python
dic = {"a": 0}
"a" in dic
# => True

"b" not in dic
# => True

not "b" in dic
# => True
```

複数のキーを調べるには、`all`(すべての要素がTrueであるか判定)や`any`(いずれかの要素がTrueであるか判定)と、for文やリスト内包表記などと組み合わせて実現します。

``` Python
dic = {"a": 0, "b": 0}

all(key in dic for key in {"a", "b"})
# => True

all(key in dic for key in {"a", "c"})
# => False

any(key in dic for key in {"a", "c"})
# => True

any(key in dic for key in {"c", "d"})
# => False
```

紹介したコードは、if文などと組み合わせることができます。

``` Python
if "a" in dic:
  ...

if all(key in dic for key in {"a", "b"}):
  ...
```

## 要素をフィルターする
辞書から任意の要素を抽出する方法を紹介します。
辞書内包表記は書き方が独特ですが、最も性能に優れた方法ですので、コードが長いなど可読性に問題がない場合は積極的に使いましょう。

``` Python
dic = {"a": 0, "b": 0}

# for文
result = {}
for key, value in dic.items():
  if key in {"a"}:
    result[key] = dic[key]
# => {"a": 0}

# フィルター関数
# キーと値が格納されたtuppleを評価する。インデックスでキー(0)と値(1)を取得できる。
result = dict(filter(lambda key_value: key_value[0] in {"a"}, dic.items()))
# => {"a": 0}

# 辞書内包表記
result = {key:value for key, value in dic.items() if key in {"a"}}
# => {"a": 0}
```



## シャローコピーする
辞書をコピーする方法を紹介します。
いくつか実現方法がありますが、`copy`メソッドだけ覚えればよいでしょう。

``` Python
src = {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 30}}

# 方法１
dest1 = dict(**src)

# 方法２
dest2 = dict(src)

# 方法３
dest3 = src.copy()
```

上記で紹介したコピーはいわゆるシャローコピーです。
ネストした辞書等の値はコピーされず、オブジェクトの参照を共有するため、副作用があることに注意してください。

以下に、副作用が生じている例を紹介します。

``` Python
print(src)   # => {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 30}}

dest1["nest"]["age"] = 0
print(src)   # => {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 0}}
print(dest1) # => {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 0}}

dest2["nest"]["age"] = 1
print(src)   # => {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 1}}
print(dest2) # => {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 1}}

dest3["nest"]["age"] = 2
print(src)   # => {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 2}}
print(dest3) # => {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 2}}

print(src)  # => {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 2}}
print(dest1)  # => {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 2}}
print(dest2)  # => {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 2}}
print(dest3)  # => {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 2}}
```

`src["nest"]`に登録されている辞書の値が影響を受けていますね。
このような挙動を嫌う場合は、次章のディープコピーを用いてください。

:::message alert
- プリミティブ型（整数や文字列）など単一の値は状態が分離されますが、コンテナ型（辞書やリストなど）は内包している値が共有されてしまうことに注意しましょう
:::

## ディープコピーする
ディープコピーの方法を紹介します。
ネストした値までコピーしたい場合は、`copy`モジュールの`deepcopy`で実現できます。

シャローコピーにおける副作用を避けたい場合に利用しましょう。

``` Python
import copy
src = {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 30}}
dest = copy.deepcopy(src)

# 結果確認
dest["nest"]["age"] = 5
print(src)   # => {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 30}}
print(dest) # => {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 5}}
```

# ソート編
辞書をソートする方法を紹介します。

## デフォルトの列挙順序について
Python3.7からは、辞書が返す要素の順序は挿入順序（更新時は順序に影響はありません）になりました。
Python3.7未満では、順序に取り決めはありません（環境依存）。

Python3.7未満で挿入順序を取り扱う場合は、[`OrderedDict`](#順序性を保持した辞書を作成する)を利用してください。

## 数値をソートする
`sorted`関数は、任意のキーでソートされたリストを返します。
keyにソート用の関数を渡すと、その関数の戻り値の大小が昇順でソートされます。

``` Python
# 数値でをソートする
dic = {"a": 1, "b": 0, "c": -1}

# 値を昇順にソートし、値をリスト化する
sorted(dic.values(), key=lambda x: x)
# => [-1, ,0 ,2]

# 値を昇順にソートし、値をリスト化する（keyを省略した場合は、暗黙的に列挙された値の大小が評価されます）
sorted(dic.values())
# => [-1, ,0 ,2]

# 値を昇順にソートし、要素をリスト化する
sorted(dic.items(), key=lambda x: x[1])
# => [('c', -1), ('b', 0), ('a', 1)]

# 値を降順にソートし、要素をリスト化する
sorted(dic.items(), key=lambda x: -1 * x[1])
# => [('a', 1), ('b', 0), ('c', -1)]

# 値を絶対値を昇順順にソートし、要素をリスト化する
sorted(dic.items(), key=lambda x: abs(x[1]))
# => [('b', 0), ('a', 1), ('c', -1)]

# このようにソートされたキーと値を処理することができます
for key, value in sorted(dic.items()):
    print(key, value)
```

## 文字列をソートする
文字列も`sorted`関数を利用し、同様にソートできます。

文字列にはそれぞれ文字コードが割り当てられており、文字コードに基づいた辞書順となります。
辞書順は、先頭の文字順で並び、２文字目以降も同様に繰り返し並び替えられるイメージになります。

なお、文字コードは、`ord`関数で確認できます。

``` Python
dic = {"a": "a", "b": "12", "c": "A", "d": "AA", "e": "2", "f": "1"}

# 単純に値でソート
sorted(dic.items(), key=lambda x: x[1])
# => [('f', '1'), ('b', '12'), ('e', '2'), ('c', 'A'), ('d', 'AA'), ('a', 'a')]

# 大小文字区別なくソート（全て小文字にして比較）
sorted(dic.items(), key=lambda x: str.lower(x[1]))
# => [('f', '1'), ('b', '12'), ('e', '2'), ('a', 'a'), ('c', 'A'), ('d', 'AA')]

# 文字コード確認
ord("0")
# => 48

ord("A")
# => 65

ord("a")
# => 97
```

## 逆順にする
`sorted`関数に`reverse=True`を指定するか、`reversed`関数を利用し、列挙順序を逆にできます。

ただし、Python3.8未満で辞書およびにビューオブジェクトに対して`reversed`を利用すると、`TypeError: object is not reversible`が発生します。
Python3.8未満の場合は、`OrderedDict`を利用するか`sorted`関数を利用してください。

``` Python
dic = {"a": 0, "b": 1}

for key in sorted(dic.keys(), reverse=True):
  print(key)

for key in reversed(dic.keys()):
  print(key)
```

# マージ編
２つ以上の辞書をマージして、１つの辞書にしたい場合の実現方法を紹介します。
方法により挙動が異なるので、状況に応じて使い分けてください。

## マージする（衝突するキーは許容しない）
キーが衝突した場合に例外を発生させるマージ方法を紹介します。
以下のように、`dict`関数とアンパック記法`**`を用いることで実現できます。(Python3.5以降)

``` Python
dic = dict(**{}, **{"name": "test"})
# => {"name": "test"}

dic1 = {"name": "bob", "age": 20}
dic2 = {"name": "mary"}

# キーが衝突する場合はマージ不可
dic = dict(**dic1, **dic2)
# => TypeError: func() got multiple values for keyword argument 'name'

# キーワード引数と組み合わせることも可能
dic = dict(key1="val1", key2="val2", **dic1}
# => {"key1": "val1", "key2": "val2", "name": "bob", "age": 20}
```

:::message
- キーの衝突を検知したい場合は、`dict`関数とアンパック記法`**`を用いましょう
- Python3.5から辞書作成時に複数のアンパック記法`**`が利用可能になり、マージが簡単になりました。[^2]
:::

この方法は、`dict`関数に限った話でなく、関数に応用が可能です。

``` Python
def func(**kwargs):
  pass

func(**{}, **{"name": "test"})

# 可変長キーワード引数にも、重複してキーが渡ってくることはありません
def func(name, age, **kwargs):
  pass

func(**dic1, **dic2)
# => TypeError: func() got multiple values for keyword argument 'name'
```


## マージする（衝突するキーの値は上書き）
キーが衝突した場合、値を上書きするマージ方法を紹介します。

``` Python
dic1 = {"name": "bob", "age": 20}
dic2 = {"name": "mary"}

# 方法１（Python3.5から辞書作成時に展開記法が使用可能）
dic = {**dic1, **dic2}
# => {"name": "mary", "age": 20}

# リテラル表記と組み合わせて使用することも可能
dic = {"name": "bob", "age": 20, **dic2}
# => {"name": "mary", "age": 20}

# 方法2
dic = dict(dic1, **dic2)
# => {"name": "mary", "age": 20}

# 方法３（Python3.9から和集合演算子が使用可能）
dic = dic1 | dic2
# => {"name": "mary", "age": 20}

# 方法４
# ソースの辞書が更新されるため注意
dic1.update(dic2)
# => {"name": "mary", "age": 20}

# 方法５（Python3.9から累算代入演算子が使用可能）
# ソースの辞書が更新されるため注意
dic1 |= dic2
# => {"name": "mary", "age": 20}
```

:::message
- Python3.5以降は、アンパック記法`**`を積極的に利用しましょう
- Python3.9以降は、`|`と`|=`を積極的に利用しましょう
:::

前章で紹介した、衝突するキーは許容しないマージ方法と混同しないように注意しましょう。

``` Python
dic = {**dic1, **dic2}
# => {"name": "mary", "age": 20}

dic = dict(**dic1, **dic2)
# => TypeError: func() got multiple values for keyword argument 'name'
```

:::message alert
- `{}`と`dict`関数は、挙動が異なるので注意が必要です。
:::


## ディープマージ（ネストした辞書をマージ）する
ディープマージの方法を紹介します。

前章で紹介したマージは、ネストされた辞書同士のマージは行ってくれません。
例を見てみましょう。

``` Python
dic1 = {"nest": {"name": "bob", "age": 20}}
dic2 = {"nest": {"name": "mary"}}

# 方法１
{**dic1, **dic2}
# => {'nest': {'name': 'mary'}}

# 方法２
dict(dic1, **dic2)
# => {'nest': {'name': 'mary'}}

# 方法３
dic1 | dic2
# => {'nest': {'name': 'mary'}}

# 方法４
dic1.update(dic2)
# => {'nest': {'name': 'mary'}}

# 方法５
dic1 |= dic2
# => {'nest': {'name': 'mary'}}
```

ネストした辞書は、辞書ごと置き換えられています。
場合によっては、以下のような結果が欲しいかもしれません。

``` Python
a = {"nest": {"name": "bob", "age": 20}}
b = {"nest": {"name": "mary"}}

dic = deep_merge(a, b)
# => {'nest': {"name": "mary", "age": 20}}

```

ディープマージは、標準機能としては提供されていないため、関数を自作したり、ライブラリを使用する必要があります。
参考までに、ディープマージするためのコード例を載せておきます。

``` Python
def deep_merge(dic1, dic2):
  import copy
  src1 = copy.deepcopy(dic1)
  src2 = copy.deepcopy(dic2)
  return deep_merge_sub(src1, src2)

def deep_merge_sub(dic1, dic2):
  for key in dic2.keys():
    if isinstance(dic2[key], dict):
      deep_merge_sub(dic1[key], dic2[key])
    else:
      dic1[key] = dic2[key]
  return dic1

a = {"nest": {"name": "bob", "age": 20}}
b = {"nest": {"name": "mary"}}

dic = deep_merge(a, b)
# => {'nest': {"name": "mary", "age": 20}}
```

上記コードは、ネストした辞書をマージしますが、リストのマージなどは未考慮です。

# 特殊な辞書編

## 初期値を保持した辞書を作成する
初期値保持した辞書を作成する方法を紹介します。

例えば、履歴書を模した辞書に家族構成と学歴を登録するとしましょう。
家族構成と学歴は、リストにいくつか値を登録することを想定しています。

``` Python
person = {}
person["familiy"].append("father")  # => KeyError: 'familiy'
person["background"].append("2000/4/1 Python高校入学")
person["background"].append("2003/4/1 Python大学入学")
```

上記のコードは、２行目でエラーとなりました。
辞書初期化時に、リストを要素として登録していないので当然の結果ですね。

このような場合、初期化時にキーに対してリストを登録しておくのは１つの解決手段ですが、`defaultdict`を用いることも可能です。
`defaultdict`は、コンストラクタにインスタンスを生成する引数無しで実行できる関数を渡すことで、その関数が返したインスタンスを初期値とします。

``` Python
from collections import defaultdict

# インスタンスを生成する関数をコンストラクタに渡します
person = defaultdict(list)

person["family"].append("father")
person["background"].append("2000/4/1 Python高校入学")
person["background"].append("2003/4/1 Python大学入学")
# => defaultdict(<class 'list'>, {'family': ['father'], 'background': ['2000/4/1 Python高校入学', '2003/4/1 Python大学入学']})
```

思惑通りいきました。
コンストラクタに渡す関数は、当然list以外でもインスタンスを返す関数なら何でも大丈夫です。

intやstrを普段呼び出すことはほぼないですが、引数無しで呼び出すとデフォルト値が返るため、intやstrを渡すこともできます。

``` Python
dic1 = defaultdict(int)
dic1["new"]
# => 0

dic2 = defaultdict(str)
dic2["new"]
# => ""
```


## 順序性を保持した辞書を作成する
要素の順序性を保持した辞書を作成する方法を紹介します。

``` Python
from collections import OrderedDict
dic = OrderedDict()
for key, value in dic.items():
  print(f"{key} : {value}")

```

Python3.7以降は、標準の辞書も順序を保持するようになったので、使わないでいいでしょう。
ただし、3.7では`OrderedDict`の`__reversed__`が標準辞書でサポートされておらず、`reversed`関数などによる逆順操作ができません。
（Python3.8からサポート）

:::message
- Python3.7以降は、標準の辞書も順序を保持するようになったので、使う場面が減った [stackoverflow](https://stackoverflow.com/questions/50872498/will-ordereddict-become-redundant-in-Python-3-7)
- Python3.8以降は、標準の辞書も__reverse__をサポートするようになった  [issue33462](https://bugs.python.org/issue33462)
:::

## 要素をカウントする辞書（カウンター）を作成する
``` Python
from collections import Counter
```

## 要素の上書きを禁止した辞書を作成する
意図せず値が上書きされることを防ぐため、要素の上書きを禁止した辞書を作成したい場合があるかもしれません。
標準では機能が用意されていませんが、以下のように`__setitem__`をオーバーライドすることで実現可能です。

``` Python
class OnceDict(dict):
    def __setitem__(self, key, value):
        if key in self:
            raise KeyError(f"{key} is already exists.")
        super().__setitem__(key, value)


dic = OnceDict({"a": 1})
dic["a"] = 3
# => KeyError: 'a is already exists.'
```


# まとめ
これまでの検証結果をまとめました。
Python3.9を軸にルールを設けていますので、バージョン毎にカスタマイズしてご利用ください。

同じ結果を返す複数の実現方法がある場合は、ニュアンスが伝わりやすい方法を用いましょう。


| 要求      | コード例 | 備考 | バージョン |
| ---- | ---- | ---- | ---- |
| 作成 | dic = {"key": "value"} | `dict`関数に比べ性能が２倍以上優れる | |
| 作成 | dic = dict(key="value") | keyに予約語や整数リテラルを渡した場合、SyntaxErrorが発生 | |
| 登録 | dic["name"] = val | | |
| 登録/取得 | dic.setdefault("key") | キーが存在しない場合、Noneを登録した上で、キーの値を返す | |
| 登録/取得 | dic.setdefault("key", 0) | キーが存在しない場合、第２引数の値を登録した上で、キーの値を返す | |
| 取得 | dic["name"] | キーが存在しない場合、KeyErrorが発生 | |
| 取得 | dic.get("name") | キーが存在しない場合、Noneを返す。第２引数にNoneを指定した方がニュアンスが明確でよい | |
| 取得 | dic.get("name", None) | キーが存在しない場合、第２引数の値を返す | |
| 削除 | del dic["name"] | キーが存在しない場合、KeyErrorが発生 | |
| 削除/取得 | dic.pop("name") | キーが存在しない場合、KeyErrorが発生 | |
| 削除/取得 | dic.pop("a", None) | キーが存在しない場合、第２引数の値を返す | |
| 削除/取得 | dic.popitem() | 要素を無作為に１つ削除し、その値を返す。[^4] | |
| キー変更 | dic["new"] = dic.pop("old") | | |
| 全削除 | dic.clear() | | |
| 列挙 | for key in dic: | `keys`を使おう | |
| 列挙 | dic.keys() | キーを列挙する | |
| 列挙 | dic.values() | 値を列挙する | |
| 列挙 | dic.items() | キーと値のタプルを列挙する | |
| 列挙 | dic.iteritems() | Python3で`items`に統合された[^3] | <=2.* |
| コピー | dict(\**dic) | `copy`メソッドを使おう | |
| コピー | dict(dic) | `copy`メソッドを使おう | |
| コピー | dic.copy() | シャローコピーする | |
| コピー | copy.deepcopy(dic) | ディープコピーする | |
| マージ/作成 | dict(\**dic1, \**dic2) | キーが衝突する場合、TypeErrorが発生 | ^3.5 |
| マージ/作成 | dict(key1=1, \**dic2) | キーが衝突する場合、TypeErrorが発生 |  |
| マージ/作成 | func(\**dic1, \**dic2) | キーが衝突する場合、TypeErrorが発生 | ^3.5 |
| マージ/作成 | {\**dic1, \**dic2} | 和集合演算子`|`を使おう | ^3.5 |
| マージ/作成 | dict(dic1, \**dic2) | 和集合演算子`|`を使おう | |
| マージ/作成 | dic1 \| dic2 | キーが衝突する場合、右辺の値で上書き | ^3.9 |
| マージ/作成 | func(\**(dic1 \| dic2)) | キーが衝突する場合、右辺の値で上書き  | ^3.9 |
| マージ/更新 | dic1.update(dic2) | 累算代入演算子`|=`を使おう |  |
| マージ/更新 | dic1 \|= dic2 | キーが衝突する場合、右辺の値で上書き  | ^3.9 |
| 初期値保持 | defaultdict(list) | コンストラクタに渡したファクトリ関数の戻り値を初期値とする辞書を作成 | |
| 順序性保持 | OrderedDict() | Python3.7以降はdictが`OrderedDict`相当の順序を保持するようになったため不要 | <=3.6.* |
| カウンター | Counter() | | |
| 上書禁止 | | 自作する（`__setitem__`等をオーバーライド） | |


[^2]: pep448 [リンク](https://www.python.org/dev/peps/pep-0448/)
[^3]: [pep-3106](https://www.python.org/dev/peps/pep-3106/)にて、`iteritems`はPython3で`items`に統合されました。
[^4]: [pep-0468](https://www.python.org/dev/peps/pep-0468/)にて、辞書の要素は順序を保持するようになったが、過去との互換性やpopitemへの挙動は言及されていないため、削除順を期待すべきでない。

