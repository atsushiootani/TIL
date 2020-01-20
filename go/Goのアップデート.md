# アップデート

```bash
brew upgrade go

go version
```

## TroubleShoot

ライブラリをインストールしようとして、 `undefined: strings.Builder` というエラーがでた
go 自体をアップデートしたら直った

## GOROOT の再設定

アップデートした後、

```bash
go version
# => go: cannot find GOROOT directory: /usr/local/Cellar/go/1.9.2/libexec
```

というエラーになる時がある
バージョンが変わったので、ディレクトリも変わらないといけないのだが、 GOROOT の設定がそのままになっている

### 解決策

GoLand を起動していると、自動的に GOROOT の再設定を促す表示が出てくるので
そのままクリックして、新しいバージョンのディレクトリを選択

 <img width="1052" alt="スクリーンショット 2020-01-20 19.21.55.png (212.7 kB)" src="https://img.esa.io/uploads/production/attachments/8402/2020/01/20/32642/65f3964a-a23b-4e82-8bfd-f693e0b9302e.png">

**新しいターミナル** で確認

```
$ go version
# => go version go1.13.6 darwin/amd64
```
