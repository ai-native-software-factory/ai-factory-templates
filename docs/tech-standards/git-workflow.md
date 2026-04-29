# Git Workflow

本文档定义 iPlayABC 项目的 Git 工作流标准。

---

## 1. 分支命名规范

### 1.1 分支类型

| 类型 | 格式 | 示例 |
|------|------|------|
| 功能分支 | `feature/TICKET-XXX-description` | `feature/ABC-123-add-user-login` |
| 修复分支 | `bugfix/TICKET-XXX-description` | `bugfix/ABC-456-fix-order-error` |
| 热修复分支 | `hotfix/TICKET-XXX-description` | `hotfix/ABC-789-fix-payment-crash` |
| 发布分支 | `release/vX.Y.Z` | `release/v1.2.3` |
| 功能开发 | `feature/description` | `feature/add-payment-module` |

### 1.2 命名规则

```bash
# ✓ 正确示例
feature/ABC-123-user-authentication
bugfix/ABC-456-fix-login-timeout
hotfix/ABC-789-critical-payment-fix
release/v1.2.3
feature/add-dashboard-module

# ✗ 错误示例
feature/abc123
bugfix/fix
feature/TASK
fix-bug
```

### 1.3 分支保护

- `main` 分支：禁止直接 push，需要 PR + 至少 1 人 review
- `release/*` 分支：禁止直接 push，需要 PR + release manager review
- `feature/*` 和 `bugfix/*`：建议通过 PR 合并

---

## 2. 提交信息规范

### 2.1 Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 2.2 Type 类型

| Type | 说明 |
|------|------|
| feat | 新功能 |
| fix | Bug 修复 |
| docs | 文档更新 |
| style | 代码格式（不影响功能） |
| refactor | 重构（不是新功能或修复） |
| perf | 性能优化 |
| test | 测试相关 |
| build | 构建或依赖变更 |
| ci | CI/CD 配置 |
| chore | 其他杂项 |

### 2.3 提交示例

```bash
# ✓ 正确示例
feat(auth): add JWT refresh token mechanism

Implement refresh token rotation for enhanced security.
The access token expires in 15 minutes, refresh token in 30 days.

Closes ABC-123

---

fix(order): correct order amount calculation

Fixed precision issue in decimal calculation that caused
incorrect payment amounts for courses with discounts.

Fixes ABC-456

---

docs(api): update user endpoint documentation

Added description for new pagination parameters.

See also: ABC-789
```

### 2.4 提交规则

```bash
# ✓ 每完成一个独立功能点提交一次
git commit -m "feat(course): add course publish feature"

# ✗ 避免提交过多不相关更改
git commit -m "feat: add login, dashboard and settings"  # 太大

# ✓ 保持提交原子性
git commit -m "feat(auth): add login feature"
git commit -m "feat(auth): add logout feature"
```

---

## 3. Pull Request 流程

### 3.1 PR 创建流程

```bash
# 1. 从最新 main 创建功能分支
git checkout main
git pull origin main
git checkout -b feature/ABC-123-feature-name

# 2. 开发并提交
git add .
git commit -m "feat(scope): description"

# 3. 推送分支
git push -u origin feature/ABC-123-feature-name

# 4. 在 GitHub 创建 PR
# 选择 main 作为 target branch
# 填写 PR 模板
```

### 3.2 PR 描述模板

```markdown
## 关联 Issue
<!-- Link to related issue -->

## 变更内容
- [ ] 新增功能
- [ ] 修改功能
- [ ] 修复 Bug

## 变更类型
- [ ] API 变更
- [ ] 数据库变更
- [ ] 配置文件变更
- [ ] 依赖更新

## 测试情况
- [ ] 单元测试通过
- [ ] 集成测试通过
- [ ] 手动测试通过

## 截图或录屏
<!-- If UI changes, add screenshots -->

## Checklist
- [ ] 代码自审查
- [ ] 已添加必要的注释
- [ ] 已更新相关文档
- [ ] 无硬编码敏感信息
```

### 3.3 PR 合并策略

| 分支类型 | 合并方式 | 要求 |
|----------|----------|------|
| feature/* | Squash Merge | 至少 1 人 Review |
| bugfix/* | Squash Merge | 至少 1 人 Review |
| hotfix/* | Merge Commit | 至少 2 人 Review |
| release/* | Merge Commit | Release Manager |

---

## 4. Code Review 检查清单

### 4.1 功能性检查

```markdown
- [ ] 代码实现了需求规格中的功能
- [ ] 边界条件和异常情况已处理
- [ ] 输入参数已正确验证
- [ ] 返回值符合 API 契约定义
- [ ] 对已有功能无副作用影响
```

### 4.2 代码质量检查

```markdown
- [ ] 变量/函数命名清晰有意义
- [ ] 函数长度合理（建议 < 50 行）
- [ ] 无重复代码（DRY 原则）
- [ ] 适当抽取公共模块
- [ ] 复杂逻辑有注释说明
```

### 4.3 安全性检查

```markdown
- [ ] 无硬编码的 secrets、keys、passwords
- [ ] 用户输入已转义防止 XSS
- [ ] 数据库查询使用参数化防止 SQL 注入
- [ ] 权限检查在服务端执行
- [ ] 敏感数据不在日志中输出
```

### 4.4 测试覆盖检查

```markdown
- [ ] 核心业务逻辑有单元测试
- [ ] 新增功能有对应的测试用例
- [ ] 测试用例覆盖正常和异常路径
- [ ] 测试可以通过 CI 流水线
```

### 4.5 性能检查

```markdown
- [ ] 数据库查询有适当索引
- [ ] 无 N+1 查询问题
- [ ] 大数据量场景已考虑分页
- [ ] 无内存泄漏风险
- [ ] 循环中无阻塞操作
```

---

## 5. 版本标签规范

### 5.1 标签格式

```
v{major}.{minor}.{patch}
```

| 级别 | 说明 | 示例 |
|------|------|------|
| major | 不兼容的 API 变更 | v2.0.0 |
| minor | 向后兼容的功能新增 | v1.2.0 |
| patch | 向后兼容的问题修复 | v1.2.3 |

### 5.2 发布流程

```bash
# 1. 创建发布分支
git checkout main
git pull origin main
git checkout -b release/v1.2.0

# 2. 更新版本号
npm version minor -m "release: v1.2.0"

# 3. 推送标签
git push origin v1.2.0

# 4. 删除发布分支（如果需要）
git branch -d release/v1.2.0
```

---

## 6. 常见问题处理

### 6.1 合并冲突

```bash
# 1. 更新 main
git checkout main
git pull origin main

# 2. 切回特性分支并合并 main
git checkout feature/ABC-123
git merge main

# 3. 解决冲突后提交
git add .
git commit -m "merge: resolve conflicts with main"
```

### 6.2 撤销提交

```bash
# 撤销未 push 的提交
git reset --soft HEAD~1

# 撤销已 push 的提交（谨慎使用）
git revert HEAD

# 撤销特定文件
git checkout -- path/to/file
```

### 6.3 暂存工作

```bash
# 暂存当前更改
git stash

# 恢复暂存
git stash pop

# 查看暂存列表
git stash list
```
