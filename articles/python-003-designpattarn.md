---
title: "オブジェクト志向における誤解しがちなこと"
emoji: "😸" # アイキャッチとして使われる絵文字（1文字だけ）
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["markdown", "python"]
published: false
---


# オブジェクト志向における誤解しがちなこと


# なぜこの記事を書こうと思ったか
https://qiita.com/hayashida-katsutoshi/items/ef2e59219ba0942d3225?utm_content=buffera4033&utm_medium=social&utm_source=twitter.com&utm_campaign=buffer

営業は掃除してはいけないなどの誤ったメッセージがあった。
この記事では、暗黙的にデザインパターンに適合する汎化について述べられている。
オブジェクト指向において、この営業のような挙動は禁止されていない。（特化）

論点がごちゃごちゃである。


# 再利用
- 再利用できるように　→　再利用できなくともよい　→　具体的な物事を指したオブジェクトはより具体的な名称にするべきだ。
要はボトムアプローチとトップアプローチがある。
汎化から入るな。まずは、特化から入れ。
その後、汎化できるか考えろ。

再利用できないオブジェクトはクソ。
オブジェクトは全て再利用できるから安心しろ。
例は以下だ。
```
# 特化
# あなたには、具体的なオブジェクトが与えられている。設計など存在せず、ただ存在しているもの。
dog.bowwow()
dog.wow()
cat.meow()


# 分析のすえ、これは汎化していいものだと気づく。
# 汎化
class MyDog(Dog, Animal):
  def hello(self):
    self.hello_bowwow()
    
  def hungry(self):
    self.wow()

# 汎化
class MyCat(Cat, Animal):
  def hello(self):
    self.hello_nyaaa()
    
  def hungry(self):
    self.hello_nyaaa()

animal.hello()

dog.cry_bowwow()
dog.cry_wow()
```


# 責任をシンプルにしろ
そんなことはどうでもよい。ビジネス課題に徹しろ。
あなたは、ビジネス課題を解決するために、最短で最善だと思う手法で実装すればいい。

```
class MyDog(Dog, Animal):
  def hello(self):
    self.hello_bowwow()
    
  def hungry(self):
    self.wow()
    
  def is_hungry(self):
    self.hp < 10
```

