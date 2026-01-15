/**
 * R1 LOCK SYSTEM - Security Policy Module
 * Priority: Blacklist > Whitelist
 * Alignment: Multi-Universe (Win, Mac, GPT, TG)
 */

const { loadConfig } = require("./five_realms.loader");

function createSecurityGuard() {
  const config = loadConfig();
  
  // 默认策略：黑名单优先
  const blacklist = new Set(config.security?.blacklist || []);
  const whitelist = new Set(config.security?.whitelist || []);
  const universeKeys = new Set(config.security?.universeKeys || []);

  return {
    isAllowed: (identity, sourceUniverse) => {
      // 1. 绝对黑名单检查 (Blacklist First)
      if (blacklist.has(identity)) {
        return { allowed: false, reason: "IDENTITY_BLACK-LISTED" };
      }

      // 2. 来源宇宙合法性校验
      if (!universeKeys.has(sourceUniverse)) {
        return { allowed: false, reason: "UNIVERSE_UNALIGNED" };
      }

      // 3. 白名单准入检查
      if (whitelist.size > 0 && !whitelist.has(identity)) {
        return { allowed: false, reason: "NOT_IN_WHITE-LIST" };
      }

      return { allowed: true };
    },
    
    getPolicySummary: () => ({
      mode: "Blacklist-Priority",
      universes: Array.from(universeKeys),
      protected: whitelist.size > 0
    })
  };
}

module.exports = { createSecurityGuard };
