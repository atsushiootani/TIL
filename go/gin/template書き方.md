## template

書き方例

```.go
        <select name="status">
            {{$status := .tweet.Status}}
            {{range .Statuses}}
                {{if eq . $status}}
                    <option value={{.}} selected>{{.}}</option>
                {{else}}
                    <option value={{.}}>{{.}}</option>
                {{end}}
            {{end}}
        </select>
```

### 変数宣言

```
{{$status := .tweet.Status}}
```

### ループ

```.go
{{range .Statuses}}
  {{.}}
{{end}}
```

### 分岐

```.go
{{if eq . $status}}
{{else}}
{{end}}
```

### 比較

`eq`
string と Status(stringを元に作った独自型)の比較とかも正しく行われる
