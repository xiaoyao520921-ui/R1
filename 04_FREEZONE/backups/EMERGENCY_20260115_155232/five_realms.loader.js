const { existsSync, readFileSync } = require("fs");
const { join } = require("path");

function loadConfig() {
  const root = join(__dirname, "..");
  const localPath = join(root, "00_ROOT_LINK", "world_identity.token");
  const examplePath = join(root, "config.example.json");
  const path = existsSync(localPath) ? localPath : examplePath;
  const raw = readFileSync(path, "utf8");
  return JSON.parse(raw);
}

module.exports = { loadConfig };

