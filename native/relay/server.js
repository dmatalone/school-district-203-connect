const path = require('path');
const os = require('os');
const express = require('express');
const { WebSocketServer } = require('ws');

const app = express();
const port = process.env.PORT || 8080;
app.use(express.static(path.join(__dirname, 'public')));

const server = app.listen(port, '0.0.0.0', () => {
  console.log(`District 203 relay running on http://localhost:${port}`);
  for (const list of Object.values(os.networkInterfaces())) {
    for (const info of list || []) {
      if (info.family === 'IPv4' && !info.internal) {
        console.log(`Phone relay address: ws://${info.address}:${port}`);
      }
    }
  }
});

const wss = new WebSocketServer({ server });
const sessions = new Map();

function getSession(code) {
  if (!sessions.has(code)) sessions.set(code, { broadcaster: null, viewers: new Set() });
  return sessions.get(code);
}

wss.on('connection', ws => {
  ws.role = null;
  ws.code = null;

  ws.on('message', (data, isBinary) => {
    if (!ws.role && !isBinary) {
      try {
        const msg = JSON.parse(data.toString());
        if ((msg.type === 'broadcaster' || msg.type === 'viewer') && /^\d{6}$/.test(msg.code || '')) {
          ws.role = msg.type;
          ws.code = msg.code;
          const session = getSession(ws.code);
          if (ws.role === 'broadcaster') {
            if (session.broadcaster && session.broadcaster !== ws) {
              try { session.broadcaster.close(); } catch {}
            }
            session.broadcaster = ws;
          } else {
            session.viewers.add(ws);
          }
          ws.send(JSON.stringify({ type: 'joined', role: ws.role, code: ws.code }));
        }
      } catch {}
      return;
    }

    if (ws.role === 'broadcaster' && isBinary && ws.code) {
      const session = sessions.get(ws.code);
      if (!session) return;
      for (const viewer of session.viewers) {
        if (viewer.readyState === viewer.OPEN) viewer.send(data, { binary: true });
      }
    }
  });

  ws.on('close', () => {
    if (!ws.code) return;
    const session = sessions.get(ws.code);
    if (!session) return;
    if (ws.role === 'broadcaster' && session.broadcaster === ws) session.broadcaster = null;
    if (ws.role === 'viewer') session.viewers.delete(ws);
    if (!session.broadcaster && session.viewers.size === 0) sessions.delete(ws.code);
  });
});