gofmt コマンドを使うと、go のコードをある程度自動で整形してくれる
行頭のスペースをタブに直すとか

# 修正

## 差分の表示

git の差分表示みたいに整形前後の表示してくれる

```bash
gofmt -d main.go
```

## 修正を実行

実際に上書きされる

```bash
gofmt -w main.go
```

## 置換

自分で置換文字列を指定すると、置換してくれる

```bash
# 書き換えた結果のファイルを表示
gofmt -r 'FIELD_HEIGHT -> FieldHeight' main.go

# 書き換え前後の差分を実行
gofmt -d -r 'FIELD_HEIGHT -> FieldHeight' main.go

# 書き換えを実行
gofmt -w -r 'FIELD_HEIGHT -> FieldHeight' main.go
```

小文字1文字は、ワイルドカード扱いになる

ref. https://qiita.com/ikawaha/items/73c0a1d975680276b2c7

> 例えば，配列の record[0:len(records)] を records[0:] に置き換えるには，a[b:len(a)] -> a[b:] と指定します．

```sh
gofmt -r 'a[b:len(a)] -> a[b:]' -d foo.go
```

# 所感

IDEに任せた方が良さそう
GoLand は教えてくれる
