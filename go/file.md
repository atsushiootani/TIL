# ファイルを作る

```go
file, err := os.Create("filename")
if err != nil {
  return
}
defer file.Close()
```

# ファイルを開く
ファイルが存在すると確認できている場合

```go
file, err := os.Open("filename")
if err != nil {
  return
}
defer file.Close()
```


# ファイルを開く。なければ作る。常に追加書き込みをする

オプション色々指定できる
Open, Create も内部でこの関数を呼び出している

```go
file, err := os.OpenFile("log/development.log", os.O_RDWR | os.O_CREATE | os.O_APPEND, 0777)
if err != nil {
  return
}
defer file.Close()
```

0777 というのはunix権限のやつ

# os

これらもファイルと同様に使える

```go
os.Stdin
os.Stdout
os.Stderr
```

go のファイルは、 File そのものに限らず使える



