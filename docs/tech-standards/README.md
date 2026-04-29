# 技术标准索引 (Tech Standards Index)

本文档集包含 iPlayABC 产品的开发技术标准和最佳实践。

## 文档索引

| 文档 | 描述 |
|------|------|
| [git-workflow.md](./git-workflow.md) | Git 工作流：分支命名、提交规范、PR 流程、Code Review |
| [code-style.md](./code-style.md) | 代码规范：TypeScript/Dart/Node 命名、组织、测试 |
| [docker.md](./docker.md) | Docker 最佳实践：多阶段构建、健康检查、日志 |
| [ci-cd.md](./ci-cd.md) | CI/CD 流水线：lint → test → build → deploy |
| [security.md](./security.md) | 安全标准：环境变量、JWT、依赖审计 |

---

## 技术栈概览

| 类别 | 技术 | 版本要求 |
|------|------|----------|
| Node.js | Node.js | >= 20 |
| 包管理器 | npm | >= 10 |
| 前端框架 | Vue 3 / React Native / Flutter | 最新稳定版 |
| 后端框架 | NestJS | ^10.0 |
| 语言 | TypeScript | ^5.0 |
| 数据库 | MySQL | 8.0+ |
| 缓存 | Redis | 7.0+ |
| 容器 | Docker | 20.10+ |

---

## 快速参考

### Branch Naming
```
feature/TICKET-123-feature-name
bugfix/TICKET-456-fix-description
hotfix/TICKET-789-critical-fix
release/v1.2.3
```

### Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Code Review Checklist
- [ ] 功能完整，符合需求
- [ ] 单元测试覆盖
- [ ] 无硬编码 secrets
- [ ] 命名规范清晰
- [ ] 错误处理完善
- [ ] 日志记录适当
