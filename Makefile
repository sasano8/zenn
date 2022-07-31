doc-build:
	@cp -r articles/* docs
	@cp -r images/* docs/img
    # doc一覧を取得してimagesをimgにマップする
	@ls -F `pwd`/docs/* | grep -v /$$ | grep -v :$$ | grep -v '^\s*$$' | grep ^/ | xargs sed -i 's/..\/images/.\/img/'
    # zennとmkdocs非互換のドキュメントを除去する
	@rm docs/python-006-dictionary.md
	@poetry run mkdocs build

doc-serve: doc-build
	@poetry run mkdocs serve -a localhost:8001

aaa:
	@echo '^\s*$$'