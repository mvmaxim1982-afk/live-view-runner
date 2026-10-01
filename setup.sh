#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export DISPLAY=:1

echo "==> Installing GUI and browser packages..."
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  xfce4 xfce4-terminal \
  xvfb x11vnc \
  novnc websockify \
  dbus-x11 \
  curl

echo "==> Installing Firefox from Mozilla's official Linux build..."
if ! command -v firefox >/dev/null 2>&1; then
  tmpdir="$(mktemp -d)"
  curl -fsSL "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" -o "$tmpdir/firefox.tar.xz"
  sudo rm -rf /opt/firefox
  sudo tar -xJf "$tmpdir/firefox.tar.xz" -C /opt
  sudo ln -sfn /opt/firefox/firefox /usr/local/bin/firefox
  rm -rf "$tmpdir"
fi

echo "==> Stopping old GUI processes if present..."
pkill -f "Xvfb :1" || true
pkill -f "x11vnc.*5901" || true
pkill -f "websockify.*6081" || true
pkill -f "firefox" || true
pkill -f "@deepseek-ai/dsh" || true

echo "==> Starting virtual display..."
Xvfb :1 -screen 0 1280x800x24 -ac +extension GLX +render -noreset >/tmp/xvfb.log 2>&1 &
sleep 2

echo "==> Starting XFCE..."
dbus-launch --exit-with-session startxfce4 >/tmp/xfce.log 2>&1 &
sleep 5

echo "==> Starting VNC server..."
x11vnc -display :1 -forever -shared -rfbport 5901 -nopw -listen 127.0.0.1 >/tmp/x11vnc.log 2>&1 &
sleep 2

echo "==> Starting noVNC..."
websockify --web=/usr/share/novnc/ 6081 127.0.0.1:5901 >/tmp/novnc.log 2>&1 &
sleep 2

echo "==> Starting DeepSeek Harness on LOOPBACK only..."
echo "    DSH will listen on http://127.0.0.1:3080"
echo "    Use http://localhost:3080 inside the Codespace browser."
nohup npx --yes @deepseek-ai/dsh web --no-open --port 3080 >/tmp/dsh.log 2>&1 &

echo "==> Waiting for DSH..."
for i in {1..30}; do
  if curl -fsS http://localhost:3080 >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

echo "==> Starting Firefox inside the remote desktop..."
DISPLAY=:1 firefox --no-remote http://localhost:3080 >/tmp/firefox.log 2>&1 &

echo
echo "=============================================="
echo "Remote desktop: port 6081"
echo "DeepSeek Harness: http://localhost:3080"
echo
echo "IMPORTANT: DSH remains on 127.0.0.1:3080."
echo "Do NOT change it to --host 0.0.0.0."
echo "Open DSH as http://localhost:3080, not 127.0.0.1:3080."
echo "=============================================="
