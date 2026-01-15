const { mkdirSync, copyFileSync } = require("fs");
const { join } = require("path");

const srcDir = join(__dirname, "..", "src");
const distDir = join(__dirname, "..", "dist");

mkdirSync(distDir, { recursive: true });
copyFileSync(join(srcDir, "index.js"), join(distDir, "index.js"));

