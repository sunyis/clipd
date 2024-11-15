# 使用官方的 Alpine Linux 3.19 镜像作为基础镜像
FROM alpine:3.19

# 设置环境变量以指定要安装的 Node.js 版本
ENV NODE_VERSION 23.1.0

# 更新包索引并安装必要的工具和依赖项
RUN apk add --no-cache curl tar gnupg

# 下载并安装 Node.js
RUN set -ex; \
    curl -fsSL https://cdn.npm.cloudflare.com/dist/node/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64-musl.tar.xz | tar -xJ -C /usr/local --strip-components=1; \
    ln -s /usr/local/bin/node /usr/bin/node; \
    ln -s /usr/local/bin/npm /usr/bin/npm; \
    ln -s /usr/local/bin/npx /usr/bin/npx

# 验证 Node.js 和 npm 是否已正确安装
RUN node -v && npm -v

# 将当前目录的内容复制到容器中的 /app 目录
COPY . /app

# 设置工作目录为 /app/client
WORKDIR /app/client

# 安装项目依赖
RUN npm install

# 构建项目
RUN npm run build

# 使用官方的 Alpine Linux 3.19 镜像作为运行时镜像
FROM alpine:3.19

# 设置环境变量以指定要安装的 Node.js 版本
ENV NODE_VERSION 23.1.0

# 更新包索引并安装必要的工具和依赖项
RUN apk add --no-cache curl tar gnupg

# 下载并安装 Node.js
RUN set -ex; \
    curl -fsSL https://cdn.npm.cloudflare.com/dist/node/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64-musl.tar.xz | tar -xJ -C /usr/local --strip-components=1; \
    ln -s /usr/local/bin/node /usr/bin/node; \
    ln -s /usr/local/bin/npm /usr/bin/npm; \
    ln -s /usr/local/bin/npx /usr/bin/npx

# 将当前目录的内容复制到容器中的 /app 目录
COPY . /app

# 从构建阶段复制构建产物到运行时镜像的静态文件目录
COPY --from=builder /app/client/dist/ /app/server-node/static/

# 设置工作目录为 /app/server-node
WORKDIR /app/server-node

# 安装项目依赖
RUN npm install

# 暴露应用运行的端口（假设应用运行在3000端口）
EXPOSE 9501

# 启动应用
CMD ["node", "main.js"]
