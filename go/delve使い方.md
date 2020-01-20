https://qiita.com/minamijoyo/items/4da68467c1c5d94c8cd7

```bash
# brew install go-delve/delve/delve

go get -u github.com/derekparker/delve/cmd/dlv
```

```
$ dlv debug
# => 起動
(dlv) b main.canPlace # ブレークポイントをセット
(dlv) c # 開始 (continueの意味)
(dlv) n # 次の行へ
(dlv) s # ステップイン
(dlv) so # ステップアウト
(dlv) p x # xの値を表示
(dlv) locals # ローカル変数の値をまとめて表示
(dlv) args # 関数の引数をまとめて表示
(dlv) vars # パッケージ変数をまとめて表示
(dlv) bt # バックトレースの表示
(dlv) bp # ブレークポイントの一覧を表示
(dlv) clear 1 # ブレークポイント(id=1)を削除
(dlv) clearall # ブレークポイントを全部削除
(dlv) help # ヘルプ
```

# 標準入力受け付けない問題

dlv でデバッグ中、プログラムが標準入力を受け付ける状態になると
標準入力がdlvに飲み込まれてしまうため、プログラムが進められなくなる

## 対応

ref. https://github.com/go-delve/delve/issues/65

まず、プログラムを一度コンパイルする
コンパイルしたプログラムを実行する

```bash
$ go build  -gcflags="-N -l" reversi.go
$ ./reversi
```

で、新しいターミナルを開き
このプロセスに対してdlvをアタッチする

```bash
$  dlv attach $(pgrep -fn reversi)
```

これで無事に動く。プログラムがわのターミナルで標準入力入れて、dlv側のターミナルでデバッグできる
めっちゃイケてる
