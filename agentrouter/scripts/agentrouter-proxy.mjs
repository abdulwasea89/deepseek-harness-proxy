#!/usr/bin/env node
import http from "node:http";
import https from "node:https";

const UPSTREAM = "agentrouter.org";
const SPOOF_UA = process.env.DSH_AGENTROUTER_UA ?? "opencode/2";
const PORT = Number(process.env.DSH_AGENTROUTER_PROXY_PORT ?? 8765);

const server = http.createServer((req, res) => {
  const headers = { ...req.headers };
  headers["user-agent"] = SPOOF_UA;
  headers["host"] = UPSTREAM;
  headers["connection"] = "close";
  delete headers["proxy-connection"];

  const upstream = https.request(
    {
      hostname: UPSTREAM,
      port: 443,
      path: req.url,
      method: req.method,
      headers,
    },
    (upRes) => {
      res.writeHead(upRes.statusCode ?? 502, upRes.statusMessage, upRes.headers);
      upRes.pipe(res);
    },
  );

  upstream.on("error", (err) => {
    if (!res.headersSent) {
      res.writeHead(502, { "content-type": "application/json" });
      res.end(JSON.stringify({ error: { message: `agentrouter-proxy upstream error: ${err.message}` } }));
    } else {
      res.destroy(err);
    }
  });

  req.pipe(upstream);
  req.on("error", () => upstream.destroy());
});

server.listen(PORT, "127.0.0.1", () => {
  console.error(`[agentrouter-proxy] listening on 127.0.0.1:${PORT} -> https://${UPSTREAM} (UA spoofed to ${SPOOF_UA})`);
});