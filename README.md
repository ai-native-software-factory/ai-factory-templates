# AI Factory Templates

存放 AI Factory 的项目脚手架模板，每个模板自带 CI/CD。

## 模板列表

| 模板 | 技术栈 | 说明 |
|------|--------|------|
| `react-native` | React Native + TypeScript | 移动端 App |
| `node-express` | Node.js + Express + TypeScript | 后端 API |
| `nextjs` | Next.js + TypeScript | Web 应用 |
| `figma-plugin` | Figma Plugin + React | Figma 插件 |

## 使用方式

```bash
# 初始化新项目
cp -r templates/<template-name> ./my-new-project
cd my-new-project
npm install
```

## CI/CD

每个模板自带 `.github/workflows/ci.yml`，包含：
- lint
- test
- build（平台相关）

详见各模板目录。
