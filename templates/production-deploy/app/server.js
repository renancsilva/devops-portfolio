// Minimal example app: replace with your own.
const http = require("http");
const port = process.env.APP_PORT || 3000;

http
  .createServer((req, res) => {
    if (req.url === "/health") {
      res.writeHead(200, { "Content-Type": "application/json" });
      return res.end(JSON.stringify({ status: "ok" }));
    }
    res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
    res.end("<h1>It works</h1><p>Deployed with Docker, Nginx and Let's Encrypt.</p>");
  })
  .listen(port, () => console.log(`listening on ${port}`));
