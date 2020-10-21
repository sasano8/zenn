# 環境
- postgress
- sqlalchemy

# 制約命名ルール
制約名は以下を参考とする。

## sqlalchemy
- 主キー: {tablename}_pkey
- ユニークインデックス: ?
- 一意でないインデックス: ix_{table_name}_{column_name}
- check制約: ?
- デフォルト制約: ?
- 外部キー制約: ?

## 個人ルール
- 主キー: pk_
- ユニークインデックス: uq_
- 一意でないインデックス: ix_
- check制約: ck_
- デフォルト制約: df_
- 外部キー制約: fk_


# はじめに

```
import sqlalchemy as sa
from sqlalchemy.ext.declarative import declarative_base
Base = declarative_base()
```

# 共通化・抽象化の基本

## ケース１
Baseを継承したクラスを共通クラスとして利用することはできない。
Baseを継承した際は、__tablename__を設定し、具象化する必要がある。

```
class CommonTable(Base):
  id = sa.Column(sa.Integer, primary_key=True, index=True)
  name = sa.Column(sa.String(255), nullable=False)

# => sqlalchemy.exc.InvalidRequestError: Class <class 'CommonTable'> does not have a __table__ or __tablename__ specified and does not inherit from an existing table-mapped class.


## ケース２
制約名は、スキーマで一意なため、共通化することができない。

```
class CommonTable:
  id = sa.Column(sa.Integer, primary_key=True, index=True)
  name = sa.Column(sa.String(255), nullable=False)

__table_args__ = (
  sa.UniqueConstraint("name", name="uq_name"),
)

class Table1(CommonBase, Base):
  __tablename__ = "table1"

class Table2(CommonBase, Base):
  __tablename__ = "table2"

# => sqlalchemy.exc.ProgrammingError: (psycopg2.errors.DuplicateTable) relation "uq_name" already exists
```

## ケース３
ケース２と同じく。

```
class CommonTable:
  id = sa.Column(sa.Integer, primary_key=True, index=True)
  name = sa.Column(sa.String(255), nullable=False)

class Table1(CommonBase, Base):
  __tablename__ = "table1"
  __table_args__ = (
    sa.UniqueConstraint("name", name="uq_name"),
  )

class Table2(CommonBase, Base):
  __tablename__ = "table2"
  __table_args__ = (
    sa.UniqueConstraint("name", name="uq_name"),
  )

# => sqlalchemy.exc.ProgrammingError: (psycopg2.errors.DuplicateTable) relation "uq_name" already exists
```



# カラムの共通化
プレーンな抽象宣言クラスとBaseをミックスインする。

## 方法１
```
class Common:
  id = sa.Column(sa.Integer, primary_key=True, index=True)
  name = sa.Column(sa.String(255), nullable=False)
  
  __table_args__ = (
    sa.UniqueConstraint("name", name="uix_name"),
  )

class MyTable(Common, Base):
  __tablename__ = "mytable"

```

## 方法２
```
class CommonBase:
  id = sa.Column(sa.Integer, primary_key=True, index=True)
  name = sa.Column(sa.String(255), nullable=False)

class MyTable(CommonBase):
  __tablename__ = "mytable"

```
