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
辞書は基礎的なオブジェクトですが、たびたび機能改善されたり、発展途上の側面があります。

筆者も自分なりのノウハウをメモしているうちに、全部まとめてしまえと執筆したのが本記事です。

本記事で紹介する辞書操作や挙動は、本記事[まとめ](#まとめ)の章でコンパクトにまとめました。
本記事をひととおりお読みいただいた後は、ガイドラインとしてまとめを活用いただければ幸いです。

# 検証環境
- Python3.9.0

# 対象読者
読者のメインターゲットは、Python3.5以上のユーザーです。
検証環境は3.9ですが、Python3.5系以上の互換性は調査・考慮しています。

辞書にフォーカスした解説のため、基礎的な知識・単語については、その他の記事等で補完ください。

Python中級者以上の方は、目次とまとめを見て気になった章だけお読みください。

# 基礎編

## 辞書作成する
辞書を作成する方法を紹介します。

### `{}`で辞書を作成する
辞書リテラル`{}`で辞書を作成できます。

性能面でも優れているもっともポピュラーな方法ですので、基本的にこの方法を使用しましょう。
``` Python
dic = {"key": "test"}
```

### `dict`関数（キーワード引数）で辞書を作成する
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

### `dict`関数（キーと値のタプルリスト）で辞書を作成する
`dict`関数に、キーと値のタプルを要素とするリストを渡すと、辞書を作成できます。

``` Python
dic = dict([("key1", 1), ("key2", 2)])
# => {'key1': '1', 'key2': '2'}
```

### 辞書内包表記
辞書内包表記を用いると、イテラブル（繰り返し可能なオブジェクト）の処理結果から辞書を作成できます。
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

:::message
- `{}`は`dict`関数に比べ、性能が2倍以上優れる
- dict関数でキーワード引数を利用するとキーワード引数が要素（文字列キーと値）として定義される。ただし、キーが予約語や整数などの場合、`SyntaxError`となる
:::

## 要素（キーと値）を登録する
辞書に要素を登録する方法を紹介します。

### `__setitem__`で登録する
キーを指定し、値を渡すことで要素を登録できます。
すでに対象のキーが存在する場合は、値が上書きされます。

``` Python
dic = {}
dic["key"] = "val"
```

上記コードは、`__setitem__`の糖衣構文になります。

``` Python
dic = {}
dic.__setitem__("key", "val")
```

### `setdefault`で登録する
要素を登録するために、`setdefault`も利用できます。

:::message
`setdefault`は、キーが登録されていない場合はデフォルト値を登録したうえで、キーに対応する値を返す。
- 第1引数：　キー
- 第2引数：　キーが登録されていない場合に登録する値。省略時は`None`を登録
:::

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
キーに対応する値の取得方法を紹介します。

### `__getitem__`で値を取得する
辞書のキーにアクセスし、キーに対する値を取得できます。
キーが存在しない場合は、`KeyError`が発生します。

``` Python
dic = {"name": "test"}
val = dic["name"]
```

上記コードは、`__getitem__`の糖衣構文になります。

``` Python
dic = {"name": "test"}
val = dic.__getitem__("name")
```

### `get`メソッドで値を取得する
`KeyError`を無視したい場合は、`get`メソッドを使用できます。

:::message
`get`は、指定したキーの値を返します。
指定したキーが存在しない場合は、第2引数の値を返します。
- 第1引数：　キー
- 第2引数：　キーが登録されていない場合に返す値。省略時は`None`を返す
:::

``` Python
# キーが存在しない場合は、Noneが返る
val = dic.get("name")

# キーが存在しない場合は、第２引数の値が返る
val = dic.get("name", None)
```

### `setdefault`メソッドで値を取得する
前章で紹介した`setdefault`メソッドも値の取得に利用できます。
デフォルト値の登録と値の取得を同時に行いたいケースで利用しましょう。

``` Python
# キーが存在しない場合は、第２引数の値を登録した上で、その値を返す
val = dic.setdefault("name", None)
```

## 要素を削除する
要素を削除する方法を紹介します。

### delを使用して削除する
要素は、`del`で削除できます。

:::message
`del`は、指定したキーを削除します。
- 指定したキーが存在しない場合は、`KeyError`が発生する。
- 削除以外の余計な処理を行わないので性能がもっとも優れる。

:::

``` Python
del dic["name"]
```

### `pop`を使用して削除する
`del`の代わりに、`pop`メソッドでも要素を削除できます。

`pop`メソッドは、削除された値を受け取りたい時や`KeyError`を無視したい場合に使用しましょう。

:::message
`pop`は、指定したキーを削除し、値を返す。
- 第1引数：　キー
- 第2引数：　キーが登録されていない場合に返す値。省略時は`KeyError`が発生
:::

``` Python
# キーが存在しない場合は、KeyErrorが発生する
val = dic.pop("name")

# キーが存在しない場合は、第２引数の値を返す
val = dic.pop("a", None)
```

### `popitem`を使用して削除する
`popitem`メソッドは、要素を1つ無作為に削除します[^1]。
キーを指定できず、何が削除されるか分からないため、使う機会はほぼないでしょう。

:::message
`popitem`メソッドは、要素を1つ無作為に削除します。

:::

``` Python
key_value = dic.popitem()
```

### 複数の要素を削除する
複数の要素を削除したい場合の例を紹介します。

なお、`del`はリスト内包表記とともに利用できません。

``` Python
some_keys = ["key1", "key2"]

# 方法１
for key in some_keys:
  del dic[key]

# 方法２(パフォーマンス的には方法1を推奨)
[dic.pop(key, None) for key in some_keys]
```

### すべての要素を削除する
すべての要素を削除する場合は、`clear`メソッドを用います。

:::message
`clear`メソッドは、すべての要素を削除します。

:::

``` Python
dic.clear()
# => {}
```

## キーを変更する
キーを変更する方法を紹介します。
`pop`を用いることで簡潔に実現できます。

``` Python
# キーが存在しない場合は、KeyErrorが発生する
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

これらのメソッドはビューオブジェクトと呼ばれる主に列挙に関する機能だけ提供するオブジェクトを返します。
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

# ソース辞書に要素を追加・更新した場合は同期的に動作
dic["b"] = 0
items
# => dict_items([('a', 0), ('b', 0)])
```

# 問い合わせ編

## 要素数を調べる
辞書に登録された要素数を調べる方法を紹介します。

`len`を使い要素数を調べることができます。
``` Python
dic = {}
len(dic)
# => 0
```

## キーと値の存在を調べる
辞書に指定したキーが登録されているか調べる方法を紹介します。


## キーの存在を調べる
`in`を使うことで、キーが存在するか調べることができます。
`not`を組み合わせることで、キーが存在していないことも調べることができます。

コストは、`O(1)`です。

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

ただし、キーに対する`in`はハッシュ探索のためコストが少ないですが、値に対する`in`は線形探索となるためコストが大きいです。
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

## if文でキーの存在を条件にする
紹介したコードは、if文などと組み合わせることができます。

``` Python
if "a" in dic:
  ...

if all(key in dic for key in {"a", "b"}):
  ...
```

## 要素をフィルタする
辞書から任意の要素を抽出する方法を紹介します。

辞書内包表記は書き方が独特ですが、もっとも性能に優れた方法ですので、コードが長いなど可読性に問題がない場合は積極的に使いましょう。

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

# コピー編
辞書をコピーする方法を紹介します。

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

シャローは浅いを意味し、ネストした辞書等の値はコピーされず、ただ同じ実体を参照するだけです。
そのため、次のような副作用が生じます。

``` Python
src = {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 30}}

dest1 = dict(**src)
dest2 = dict(src)
dest3 = src.copy()

# コピーした辞書を変更したつもりが、ソース辞書まで影響を受けてしまう
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
- プリミティブ型（整数や文字列）など単一の値は状態が分離されるが、コンテナ型（辞書やリストなど）は内包している値が共有されてしまうことに注意
:::

## ディープコピーする
ディープコピーの方法を紹介します。

`copy`モジュールの`deepcopy`で実現できます。
ディープコピーは、ネストされた辞書も再帰的にコピーします。

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


# ソート編
辞書をソートする方法を紹介します。

## デフォルトの順序について
Python3.7からは、辞書が返す要素の順序は次のようになりました。

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
`sorted`関数に`reverse=True`を指定するか、`reversed`関数を利用し、列挙順序を逆にできます。ただし、辞書に対して`reversed`はPython3.8未満で使用できません[^4]。

Python3.8未満の場合は、`OrderedDict`を利用するか`sorted`関数を利用してください。

``` Python
dic = {"a": 0, "b": 1}

# 方法１
for key in sorted(dic.keys(), reverse=True):
  print(key)

# 方法２
for key in reversed(dic.keys()):
  print(key)
```

# マージ編
2つ以上の辞書をマージして、1つの辞書にしたい場合の実現方法を紹介します。
方法により挙動が異なるので、状況に応じて使い分けてください。

## マージする（衝突するキーの値は上書き）
キーが衝突した場合、値を上書きするマージ方法を紹介します。

バージョン毎にプラクティスが異なるため、バージョンごとに紹介します。
互換性があるので、上位バージョンで下位バージョンのプラクティスも使用可能です。

### Python3.5未満
`dict`関数の第1位置引数にソース辞書を渡し、アンパック記法を併用することでマージされた辞書を作成できます。
ソース辞書を直接更新する場合は、`update`メソッドが使用できます。

``` Python
dic1 = {"name": "bob", "age": 20}
dic2 = {"name": "mary"}

# 新たに辞書を作成
dic = dict(dic1, **dic2)
# => {"name": "mary", "age": 20}

# ソース辞書を更新
dic1.update(dic2)
# => {"name": "mary", "age": 20}
```

### Python3.5以上
辞書リテラル内に、アンパック記法`**`を使用できるようになりました[^2]。
モダンなアプリケーションでは、よく用いられます。

``` Python
dic1 = {"name": "bob", "age": 20}
dic2 = {"name": "mary"}

# 新たに辞書を作成
dic = {**dic1, **dic2}
# => {"name": "mary", "age": 20}

# ソース辞書を更新
dic1.update(dic2)
# => {"name": "mary", "age": 20}
```

### Python3.9以上
Python3.9からは、和集合演算子`|`と累算代入演算子`|=`が導入され、マージする意思をより明示的に表現可能になりました[^5]。

``` Python
dic1 = {"name": "bob", "age": 20}
dic2 = {"name": "mary"}

# 新たに辞書を作成
dic = dic1 | dic2
# => {"name": "mary", "age": 20}

# ソース辞書を更新
dic1 |= dic2
# => {"name": "mary", "age": 20}
```

:::message
- Python3.5以降は、アンパック記法`**`を積極的に利用しましょう
- Python3.9以降は、`|`と`|=`を積極的に利用しましょう
:::

## マージする（衝突するキーは許容しない）
キーが衝突した場合に例外を発生させるマージ方法を紹介します。

この方法は、Python3.5以上で利用可能です。

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
- Python3.5から辞書作成時に複数のアンパック記法`**`が利用可能になり、マージが簡単になった
- この方法で使用できるキーは、文字列に限定される
:::

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
前章で紹介したマージは、ネストされた辞書どうしのマージは行ってくれません。
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
ここでは、次のようにネストした辞書を再帰的にマージする方法を紹介します。

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


# 特殊な辞書編

## 初期値を保持した辞書を作成する
初期値保持した辞書を作成する方法を紹介します。

たとえば、履歴書を模した辞書に家族構成と学歴を登録するとしましょう。
家族構成と学歴は、リストにいくつか値を登録することを想定しています。

``` Python
person = {}
person["familiy"].append("father")  # => KeyError: 'familiy'
person["background"].append("2000/4/1 Python高校入学")
person["background"].append("2003/4/1 Python大学入学")
```

上記のコードは、2行目でエラーとなりました。
辞書初期化時に、リストを要素として登録していないので当然の結果ですね。

このような場合、初期化時にキーに対してリストを登録しておくのは1つの解決手段ですが、`defaultdict`を用いることも可能です。
`defaultdict`は、コンストラクタにインスタンスを生成する引数なしで実行できる関数を渡すことで、その関数が返したインスタンスを初期値とします。

``` Python
from collections import defaultdict

# インスタンスを生成する関数をコンストラクタに渡します
person = defaultdict(list)

person["family"].append("father")
person["background"].append("2000/4/1 Python高校入学")
person["background"].append("2003/4/1 Python大学入学")
# => defaultdict(<class 'list'>, {'family': ['father'], 'background': ['2000/4/1 Python高校入学', '2003/4/1 Python大学入学']})
```

思惑通りにいきました。
コンストラクタに渡す関数は、当然list以外でもインスタンスを返す関数なら何でも大丈夫です。

intやstrを普段呼び出すことはほぼないですが、引数なしで呼び出すとデフォルト値が返るため、intやstrを渡すこともできます。

``` Python
dic1 = defaultdict(int)
dic1["new"]
# => 0

dic2 = defaultdict(str)
dic2["new"]
# => ""
```


## 挿入順を保持した辞書を作成する
要素の挿入順を保持した辞書を作成するには、`OrderedDict`を使用します。

``` Python
from collections import OrderedDict
dic = OrderedDict()
```

ただし、Python3.7以降は標準の辞書も挿入順を保持するようになったので、`OrderedDict`は使わないでいいでしょう[^1]。

:::message
- Python3.7未満では、辞書の挿入順序を取り扱うために`OrderedDict`を使用する
:::

## 要素をカウントする辞書（カウンタ）を作成する
``` Python
from collections import Counter
```

## 要素の上書きを禁止した辞書を作成する
意図しない値の上書きを防ぐため、要素の上書きを禁止した辞書を作成したい場合は、次のように`__setitem__`をオーバーライドすることで実現可能です。

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
| 作成 | `dic = {"key": "value"}` | `dict`関数に比べ性能が2倍以上優れる | |
| 作成 | `dic = dict(key="value")` | 言語仕様上、キーワード引数に予約語や数値リテラルは使用できない | |
| 作成 | `dic = dict([("key", "value")])` | キーと値のタプルから辞書を作成 | |
| 作成 | `dic = {key:value for key, value in [("key", "value")]}` | キーと値のタプルから辞書を作成 | |
| 登録 | `dic["name"] = val` | キーが存在しない場合、`KeyError`が発生。`__setitem__`の糖衣構文 | |
| 登録/取得 | `dic.setdefault("key")` | キーが存在しない場合、`None`を登録したうえで、キーの値を返す | |
| 登録/取得 | `dic.setdefault("key", None)` | キーが存在しない場合、第2引数の値を登録したうえで、キーの値を返す | |
| 取得 | `dic["name"]` | キーが存在しない場合、`KeyError`が発生。`__getitem__`の糖衣構文 | |
| 取得 | `dic.get("name")` | キーが存在しない場合、`None`を返す | |
| 取得 | `dic.get("name", None)` | キーが存在しない場合、第2引数の値を返す | |
| 削除 | `del dic["name"]` | キーが存在しない場合、`KeyError`が発生 | |
| 削除/取得 | `dic.pop("name")` | キーが存在しない場合、`KeyError`が発生 | |
| 削除/取得 | `dic.pop("a", None)` | キーが存在しない場合、第2引数の値を返す | |
| 削除/取得 | `dic.popitem()` | 要素を無作為に1つ削除し、その値を返す。[^1] | |
| キー変更 | `dic["new"] = dic.pop("old")` | | |
| 全削除 | `dic.clear()` | | |
| 列挙 | `for key in dic:` | `keys`を使おう | |
| 列挙 | `dic.keys()` | キーを列挙する | |
| 列挙 | `dic.values()` | 値を列挙する | |
| 列挙 | `dic.items()` | キーと値のタプルを列挙する | |
| 列挙 | `dic.iteritems()` | Python3で`items`に統合された[^3] | <=2.* |
| 要素数 | `len(dic)` |  |  |
| 要素数 | `len(dic)` |  |  |
| コピー | `dict(**dic)` | `copy`メソッドを使おう | |
| コピー | `dict(dic)` | `copy`メソッドを使おう | |
| コピー | `dic.copy()` | シャローコピーする | |
| コピー | `copy.deepcopy(dic)` | ディープコピーする | |
| マージ/作成 | `{**dic1, **dic2}` | 和集合演算子`|`を使おう | ^3.5 |
| マージ/作成 | `dict(dic1, **dic2)` | 和集合演算子`|`を使おう | |
| マージ/作成 | `dic1 | dic2` | キーが衝突する場合、右辺の値で上書き | ^3.9 |
| マージ/作成 | `func(**(dic1 | dic2))` | キーが衝突する場合、右辺の値で上書き  | ^3.9 |
| マージ/更新 | `dic1.update(dic2)` | 累算代入演算子`|=`を使おう |  |
| マージ/更新 | `dic1 |= dic2` | キーが衝突する場合、右辺の値で上書き  | ^3.9 |
| マージ/作成 | `dict(**dic1, **dic2)` | キーが衝突する場合、`TypeError`が発生 | ^3.5 |
| マージ/作成 | `dict(key1=1, **dic2)` | キーが衝突する場合、`TypeError`が発生 |  |
| マージ/作成 | `func(**dic1, **dic2)` | キーが衝突する場合、`TypeError`が発生 | ^3.5 |
| 初期値保持 | `defaultdict(list)` | コンストラクタに渡したファクトリ関数の戻り値を初期値とする辞書を作成 | |
| 挿入順保持 | `OrderedDict()` | Python3.7以降はdictが`OrderedDict`相当の順序を保持するようになったため不要 | <=3.6.* |
| カウンタ | `Counter()` | | |
| 上書禁止 | | 自作する（`__setitem__`等をオーバーライド） | |


- [^1]: [pep-0468](https://www.python.org/dev/peps/pep-0468/)にて、Python3.7より辞書の要素は順序を保持するようになった。
- [^4]: [issue33462](https://bugs.python.org/issue33462)にて、Python3.8より辞書はリバーシブルになった。
- [^2]: [pep-0448](https://www.python.org/dev/peps/pep-0448/)にて、Python3.5よりアンパック記法がより汎用的となった。
- [^3]: [pep-3106](https://www.python.org/dev/peps/pep-3106/)にて、Python3より`iteritems`は`items`に統合された。
- [^5]: [pep-0584](https://www.python.org/dev/peps/pep-0584/)にて、Python3.9よりマージ用の演算子が実装された。

