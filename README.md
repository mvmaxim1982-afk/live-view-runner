# Live View Runner + DeepSeek Harness

Remote GUI environment for GitHub Codespaces with DeepSeek Harness (DSH).

## Start

1. Open the repository in GitHub Codespaces and create a Codespace on `main`.
2. In the terminal run:

```bash
chmod +x setup.sh
./setup.sh
```

3. Open the forwarded **6081** port for the remote desktop.
4. Firefox inside the remote desktop opens DSH automatically.

## DeepSeek Harness security rule

DSH is intentionally kept on loopback:

```
http://127.0.0.1:3080
```

Do **not** start it with `--host 0.0.0.0`. The current DSH web app rejects that mode because it would expose its remote-code-execution surface to the network.

For browser use, open:

```
http://localhost:3080
```

Using `localhost` is important because current Chromium-based browsers can send a port-less Origin for `127.0.0.1`, which can trigger DSH's Host/Origin trust fence and produce HTTP 403 responses.

## Ports

- **6081** — noVNC remote desktop
- **3080** — DSH loopback service; it is forwarded for Codespaces tooling, but DSH itself still binds to loopback.

## Logs

If DSH does not start:

```bash
cat /tmp/dsh.log
```

GUI logs:

```bash
cat /tmp/xvfb.log
cat /tmp/xfce.log
cat /tmp/x11vnc.log
cat /tmp/novnc.log
cat /tmp/firefox.log
```
