https://go-tour-jp.appspot.com/welcome/1

# インストール

https://golang.org/dl/
からダウンロード、インストール

インストールディレクトリは `/usr/local/go/`
バイナリは `/usr/local/go/bin/go`

# 文法

## package

Go プログラムはパッケージで構成される
main パッケージが起点となる
パッケージ名は、インポートパスの最下ディレクトリと同名になる
- `math/rand` なら `package rand`
- `golang.org/x/net/websocket` なら `package websocket`

```.go
package main

import (
	"fmt"
	"math/rand"
)

func main() {
	fmt.Println("My favorite number is", rand.Intn(10))
}
```

### Exported name

大文字で始まる名前は、パッケージ外から参照可能

```.go
import "math"
math.Pi // => 3.14...
```

## 関数

```go
func add(x int, y int) int {
	return x + y
}

func add(x, y int) int {  // 型名が同じなら省略できる
	return x + y
}

func swap(x, y string) (string, string) { // 複数の値を返せる  # a, b := swap(c, d)
	return y, x
}

func split(sum int) (x, y int) { // 戻り値に名前をつけることもできる
	x = sum * 4 / 9  // 戻り値変数に代入している
	y = sum - x
	return // 単にreturn だけで、x,yを返せる (naked return と呼ぶ)
}
```

型名は変数の**後ろ**
その理由は　https://blog.golang.org/gos-declaration-syntax
要約すると
- C 言語の型名は、 `*` があると紛らわしい ( `int *p` など)
- そこで前後逆にした。 ( `a int` , `arr []int` )
- ただし、参照外しの `*` の順序はCと同じ ( `a = *p` )

### 関数も変数

関数も変数である
変数のように関数を渡せる

```go
//関数を変数に格納
hypot := func(x, y float64) float64 { //func と書くと関数の宣言(?)になる。
	return math.Sqrt(x*x + y*y)
}
fmt.Println(hypot(5, 12)) //呼び出し
// => 13


//関数のシグニチャに使用
func compute(fn func(float64, float64) float64) float64 { //float64を2つ引数にとり、float64を返す関数fn
	return fn(3, 4)
}

//関数を渡す
fmt.Println(compute(math.Pow))
// => 81

```

### 関数はクロージャ

Goの関数はクロージャである
つまり、外部の変数を参照して書き換えることができる

```go
func adder() func(int) int {
	sum := 0
	return func(x int) int {
		sum += x
		return sum
	}
}

func main() {
	pos, neg := adder(), adder()
	for i := 0; i < 10; i++ {
		fmt.Println(
			pos(i),
			neg(-2*i),
		)
	}
}

//=>
0 0
1 -2
3 -6
6 -12
10 -20
15 -30
21 -42
28 -56
36 -72
45 -90
```

関数内の sum の値を保持してどんどん加算していくことになる
クロージャは、自分自身の sum 変数をバインドしている
つまり、 sum はクロージャが作られるたびに新しく実態が作られる。だから pos, neg は別々の sum を加算していることになる。計算結果は混ざらない


## 変数

`var` で宣言
型名も指定できる

```.go
var i int // 型を指定。値は0になっている

var i = 0 // 初期値を与える。型がintになる

var i // これはエラー。型が不明のため

var i, j int = 1, 2 // 複数

func hoge(){
	k := 3  // 関数の中では、この書き方で暗黙的宣言になる
}
```

## 型

```
bool

string

int  int8  int16  int32  int64
uint uint8 uint16 uint32 uint64 uintptr

byte // uint8 の別名

rune // int32 の別名
     // Unicode のコードポイントを表す

float32 float64

complex64 complex128
```

- int, uint, uintptr は、処理系によってサイズが変わる
- 基本的に整数型はintを使う
- 変数に初期値を与えない場合、ゼロ値が代入される
    - int, float ... 0
    - bool ... false
    - string ... ""
    - complex ... 0+0i

### 配列とスライス

配列は固定長
スライスは可変長
スライスは実体を持たない。配列の部分列への参照である
スライスを直接生成すると、暗黙的に配列も作られ（、その配列への参照を持つスライスが作られ）る
スライスを変更すると、元の配列も変更される。逆もまた然り

```go
primes := [6]int{2, 3, 5, 7, 11, 13} //個数を指定したものは配列
primes := []int{2, 3, 5, 7, 11, 13} //個数を指定しないものはスライス。（暗黙的に配列も作られている）

ret := [2][3]uint8{{1,1,2},{2,3,3}} //2次元配列
//ret := [2]uint8 //初期化子がないのはエラー
//ret := [x]uint8 //サイズが定数でないのもエラー


var s []int = primes[2:4] //スライス。始点と終点を指定。始点〜終点の1つ前がスライスされ、 {5,7} になる
var s []int = primes[:4] //0~3のスライスになる
var s []int = primes[2:] //2~6のスライスになる
var s []int = primes[:] //0~6のスライスになる
```


#### スライスの拡張

スライスは、後ろにのみ再拡張することができる
`len()` でスライスの長さ、 `cap()` で再拡張できる長さが返る
（スライスの実体はポインタなのだろうか？そう考えるとスッキリ説明がつくか）

```go
	s := []int{2, 3, 5, 7, 11, 13}
	printSlice(s) // len(s)=6 cap(s)=6 [2 3 5 7 11 13]

	// 後ろを全部消す
	s = s[:0]
	printSlice(s) // len(s)=0 cap(s)=6 []

	// 再度拡張できる
	s = s[:4]
	printSlice(s) // len(s)=4 cap(s)=6 [2 3 5 7]

	// 前を切り捨てる
	s = s[2:]
	printSlice(s) // len(s)=2 cap(s)=4 [5 7]

	// 再拡張は後ろにしかできない
	s = s[:4] //s[:5] にすると実行時エラーになる. panic: runtime error: slice bounds out of range [:5] with capacity 4
	printSlice(s) // len(s)=4 cap(s)=4 [5 7 11 13]
```

#### スライスの追加

```go
	var s []int
	printSlice(s) // len=0 cap=0[]

	s = append(s, 0)
	printSlice(s) // len=1 cap=2 [0]

	// The slice grows as needed.
	s = append(s, 1)
	printSlice(s) // len=2 cap=2 [0 1] // capacity は自動でアロケートされるので、1より大きくなることもある

	// We can add more than one element at a time.
	s = append(s, 2, 3, 4)
	printSlice(s) // len=5 cap=8 [0 1 2 3 4]

	//同じ配列を参照する別のスライスを追加
	t := s[1:3]
	printSlice(t) //len=2 cap=7 [1 2]

	//別のスライスの方をappendする
	t = append(t, 9)
	printSlice(s) // len=5 cap=8 [0 1 2 9 4]  // <= !!!! 元のスライスが上書きされる。スライスが単なる参照と考えれば説明がつく
```

#### 動的サイズのスライスを作成

動的サイズの配列を作ることはできない

```go
a := make([]int, 5)  // len(a)=5
b := make([]int, 0, 5) // len(b)=0, cap(b)=5
b = b[:cap(b)] // len(b)=5, cap(b)=5
b = b[1:]      // len(b)=4, cap(b)=4
```

#### 二次元配列、スライスのスライス

二次元配列の宣言

```go
matrix := [4][2]float64{{0, 0}, {0, 1}, {1, 0}, {1, 1}}
```

スライスのスライス

```go
matrix := [][]float64{{0, 0}, {0, 1}, {1, 0}, {1, 1}}

//あるいは
matrix := [][]float64{[]float64{0, 0}, []float64{0, 1}, []float64{1, 0}, []float64{1, 1}}
```

二次元スライスを動的に作る

```go
matrix := make([][]float64, 4)
matrix[0] = []float64{1, 0, 0, 0}
matrix[1] = []float64{0, 1, 0, 0}
matrix[2] = []float64{0, 0, 1, 0}
matrix[3] = []float64{0, 0, 0, 1}
```

```go
dx := 2
dy := 4
matrix := make([][]float64, dy)
for y := 0; y < dy; y++ {
  matrix[y] = make([]float64, dx)
}
```

### 型変換

Cとは異なり、暗黙的キャストは実行されない
`T(v)` と書く

```go
var i int = 42
var f float64 = float64(i)
var u uint = uint(f)

var f float64 = i // これはエラー。暗黙的キャストしないため

//こうでも良い
i := 42
f := float64(i)
u := uint(f)
```

### 型の確認

`%T` を使う

```.go
import "fmt"
fmt.Printf("v is of type %T\n", v)
```

## 定数

`const` を使う

```go
const PI float = 3.14
const PI = 3.14

const Big = 1 << 100 //型のない定数は、必要なだけ精度の高い型になる。これでちゃんと動く
```

intの精度が64bitで足りない時は、constにすると言うのも手

## 制御構造

### for文

C と同じ。カッコはいらない

```.go
	sum := 0
	for i := 0; i < 10; i++ {
		sum += i
	}
	fmt.Println(sum)


	for ; sum < 1000; { //省略可能
		sum += sum
	}

	for sum < 1000 { //さらにセミコロンも省略。これが while 文になる
		sum += sum
	}

	for { //さらにさらに省略。これで無限ループ
	}
```

### for each

**range** を使う

スライスやmapの列挙
for文の中でないと書けない？

```go
var pow = []int{1, 2, 4, 8, 16, 32, 64, 128}

func main() {
	for i, v := range pow { //インデックスと値を取る
		fmt.Printf("2**%d = %d\n", i, v)
	}
}

for i := range pow { //値が不要な場合はこう

for _, v := range pow{ //インデックスが不要な場合はこう
```

### if文

かっこ不要
`else if` `else` は、必ず **前の`}` と同じ行に書くこと**。改行するとエラーになる


```go
	if x < 0 {
		return sqrt(-x) + "i"
	}

	if v := math.Pow(x, n); v < lim { //式が使える。変数も宣言できる。スコープはif文内(else節含む)
		return v
	} else if v > hoge{ //else if
	} else{
		return v //こちらでも使える
	}
```

### switch

case は1つだけ実行される。（defaultもある）
break の記述は不要。必ず1つだけ実行
case は定数でなくても良い

```go
	switch os := runtime.GOOS; os {
	case "darwin":
		fmt.Println("OS X.")
	case "linux":
		fmt.Println("Linux.")
	default:
		// freebsd, openbsd,
		// plan9, windows...
		fmt.Printf("%s.", os)
	}

	switch { //switch の後ろを省略すると、true が書かれていることになる
	case t.Hour() < 12: //そのため、このように書ける
		fmt.Println("Good morning!")
	case t.Hour() < 17:
		fmt.Println("Good afternoon.")
	default:
		fmt.Println("Good evening.")
	}
```

### defer

後ろに関数呼び出しを伴う。伴った関数の実行を、呼び出し元の関数の終わりまで遅延させる
defer の後ろが関数呼び出しでないとエラーになる
関数呼び出しは遅延するが、**引数の評価は即時に行われる**
複数回 defer した場合、最後のdefer から先に実行される(LIFO)

```go
func main() {
	defer fmt.Println("world")

	fmt.Println("hello")
}
//=> hello / world

defer 1 //これはエラー

func hoge(){
	x := 1
	defer fmt.Println(x)
	x += 1
}
// => 1 // 関数呼び出しは遅延するが、引数の評価は即時に行われる
```

defer に付いて https://blog.golang.org/defer-panic-and-recover
- クリーンアップ処理などを簡易に行うためのもの

```go
func CopyFile(dstName, srcName string) (written int64, err error) {
    src, err := os.Open(srcName)
    if err != nil {
        return
    }
    defer src.Close()

    dst, err := os.Create(dstName)
    if err != nil {
        return
    }
    defer dst.Close()

    return io.Copy(dst, src)
}
```

ラムダ式（という呼び方でいいのか？）も書くことができる
```go
    defer func() { i++ }()
```

戻り値を書き換えることもできる
これはエラーコードを返す使い方などが想定されている

```go
func c() (i int) {
    defer func() { i++ }()
    return 1
}
// => 2が返る
```

### panic, recover 

raise と rescue に相当


```go
package main

import "fmt"

func main() {
    f()
    fmt.Println("Returned normally from f.")
}

func f() {
    defer func() {
        if r := recover(); r != nil {
            fmt.Println("Recovered in f", r)
        }
    }()
    fmt.Println("Calling g.")
    g(0)
    fmt.Println("Returned normally from g.")
}

func g(i int) {
    if i > 3 {
        fmt.Println("Panicking!")
        panic(fmt.Sprintf("%v", i))
    }
    defer fmt.Println("Defer in g", i)
    fmt.Println("Printing in g", i)
    g(i + 1)
}
=> Calling g.
Printing in g 0
Printing in g 1
Printing in g 2
Printing in g 3
Panicking!
Defer in g 3
Defer in g 2
Defer in g 1
Defer in g 0
Recovered in f 4
Returned normally from f.
```

## 日付

```go
import "time"

time.Now() //現在時刻。 time.Time 型
time.Now().Year() //年。 time.Year 型
time.Now().Weekday() //曜日。 time.Weekday型
```

### sleep

3秒待つ例

```go
import "time"

time.Sleep(3 * time.Second) //3秒待つ

//ちなみに
int(time.Second) // => 1000000000
//つまり、timeはナノ秒単位で扱われている
```



## ポインタ

```.go
i := 42
p := &i
*p = 21
```

## 構造体

```.go
type Vertex struct {
	X int
	Y int
}

v := Vertex{1, 2}
fmt.Println(v.X) // => 1

//ポインタアクセス
p := &v
p.X = 19 //(*p).X でも同じ。アロー演算子は無いようだ

//いろんな初期化方法
var (
	v1 = Vertex{1, 2}  // has type Vertex
	v2 = Vertex{X: 1}  // Y:0 is implicit
	v3 = Vertex{}      // X:0 and Y:0
	p  = &Vertex{1, 2} // has type *Vertex
)
fmt.Println(v1.X, p.X) //実体だろうがポインタだろうが、ドットアクセスすることは同じ
```

## map

```go
var m map[string]int //キーがstring, バリューがint のmap型
m = make(map[string]int) //make で作る
m["Bell"] = 1 //値の格納

//値が構造体の例
var m map[string]Vertex
m = make(map[string]Vertex)
m["Bell Labs"] = Vertex{
	40.68433, -74.39967,
}

//初期化子の書き方
var m = map[string]Vertex{
	"Bell Labs": Vertex{
		40.68433, -74.39967,
	},
	"Google": Vertex{
		37.42202, -122.08408,
	},
}

//型の類推はされるので、省略できる
var m = map[string]Vertex{
	"Bell Labs": {
		40.68433, -74.39967,
	},
	"Google": {
		37.42202, -122.08408,
	},
}
```

要素の操作

```go
//代入
m[key] = elem

//取得
elem := m[key]
elem, ok := m[key] //こうすると、ok が true/false で値が存在するかを返す
//ゼロ値が返ってきた時、ゼロ値が格納されているのか、キーが存在しないのかの区別はこれで行う

//削除
delete(m, key)
```

## クラス

ない

## メソッド

型にメソッドを定義できる
メソッドは、特別なレシーバを定義できる関数である

```go
type Vertex struct {
	X, Y float64
}

//   レシーバ定義
//   ↓↓↓↓↓↓↓↓↓↓
func (v Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

v := Vertex{3,4}
v.Abs()
//ポインタ変数からでも呼び出せる。つまり、 p := &v の時、 p.Abs() と書いても大丈夫(Goが (*p).Abs() と解釈してくれる)

//ちなみに普通の関数だと
func Abs(v Vertex) float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}
Abs(v)

//レシーバ自身を変更したい場合は、 * をつける
func (v *Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y) //この例だと書き換えてないので意味ないが
}
v.Abs() //呼び出し方法はそのまま。 Go が自動的に (&v).Abs() と解釈する

//ちなみに普通の関数だと
func Abs(v *Vertex) float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}
Abs(&v) //&が必要になる（ないとコンパイルエラー）
```

ポインタレシーバを使うと、値コピーが発生しない
値レシーバとポインタレシーバは混在させない方が良い


### 定義はパッケージ内で

メソッド定義は、型と同じパッケージ内で行う必要がある
つまり、よそのライブラリに拡張メソッドとか作ることはできない
組み込み型にメソッドを作ることもできない

それをしたい場合は、独自型を作ることになる

```go
type MyFloat float64 //型の別名？

func (f MyFloat) Abs() float64 {
	if f < 0 {
		return float64(-f)
	}
	return float64(f)
}

f := MyFloat(-10)
f.Abs() // => 10
```

## インタフェース

```go
//I と言う名前のインタフェースは、 M() と言うメソッドを実装していることを求める
type I interface {
	M()
}

//T という型があり、M()と言うメソッドを実装している
type T struct {
	S string
}
func (t T) M() {  //M() が実装さえしてあればいい。implements I のような構文は不要
	fmt.Println(t.S)
}

//すると、TはIとして扱えるようになる
var i I = T{"hello"}
i.M() //=> "hello"
```
```go
type I interface {
	M()
}

//もしも、M()がポインタレシーバだったら
type T struct {
	S string
}
func (t *T) M() {
	fmt.Println(t.S)
}

//呼び出し側もポインタにすること
var i I = &T{"hello"} //Tのポインタは、値レシーバたるM()を呼び出せる
i.M()
```

### 空のinterface

メソッドを一つも持たないinterfaceは、あらゆる型を受け付けることができる

### 型アサーション（キャスト）

インタフェース変数から、具体的な型にキャストする

```go
t := i.(T) //もし i がT型でなければpanic
t, ok := i.(T) //ok にtrue/false が入る。falseならtはゼロ値になる。panic しない

t := i.(int) //iをint型にキャスト。カッコは必須
```

### 型スイッチ

- 引数で汎用型を受け取りたい時は、 `interface{}` と書けば良い
- 変数の型を取得する時は、 `i.(type)` と書く（switch文でのみ有効な文法）

```go
func do(i interface{}) {
    switch v := i.(type) {
    case int:
        fmt.Printf("Twice %v is %v\n", v, v*2)
    case string:
        fmt.Printf("%q is %v bytes long\n", v, len(v))
    default:
        fmt.Printf("I don't know about type %T!\n", v)
    }
}
​
func main() {
    do(21)
    do("hello")
    do(true)
}

```

### インタフェースを受け取るメソッドの例（fmt.Println）

`fmt.Println` の引数は、 Stringer インタフェースである
つまり、 string 型を返す `String()` という名前のメソッドがあれば、どんなものでも Println に渡すことができる

```go
type Stringer interface {
    String() string
}
```

例

```go
type Person struct {
	Name string
	Age  int
}

func (p Person) String() string {
	return fmt.Sprintf("%v (%v years)", p.Name, p.Age)
}

a := Person{"Arthur Dent", 42}
fmt.Println(a)
// => Arthur Dent (42 years)
```

### error型

エラーの状態を表す型。組み込みのインタフェース

```go
type error interface {
    Error() string
}
```

使用例
MyError 型ではなく、 *MyError 型が error インタフェースを満たすように作っている例
そのため、error が必要な場面では、 `&MyError` を渡すようにしている

```go
type MyError struct {
	When time.Time
	What string
}

func (e *MyError) Error() string { // <= MyError
	return fmt.Sprintf("at %v, %s",
		e.When, e.What)
}

func run() error {
	return &MyError{ // <= ポインタにして返す
		time.Now(),
		"it didn't work",
	}
}

func main() {
	if err := run(); err != nil {
		fmt.Println(err)
	}
}
```

ちなみに、go はポインタについてある程度自動でやってくれるため、以下のような挙動になる

| 定義 | 呼び出し | 結果 |
|---|---|---|
|*MyError|&MyError|OK|
|*MyError|MyError|コンパイルエラー|
|MyError|&MyError|OK|
|MyError|MyError|OK|

定義をポインタメソッドでやるかどうかは、単にインスタンスコピーを発生させたくないかどうかに依る（のだと思う）

### 組み込み型にエラー情報を追加する方法

float64 型を拡張し、 `ErrNegativeSqrt` 型を作り、 Error() メソッドを定義する

```go
type ErrNegativeSqrt float64

func (e ErrNegativeSqrt) Error() string{
	return fmt.Sprintf("cannot Sqrt negative number: %f", e); // <= これで、e がfloat64 として出力できる
}

func Sqrt(x float64) (float64, error) {
	if (x < 0) {
		return 0, ErrNegativeSqrt(x)
	}

	z := 1.0
	for i := 0; i < 10; i++ {
		z -= (z*z - x) / (2*z)
	}
	return z, nil
}

func main() {
	fmt.Println(Sqrt(2))
	fmt.Println(Sqrt(-2))
}
// =>
//1.414213562373095 <nil>
//0 cannot Sqrt negative number: -2.000000
```

# goroutine

Goのランタイムに管理される軽量なスレッド

```go
go f(x, y, z)
```

x,y,z はカレントのスレッドで実行され
go() の呼び出しが新しいスレッド（ゴルーチン）で実行される
同じメモリ空間で実行される

ラムダ関数も使える

```go
go func() { ... }()
```

## channel

チャネルとは、スレッドを超えて値をやり取りする仕組み

`c := make(chan int)` のように生成
`c <- value` のようにして値を渡す（ゴルーチンから） ...(A)
`x := <- c` のようにして値を受け取る（メインスレッド） ...(B)
(A)が実行されるまで(B)は待つ。ロックなどを管理する必要がない。便利！

```go
func sum(s []int, c chan int) {
	sum := 0
	for _, v := range s {
		sum += v
	}
	c <- sum // send sum to c
}

func main() {
	s := []int{7, 2, 8, -9, 4, 0}

	c := make(chan int)
	go sum(s[:len(s)/2], c)
	go sum(s[len(s)/2:], c)
	x, y := <-c, <-c // receive from c

	fmt.Println(x, y, x+y) // => -5 17 12
}
```

ゴルーチンはスタック？後からgo した方が先に実行されている

### チャネルのサイズ

チャネルはサイズを指定してバッファとして扱える
`c <- v` で格納され、 `x <- c` で取り出される

```go
	ch := make(chan int, 2) //サイズ2のバッファとして作成
	ch <- 1
	ch <- 2 //バッファが満杯になる
	fmt.Println(<-ch)
	fmt.Println(<-ch) //ここでバッファが空になる
	ch <- 3 //再びバッファに格納できるようになる
	fmt.Println(<-ch)
```

バッファサイズを超えて格納しようとする、あるいはバッファが空なのに取り出そうとすると以下のようなエラーが起きる

```go
fatal error: all goroutines are asleep - deadlock!

goroutine 1 [chan send]:
main.main()
	/tmp/sandbox524996555/prog.go:9 +0xa0 // <= この位置でエラーが起きている
```

### チャネルを閉じる

送受信する値がもう無いということを明示するために、チャネルをクローズすることができる
クローズすることは必須ではない

```go
close(c)
```

送信側でも受信側でもクローズすることはできるが、必ず **送信側で** クローズするのが良い
受信側でクローズしてしまうと、送信側が気づけない。クローズしたチャネルに送信すると panic になる

チャネルを閉じたかどうか知るには、以下のように書く

```go
v, ok := <-ch
```

vには値が、 ok には true/false が格納される。
チャネルの値が空になり、かつクローズしている場合に `ok = false` になる

#### 使用例

再帰関数で ch を使ってデータを送るときとか
最後に `close(ch)` したいときはよくある
再帰部分を内部関数にして、本体関数の最後で `close(ch)` をするとかが有効

### チャネルの値をループで受け取る

```go
for i := range c {
	fmt.Println(i)
}
```

チャネルが空になり、かつクローズすると for は終了する

### select

goroutine に対する処理を複数書くことができる
複数のチャネルを跨いだ分岐処理などが記述できる
case 文に書いた操作が実行できる時は、そのcaseブロックを実行する
複数が実行できる時は、ランダムに実行する


```go
func fibonacci(c, quit chan int) { // c, quit はチャネル
	x, y := 0, 1
	for {
		select {
		case c <- x: // cチャネルに値を格納することができるなら
			x, y = y, x+y //これを実行...(A)
		case <-quit: // quitチャネルから値が取得できたら
			fmt.Println("quit") //これを実行...(B)
			return
		default: //どれも実行されないなら
			fmt.Println("...") //これを実行
			time.Sleep(1 * time.Second) //スリープさせないといけないと思う
		}
	}
}

func main() {
	c := make(chan int)
	quit := make(chan int)
	go func() {
		for i := 0; i < 10; i++ {
			fmt.Println(<-c) // c チャネルから値を取得。チャネルが空くので、(A)が実行されることになる
			time.Sleep(3 * time.Second)
		}
		quit <- 0 // quit チャネルに値を格納。(B)が実行されることになる
	}()
	fibonacci(c, quit)
}
```

## 排他制御

`sync.Mutex` を使うと、排他制御ができる

```go
import "sync"

a int
a_mux sync.Mutex

func modifyA(){
  a_mux.Lock()
  a++ //ここは排他的
  a_mux.Unlock()
}

func getA(){
  a_mux.Lock()
  defer a_mux.Unlock() //defer を使うことで、 unlock を忘れない

  return a //ここも排他制御
}
```
