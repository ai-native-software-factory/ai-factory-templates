# CI/CD Pipeline Standards

本文档定义 iPlayABC 项目的持续集成和持续部署标准。

---

## 1. Pipeline 流程

### 1.1 完整流水线

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  Lint   │───>│  Test   │───>│  Build  │───>│  Deploy │───>│  Notify │
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
     │              │              │              │              │
     ▼              ▼              ▼              ▼              ▼
  ESLint        Unit Test      Docker Build    K8s Deploy     Slack
  Prettier      E2E Test       Image Push      Helm Upgrade    Email
```

### 1.2 分支策略

| 分支 | 触发条件 | 流程 |
|------|----------|------|
| feature/* | PR | lint → test |
| bugfix/* | PR | lint → test |
| main | Push/PR | lint → test → build → deploy(staging) |
| release/* | Tag | lint → test → build → deploy(prod) |
| hotfix/* | PR | lint → test → build → deploy(prod) |

---

## 2. GitHub Actions 配置

### 2.1 NestJS API CI 配置

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run lint
        run: npm run lint

  test:
    name: Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
          fail_ci_if_error: true

  build:
    name: Build
    runs-on: ubuntu-latest
    needs: [lint, test]
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build

      - name: Build Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: false
          tags: nestjs-api:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max

  e2e:
    name: E2E Tests
    runs-on: ubuntu-latest
    needs: [build]
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run E2E tests
        run: npm run test:e2e
```

### 2.2 Vue Web CI 配置

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run lint
        run: npm run lint

  type-check:
    name: Type Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run type check
        run: npm run type-check

  test:
    name: Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm run test

  build:
    name: Build
    runs-on: ubuntu-latest
    needs: [lint, type-check, test]
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist
          retention-days: 7
```

---

## 3. 构建工件命名

### 3.1 镜像命名

```
# 格式
{DOCKER_REGISTRY}/{PROJECT}/{SERVICE}:{VERSION}

# 示例
registry.example.com/iplayabc/api:v1.2.3
registry.example.com/iplayabc/web:v1.2.3
registry.example.com/iplayabc/admin:v1.2.3

# Latest tag 仅用于开发
registry.example.com/iplayabc/api:latest
```

### 3.2 工件版本号

```bash
# 使用 Git tag 作为版本号
VERSION=$(git describe --tags --abbrev=0)

# 或使用语义化版本
VERSION=1.2.3

# 带 commit hash 的版本（CI 环境）
VERSION=1.2.3-${GITHUB_SHA:0:8}
```

---

## 4. 环境配置

### 4.1 环境变量管理

```bash
# .env 文件（本地开发）
# 不要提交到版本控制
NODE_ENV=development
DATABASE_URL=mysql://user:pass@localhost:3306/db
JWT_SECRET=your-secret-key

# .env.production（生产配置模板）
# 仅包含变量名，不包含实际值
DATABASE_URL=
JWT_SECRET=
REDIS_URL=
```

### 4.2 GitHub Secrets

```yaml
# 在 GitHub Settings > Secrets 中配置
# 供 CI/CD 使用

DOCKER_REGISTRY
DOCKER_USERNAME
DOCKER_PASSWORD

K8S_CLUSTER_URL
K8S_CA_certificate
K8S_TOKEN

SLACK_WEBHOOK
```

---

## 5. 部署阶段

### 5.1 Staging 部署

```yaml
# .github/workflows/deploy-staging.yml
name: Deploy to Staging

on:
  push:
    branches: [main]

jobs:
  deploy:
    name: Deploy
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to staging
        run: |
          kubectl config use-context staging
          helm upgrade --install api ./charts/api \
            --namespace staging \
            --set image.tag=${{ github.sha }} \
            --wait --timeout 5m

      - name: Verify deployment
        run: |
          kubectl rollout status deployment/api -n staging
          curl -f https://staging.api.example.com/health
```

### 5.2 Production 部署

```yaml
# .github/workflows/deploy-prod.yml
name: Deploy to Production

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    name: Deploy
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to production
        run: |
          kubectl config use-context production
          helm upgrade --install api ./charts/api \
            --namespace production \
            --set image.tag=${{ github.ref_name }} \
            --wait --timeout 10m

      - name: Verify deployment
        run: |
          kubectl rollout status deployment/api -n production
          curl -f https://api.example.com/health

      - name: Notify success
        if: success()
        run: |
          curl -X POST ${{ secrets.SLACK_WEBHOOK }} \
            -d '{"text":"Production deployed: ${{ github.ref_name }}"}'
```

---

## 6. 回滚流程

### 6.1 自动回滚触发条件

```yaml
# 健康检查失败自动回滚
helm upgrade --install api ./charts/api \
  --namespace production \
  --set image.tag=${{ github.ref_name }} \
  --wait --timeout 10m \
  --atomic \
  --cleanup-on-fail
```

### 6.2 手动回滚

```bash
# 查看部署历史
helm history api -n production

# 回滚到上一个版本
helm rollback api -n production

# 回滚到指定版本
helm rollback api 3 -n production

# Kubernetes 回滚
kubectl rollout undo deployment/api -n production

# 回滚到指定版本
kubectl rollout undo deployment/api -n production --to-revision=2
```

### 6.3 回滚检查清单

```markdown
- [ ] 确认回滚版本
- [ ] 通知相关人员
- [ ] 执行回滚
- [ ] 验证服务健康
- [ ] 确认功能正常
- [ ] 更新事件记录
- [ ] 分析回滚原因
```

---

## 7. 质量门禁

### 7.1 测试覆盖率要求

| 类型 | 最低覆盖率 |
|------|-----------|
| Statements | 80% |
| Branches | 75% |
| Functions | 80% |
| Lines | 80% |

### 7.2 门禁检查项

```yaml
# 必须全部通过才能合并
checks:
  - name: Lint
    pass: true
  - name: Type Check
    pass: true
  - name: Unit Tests
    pass: true
    coverage_threshold: 80%
  - name: E2E Tests
    pass: true
  - name: Security Scan
    pass: true
  - name: Bundle Size
    pass: true
    max_size: 500kb
```

### 7.3 质量报告

```yaml
# CI 完成后生成质量报告
- name: Generate quality report
  run: |
    npm run test:coverage
    npx jest-junit --outputFile test-results/jest.xml

- name: Publish test results
  uses: dorny/test-reporter@v1
  with:
    name: Test Results
    path: 'test-results/*.xml'
    reporter: java-junit
```

---

## 8. 通知机制

### 8.1 Slack 通知

```yaml
# 部署成功通知
- name: Notify Slack
  if: always()
  run: |
    STATUS=${{ job.status }}
    MESSAGE="Build ${{ job.status }}: ${{ github.workflow }}"

    if [ "$STATUS" == "success" ]; then
      COLOR="good"
    elif [ "$STATUS" == "failure" ]; then
      COLOR="danger"
    else
      COLOR="warning"
    fi

    curl -X POST ${{ secrets.SLACK_WEBHOOK }} \
      -H 'Content-Type: application/json' \
      -d "{
        \"attachments\": [{
          \"color\": \"$COLOR\",
          \"title\": \"${{ github.workflow }}\",
          \"text\": \"$MESSAGE\",
          \"fields\": [
            {\"title\": \"Branch\", \"value\": \"${{ github.ref_name }}\", \"short\": true},
            {\"title\": \"Commit\", \"value\": \"${{ github.sha }}\", \"short\": true}
          ]
        }]
      }"
```

### 8.2 邮件通知

```yaml
# 失败时发送邮件
- name: Send email on failure
  if: failure()
  uses: dawidd6/action-send-email@v3
  with:
    server: smtp.example.com
    port: 587
    username: ${{ secrets.EMAIL_USERNAME }}
    password: ${{ secrets.EMAIL_PASSWORD }}
    to: team@example.com
    subject: "CI Failed: ${{ github.workflow }}"
    body: "Build failed on ${{ github.ref_name }}"
```
