#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-8080}"
ROOT="/workspace"
LOG="/tmp/matchday-http.log"
PIDFILE="/tmp/matchday-http.pid"

if [[ -f "$PIDFILE" ]]; then
  old_pid="$(cat "$PIDFILE")"
  if kill -0 "$old_pid" 2>/dev/null; then
    if curl -sf "http://127.0.0.1:${PORT}/" -o /dev/null; then
      exit 0
    fi
  fi
fi

cd "$ROOT"
nohup python3 -m http.server "$PORT" --bind 127.0.0.1 >"$LOG" 2>&1 &
echo $! >"$PIDFILE"

for _ in $(seq 1 40); do
  if curl -sf "http://127.0.0.1:${PORT}/" -o /dev/null; then
    exit 0
  fi
  sleep 0.25
done

echo "Dev server did not become ready on port ${PORT}" >&2
exit 1
