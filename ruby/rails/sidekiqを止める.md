簡易コマンド作った

```bash
PID=`pgrep -nf sidekiq`
echo $PID
if [ -n "$PID" ]; then
  kill -TERM $PID
fi
```
