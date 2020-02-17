書き出し先を設定（標準出力、標準エラー、ファイル、、、）
コールスタックを遡って指定（エラーの位置そのものでなく、それを呼び出した関数を表示できる。log 表示用関数を作っておくとき、その関数自体が呼ばれてしまうのを防げる）
ヘッダを指定したり、色々できる様子


# 例

```go

func init(){
	log.SetPrefix("[SAMPLE]")
	log.SetFlags(log.Ldate | log.Ltime | log.LUTC | log.Llongfile) // ログに日付と時刻をUTCで表示し、ファイル名はフルパスで表示
}

func main(){
	log.Print("aaa")
}
```

```
[SAMPLE]2020/02/17 08:45:26 /path/to/test.go:30: aaa
```

## Output

```
func mylog(){
    log.Output(1, s)
}
```

第1引数は、コールスタックの深さを表す

- 0 ... `log.Output()` の中の行数を返す
    - `/usr/local/Cellar/go/1.13.6/libexec/src/log/log.go:363` みたいなのが返ってくる。全然意味ない
- 1 ... 上の例でいうと `mylog()` が返ってくる
    - これで良い
    - 例えば、mylog() というメソッド自体が、自分で作ったログ用関数だとすると、その行数がでたところで参考にならない
- 2 ... 上の例でいうと、 mylog() を呼び出した行が返ってくる

## log インスタンスを生成

Output とかヘッダとかは、一度設定するとずっとそのままになるので
パッケージごととかに log インスタンスを作るのが良い

```go

var logger *log.Logger

func init(){
	logger = log.New(os.Stdout, "[SAMPLE]", log.Ldate | log.Ltime | log.LUTC | log.Llongfile)
}

func main(){
	logger.Print("aaa")
}
```

## ファイルに書き出す

ファイルを開いて、 `log.New` にファイルストリームを指定

```go
func init(){
	file, err := os.OpenFile("development.log", os.O_RDWR | os.O_CREATE | os.O_APPEND, 0777)
	if err != nil{
		panic(err)
	}

	logger = log.New(file, "[SAMPLE]", log.Ldate | log.Ltime | log.LUTC | log.Llongfile)
}
```

