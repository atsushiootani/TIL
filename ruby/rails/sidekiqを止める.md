簡易コマンド作った

```bash
PID=`pgrep -nf sidekiq`
if [ -n "$PID" ]; then
  kill -TERM $PID
fi
```
