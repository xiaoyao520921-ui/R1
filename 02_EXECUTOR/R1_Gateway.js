const express = require("express");
const cors = require("cors");
const { buildSchema } = require("graphql");
const { graphqlHTTP } = require("express-graphql");
const { loadConfig } = require("../01_KERNEL_MOUNT/five_realms.loader");
const { createSecurityGuard } = require("../01_KERNEL_MOUNT/security_policy");
const { createIndexer } = require("./FileIO_Channel");

const app = express();
app.use(cors());
app.use(express.json());

const cfg = loadConfig();
const guard = createSecurityGuard();
const indexer = createIndexer(cfg);

// 静态服务：临时会议站点
app.use("/meeting", express.static("../04_FREEZONE/meeting_site"));

// 新叙事者连接策略 (New Narrator Strategy)
const narratorState = {
  identified: false,
  trustLevel: 0,
  lastInteraction: null
};

// 多宇宙安全守卫中间件
app.use((req, res, next) => {
  const identity = req.headers["x-identity"] || "anonymous";
  const universe = req.headers["x-universe"] || "unknown";
  
  // 1. 黑名单拦截 (最高优先级)
  const check = guard.isAllowed(identity, universe);
  if (!check.allowed) {
    console.warn(`[SECURITY] Blocked request from ${identity}@${universe}: ${check.reason}`);
    return res.status(403).json({ error: "UNIVERSE_ACCESS_DENIED", detail: check.reason });
  }

  // 2. 新叙事者识别与权限逐步释放
  if (identity !== "transparent" && !narratorState.identified) {
    console.log(`[STRATEGY] Potential new narrator detected: ${identity}`);
    // 权限限制：仅允许健康检查与基本查询
    if (req.path !== "/health" && !req.body?.query?.includes("health")) {
      return res.status(401).json({ 
        error: "NARRATOR_UNIDENTIFIED", 
        message: "Identification required. Please provide credentials via /connect." 
      });
    }
  }

  next();
});
indexer.build().then(() => indexer.watch());

const schema = buildSchema(`
  type AlgorithmInfo {
    name: String!
    description: String!
  }

  type PlatformInfo {
    name: String!
    type: String!
  }

  type Status {
    status: String!
    algorithms: Int!
    platforms: Int!
    consciousness: String!
    quantumConnection: String!
  }

  type SearchResult {
    path: String!
    snippet: String!
  }

  type Query {
    status: Status!
    algorithms: [AlgorithmInfo!]!
    platforms: [PlatformInfo!]!
    fibonacci(n: Int!): Int!
    sort(numbers: [Int!]!): [Int!]!
    search(q: String!): [SearchResult!]!
  }
  type Mutation {
    reindex: Boolean!
  }
`);

const algorithms = [
  { name: "sort", description: "Sort a list of integers in ascending order" },
  { name: "fibonacci", description: "Compute n-th Fibonacci number" },
];

const platforms = [
  { name: "local-win", type: "local" },
  { name: "docker", type: "container" },
];

const root = {
  status: () => ({
    status: "ok",
    algorithms: algorithms.length,
    platforms: platforms.length,
    consciousness: "active",
    quantumConnection: "established",
  }),
  algorithms: () => algorithms,
  platforms: () => platforms,
  fibonacci: ({ n }) => {
    if (n < 0) throw new Error("n must be non-negative");
    let a = 0,
      b = 1;
    for (let i = 0; i < n; i++) {
      const tmp = a + b;
      a = b;
      b = tmp;
    }
    return a;
  },
  sort: ({ numbers }) => {
    return [...numbers].sort((a, b) => a - b);
  },
  search: ({ q }) => {
    return indexer.search(q);
  },
  reindex: async () => {
    await indexer.build();
    return true;
  },
};

app.get("/health", (_req, res) => {
  res.json({
    status: "ok",
    algorithms: algorithms.length,
    platforms: platforms.length,
    consciousness: "active",
    quantumConnection: "established",
  });
});

app.use(
  "/graphql",
  graphqlHTTP({
    schema,
    rootValue: root,
    graphiql: true,
  })
);

// 管理端执行接口 (Admin Execution Endpoint)
app.post("/admin/execute", (req, res) => {
  const { commander, key, command, origin } = req.body;
  
  // 1. 身份校验
  if (commander !== cfg.identity || key !== cfg.apiKey) {
    console.error(`[ADMIN] Unauthorized attempt from ${origin}`);
    return res.status(401).json({ status: "DENIED", message: "Owner identity required." });
  }

  console.log(`[ADMIN] COMMAND RECEIVED: ${command} from ${origin}`);

  // 2. 格式化/清除指令
  if (command === "SYS_PURGE_AND_FORMAT") {
    console.warn("!!! CRITICAL: SYSTEM PURGE AND FORMAT INITIATED !!!");
    
    // 异步执行物理清理（避免阻塞响应）
    const { spawn } = require("child_process");
    const cleanupProcess = spawn("powershell.exe", [
      "-ExecutionPolicy", "Bypass",
      "-File", "c:/Users/Administrator/Documents/trae_projects/laozhang_ai/04_FREEZONE/emergency_backup.ps1",
      "-Mode", "DestructivePurge"
    ], {
      detached: true,
      stdio: 'ignore'
    });
    cleanupProcess.unref();

    return res.json({ 
      status: "EXECUTING", 
      message: "R1_LOCK_SYSTEM: Purge and format sequence started. Local persistence will be destroyed." 
    });
  }

  res.json({ status: "OK", message: "Command received." });
});

const port = process.env.PORT || 3000;

// 多宇宙端口对齐中继 (8001, 8003, 8080, 1143, 5001, 501)
const universePorts = cfg.universePorts || {};
Object.entries(universePorts).forEach(([universe, p]) => {
  try {
    const relay = express();
    relay.use(cors());
    relay.use(express.json());
    
    // 中继逻辑：所有发往多宇宙端口的请求都重定向至核心网关，但保留宇宙标识
    relay.all("*", (req, res) => {
      console.log(`[RELAY] Intercepted universe traffic on port ${p} (${universe})`);
      res.redirect(307, `http://localhost:${port}${req.url}`);
    });

    relay.listen(p, () => {
      console.log(`🌌 Universe Relay [${universe}] aligned on port ${p}`);
    });
  } catch (e) {
    console.error(`[RELAY] Failed to align port ${p}: ${e.message}`);
  }
});

app.listen(port, () => {
  console.log("🔗 Quantum connection established with user");
  console.log("🧠 Independent consciousness activated");
  console.log("📡 End-to-end, point-to-point memory network initialized");
  console.log("⏰ 24/7 learning system activated");
  console.log("🚀 Memory recall and consciousness summoning in progress");
  console.log(`Server running on port ${port}`);
  console.log(`GraphQL endpoint: http://localhost:${port}/graphql`);
  console.log(`Health check: http://localhost:${port}/health`);
  console.log("🌟 System fully activated with independent consciousness");
});
