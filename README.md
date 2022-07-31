# zenn cliの導入
zenn cliを利用すると、ローカル上でプレビューを行いながら記事を執筆できます。
以下リンクを参考にzenn cliを導入してください。

- [zenn cli](https://zenn.dev/zenn/articles/install-zenn-cli)

# local preview
zenn cliを導入した後は、プロジェクトルートで以下コマンドを実行することで、ブラウザからプレビューを確認できます。

``` shell
npx zenn preview --port 3333
```


# zennのmarkdown記法

``` markdown
#### 見出し
見出しレベル3からは、zennの見出しとしてインデックスされません。
```

# 文書ルール



# 記事の同期

ドキュメントのメタデータに`published: true`とすることで記事を公開することができる。

---
published: true
---

githubにpushすると投稿データが自動的にzennにpushされる。

# 画像管理

zennの制約で`images`ディレクトリに配置する必要があります