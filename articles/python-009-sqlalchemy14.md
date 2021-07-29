
# sqlalchemy1.4
sqlalchemy1.4が3/15？にリリースされた。sqlalchemy1.4では、コンセプト一新しておりsqlalchemy2.0に向けた新しいAPIを提供する。

# 何が新しいか
sqlalchemy1.4では以下のような変更があり、重大な非互換についてはfuture=Trueで利用することができる。
sqlalchemy2.0では、今回の変更がベースになるので新しいAPIを利用するように更新していく。

- statementの実行結果はnamedtupleとdictのハイブリッドのようなものが返るようになった
- db.query(Model).delete updateは delete(Model).where(id==1).execution.option(synchronize_session="fetch")が推奨されるようになった

