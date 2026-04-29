# NestJS API Template

## 技术栈

- Node.js 20+ (Alpine Linux)
- NestJS 10
- TypeScript 5
- TypeORM + MySQL
- Redis (ioredis)
- Passport JWT
- Prisma (可选 ORM)
- Jest (测试)
- Pino (日志)
- Docker + Docker Compose

## 项目结构

```
nestjs-api/
├── apps/
│   └── default/                    # 主应用
│       └── src/
│           ├── main.ts             # 入口
│           ├── app.module.ts       # 根模块
│           ├── api/                # 业务 API 模块
│           │   ├── api.module.ts
│           │   └── example/        # 示例功能模块
│           ├── config/             # 配置
│           ├── constants/          # 常量
│           ├── enums/              # 枚举
│           ├── provider/           # Provider (Snowflake 等)
│           ├── repository/         # TypeORM Repository
│           └── interface/          # 接口定义
├── libs/
│   └── common/                     # 公共库 (@iplayabc/common)
│       └── src/
│           ├── database/           # 数据库模块 (TypeORM)
│           │   ├── repository/     # 通用 Repository
│           │   └── history/        # 历史记录
│           ├── cache/              # Redis 缓存模块
│           ├── health/             # 健康检查
│           ├── auth-permission/    # 认证授权
│           ├── interceptor/        # 拦截器 (异常、缓存)
│           ├── exception/          # 异常过滤器
│           ├── logger/             # Pino 日志
│           ├── config/             # 配置加载
│           └── validator/           # 自定义验证器
├── prisma/
│   └── schema.prisma               # Prisma Schema (可选)
├── test/
│   └── jest-e2e.json               # E2E 测试配置
├── .github/workflows/
│   └── ci.yml                      # CI/CD
├── Dockerfile
├── docker-compose.yml
├── package.json
├── tsconfig.json
├── nest-cli.json
├── jest.config.ts
├── .eslintrc.js
└── .prettierrc
```

## 开发

```bash
# 安装依赖
npm install

# 开发模式 (热重载)
npm run start:dev

# 生产构建
npm run build

# 生产模式
npm start

# 运行测试
npm test

# E2E 测试
npm run test:e2e

# 代码检查
npm run lint

# 格式美化
npm run format
```

## 数据库

```bash
# 生成 Prisma Client (如果使用 Prisma)
npx prisma generate

# 推送 schema 到数据库
npx prisma db push

# 创建 migration
npx prisma migrate dev --name init
```

## 环境变量

创建 `.env` 文件：

```env
NODE_ENV=development
PORT=3000

# 数据库
DATABASE_HOST=localhost
DATABASE_PORT=3306
DATABASE_USER=root
DATABASE_PASSWORD=password
DATABASE_NAME=app

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=7d

# 阿里云 OSS
ALIYUN_OSS_ACCESS_KEY_ID=
ALIYUN_OSS_ACCESS_KEY_SECRET=
ALIYUN_OSS_BUCKET=
ALIYUN_OSS_REGION=oss-cn-hangzhou
```

## CI/CD

GitHub Actions 自动运行：
1. `lint` — ESLint 检查
2. `test` — Jest 单元测试
3. `build` — TypeScript 编译 + Docker 镜像构建

## Docker 部署

```bash
# 构建镜像
docker build -t nestjs-api .

# 运行容器
docker-compose up -d

# 查看日志
docker-compose logs -f
```

## 使用此模板创建新项目

```bash
# 方式一: GitHub Template
gh repo create my-new-api --template ai-native-software-factory/ai-factory-templates/templates/nestjs-api

# 方式二: 手动复制
cp -r templates/nestjs-api ./my-new-api
cd my-new-api
rm -rf .git
npm install
```
