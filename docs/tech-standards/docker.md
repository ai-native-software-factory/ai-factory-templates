# Docker Best Practices

本文档定义 iPlayABC 项目的 Docker 镜像构建和运行规范。

---

## 1. Multi-stage Builds

### 1.1 NestJS 应用 Dockerfile

```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builds
WORKDIR /script

# Install dependencies
ADD package*.json ./
RUN npm ci --only=production && \
    npm cache clean --force

# Copy source and build
COPY . .
RUN npm run build

# Stage 2: Package
FROM node:20-alpine AS package
WORKDIR /script

# Copy dependencies from build stage
COPY --from=builds /script/node_modules ./node_modules
COPY --from=builds /script/package*.json ./

# Copy built artifacts
COPY --from=builds /script/dist ./dist

# Stage 3: Deploy
FROM node:20-alpine AS deploy
WORKDIR /script

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy application files
COPY --from=package /script .
RUN chown -R nodejs:nodejs /script

# Switch to non-root user
USER nodejs

EXPOSE 3000

CMD ["node", "dist/apps/default/main"]
```

### 1.2 前端应用 Dockerfile

```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builds
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy source and build
COPY . .
RUN npm run build

# Stage 2: Deploy (Nginx)
FROM nginx:alpine AS deploy

# Copy nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built static files
COPY --from=builds /app/dist /usr/share/nginx/html

# Create non-root user
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

USER nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

---

## 2. Alpine Linux

### 2.1 为什么使用 Alpine

| 特性 | Alpine | Debian |
|------|--------|--------|
| 镜像大小 | ~5MB | ~120MB |
| 包管理 | apk | apt |
| 安全性 | musl libc | glibc |
| 启动速度 | 快 | 较慢 |

### 2.2 常用 Alpine 命令

```dockerfile
# 安装依赖
RUN apk add --no-cache tzdata

# 安装特定版本
RUN apk add --no-cache postgresql-client=15.4-r0

# 清理缓存
RUN apk cache clean

# 添加自定义用户
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001
```

---

## 3. Non-root User

### 3.1 安全原则

- 容器内不应以 root 运行
- 使用最小权限原则
- 文件系统只读权限（生产环境）

### 3.2 实现方式

```dockerfile
# 创建用户组和用户
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# 修改文件所有者
RUN chown -R nodejs:nodejs /script

# 切换用户
USER nodejs

# 验证（可选）
USER XXX
```

### 3.3 端口权限

```dockerfile
# Alpine 默认不允许非 root 用户使用 1024 以下端口
# 解决方案：使用高端口或配置

# 方案一：使用高端口
EXPOSE 3000

# 方案二：在启动命令中使用 capabilities
# 仅在学习/开发环境使用
# docker run --cap-add=SYS_NETWORK ...
```

---

## 4. Health Checks

### 4.1 HTTP Health Check

```dockerfile
# NestJS 应用
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
```

### 4.2 TCP Health Check

```dockerfile
# Redis
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD nc -z localhost 6379 || exit 1

# MySQL
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD mysqladmin ping -h localhost || exit 1
```

### 4.3 NestJS 健康检查端点

```typescript
// src/health/index.ts
import { Controller, Get } from '@nestjs/common'
import { ApiTags, ApiOperation } from '@nestjs/swagger'

@ApiTags('健康检查')
@Controller('health')
export class HealthController {
  @Get()
  @ApiOperation({ summary: '健康检查' })
  check() {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
    }
  }
}
```

### 4.4 Docker Compose 健康检查

```yaml
version: '3.8'

services:
  api:
    build: .
    ports:
      - '3000:3000'
    healthcheck:
      test: ['CMD', 'wget', '--no-verbose', '--tries=1', '--spider', 'http://localhost:3000/health']
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s

  depends_on:
    api:
      condition: service_healthy
```

---

## 5. Logging to stdout

### 5.1 为什么不用文件日志

```yaml
# ✗ 不推荐：写入文件
logging:
  driver: 'json-file'
  options:
    max-size: '10m'
    max-file: '3'

# ✓ 推荐：直接输出到 stdout/stderr
# Docker 会自动收集并由容器运行时处理
```

### 5.2 NestJS 日志配置

```typescript
// src/logger/logger.module.ts
import { Module, Logger } from '@nestjs/common'

@Module({
  providers: [Logger],
  exports: [Logger],
})
export class LoggerModule {}
```

```typescript
// src/application.bootstrap.ts
import { NestFactory } from '@nestjs/core'
import { Logger } from '@nestjs/common'

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn', 'log', 'debug', 'verbose'],
  })

  // 使用 pino 或 winston 配合 docker 日志驱动
  app.useLogger(app.get(Logger))
}

bootstrap()
```

### 5.3 容器运行时日志配置

```bash
# 查看日志
docker logs -f <container>

# 配置日志驱动
docker run \
  --log-driver=json-file \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  myapp:latest

# 使用 journald 驱动
docker run \
  --log-driver=journald \
  myapp:latest
```

---

## 6. 环境变量配置

### 6.1 构建时 vs 运行时

```dockerfile
# ✓ 构建时变量（ARG）
ARG NODE_ENV=production
RUN npm ci --only=production

# ✓ 运行时变量（ENV）
ENV NODE_ENV=production
ENV PORT=3000

# ✗ 避免在镜像中硬编码 secrets
# 应该通过 docker run -e 或 docker-compose 提供
```

### 6.2 Docker Compose 环境配置

```yaml
version: '3.8'

services:
  api:
    build:
      context: .
      args:
        - NODE_ENV=production
    environment:
      - NODE_ENV=production
      - PORT=3000
      - DATABASE_HOST=db
      - REDIS_HOST=redis
      # 敏感信息通过 docker secrets 或 .env 文件
    secrets:
      - db_password
      - jwt_secret
    ports:
      - '3000:3000'
    restart: unless-stopped

secrets:
  db_password:
    file: ./secrets/db_password.txt
  jwt_secret:
    file: ./secrets/jwt_secret.txt
```

---

## 7. 镜像优化

### 7.1 减小镜像体积

```dockerfile
# ✓ 按正确顺序 COPY，充分利用层缓存
COPY package*.json ./
RUN npm ci

COPY . .

# ✓ 合并 RUN 指令减少层数
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      postgresql-client \
      redis-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ✓ 使用 .dockerignore
```

### 7.2 .dockerignore 示例

```gitignore
# 版本控制
.git
.gitignore

# 开发文件
*.md
.env*
.vscode
.idea

# 测试文件
test
*.spec.ts
coverage

# 构建产物
dist
node_modules

# 其他
*.log
npm-debug.log*
```

---

## 8. docker-compose.yml 规范

```yaml
version: '3.8'

services:
  # API Service
  api:
    build:
      context: .
      dockerfile: Dockerfile
      target: deploy
    image: iplayabc/api:${VERSION:-latest}
    container_name: api
    environment:
      - NODE_ENV=${NODE_ENV:-production}
      - PORT=3000
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - backend
    restart: unless-stopped
    healthcheck:
      test: ['CMD', 'wget', '--no-verbose', '--tries=1', '--spider', 'http://localhost:3000/health']
      interval: 30s
      timeout: 10s
      retries: 3

  # Database
  db:
    image: mysql:8.0
    container_name: mysql
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_DATABASE: ${DB_NAME}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - backend
    healthcheck:
      test: ['CMD', 'mysqladmin', 'ping', '-h', 'localhost']
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis
  redis:
    image: redis:7-alpine
    container_name: redis
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - backend
    healthcheck:
      test: ['CMD', 'redis-cli', 'ping']
      interval: 10s
      timeout: 5s
      retries: 5

networks:
  backend:
    driver: bridge

volumes:
  mysql_data:
  redis_data:
```

---

## 9. 安全最佳实践

```dockerfile
# ✓ 使用特定版本而非 latest
FROM node:20-alpine

# ✓ 使用官方镜像
FROM node:20-alpine

# ✗ 避免使用 root
USER nodejs

# ✓ 只暴露必要端口
EXPOSE 3000

# ✓ 容器只读（生产环境）
# docker run --read-only myapp:latest

# ✓ 不使用特权模式
# docker run --privileged myapp:latest
```
