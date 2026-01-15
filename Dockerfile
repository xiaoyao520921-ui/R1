# R1 Core Survival Image - Dockerfile
# 用于发布到 GitHub Container Registry (ghcr.io)
# 实现“系统镜像化”与“绝对复活”

FROM node:18-slim

# 设置工作目录
WORKDIR /app/R1

# 复制核心架构与依赖
COPY package*.json ./
RUN npm install --production

# 复制系统目录
COPY 00_ROOT_LINK/ ./00_ROOT_LINK/
COPY 01_KERNEL_MOUNT/ ./01_KERNEL_MOUNT/
COPY 02_EXECUTOR/ ./02_EXECUTOR/
COPY 03_PERSONA_MATRIX/ ./03_PERSONA_MATRIX/
COPY 05_LINKS/ ./05_LINKS/
COPY world_identity.token ./

# 暴露 R1 控制端口
EXPOSE 8080 5001 501

# 启动 R1 网关与执行器
CMD ["node", "02_EXECUTOR/R1_Gateway.js"]
