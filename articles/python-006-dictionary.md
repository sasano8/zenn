---
title: "pythonの辞書操作を極める"
emoji: "😸" # アイキャッチとして使われる絵文字（1文字だけ）
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["markdown", "python"]
published: false
---

これも参考になるかも
https://gist.github.com/kemsakurai/3f2c5ad0638391e01fd687bd5fa8bd88


# この記事を書いた動機
pythonで辞書を操作する際に、適切なメソッドやメソッドの挙動が分からず、また、検索結果によって実現方法が異なり混乱していたため、自分なりに検証・整理するために本記事を執筆しました。

本記事まとめの章で、検証結果をコンパクトにまとめましたので、実装する際のガイドラインとして活用いただければ幸いです。

# 検証環境
- python3.9.0

メインの読者ターゲットは、python3.5以降のユーザーです。一応、python2の歴史も軽く追っています。

# 基礎編

## 辞書を作成する
辞書リテラル`{}`かdict関数を用いて、辞書を作成することができます。

``` python
# 方法１
dic = {"key": "test"}

# 方法２
dic = dict(key="test")

# 例外(fromは予約語のため、キーワード引数で用いることができません)
dic = dict(from=0)
# => SyntaxError: invalid syntax
```

:::message
- 辞書リテラルで文字列キーを定義する場合、キーは文字リテラルを用いる必要があります
- dict関数で文字列キーを定義する場合、キーワード引数がそのままキーとして定義されます。ただし、キーが予約語の場合、SyntaxErrorとなります
:::

## 値を追加する

``` python
# 方法１
# キーが存在する場合、新たな値で上書きされる
dic1['key'] = "val"

# 方法２
# キーが存在しない場合、値をにNoneを追加する
val = dic1.setdefault('new_key')
# => None

# 方法３
# キーが存在しない場合、値をに第２引数の値を追加する
val = dic1.setdefault('new_key', 0)
# => 0
```

## 辞書からキーに対応する値を取得する
``` python
# 方法１
# キーが存在しない場合は、KeyErrorが発生します
val = dic["name"]

# 方法２
# キーが存在しない場合は、Noneが返ります
val = dic.get("name")

# 方法３
# キーが存在しない場合は、第２引数の値をデフォルト値として受け取ります
val = dic.get("name", 0)
```

## キーを変更する
`pop`を用いることで簡潔に実現することができます。

``` python
dic["new"] = dic.pop("old")
```


## 辞書からキーと値を削除する
``` python
# 方法１
# パフォーマンス的に最も効率的です
# キーが存在しない場合は、KeyErrorが発生します
del dic1["name"]

# 方法２
# キーを削除しながら値を受け取ることができます
# キーが存在しない場合は、KeyErrorが発生します
val = dic1.pop("name")

# 方法３
# キーを削除しながら値を受け取ることができます
# キーが存在しない場合は、第２引数の値をデフォルト値として受け取ります
val = dic1.pop("a", None)

# 方法４
# 要素をランダムに一つ削除する。（python3.7からは要素の順序が保存されるようになったため、最後の要素から削除される？？collections.OrderedDict相当）
key_value = dic1.popitem()
# => ('age', 20)
```

## 辞書から複数のキーと値を削除する
複数のキーを削除したい場合は以下のように。なお、delはリスト内包表記で利用することはできません。

``` python
# 方法１
for key in some_keys:
  del dic1[key]

# 方法２(パフォーマンス的に方法1を推奨)
[dic1.pop(key, None) for key in some_keys]
```

## 辞書から全ての要素を削除する
``` python
# 方法１
dic1.clear()
# => {}

# 方法２
for key, value in dic1.popitem():
  pass
# => {}
```

## キーや値を列挙する
以下のようにキーや値を列挙することができます。

``` python
# キーを列挙する
for value in dic1:
  print(value)

# キーを列挙する
for key in dic1.keys():
  print(key)

# 値を列挙する
for value in dic1.values():
  print(value)

# キーと値を列挙する
for key, value in dic1.items():
  print(key, value)

# キーと値を列挙する
# python2.x系ではitemsよりオーバーヘッドが少ないiteritemsが用意されている。（itemsはリストを生成しているためコストが大きい）
# python3系ではitemsの実装が改善され、dict_items（キーバリューペア列挙機能を実装したイテラブルなオブジェクト）を返すようになったため、iteritemsは廃止された。
for key, value in dic1.iteritems():
  print(key, value)

```


## 辞書をコピーする
辞書をコピーする場合、シャローコピー（参照のコピー）とディープコピー（再帰的に値をコピーし、新たなインスタンスを作成）に注意しましょう。
シャローコピーでは、コンテナ型オブジェクト（リストや辞書など）の内部値はコピーされません。

``` python
src = {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 30}}

# 方法１（シャローコピー）
# copyメソッドと同様。copyメソッドを利用しましょう。
copy1 = dict(**src)

# 方法２（シャローコピー）
# copyメソッドと同様。copyメソッドを利用しましょう。
copy1 = dict(src)

# 方法３（シャローコピー）
copy1 = src.copy()

# 方法４（ディープコピー）
import copy
copy2 = copy.deepcopy(src)

# 結果確認
print(src)   # => {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 30}}

copy1["age"] += 5
copy1["nest"]["age"] += 100
print(src)   # => {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 130}}
print(copy1) # => {"name": "bob", "age": 25, "nest": {"name": "mary", "age": 130}}

copy2["nest"]["age"] -= 30
print(src)   # => {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 130}}
print(copy2) # => {"name": "bob", "age": 20, "nest": {"name": "mary", "age": 0}}
```

:::message alert
値を変更する時、副作用に注意しましょう
:::

# マージ編
２つ以上の辞書をマージする方法はいくつもあります。それらは、同じ挙動であったり、異なる挙動であったり注意点があるため、状況に応じて使い分けてください。

前提として、以下２つの辞書をマージ対象の辞書として利用します。
```
dic1 = {"name": "bob", "age": 20}
dic2 = {"name": "mary"}
```

## 辞書をマージする（衝突するキーの値は上書き）
挙動はマージとなる。Python3.5から辞書作成時にアンパック記法`**`が利用可能。[^2]
[^2]: pep448 [リンク](https://www.python.org/dev/peps/pep-0448/)

``` python
# 方法１（python3.5から辞書作成時に展開記法が使用可能） 性能的にも優れたマージ方法です
{**dic1, **dic2}
# => {"name": "mary", "age": 20}

# リテラル表記と組み合わせて使用することも可能
{"name": "bob", "age": 20, **dic2}
# => {"name": "mary", "age": 20}

# 方法2
dict(dic1, **dic2)
# => {"name": "mary", "age": 20}

# 方法３（python3.9から和集合演算子が使用可能）
dic1 | dic2
# => {"name": "mary", "age": 20}

# 方法４
# ソースの辞書が更新されるため注意
dic1.update(dic2)
# => {"name": "mary", "age": 20}

# 方法５（python3.9から累算代入演算子が使用可能）
# ソースの辞書が更新されるため注意
dic1 |= dic2
# => {"name": "mary", "age": 20}
```

## 辞書をマージする（衝突するキーは許容しない）
辞書をマージする際、衝突したキーの値を上書きしたくない、もしくは、キーの衝突があるか分からない場合は、以下の方法でキー衝突時にエラーを発生させることが可能です。

``` python
# 方法１
dict(**dic1, **dic2)
# => TypeError: func() got multiple values for keyword argument 'name'

# リテラル表記と組み合わせて使用することも可能
dict(key1="val1", key2="val2", **dic1}
# => {"key1": "val1", "key2": "val2", "name": "bob", "age": 20}

# dict関数を用いなくとも、キーワード引数としてアンパックする際は同様の効果が得られる
def func(**kwargs):
  pass

func(**dic1, **dic2)
# => TypeError: func() got multiple values for keyword argument 'name'

# 以下のようなケースでも、重複してキーが渡ってくることはない
def func(name, age, **kwargs):
  pass

func(**dic1, **dic2)
# => TypeError: func() got multiple values for keyword argument 'name'

# 注意
# dictの代わりに{}を使用した場合、結果はマージとなるため、混同して使用しないようにしましょう
{**dic1, **dic2}
# => {"name": "mary", "age": 20}
```

:::message
- キーが衝突するか分からない場合は、キーの衝突が検知できるようにこの方法を使用しましょう
:::

:::message alert
dict(`**dic1, **dic2)`と`{**dic1, **dic2}`は挙動が違うため、キーの衝突を許容しない場合は必ずdict関数を使うように意識しましょう
:::

### マージの際、ネストした辞書はどうなる？
さて、マージの方法が分かったところで、以下のコードを見てみましょう。
あなたはどんな結果を想定しますか？

``` python
a = {"nest": {"name": "bob", "age": 20}}
b = {"nest": {"name": "mary"}}

# 方法１
{**a, **b}
# => {'nest': {'name': 'mary'}}

# 方法２
dict(a, **b)
# => {'nest': {'name': 'mary'}}

# 方法３
a | b
# => {'nest': {'name': 'mary'}}

# 方法４
a.update(b)
# => {'nest': {'name': 'mary'}}

# 方法５
dic1 |= dic2
# => {'nest': {'name': 'mary'}}
```

紹介した方法のいずれも、ネストした辞書は単純に辞書を置き換えているだけですね。
もし、ネストした辞書をマージする場合は別の方法を検討しなければいけません。

:::message alert
ネストした辞書のマージ結果を意識しましょう
:::

## ネストした辞書をマージする
ネストした辞書をマージするための機能は標準では用意されていないようです。

```
dict(dict1.items() + dict2.items())  # できない
itertools.chain

def deep_merge(dic1, dic2):
  for key in dic2.keys():
    if isinstance(dic2[key], dict):
      deep_merge(dic1[key], dic2[key])
    else:
      

# https://www.greptips.com/posts/1242/
def deepupdate(dict_base, other):
  for k, v in other.items():
    if isinstance(v, collections.Mapping) and k in dict_base:
      deepupdate(dict_base[k], v)
    else:
      dict_base[k] = v
```


# 特殊な辞書編

## 初期値を保持した辞書を作成する
リストを初期値とする辞書を作成したい場合など、いちいち初期値とするリストを渡すのは億劫です。
そのような場合、`defaultdict`を利用することができます。

``` python
from collections import defaultdict

# 方法１
# 引数無しで実行可能なコンストラクタを持つ型を渡せば、初期値としてインスタンスを渡してくれます
dic = defaultdict(list)

dic["family"].append("father")
print(dic)
# => defaultdict(<class 'list'>, {'family': ['father']})

# 方法２
# 引数無しで実行可能な関数を渡せば、戻り値を初期値としてくれます
def create_default():
    return ["mather"]

dic = defaultdict(create_default)
# もしくは
dic = defaultdict(lambda: ["mather"])

dic["family"].append("father")
print(dic)
# => defaultdict(<function <lambda> at 0xXXXXXXXXX>, {'family': ['mather', 'father']})
```

なお、getを利用して同様のことができそうですが、ソースの辞書に初期値を登録するわけではないので、以下の例では元の辞書は空っぽのままです。
``` python
dic = {}
dic.get("family", []).append("father")
# => {}
```


## 順序性を保持した辞書を作成する

## 再登録禁止の辞書を作成する
意図せず値が上書きされることを防ぐため、再登録不可な辞書を作成したい場合があるかもしれません。
標準では機能が用意されていませんが、以下のように`__setitem__`をオーバーライドすることで実現可能です。

``` python
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
スマートな辞書操作を心掛けたいものの、様々な実現方法があって混乱してしまいますね。
ケースに応じた実現方法をまとめましたので、参考にしていただけると幸いです。
複数の実現方法がある場合は、ニュアンスが伝わりやすい実現方法を使いましょう。
python3.9を軸にルールを設けていますので、バージョン毎にカスタマイズしてご利用ください。
要求
| 要求      | コード例 | 備考 | バージョン |
| ---- | ---- | ---- | ---- |
| 作成 | dic = {"key": "value"} | | |
| 作成 | dic = dict(key="value") | keyに予約語を渡した場合、SyntaxErrorが発生 | |
| 登録 | dic["name"] = val | | |
| 登録/取得 | dic.setdefault("key") | キーが存在しない場合、Noneを登録した上で、キーの値を返す | |
| 登録/取得 | dic.setdefault("key", 0) | キーが存在しない場合、第２引数の値を登録した上で、キーの値を返す | |
| 取得 | dic["name"] | キーが存在しない場合、KeyErrorが発生 | |
| 取得 | dic.get("name") | キーが存在しない場合、Noneを返す | |
| 取得 | dic.get("name", 0) | キーが存在しない場合、第２引数の値を返す | |
| 削除 | del dic["name"] | キーが存在しない場合、KeyErrorが発生 | |
| 削除/取得 | dic.pop("name") | キーが存在しない場合、KeyErrorが発生 | |
| 削除/取得 | dic.pop("a", None) | キーが存在しない場合、第２引数の値を返す | |
| キー変更 | dic["new"] = dic.pop("old") | | |
| 全削除 | dic.clear() | | |
| 列挙 | for value in dic: | `keys`を使おう | |
| 列挙 | dic.keys() | キーを列挙する | |
| 列挙 | dic.values() | 値を列挙する | |
| 列挙 | dic.items() | キーと値のタプルを列挙する | |
| 列挙 | dic.iteritems() | python3で`items`に統合された[^3] | <=2.* |
| コピー | dict(\**dic) | `copy`メソッドを使おう | |
| コピー | dict(dic) | `copy`メソッドを使おう | |
| コピー | dic.copy() | シャローコピーする | |
| コピー | copy.deepcopy(dic) | ディープコピーする | |
| マージ/作成 | {\**dic1, \**dic2} | 和集合演算子`|`を使おう | ^3.5 |
| マージ/作成 | dict(dic1, \**dic2) | 和集合演算子`|`を使おう | |
| マージ/作成 | dic1 \| dic2 | キーが衝突する場合、右辺の値で上書き | ^3.9 |
| マージ/作成 | func(\**(dic1 \| dic2)) | キーが衝突する場合、右辺の値で上書き  | ^3.9 |
| マージ/更新 | dic1.update(dic2) | 累算代入演算子`|=`を使おう |  |
| マージ/更新 | dic1 \|= dic2 | キーが衝突する場合、右辺の値で上書き  | ^3.9 |
| マージ/作成 | dict(\**dic1, \**dic2) | キーが衝突する場合、TypeErrorが発生 | ^3.5 |
| マージ/作成 | dict(key1=1, \**dic2) | キーが衝突する場合、TypeErrorが発生 |  |
| マージ/作成 | func(\**dic1, \**dic2) | キーが衝突する場合、TypeErrorが発生 | ^3.5 |
| 初期値保持 | defaultdict(list) | コンストラクタに渡したファクトリ関数の戻り値を初期値とする辞書を作成 | |
| 順序性保持 | OrderedDict | python3.7以降はdictが`OrderedDict`相当の順序を保持するようになったため不要 | <=3.6.* |
| 再登録禁止 | | 自作する（`__setitem__`等をオーバーライド） | |



# 用語
本記事では以下の操作を区別し執筆しています。（これらの概念の正式名称があれば教えていただけると幸いです。）

| 用語 | 概要 |
| :---- | :---- |
| 結合 | 複数の辞書を１つにまとめる。 |
| マージ | 複数の辞書を結合し、かつ、衝突するキーに対しては後勝ちで値を上書きする。 |
| ユニオン | 複数の辞書のキーとバリューを辞書の要素として展開し結合する。キーが衝突する場合は、エラーとなる。[^1] |


[^1]: [pep-584](https://www.python.org/dev/peps/pep-0584/)にて、ユニオンオペレーターはマージのことを指していますが、本記事におけるユニオンとはpep584のユニオンと関係ないものとしてください。（適切な単語が思い浮かびませんでした。）

[^3]: [pep-3106](https://www.python.org/dev/peps/pep-3106/)iteritemsはpython3で`items`に統合されました
