---
title: "fastapiで爆速開発"
emoji: "😸" # アイキャッチとして使われる絵文字（1文字だけ）
type: "tech" # tech: 技術記事 / idea: アイデア記事
topics: ["markdown", "python", "fastapi"]
published: false
---

# 対象の読者
- FastAPIをこれから初めてみようと思っている人
- poetry

# 環境構築

``` shell
mkdir sample
cd sample

poetry init
# <プロジェクトの情報を入力>

poetry add fastapi
poetry add uvicorn
poetry add genson
poetry add datamodel-code-generator

touch main.py
```

# コードを書く

``` python
from fastapi import FastAPI
import asyncio

app = FastAPI()

@app.get("/")
async def get_info():
    return {
        "name": "yamada"
    }
```

# asyncio
awaitable オブジェクトには主に3つの種類があります

- coroutine
- Task
- Future


```
import asyncio

async def func():
 return True

loop = asyncio.get_event_loop()

print(type(func)) #function
print(type(func())) #coroutine

task = loop.create_task(get_info())
print(task) # ta
```
