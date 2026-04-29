# AI Factory Templates

存放 AI Factory 的项目脚手架模板，每个模板自带 CI/CD。

## 模板列表

| 模板 | 技术栈 | 说明 |
|------|--------|------|
| `nestjs-api` | NestJS + TypeORM + MySQL + Redis | 后端 API（生产级） |
| `flutter-app` | Flutter 3.x + Riverpod + GoRouter + Dio | 移动端 App |
| `vue-web` | Vue 3 + Vite + Pinia + Element Plus | Web 应用 |
| `nextjs` | Next.js + TypeScript | Web 应用（占位） |
| `node-express` | Node.js + Express + TypeScript | 后端 API（占位） |
| `react-native` | React Native + TypeScript | 移动端 App（占位） |
| `figma-plugin` | Figma Plugin + React | Figma 插件（占位） |

## NPM 包

| 包名 | 说明 | 复用项目数 |
|------|------|-----------|
| `@iplayabc/common` | OSS/MySQL/JWT/JSON/Date/Log 工具库 | 36+ |
| `@iplayabc/nestjs-common` | NestJS Database/Cache/Logger/Auth/Health 模块 | 待测 |

## 使用方式

```bash
# 克隆模板仓库
git clone https://github.com/ai-native-software-factory/ai-factory-templates.git
cd ai-factory-templates

# 复制模板到新项目
cp -r templates/<template-name> ../my-new-project
cd ../my-new-project
npm install
```

## 模板开发

```bash
# 安装依赖
cd templates/nestjs-api
npm install

# 开发
npm run start:dev

# 构建
npm run build

# CI（push 后自动运行）
git push
```

## CI/CD

每个模板自带 `.github/workflows/ci.yml`，包含：
- lint
- test
- build（平台相关）

## 知识库文档

详见 `docs/` 目录。
