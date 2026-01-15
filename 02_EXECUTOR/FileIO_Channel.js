const fg = require("fast-glob");
const chokidar = require("chokidar");
const { readFileSync, statSync } = require("fs");
const { join, extname } = require("path");
const lunr = require("lunr");

function createIndexer(cfg) {
  const allowedExt = new Set(cfg.fileExtensions || [".txt", ".md"]);
  const maxBytes = (cfg.maxFileSizeMB || 5) * 1024 * 1024;
  let docs = [];
  let idx = lunr(function () {
    this.ref("path");
    this.field("content");
  });

  function addDoc(path) {
    try {
      const st = statSync(path);
      if (st.size > maxBytes) return;
      const ext = extname(path).toLowerCase();
      if (!allowedExt.has(ext)) return;
      const content = readFileSync(path, "utf8");
      const doc = { path, content };
      docs.push(doc);
      idx = lunr(function () {
        this.ref("path");
        this.field("content");
        docs.forEach(d => this.add(d));
      });
    } catch {}
  }

  async function build() {
    docs = [];
    const patterns = cfg.dataDirs.map(d => join(d, "**/*"));
    const entries = await fg(patterns, { dot: false });
    entries.forEach(addDoc);
  }

  function watch() {
    const watcher = chokidar.watch(cfg.dataDirs, { ignoreInitial: true });
    watcher.on("add", addDoc);
    watcher.on("change", addDoc);
    return watcher;
  }

  function search(q) {
    const res = idx.search(q);
    return res.map(r => {
      const doc = docs.find(d => d.path === r.ref) || { path: r.ref, content: "" };
      const pos = doc.content.toLowerCase().indexOf(q.toLowerCase());
      const start = Math.max(0, pos - 40);
      const end = Math.min(doc.content.length, start + 160);
      const snippet = doc.content.slice(start, end);
      return { path: doc.path, snippet };
    });
  }

  return { build, watch, search };
}

module.exports = { createIndexer };

