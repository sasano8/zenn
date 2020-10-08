---
title: "fastapiで爆速開発"
emoji: "😸" # アイキャッチとして使われる絵文字（1文字だけ）
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["markdown", "python", "fastapi"]
published: false
---

# 対象の読者
- 2020/10のpython事情を知りたい人

# 近況
2020/10/5に、python3.9がリリースされた。python3.9では、型ヒントがtypingモジュールのインポートなしに利用できるようになり、型ヒントを簡単に扱えるようになったため、積極的に移行していきたい。ただ、現時点では、3.9に対応していないライブラリも多いため、３ヵ月後など状況を確認するなど、移行時期を見極めていきたい。


# Web Framework
REST APIをベースとするアプリケーションなら、Fast API一強。Open API Schemaやpydanticなど、開発に便利なスタックが取り入れられている。
htmlをレンダリングするのであれば、お好みで。Fast APIは、REST API用のスタックしか同梱していないため、環境構築が面倒。
現在の主流としては、バックエンドはREST API専用で開発し、フロントエンドはReact Vue等で対応する。

- Django
- flask
- responder
- fastapi

# コマンドライン作成ツール
- typer
- click

# パッケージ管理/環境管理
今後は、パッケージ作成等が楽なPoetryか。

- pip
- venv
- pyenv
- pipenv
- Poetry

# コードチェック
コードチェッカーとフォーマッタを併用する。

## コードチェッカー
- pylint
- flake8

## 型チェッカー
- mypy

## フォーマッタ
- autopep8
- black
- isort

# テスト
- unittest
- pytest

# database/validator
- pydantic
- sqlalchemy
- Django orm

# 暗号化
- RSA
- 共通鍵方式
- CSPRNG
- エントロピー源
- UUID
