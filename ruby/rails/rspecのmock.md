mock を返し、そのmockがさらに次のメソッドを返すようにしたい時はこうかく

ref. https://qiita.com/sesame/items/8d4419da0afde3bb845f#%E3%82%A4%E3%83%B3%E3%82%B9%E3%82%BF%E3%83%B3%E3%82%B9%E3%81%8C%E5%8F%8D%E5%BF%9C%E3%81%99%E3%82%8B%E3%83%A1%E3%82%BD%E3%83%83%E3%83%89%E3%82%92%E8%A8%AD%E5%AE%9A%E3%81%99%E3%82%8B

```.rb
mock_obj = double('DummyClass')
allow(sample).to receive(:method).and_return(mock_obj)
allow(mock_obj).to receive(:another_method)
```

こうすると、

```.rb
sample.method.another_method
```
というコードがmockで動かせるようになる
