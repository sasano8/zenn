---
title: "Pythonの辞書操作チートシート"
emoji: "😸" # アイキャッチとして使われる絵文字（1文字だけ）
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["python"]
published: true
---

# 概要
本記事では、**一般的な辞書操作とそれらの細かい挙動に応じた使い分け**を紹介しています。

本記事[チートシート](#チートシート)のような要求操作に対する実装例をコンパクトに俯瞰できるドキュメントが欲しかったのですが、画面幅の都合で詳細が伝わりきらないため、ひととおり執筆するハメになりました（汗）。

本記事をひととおりお読みいただいた後は、ガイドラインとして[チートシート](#チートシート)を活用いただければ幸いです。

# 検証環境
- Python3.9.0

# 対象読者
読者のメインターゲットは、Python3.5以上のユーザーです。
検証環境は3.9ですが、Python3.5系以上の互換性は調査・考慮しています。

辞書にフォーカスした解説のため、基礎的な知識・単語については、その他の記事等で補完ください。

Python中級者以上の方は、目次と[チートシート](#チートシート)を見て気になった章だけお読みください。

# 公式ドキュメント
最新の仕様や、より正確な仕様の理解には、公式ドキュメントも参照ください。

https://docs.python.org/ja/3/library/stdtypes.html#dict

# 基礎編

## 辞書を作成する

### `{}`で辞書を作成する
辞書リテラル`{}`で辞書（以後、`dict`とする）を作成できます。

性能面でも優れているもっともポピュラーな方法ですので、基本的にこの方法を使用しましょう。
``` Python
dic = {"key": "test"}
```

### キーワード引数から`dict`を作成する
`dict`関数でキーワード引数に値を渡すと、そのままキーと値として定義できます。

ただし、`dict`関数を使用する場合、次の言語仕様上の制約があります。

- キーワード引数に予約語は使用できません
- キーワード引数に数値は使用できません

``` Python
dic = dict(key="test")

# 例外
dic = dict(from=0)
dic = dict(1=0)
# => SyntaxError: invalid syntax
```

### キーと値のタプルリストから`dict`を作成する
`dict`関数に、キーと値のタプルを要素とするリストを渡すと、`dict`を作成できます。

``` Python
dic = dict([("key1", 1), ("key2", 2)])
# => {'key1': '1', 'key2': '2'}
```

### 辞書内包表記で`dict`を作成する
辞書内包表記を用いると、イテラブル[^10002]の処理結果から`dict`を作成できます。
`{キー:値 for 変数名 in イテラブル}`のように記述します。

``` Python
dic = {str(x):x for x in range(5)}
# => {'0': 0, '1': 1, '2': 2, '3': 3, '4': 4}
```

辞書内包表記を、リスト内包表記で書き直すと次のようになります。

``` Python
arr = [(str(x), x) for x in range(5)]
dic = dict(arr)
# => {'0': 0, '1': 1, '2': 2, '3': 3, '4': 4}
```

### キーのリストから`dict`を作成する

### `fromkeys`
`fromkeys`は、第1引数に与えられたイテラブルをキーとする`dict`インスタンスを生成します。

- 第1引数：　キーとするイテラブル
- 第2引数：　初期値とする値。省略時は`None`

``` Python
dic = dict.fromkeys(["a", "b"])
# => {'a': None, 'b': None}

dic = dict.fromkeys(["a", "b"], 0)
# => {'a': 0, 'b': 0}
```

注意点として、初期値とする値をミュータブルな値にしてしまうと、同じオブジェクトを参照するため、副作用に気を付けましょう。

``` Python
dic = dict.fromkeys(["a", "b"], [])
# => {'a': [], 'b': []}

# "a"のリストにのみ追加される想定だが、同じオブジェクトを参照しているため、すべてに影響が生じてしまう
dic["a"].append(1)
# => {'a': [1], 'b': [1]}
```

辞書内包表記で代替可能ですので、`fromkeys`は忘れてしまってもよいでしょう。

``` Python
dic = {key:[] for key in ["a", "b"]}
# => {'a': [], 'b': []}

dic["a"].append(1)
# => {'a': [1], 'b': []}
```

:::message
- `{}`は`dict`関数に比べ、性能が2倍以上優れる
- dict関数でキーワード引数を利用するとキーワード引数が要素（文字列キーと値）として定義される。ただし、キーが予約語や整数などの場合、`SyntaxError`となる
:::

## 要素（キーと値）を登録する
キーを指定し、値を渡すことで要素を登録できます。
すでに対象キーが存在する場合は、値が上書きされます。

``` Python
dic = {}
dic["key"] = "val"
```

### `__setitem__`
`dic[key] = value`は、`dic.__setitem__(key, value)`と等価です。

``` Python
dic = {}
dic.__setitem__("key", "val")
```

### `setdefault`
`setdefault`は、キーが登録されていない場合はデフォルト値を登録したうえで、キーに対応する値を返します。

- 第1引数：　キー
- 第2引数：　キーが登録されていない場合に登録する値。省略時は`None`を登録

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

## キーに対応する値を取得する
キーに対応する値を取得には、次のようにします。
キーが存在しない場合は、`KeyError`が発生します。

``` Python
dic = {"name": "test"}
val = dic["name"]
```

### `__getitem__`
`dic[key]`は、`dic.__getitem__(key)`と等価です。

``` Python
dic = {"name": "test"}
val = dic.__getitem__("name")
```

### `get`
`KeyError`を無視したい場合は、`get`メソッドを使用できます。

`get`は、指定したキーの値を返します。
指定したキーが存在しない場合は、第2引数の値を返します。
- 第1引数：　キー
- 第2引数：　キーが登録されていない場合に返す値。省略時は`None`を返す

``` Python
# キーが存在しない場合は、Noneが返る
val = dic.get("name")

# キーが存在しない場合は、第２引数の値が返る
val = dic.get("name", None)
```

### `setdefault`
デフォルト値の登録と値の取得を同時に行いたい場合は、`setdefault`メソッドを利用しましょう。

``` Python
# キーが存在しない場合は、第２引数の値を登録した上で、その値を返す
val = dic.setdefault("name", None)
```

## 要素を削除する

### `del`
`del`は、指定したキーを削除します。
- 指定したキーが存在しない場合は、`KeyError`が発生する
- 削除以外の余計な処理を行わないので性能がもっとも優れる

``` Python
del dic["name"]
```

### `pop`
要素を削除するとともに、削除された値を受け取りたい時や`KeyError`を無視したい場合は、`pop`メソッドを使用します。

`pop`は、指定したキーを削除し、値を返します。
- 第1引数：　キー
- 第2引数：　キーが登録されていない場合に返す値。省略時は`KeyError`が発生

``` Python
# キーが存在しない場合は、KeyErrorが発生する
val = dic.pop("name")

# キーが存在しない場合は、第２引数の値を返す
val = dic.pop("a", None)
```

### `popitem`
`popitem`メソッドは、要素を1つ削除し、その値を返します。

- `dict`の要素が空の場合、`KeyError`を送出する
- Python3.7から、最後の要素から削除されることが保証された[^1]
- Python3.7未満は、無作為な順序で要素を削除する

``` Python
key_value = dic.popitem()
```

### 複数の要素を削除する
複数の要素を削除したい場合は、次のようにします。
なお、`del`はリスト内包表記とともに利用できません。

``` Python
dic = {"key1": 1, "key2": 2, "key3": 3}
some_keys = ["key1", "key2"]

# 方法１
for key in some_keys:
  del dic[key]

# 方法２(パフォーマンス的には方法1を推奨)
[dic.pop(key, None) for key in some_keys]
```

### すべての要素を削除する

### `clear`
すべての要素を削除します。

``` Python
dic.clear()
# => {}
```

## キーを変更する
`pop`を用いることで簡潔に実現できます。

``` Python
# キーが存在しない場合は、KeyErrorが発生する
dic["new"] = dic.pop("old")
```

## 要素（キーや値）を列挙する
要素（キーや値）を列挙するには、次のようにします。

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
`dict`が持っている列挙用メソッド`keys` `values` `items`は、ビューオブジェクトを返します。
ビューオブジェクトは、主に列挙に関する機能だけ提供します。

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

ビューオブジェクトは、ソースに要素を追加した場合、同期的に動作します。

``` Python
dic = {"a": 0}
items = dic.items()

# ソースに要素を追加・更新した場合は同期的に動作
dic["b"] = 0
items
# => dict_items([('a', 0), ('b', 0)])
```

# コピー編

## シャローコピーする
シャローコピーの方法を紹介します。

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

シャローは浅いを意味し、ネストした`dict`等の値はコピーされず、ただ同じ実体を参照するだけです。
そのため、次のような副作用が生じます。

``` Python
src = {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 30}}

dest1 = dict(**src)
dest2 = dict(src)
dest3 = src.copy()

# コピーしたdictを変更したつもりが、ソースまで影響を受けてしまう
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

:::message alert
- プリミティブ型（整数や文字列）など単一の値は状態が分離されるが、コンテナ型（`dict`や`list`など）は内包している値が共有されてしまうことに注意
:::

## ディープコピーする
ディープコピーの方法を紹介します。

`copy`モジュールの`deepcopy`で実現できます。
ディープコピーは、ネストされた`dict`も再帰的にコピーします。

``` Python
import copy
src = {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 30}}
dest = copy.deepcopy(src)

# 結果確認
dest["nest"]["age"] = 5
print(src)   # => {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 30}}
print(dest) # => {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 5}}
```

## コピーの挙動を変更する
コピーの独自実装をする場合は、`__copy__`（シャローコピー用）メソッドと`__deepcopy__`（ディープコピー用）メソッドを実装します。

実装例については、割愛します。

``` Python
class MyDict(dict):
  def __copy__(self):
    ...
  def __deepcopy__(self, memo):
    ...
```

# マージ編
2つ以上の`dict`をマージして、1つの`dict`にしたい場合の実現方法を紹介します。
方法により挙動が異なるので、状況に応じて使い分けてください。

## マージする（衝突するキーの値は上書き）
キーが衝突した場合、値を上書きするマージ方法を紹介します。

バージョン毎にプラクティスが異なるため、バージョンごとに紹介します。

### Python3.5未満
`dict`関数の第1位置引数にソース`dict`を渡し、アンパック記法を併用することでマージされた`dict`を作成できます。
ソース`dict`を直接更新する場合は、`update`メソッドが使用できます。

``` Python
dic1 = {"name": "bob", "age": 20}
dic2 = {"name": "mary"}

# 新たにdictを作成
dic = dict(dic1, **dic2)
# => {"name": "mary", "age": 20}

# ソースdictを更新
dic1.update(dic2)
# => {"name": "mary", "age": 20}
```

### Python3.5以上
辞書リテラル内に、アンパック記法`**`を使用できるようになりました[^2]。
モダンなアプリケーションでは、よく用いられます。

``` Python
dic1 = {"name": "bob", "age": 20}
dic2 = {"name": "mary"}

# 新たにdictを作成
dic = {**dic1, **dic2}
# => {"name": "mary", "age": 20}

# ソースdictを更新
dic1.update(dic2)
# => {"name": "mary", "age": 20}
```

### Python3.9以上
Python3.9からは、和集合演算子`|`と累算代入演算子`|=`が導入され、マージする意思をより明示的に表現可能になりました[^5]。

``` Python
dic1 = {"name": "bob", "age": 20}
dic2 = {"name": "mary"}

# 新たにdictを作成
dic = dic1 | dic2
# => {"name": "mary", "age": 20}

# ソースdictを更新
dic1 |= dic2
# => {"name": "mary", "age": 20}
```

:::message
- Python3.5以降は、アンパック記法`**`を積極的に利用しましょう
- Python3.9以降は、`|`と`|=`を積極的に利用しましょう
:::

## マージする（衝突するキーは許容しない）
Pythonの言語仕様上、関数に渡したキーワード引数が衝突すると`TypeError`が発生します。

この仕様を利用して、衝突するキーは許容しないマージを実現します。

``` Python
dic1 = {}
dic2 = {"name": "test"}

dic = dict(**dic1, **dic2)
# => {"name": "test"}

# キーワード引数と組み合わせることも可能
dic = dict(key1="val1", key2="val2", **dic2}
# => {"key1": "val1", "key2": "val2", "name": "test"}
```

キーが衝突した場合は、`TypeError`が発生します。

``` Python
dic1 = {"name": "bob", "age": 20}
dic2 = {"name": "mary"}

# キーが衝突する場合はマージ不可
dic = dict(**dic1, **dic2)
# => TypeError: func() got multiple values for keyword argument 'name'
```

この方法は、`dict`関数に限った話でなく、関数全般に応用が可能です。

``` Python
dic1 = {}
dic2 = {"name": "test"}

def func(**kwargs):
  pass

func(**dic1, **dic2)
```

関数が可変長キーワードを受け入れ可能な場合も、重複したキーが渡ってくるようなことはありません。

``` Python
# 可変長キーワード引数に、重複してキーが渡ってくることもありません
dic1 = {"name": "bob", "age": 20}
dic2 = {"name": "mary"}

def func(name, age, **kwargs):
  pass

func(**dic1, **dic2)
# => TypeError: func() got multiple values for keyword argument 'name'
```

キーに空文字・記号・予約語が含まれていても問題ありません。

``` Python
dic = {"": 0, "@": 0, "from": 0}
dict(**dic)
# => {'from': 0, '@': 0, '': 0}
```

ただし、この方法で使用できるキーは文字列に限ります。

``` Python
dic = {0: 0}
dict(**dic)
# => TypeError: func() keywords must be strings
```

:::message
- キーの衝突を検知したい場合は、`dict`関数とアンパック記法`**`を使用する
- Python3.5から`dict`作成時に複数のアンパック記法`**`が利用可能になり、マージが簡単になった
- この方法で使用できるキーは、文字列に限定される
:::

### `{}`と`dict`の混同に注意
`{}`によるマージと`dict`関数によるマージの挙動は異なるため、混同しないように注意しましょう。

``` Python
dic1 = {"name": "bob", "age": 20}
dic2 = {"name": "mary"}

dic = {**dic1, **dic2}
# => {"name": "mary", "age": 20}

dic = dict(**dic1, **dic2)
# => TypeError: func() got multiple values for keyword argument 'name'
```

:::message alert
- `{}`と`dict`関数の挙動を使い分けてマージしましょう。
:::


## ディープマージ（ネストした辞書をマージ）する
前章で紹介したマージは、ネストされた`dict`どうしのマージは行ってくれません。
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

ネストした`dict`は、`dict`ごと置き換えられています。
ここでは、次のようにネストした`dict`を再帰的にマージする方法を紹介します。

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

# 問い合わせ編

## キーの存在を調べる
`in`を使うことで、キーが存在するか調べることができます。
`not`を組み合わせることで、キーが存在していないことも調べることができます。

``` Python
dic = {"a": 0}
"a" in dic
# => True

"b" not in dic
# => True

not "b" in dic
# => True
```

## 値の存在を調べる
値の存在を調べる場合は、`in`と`values`メソッドを併用します。

``` Python
dic = {"a": 0}
0 in dic.values()
# => True
```

キーに対する`in`はハッシュ探索のためコストが少ないですが、値に対する`in`は線形探索となるためコストが大きいです。
何度も走査する場合は、`set`型などのハッシュ探索を実装したオブジェクトを使用しましょう。

``` Python
dic = {"a": 0}
values = set(dic.values())
0 in values
```

## 複数のキーの存在を調べる
複数のキーを調べるには、`all`（すべての要素がTrueか判定）や`any`（いずれかの要素がTrueか判定）と、for文やリスト内包表記などと組み合わせて実現します。

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

紹介したコードは、if文などと組み合わせて使用ください。

``` Python
if "a" in dic:
  ...

if all(key in dic for key in {"a", "b"}):
  ...
```

## 要素をフィルタする
`dict`から任意の要素を抽出するには、次のようにします。

``` Python
dic = {"a": 0, "b": 0}
condition = {"a"}

result = {}
for key, value in dic.items():
  if key in condition:
    result[key] = dic[key]
# => {"a": 0}
```

なお、`condition = {"a"}`は`set`インスタンスを生成しています。
`set`インスタンスは、ユニークなリスト（値を持たない`dict`のようなもの）で、ハッシュ探索による高速な検索を行えます。

### 辞書内包表記
上記のコードは、やや冗長です。辞書内包表記を用いることでより簡潔にできます。
書き方が独特ですが、性能面でも優遇されているので、積極的に使いましょう。

``` Python
dic = {"a": 0, "b": 0}
condition = {"a"}

result = {key:value for key, value in dic.items() if key in condition}
# => {"a": 0}
```

### `filter`
`filter`関数は、第1引数に評価関数、第2引数にイテラブルを取ります。
各要素を評価関数で評価し、`True`と判定される要素のみを抽出するイテレータ[^10001]を生成します。

評価関数は1つの引数を取り、キーと値のタプルを受け取ります。

``` Python
dic = {"a": 0, "b": 0}
condition = {"a"}

# キーが"a"のみ抽出する
result = dict(filter(lambda key_value: key_value[0] in condition, dic.items()))
# => {"a": 0}

# 値が"a"のみ抽出する
result = dict(filter(lambda key_value: key_value[1] in condition, dic.items()))
# => {}
```

## 要素数を調べる
要素数を調べる場合は、`len`を使用します。

``` Python
dic = {}
len(dic)
# => 0
```

## 集計する
要素を集計したい場合は、`Counter`を利用できます。
詳しい使い方については、[要素を集計した辞書](#要素を集計した辞書を作成する)を参照ください。

``` Python
from collections import Counter

dic = {
    "Google": "America",
    "Amazon": "America",
    "Facebook": "America",
    "Apple": "America",
    "Toyota": "Japan"
}

countries = dic.values()
Counter(countries)
# => Counter({'America': 4, 'Japan': 1})
```

# ソート編
`dict`をソートする方法を紹介します。

## デフォルトの順序について
Python3.7からは、`dict`が返す要素の順序は次のようになりました。

- 挿入順で要素を返す[^1]
- 要素の更新は順序に影響を与えない

Python3.7未満は順序不定ですので、挿入順序を管理する場合は[`OrderedDict`](#挿入順を保持した辞書を作成する)を利用ください。

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
辞書順は、先頭の文字順で並び、2文字目以降も同様に繰り返し並び替えられるイメージになります。

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

### `sorted`
`sorted`関数に`reverse=True`を指定し、イテラブルを渡すと、列挙順序を逆にした`list`を返します。

``` Python
dic = {"a": 0, "b": 1}

sorted(dic.keys(), reverse=True)
# => ['b', 'a']
```

### `reversed`
`reversed`関数に、リバーシブル[^10000]を渡すと、列挙順序を逆にしたイテレータを返します。

ただし、Python3.8未満では`dict`およびにビューオブジェクトに対して`reversed`を使用できません[^4]。
その場合は、`sorted`関数か`OrderedDict`を利用してください。

``` Python
dic = {"a": 0, "b": 1}

list(reversed(dic.keys()))
# => ['b', 'a']
```

`reversed`はイテレータを返すため、実体化するには`list`等にイテレータを渡す必要があります。

# 特殊な辞書編

## 初期値を保持した辞書を作成する
初期値保持した`dict`を作成する方法を紹介します。

たとえば、履歴書を模した`dict`に家族構成と学歴を登録するとしましょう。
家族構成と学歴は、リストにいくつか値を登録することを想定しています。

``` Python
person = {}
person["family"].append("father")  # => KeyError: 'family'
person["background"].append("2000/4/1 Python高校入学")
person["background"].append("2003/4/1 Python大学入学")
```

上記のコードは、2行目でエラーとなりました。
`dict`初期化時に、リストを要素として登録していないので当然の結果ですね。

このような場合、`defaultdict`を用いることが可能です。

### `defaultdict`
`defaultdict`は、コンストラクタにインスタンスを生成する引数なしで実行できる関数を渡すことで、その関数が返したインスタンスを初期値とします。

次の例は、`list()`で生成されるインスタンスを初期値としています。

``` Python
from collections import defaultdict

# インスタンスを生成する関数をコンストラクタに渡します
person = defaultdict(list)

person["family"].append("father")
person["background"].append("2000/4/1 Python高校入学")
person["background"].append("2003/4/1 Python大学入学")
# => defaultdict(<class 'list'>, {'family': ['father'], 'background': ['2000/4/1 Python高校入学', '2003/4/1 Python大学入学']})
```

intやstrを渡すこともできます。

``` Python
dic1 = defaultdict(int)
dic1["new"]
# => 0

dic2 = defaultdict(str)
dic2["new"]
# => ""
```

もちろん、関数を渡すこともできます。

``` Python
def create_list():
    return ["hello"]

dic1 = defaultdict(create_list)
dic1["new"]
# => ["hello"]
```


## 挿入順を保持した辞書を作成する

### `OrderedDict`
要素の挿入順を保持した`dict`を作成するには、`OrderedDict`を使用します。

ただし、Python3.7以降は標準の`dict`も挿入順を保持するようになったので、`OrderedDict`は使わないでいいでしょう[^1]。
``` Python
from collections import OrderedDict
dic = OrderedDict()

dic["key1"] = 0
dic["key2"] = 0

for item in dic.items():
  print(item)
# => ("key1", 0)
# => ("key2", 0)
```

:::message
- Python3.7未満では、辞書の挿入順序を取り扱うために`OrderedDict`を使用する
:::

## 要素を集計した辞書を作成する

### `Counter`
要素を集計するには`Counter`というクラスが利用できます。

コンストラクタに、イテラブルを渡すと要素数を集計できます。

``` Python
from collections import Counter

data = ["tokyo", "osaka", "osaka"]
dic = Counter(data)
# => Counter({'tokyo': 2, 'osaka': 1})
```

文字列もイテラブルなため集計可能です。

``` Python
from collections import Counter

data = "すもももももももものうち"
dic = Counter(data)
# => Counter({'も': 8, 'す': 1, 'の': 1, 'う': 1, 'ち': 1})
```

`dict`の初期化と同じように、`Counter`インスタンスを生成できます。

``` Python
from collections import Counter

data = {"osaka": 1, "tokyo": 2}
dic = Counter(data)
# => Counter({'tokyo': 2, 'osaka': 1})

dic = Counter(osaka=1, tokyo=2))
# => Counter({'tokyo': 2, 'osaka': 1})
```

`Counter`は、`dict`のサブクラスのため`dict`と同じように扱うことができます。
ただし、いくつか集計用に拡張されたメソッドや異なる挙動が存在するので紹介します。

### 値を取得する
`dict`と同じようにキーを指定し、値にアクセスできます。
キーが存在しない場合は、`dict`と挙動が異なり`0`を返します。

``` Python
from collections import Counter

data = ["tokyo", "osaka", "osaka"]
dic = Counter(data)
dic["chiba"]
# => 0
```

### `update`
`dict.update`と同じように、複数の`dict`をマージできます。
`dict`では、衝突したキーの値を上書きしますが、`Counter`においては値を加算します。

``` Python
from collections import Counter

data = ["tokyo", "osaka", "osaka"]
dic = Counter(data)

dic.update({"tokyo": 2})
# => Counter({'tokyo': 3, 'osaka': 2})
```

### `subtract`
複数の`dict`をマージし、衝突したキーの値は減算します。
`update`の逆の挙動になります。

``` Python
from collections import Counter

data = ["tokyo", "osaka", "osaka"]
dic = Counter(data)

dic.subtract({"tokyo": 2})
# => Counter({'osaka': 2, 'tokyo': -1})
```

### `most_common`
値の降順で要素を返します。
引数`n`を指定でき、n個の要素を返すか、省略または`None`の場合はすべての要素が返されます。

``` Python
from collections import Counter

data = ["tokyo", "osaka", "osaka"]
dic = Counter(data)

for x in dic.most_common(1):
  print(x)
# => ('osaka', 2)

for x in dic.most_common():
  print(x)
# => ('osaka', 2)
# => ('tokyo', 1)
```

### `elements`
それぞれの値と同じ回数キーを繰り返すイテレータを返します。要素が1未満の場合は、キーは返されません。

``` Python
counter = Counter(a=4, b=2, c=0, d=-2)
sorted(counter.elements())
# => ['a', 'a', 'a', 'a', 'b', 'b']
```

## 要素の上書きを禁止した辞書を作成する
意図しない値の上書きを防ぐため、要素の上書きを禁止した`dict`を作成したい場合は、次のように`__setitem__`をオーバーライドすることで実現可能です。

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


# チートシート
これまでの検証結果をまとめました。俯瞰的に挙動を理解するためにご活用ください。

同じ結果を返す複数の実現方法がある場合は、ニュアンスが伝わりやすい方法を用いましょう。


| 要求      | コード例 | 備考 | バージョン |
| ---- | ---- | ---- | ---- |
| 作成 | `dic = {"key": "value"}` | `dict`関数に比べ性能が2倍以上優れる | |
| 作成 | `dic = dict(key="value")` | 言語仕様上、キーワード引数に予約語や数値リテラルは使用できない | |
| 作成 | `dic = dict([("key", "value")])` | キーと値のタプルから`dict`を作成 | |
| 作成 | `dic = {key:value for key, value in [("key", "value")]}` |  | |
| 作成 | `dic = dict.fromkeys(["a", "b"], [])` | キーのリストから`dict`を生成する。ミュータブルな値を初期値（第2引数）とする場合に、副作用がある。辞書内包表記を使おう | |
| 登録 | `dic["name"] = val` | キーが存在しない場合、`KeyError`が発生。`__setitem__`の糖衣構文 | |
| 登録/取得 | `dic.setdefault("key")` | キーが存在しない場合、`None`を登録したうえで、キーの値を返す | |
| 登録/取得 | `dic.setdefault("key", None)` | キーが存在しない場合、第2引数の値を登録したうえで、キーの値を返す | |
| 取得 | `dic["name"]` | キーが存在しない場合、`KeyError`が発生。`__getitem__`の糖衣構文 | |
| 取得 | `dic.get("name")` | キーが存在しない場合、`None`を返す | |
| 取得 | `dic.get("name", None)` | キーが存在しない場合、第2引数の値を返す | |
| 削除 | `del dic["name"]` | キーが存在しない場合、`KeyError`が発生 | |
| 削除/取得 | `dic.pop("name")` | キーが存在しない場合、`KeyError`が発生 | |
| 削除/取得 | `dic.pop("a", None)` | キーが存在しない場合、第2引数の値を返す | |
| 削除/取得 | `dic.popitem()` | 最後の要素を削除し、その値を返す[^1]。Python3.7未満は、無作為な順序で削除する | |
| キー変更 | `dic["new"] = dic.pop("old")` | | |
| 全削除 | `dic.clear()` | | |
| 列挙 | `for key in dic:` | `keys`を使おう | |
| 列挙 | `dic.keys()` | キーを列挙する | |
| 列挙 | `dic.values()` | 値を列挙する | |
| 列挙 | `dic.items()` | キーと値のタプルを列挙する | |
| 列挙 | `dic.iteritems()` | Python3で`items`に統合された[^3] | <=2.* |
| コピー | `dict(**dic)` | `copy`メソッドを使おう | |
| コピー | `dict(dic)` | `copy`メソッドを使おう | |
| コピー | `dic.copy()` | シャローコピーする | |
| コピー | `copy.deepcopy(dic)` | ディープコピーする | |
| マージ/作成 | `dict(dic1, **dic2)` | 和集合演算子`|`を使おう | |
| マージ/作成 | `{**dic1, **dic2}` | 和集合演算子`|`を使おう | ^3.5 |
| マージ/作成 | `dic1 | dic2` | キーが衝突する場合、右辺の値で上書き | ^3.9 |
| マージ/更新 | `dic1.update(dic2)` | 累算代入演算子`|=`を使おう |  |
| マージ/更新 | `dic1 |= dic2` | キーが衝突する場合、右辺の値で上書き  | ^3.9 |
| マージ/作成 | `dict(key1=1, **dic2)` | キーが衝突する場合、`TypeError`が発生 |  |
| マージ/作成 | `dict(**dic1, **dic2)` | キーが衝突する場合、`TypeError`が発生 | ^3.5 |
| 問合 | `"a" in dic` | キーの存在を確認する |  |
| 問合 | `"a" in dic.values()` | 値の存在を確認する |  |
| 問合 | `dict(filter(lambda key_value: key_value[0] in cond, dic.items()))` | 評価関数に一致する要素を抽出する。なるべく辞書内包表記を使おう |  |
| 問合 | `{key:value for key, value in dic.items() if key in cond}` |  |  |
| 問合 | `len(dic)` | 要素数を取得する |  |
| 問合 | `Counter(dic.values())` | イテラブルからキーと個数を集計した'dict'を生成する |  |
| ソート | `sorted(dic.items())` | 昇順でソートする |  |
| ソート | `sorted(dic.items(), key=lambda x: x)` | 任意の評価関数でソートする |  |
| ソート | `sorted(dic.items(), reverse=True)` | 逆順にソートする |  |
| ソート | `list(reversed(dic.items()))` | 逆順にソートする | ^3.7[^4] |
| 初期値保持 | `defaultdict(list)` | コンストラクタに渡したファクトリ関数の戻り値を初期値とする`dict`を作成 | |
| 挿入順保持 | `OrderedDict()` | Python3.7以降はdictが`OrderedDict`相当の順序を保持するようになったため不要 | <=3.6.* |
| 集計 | `Counter(data)` | イテラブルからキーと個数を集計した'dict'を生成する | |
| 上書禁止 | | `__setitem__`等をオーバーライドし、自作する必要がある | |

# 最後に
自分でまとめているうちに、なんとなく使っていた機能や知らなかった機能を発見できました。
Pythonは歴史があり、いろいろな実装方法があったりするので、少しは混乱を解消できた気がします。

# つぶやき
チートシートの左列が狭い。表の幅を指定できないかなぁ。


[^1]: [pep-0468](https://www.python.org/dev/peps/pep-0468/)にて、Python3.7より`dict`の要素は順序を保持するようになった
[^4]: [issue33462](https://bugs.python.org/issue33462)にて、Python3.8より`dict`はリバーシブルになった
[^2]: [pep-0448](https://www.python.org/dev/peps/pep-0448/)にて、Python3.5よりアンパック記法がより汎用的となった
[^3]: [pep-3106](https://www.python.org/dev/peps/pep-3106/)にて、Python3より`iteritems`は`items`に統合された
[^5]: [pep-0584](https://www.python.org/dev/peps/pep-0584/)にて、Python3.9よりマージ用の演算子が実装された

<!-- 用語集 -->
[^10000]: リバーシブル： `__reversed__`をもつオブジェクト
[^10001]: イテレータ： `__iter__`と`__next__`をもつ反復可能なオブジェクト
[^10002]: イテラブル： `__iter__`をもつ反復可能なオブジェクト
