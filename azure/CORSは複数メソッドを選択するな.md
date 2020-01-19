- blob storage は CORS 設定ができる
  - ref. https://docs.microsoft.com/ja-jp/rest/api/storageservices/Cross-Origin-Resource-Sharing--CORS--Support-for-the-Azure-Storage-Services?redirectedfrom=MSDN

# blob storage の CORS 設定でHTTPメソッドを複数選択すると、 function の input trigger でエラーが起きる

- blob storage の CORS 設定では、HTTPメソッドを複数選択することができる(ex. 'GET,POST,PUT')
- 通常使う分には多分問題ない
- function app の input trigger を blob storage にしていると、function でエラーが発生し、trigger で起動しなくなる

## 何が起きるのか

- 詳しくは
  - https://github.com/Azure/azure-storage-net/issues/916
- 多分、Httpメソッドの情報に 'DELETE,GET,HEAD,MERGE,POST,OPTIONS,PATCH,PUT' という文字列がそのまま設定される
- function 側でHTTPメソッドをパースするときに、↑こんなメソッド名知らないよ、でエラーになっているらしい

## 回避策
- HTTPメソッドは1つだけ選択にする
