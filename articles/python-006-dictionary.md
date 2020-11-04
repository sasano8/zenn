---
title: "pythonの辞書マージ操作を極める"
emoji: "😸" # アイキャッチとして使われる絵文字（1文字だけ）
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["markdown", "python"]
published: false
---

# 対象の読者

辞書の合成
２つの辞書を合成した場合、重複したキーはどうなるか検証した。 dict(**dic1, **dic2)、func(**dic1, **dic2)は重複したキーが投入された時、エラーとなるので積極的に使ってよい。 {**dic1, **dic2}は、後勝ちで上書きされるので危険。

dic1 = {"name": "bob", "age": 20}
dic2 = {"name": "mary"}

# 辞書作成時
{**dic1, **dic2}  # => {"name": "mary", "age": 20}  右辺の値で上書き
dict(**dic1, **dic2)  # => TypeError: func() got multiple values for keyword argument 'name'

# update / 代入演算子
update_dic = {"name": "bob", "age": 20}
update_dic.update(dic2)
# または
update_dic |= dic2
# => {"name": "mary", "age": 20}  右辺の値で上書きされる。また、元データを変更するので、できればあまり使わないほうがよい。

dict(update_dic, **dic2)
# 元のソース自体は更新されない
# => {"name": "mary", "age": 20}

# マージ演算子
new_dic = dict_1 | dict_2
# => {"name": "mary", "age": 20}  右辺の値で上書きされる


# キーワード引数として渡す際に合成
def func(**kwargs):
    print(kwargs)

func(**dic1, **dic2)
# => TypeError: func() got multiple values for keyword argument 'name'
