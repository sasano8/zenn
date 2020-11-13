いいからpydanticを使えって話。

# 1. dataclassはデフォルト値に設定した値の参照を使い回す

```
from dataclasses import dataclass

@dataclass
class Parent:
    name: str
    age: int = 0

@dataclass
class Child:
    name: str
    age: int = 0
    parent: User = User(name="parent", age=40)

        
a = Child(name="child", age=20)
b = Child(name="child", age=20)

print(id(a.parent) == id(b.parent))
# => True
```

```
from pydantic import BaseModel

class Parent(BaseModel):
    name: str
    age: int = 0

class Child(BaseModel):
    name: str
    age: int = 0
    parent: User = User(name="parent", age=40)

        
a = Child(name="child", age=20)
b = Child(name="child", age=20)

print(id(a.parent) == id(b.parent))
# => False
```


