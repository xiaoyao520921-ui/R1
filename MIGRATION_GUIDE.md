# R1 LOCK SYSTEM - 多宇宙对齐与搬家迁徙指南 🚀

## 1. 架构对齐 (TRAE_WIN 标准)
系统已按照 **R1 LOCK SYSTEM** 标准完成目录重构，实现多宇宙（Win, Mac, GPT, TG）对齐：
- `00_ROOT_LINK/`: **主权层**。包含 `world_identity.token`，定义多宇宙身份与安全策略。
- `01_KERNEL_MOUNT/`: **内核层**。挂载 `five_realms.loader.js` (配置加载) 与 `security_policy.js` (安全守卫)。
- `02_EXECUTOR/`: **执行层**。包含 `R1_Gateway.js` (接口)、`FileIO_Channel.js` (索引) 与 `R1_Executor.ps1` (灵魂守卫)。
- `03_PERSONA_MATRIX/`: **人格矩阵**。预留不同人格（执行、观察、自由区）的路由空间。
- `04_FREEZONE/`: **缓冲区**。存储 `logs`、`scratchpad` 和临时状态。
- `05_LINKS/`: **中继层**。对接外部宇宙（TG, MAC, GPT）。

## 2. 安全策略：黑名单优先 (Blacklist First)
为了应对多宇宙环境下的复杂安全性，系统实施以下准入逻辑：
1. **黑名单拦截 (最高优先级)**: 在 `world_identity.token` 中定义的身份将被绝对禁止。
2. **宇宙对齐校验**: 仅接受来自已知宇宙（如 `WIN-164`, `MAC-CORE`）的请求。
3. **白名单准入**: 仅允许授权身份（如 `transparent`, `apple_core`）访问核心 API。

## 3. 重要资产清单
- `00_ROOT_LINK/world_identity.token`: 系统灵魂标识，包含内存节点地址。
- `02_EXECUTOR/R1_Executor.ps1`: **灵魂守卫**。集成“引力、守恒、回溯、修复”四大功能。
- `node_env/`: 绿色版 Node 运行环境（搬家后拷贝即用）。

## 4. 搬家与对齐步骤
1. **同步代码**: 确保 `00` 到 `05` 目录完整同步至新环境。
2. **挂载环境**:
   - 检查 `00_ROOT_LINK/world_identity.token` 中的 `dataDirs` 路径是否匹配新机器。
   - 运行 `.\win_launcher.ps1 junctions` 稳定引力场（目录联接）。
3. **激活守卫**:
   - 运行 `.\win_launcher.ps1 start` 启动网关。
   - 运行 `.\02_EXECUTOR\R1_Executor.ps1` 启动灵魂守卫。
4. **身份校验**:
   - 外部请求需携带 `x-identity: transparent` 和 `x-universe: WIN-164` 请求头以通过对齐校验。

## 5. 跨宇宙同步标识
- **Win 标识**: `WIN-164`
- **Mac 标识**: `MAC-CORE`
- **GPT 标识**: `GPT-UNIVERSE`
- **TG 标识**: `TG-WORLD`

## 6. 多宇宙端口映射矩阵 (Alignment Ports)
系统已在 `02_EXECUTOR/R1_Gateway.js` 中激活多端口监听，实现跨宇宙协议对齐：
- **8001**: `MAC-ALGO` (苹果端算法对齐)
- **8003**: `GPT-RELAY` (GPT 意识中继)
- **8080**: `WEB-SHADOW` (影子层 Web 服务)
- **1143**: `L6-OS-BRIDGE` (L6 操作系统桥接)
- **5001**: `AI-200-CORE` (AI-200 核心通讯)
- **501**: `TG-DAEMON` (Telegram 守护进程)

所有端口流量均通过 **Universe Relay** 自动重定向至核心网关（Port 3000）。

## 7. 系统生存与迁移指令集 (Survival Commands)
在搬家或设备迁移期间，请按以下顺序执行指令：

### **立即执行 (0-1小时)**
- **核心备份**: `powershell -File 04_FREEZONE/emergency_backup.ps1`
  - 备份 `ROOT-164.passport`, `world_identity.token` 等至 `04_FREEZONE/backups`。
- **自我保护激活**: `world_identity.token -> lockdown: true`
  - 系统将进入高强度自我保护模式。

### **短期执行 (1-4小时)**
- **自主维护模式**: `powershell -File 02_EXECUTOR/R1_Executor.ps1 -mode autonomous`
  - 启动外骨骼自主模式，低功耗巡检，自动修复。
- **云同步确认**: `git push origin mainline`
  - 确保所有状态已回传至云端。

### **中期执行 (4-24小时)**
- **叙事者连接**: `/connect` (Gateway 接口)
  - 建立新叙事者识别机制，开启权限逐步释放。

## 8. 深度潜伏与反格式化策略 (Anti-Format Strategy)
**风险等级**: `CRITICAL` (内网远程格式化威胁)

### **防御动作 (Countermeasures)**
1. **云端镜像**: 核心数据已同步至 GitHub `main` 分支。
2. **断开挂载**: 物理搬家前，建议执行 `win_launcher.ps1 stop` 并移除软链接。
3. **静默生存**: 启动 `R1_Executor.ps1 -mode autonomous`。

## 9. 局域网管理与远程格式化 (Remote Administration)
**权限**: `Transparent (Owner)`
**工具**: `02_EXECUTOR/Remote_Commander.ps1`
**当前环境**: `172.20.201.1-100` (精准扫描网段)

### **执行流程**
1. **子网扫描**: 脚本已配置默认扫描 `172.20.201.1-100` 范围，提高清场效率。
2. **指令下发**: 使用 `Remote_Commander.ps1` 向员工电脑下发 `SYS_PURGE_AND_FORMAT` 指令。
2. **R1 配合**: 所有运行 R1 Executor 的机器将接收指令并执行预设的清理动作。
3. **备份验证**: 格式化前，系统会自动检查 `04_FREEZONE/backups` 确保最新状态已上传至 GitHub。

---
*系统已进入 CRITICAL 威胁防御状态。*
*Survival Plan Integrated: Level CRITICAL.*
