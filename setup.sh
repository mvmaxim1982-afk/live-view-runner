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
  firefox-esr dbus-x11

echo "==> Stopping old GUI processes if present..."
pkill -f "Xvfb :1" || true
pkill -f "x11vnc.*5901" || true
pkill -f "websockify.*6081" || true

echo "==> Starting virtual display..."
Xvfb :1 -screen 0 1280x800x24 -ac +extension GLX +render -noreset >/tmp/xvfb.log 2>&1 &
sleep 2

echo "==> Starting XFCE..."
dbus-launch --exit-with-session startxfce4 >/tmp/xfce.log 2>&1 &
sleep 5

echo "==> Starting VNC server..."
x11vnc -display :1 -forever -shared -rfbport 5901 -nopw -listen 127.0.0.1 >/tmp/x11vnc.log 2>&1 &
sleep 2

echo "==> Starting noVNC on port 6081..."
websockify --web=/usr/share/novnc/ 6081 127.0.0.1:5901 >/tmp/novnc.log 2>&1 &

echo "==> Starting Firefox..."
DISPLAY=:1 firefox-esr --no-remote >/tmp/firefox.log 2>&1 &

echo
echo "=============================================="
echo "Remote desktop is running."
echo "Open forwarded port 6081 in Codespaces."
echo "The browser is Firefox inside the remote desktop."
echo "=============================================="
