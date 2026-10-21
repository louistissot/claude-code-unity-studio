#!/bin/bash
# A skeleton of the network test and the soak test: one headless host and N headless clients of the development player
# on this machine (127.0.0.1). Adapt it to your network library and to your game (the TODO lines).
#
# Usage: tools/unity-lock.sh tools/net-test.sh [seconds] [clients] [mode]
#   Default: 120 s, 1 client, mode "walk". A soak: tools/unity-lock.sh tools/net-test.sh 3600 3 roam
# Build the development player first: tools/unity-lock.sh --exclusive tools/batch.sh BuildTools.BuildDevMac
#
# The contract with the game (the sample driver: templates/unity/Assets/Scripts/Testing/CommandLineDriver.cs):
#   -net host -net-players <n>   start a host and wait for n players
#   -net join <address>          join a host
#   -net-mode <mode>             what the driver does (walk, roam, or your own modes)
#   -net-seconds <s>             quit with exit code 0 after s seconds
#   -net-log <file>              write the test lines to this file
# The test lines that the checks read (the driver writes them):
#   "[NetTest] host started"   "[NetTest] connected"   "[NetTest] players <n>"   "[NetTest] seed <n>"
#
# The checks: each player ends with exit code 0; no exception in the Unity logs; the host starts; each client connects;
# the last "players" line of each player shows all players; all players have the same seed (the same game); in a run of
# 10 minutes or more, the memory of each player grows less than NET_MEMORY_GROWTH_MB_MAX from the first quarter to the
# end. The output is in Logs/nettest/. The exit code is 0 when all checks pass.

source "$(dirname "$0")/lib/common.sh"
require_lock
cd "$PROJECT_DIR" || exit 2
SECS=${1:-120}
CLIENTS=${2:-1}
MODE=${3:-walk}
BIN="$PROJECT_DIR/$DEV_PLAYER"
OUT="$PROJECT_DIR/Logs/nettest"
[ -x "$BIN" ] || die "no development player at $BIN (build it first; DEV_PLAYER in sessions.conf)"
mkdir -p "$OUT"
rm -f "$OUT"/*.log "$OUT"/memory.csv "$OUT"/exit-*.txt

# TODO: add the arguments of your game (a quality preset, a fixed frame rate, a level, a seed).
"$BIN" -batchmode -nographics -logFile "$OUT/host-unity.log" -net host -net-players $((CLIENTS + 1)) \
  -net-mode "$MODE" -net-log "$OUT/host.log" -net-seconds "$SECS" </dev/null >/dev/null 2>&1 &
PIDS=($!)
NAMES=(host)
# The clients start when the host listens. A client that starts too early can fail to connect, and then the host waits
# for ever for the last player.
for _ in $(seq 1 60); do
  grep -q "\[NetTest\] host started" "$OUT/host.log" 2>/dev/null && break
  sleep 1
done
sleep 1
for i in $(seq 1 "$CLIENTS"); do
  # Each client stops before the host: a client that lives longer than the host loses it and connects again.
  "$BIN" -batchmode -nographics -logFile "$OUT/client$i-unity.log" -net join 127.0.0.1 -net-mode "$MODE" \
    -net-log "$OUT/client$i.log" -net-seconds "$((SECS - 8 - 2 * i))" </dev/null >/dev/null 2>&1 &
  PIDS+=($!)
  NAMES+=("client$i")
  sleep 2
done

# The resident memory of each player every 30 s: seconds since the start, name, MB.
(
  start=$(date +%s)
  while :; do
    alive=0
    for k in "${!PIDS[@]}"; do
      rss=$(ps -o rss= -p "${PIDS[$k]}" 2>/dev/null | tr -d ' ')
      if [ -n "$rss" ]; then
        alive=1
        echo "$(( $(date +%s) - start )),${NAMES[$k]},$((rss / 1024))" >> "$OUT/memory.csv"
      fi
    done
    [ $alive -eq 0 ] && break
    sleep 30
  done
) &
SAMPLER=$!
# A watchdog: a player that hangs is stopped 120 s after the end of the run.
( sleep $((SECS + 120)) >/dev/null 2>&1 </dev/null; for p in "${PIDS[@]}"; do kill "$p" 2>/dev/null; done ) &
WATCHDOG=$!
for k in "${!PIDS[@]}"; do
  wait "${PIDS[$k]}"
  echo $? > "$OUT/exit-${NAMES[$k]}.txt"
done
kill $SAMPLER $WATCHDOG 2>/dev/null

python3 - "$OUT" "$CLIENTS" "$SECS" "$NET_MEMORY_GROWTH_MB_MAX" "$MODE" <<'PY'
import os, re, sys
out, clients, secs, growth_max, mode = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]), sys.argv[5]
names = ["host"] + [f"client{i}" for i in range(1, clients + 1)]
ok = True

def check(cond, text):
    global ok
    print(("PASS " if cond else "FAIL ") + text)
    ok = ok and cond

def lines(name):
    p = os.path.join(out, name)
    return open(p, errors="replace").read().splitlines() if os.path.exists(p) else []

for n in names:
    code = (lines(f"exit-{n}.txt") or ["none"])[0].strip()
    check(code == "0", f"{n} ended with exit code {code}")
    exc = [l for l in lines(f"{n}-unity.log") if "Exception" in l]
    check(not exc, f"{n}: no exception in the Unity log" + (f" (first: {exc[0][:200]})" if exc else ""))
check(any("[NetTest] host started" in l for l in lines("host.log")), "the host started")
seeds = {}
for n in names:
    log = lines(f"{n}.log")
    if n != "host":
        check(any("[NetTest] connected" in l for l in log), f"{n} connected")
    counts = [int(m.group(1)) for m in (re.search(r"\[NetTest\] players (\d+)", l) for l in log) if m]
    check(bool(counts) and counts[-1] == clients + 1, f"{n} sees all players at the end ({counts[-1] if counts else 'none'} of {clients + 1})")
    found = [m.group(1) for m in (re.search(r"\[NetTest\] seed (-?\d+)", l) for l in log) if m]
    seeds[n] = found[-1] if found else None
check(len(set(seeds.values())) == 1 and None not in seeds.values(), f"all players have the same seed ({seeds})")

# TODO: add the checks of your modes here, for example the same position of a player on the host and on a client.

if secs >= 600 and os.path.exists(os.path.join(out, "memory.csv")):
    rows = [l.split(",") for l in lines("memory.csv")]
    for n in names:
        mine = [(int(t), int(mb)) for t, who, mb in rows if who == n]
        early = [mb for t, mb in mine if t <= secs / 4]
        if mine and early:
            growth = mine[-1][1] - min(early)
            check(growth < growth_max, f"{n}: the memory grew {growth} MB from the first quarter to the end (limit {growth_max} MB)")
print("net-test: " + ("PASS" if ok else "FAIL"))
sys.exit(0 if ok else 1)
PY
