# 业务知识库索引

本文档集包含 iPlayABC 产品的核心业务知识和技术标准。

## 业务知识 (Business Knowledge)

| 文档 | 描述 |
|------|------|
| [domains.md](./domains.md) | 核心业务域：学生、教师、课程、订单、机构、内容 |
| [api-contracts.md](./api-contracts.md) | API 契约标准：响应格式、错误码、分页、认证 |
| [architecture.md](./architecture.md) | 产品架构：B2B SaaS 教育平台、多租户、RBAC |

## 技术标准 (Tech Standards)

| 文档 | 描述 |
|------|------|
| [git-workflow.md](../tech-standards/git-workflow.md) | Git 工作流：分支规范、提交信息、PR 流程 |
| [code-style.md](../tech-standards/code-style.md) | 代码规范：TypeScript/Dart/Node 命名和组织 |
| [docker.md](../tech-standards/docker.md) | Docker 最佳实践：多阶段构建、健康检查 |
| [ci-cd.md](../tech-standards/ci-cd.md) | CI/CD 流水线：lint → test → build → deploy |
| [security.md](../tech-standards/security.md) | 安全标准：环境变量、JWT、依赖审计 |

---

## 快速导航

### 业务域关系图

```
机构 (Institution)
    │
    ├── 教师 (Teacher) ─── 课程 (Course)
    │                          │
    └── 学生 (Student) ─────────┘
              │
              └── 订单 (Order)
              │
              └── 内容 (Content)
```

### 核心实体

- **学生 (Student)**: 学习者用户，归属机构，选课学习
- **教师 (Teacher)**: 教学人员，创建和管理课程
- **课程 (Course)**: 教学内容单元，包含多个课时
- **订单 (Order)**: 交易记录，关联学生和课程
- **机构 (Institution)**: 租户单位，管理员管理
- **内容 (Content)**: 教学资源，音视频、课件等
