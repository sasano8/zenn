---
title: "pythonの辞書操作を極める"
emoji: "😸" # アイキャッチとして使われる絵文字（1文字だけ）
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["markdown", "python"]
published: false
---

これも参考になるかも
https://gist.github.com/kemsakurai/3f2c5ad0638391e01fd687bd5fa8bd88


# はじめに
pythonにおける辞書操作は基礎的なことですが、ケースによって操作の使い分けが必要です。しかし、人により様々な方法を用いていたり、著者も毎回やり方がブレるという状況でしたので、自分なりのプラクティスをを整理するために本記事を執筆しました。

特に今回は、２つの辞書をマージする方法は分かった。でも、「キーの衝突を許可しないマージを行いたい」というケースに遭遇し、それが大きな検証動機になっています。
そのついでに一通り基礎操作をまとめたので、誰かのガイドラインとして役に立てば幸いです。

# 検証環境
- python3.9.0

本記事では、python3.5以降から利用可能な構文を多く利用するため、python3.5未満のユーザーはあまり参考にならないと思います。

# 用語
本記事では以下の操作を区別し執筆しています。（これらの概念の正式名称があれば教えていただけると幸いです。）

| 用語 | 概要 |
| :---- | :---- |
| 結合 | 複数の辞書を１つにまとめる。 |
| マージ | 複数の辞書を結合し、かつ、衝突するキーに対しては後勝ちで値を上書きする。 |
| ユニオン | 複数の辞書のキーとバリューを辞書の要素として展開し結合する。キーが衝突する場合は、エラーとなる。[^1] |


[^1]: [pep584](https://www.python.org/dev/peps/pep-0584/)にて、ユニオンオペレーターはマージのことを指していますが、本記事におけるユニオンとはpep584のユニオンと関係ないものとしてください。（適切な単語が思い浮かびませんでした。）

# 基礎編

## 値を追加したい

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

## 初期値を持つ辞書を作成したい
リストを初期値とする辞書を作成したい場合など、いちいち初期値とするリストを渡すのは億劫です。
そのような場合、defaultdictを利用することができます。

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


## 再代入禁止の辞書を作成したい


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


## 辞書からキーに対応する値を取得したい
``` python
# 方法１
# キーが存在しない場合は、KeyErrorが発生します
val = dic1["name"]

# 方法２
# キーが存在しない場合は、Noneが返ります
val = dic1.get("name")

# 方法３
# キーが存在しない場合は、第２引数の値をデフォルト値として受け取ります
val = dic1.get("name", 0)
```


## 辞書からキーと値を削除したい
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

## 辞書から複数のキーと値を削除したい
複数のキーを削除したい場合は以下のように。delはリスト内包表記で利用することはできません。
``` python
# 方法１
for key in some_keys:
  del dic1[key]

# 方法２
[dic1.pop(key, None) for key in some_keys]
```

## 辞書から全ての要素を削除したい
``` python
# 方法１
dic1.clear()
# => {}

# 方法２
for key, value in dic1.popitem():
  pass
# => {}
```


## 辞書をコピーしたい
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

## キーや値を列挙したい
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

# 結合操作編

## ソース辞書
結合対象の辞書として、以下２つ辞書をソースとして利用します。
```
dic1 = {"name": "bob", "age": 20}
dic2 = {"name": "mary"}
```

## 辞書をマージしたい（衝突するキーの値は上書き）
挙動はマージとなる。Python3.5から辞書作成時にアンパック記法（\**）が利用可能。[^2]
[^2]: pep448 [リンク](https://www.python.org/dev/peps/pep-0448/)

``` python
# 方法１（python3.5から辞書作成時に展開記法が使用可能）
{**dic1, **dic2}
# => {"name": "mary", "age": 20}

# リテラル表記と組み合わせて使用することも可能
{"key1": "val1", "key2": "val2", **dic1}
# => {"key1": "val1", "key2": "val2", "name": "bob", "age": 20}

# なお、波括弧での辞書宣言時はキーが衝突してようとおかまいなしなので注意
{"name": "bob", "name": "mary"}
# => {"name": "mary"}

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
もし、ネストした辞書をマージしたい場合は別の方法を検討しなければいけません。

:::message alert
ネストした辞書のマージ結果を意識しましょう
:::

## ネストした辞書をマージしたい
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


## 辞書をユニオンしたい（衝突するキーの値の上書きを許容しない）
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
dict(\**dic1, \**dic2)と{\**dic1, \**dic2}は挙動が違うため、キーの衝突を許容しない場合は必ずdict関数を使うように意識しましょう
:::

# 応用編

## キーを変更したい
``` python
dic1["new_key"] = dic1.pop("old_key")
```




# まとめ
スマートな辞書操作を心掛けたいものの、様々な実現方法があって混乱してしまいますね。
ケースに応じた実現方法をまとめましたので、参考にしていただけると幸いです。
複数の実現方法がある場合は、ニュアンスが伝わりやすい実現方法を使いましょう。
python3.9を軸にルールを設けていますので、バージョン毎にカスタマイズしてご利用ください。

| バージョン | コード例 | 要求 | 備考 |
| ---- | ---- | ---- | ---- |
| | dic1["name"] = val | 登録 | |
| | dic1.setdefault("key", 0) | 取得/登録 | キーが存在しない場合、第２引数の値を登録した上で、キーの値を返す |
| | dic1["name"] | 取得 | キーが存在しない場合、KeyErrorが発生 |
| | dic1.get("name") | 取得 | キーが存在しない場合、Noneを返す |
| | dic1.get("name", 0) | 取得 | キーが存在しない場合、第２引数の値を返す |
| | del dic1["name"] | 削除 | キーが存在しない場合、KeyErrorが発生 |
| | dic1.pop("name") | 削除/取得 | キーが存在しない場合、KeyErrorが発生 |
| | dic1.pop("a", None) | 削除/取得 | キーが存在しない場合、第２引数の値を返す |
| | dic1.clear() | 全削除 | |
| | dic1["new"] = dic1.pop("old") | キー変更 | |
| | for value in dic1: | 列挙/キー | keysを使おう |
| | dic1.keys() | 列挙/キー | |
| | dic1.values() | 列挙/バリュー | |
| | dic1.items() | 列挙/キーバリュー | |
| <=2.* | dic1.iteritems() | 列挙/キーバリュー | python3でitemsに統合 |
| | dict(\**dic1) | シャローコピー | copyメソッドを使おう |
| | dict(dic1) | シャローコピー | copyメソッドを使おう |
| | dic1.copy() | シャローコピー | |
| | copy.deepcopy(dic1) | ディープコピー | |
| 3.5 | {\**dic1, \**dic2} | 作成/シャローマージ | 和集合演算子（\|）を使おう |
| | dict(dic1, \**dic2) | 作成/シャローマージ | 和集合演算子（\|）を使おう |
| 3.9 | dic1 \| dic2 | 作成/シャローマージ | |
| 3.9 | func(\**(dic1 \| dic2)) | 作成/シャローマージ | |
|  | dic1.update(dic2) | 更新/シャローマージ | 累算代入演算子（\|=）を使おう |
| 3.9 | dic1 \|= dic2 | 更新/シャローマージ | |
| | | ディープマージ | 自作かライブラリを用いる |
| 3.5 | dict(\**dic1, \**dic2) | 作成/ユニオン | キーが衝突する場合、TypeErrorが発生 |
|  | dict(key1=1, \**dic2) | 作成/ユニオン | キーが衝突する場合、TypeErrorが発生 |
| 3.5  | func(\**dic1, \**dic2) | 作成/ユニオン | キーが衝突する場合、TypeErrorが発生 |
| | | 更新/ユニオン | 対応する操作は存在しない |
| | defaultdict(list) | 初期値保持 | コンストラクタに渡したファクトリ関数の戻り値を初期値とする辞書を作成 |
| <=3.6 | OrderedDict | 順序性保持 | python3.7以降はdictがOrderedDict相当の順序を保持するようになったため不要。 |
