# Builder stage
FROM node:23.1.0-alpine AS builder  # 使用 Node.js 官方镜像作为构建基础
ENV NODE_OPTIONS=--openssl-legacy-provider

# 设置工作目录
WORKDIR /app

# 复制应用程序源代码
COPY . .

# 安装客户端依赖
WORKDIR /app/client
RUN npm install

# 构建客户端应用
RUN npm run build

# Production stage
FROM node:23.1.0-alpine  # 使用同样的 Node.js 镜像作为运行基础
ENV NODE_OPTIONS=--openssl-legacy-provider

# 设置工作目录
WORKDIR /app

# 复制构建的客户端静态文件到服务器目录
COPY --from=builder /app/client/dist/ /app/server-node/static/

# 复制后端代码
COPY ./server-node/package*.json ./server-node/  # 仅复制 package.json 和 package-lock.json
WORKDIR /app/server-node
RUN npm install --production  # 只安装生产依赖

# 暴露服务端口
EXPOSE 9501

# 设置启动命令
CMD ["node", "main.js"]
