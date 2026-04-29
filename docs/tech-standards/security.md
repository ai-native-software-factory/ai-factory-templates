# Security Standards

本文档定义 iPlayABC 项目的安全标准和最佳实践。

---

## 1. 环境变量 Secrets

### 1.1 Secrets 管理原则

```bash
# ✗ 禁止在代码中硬编码 secrets
const SECRET = 'my-api-key-12345'  # 绝对禁止

# ✓ 使用环境变量
const SECRET = process.env.API_SECRET

# ✓ 使用 .env 文件（仅本地开发）
# .env 文件必须添加到 .gitignore

# ✓ 生产环境使用密钥管理服务
# AWS Secrets Manager / HashiCorp Vault / Kubernetes Secrets
```

### 1.2 环境变量命名规范

```bash
# 格式：{CATEGORY}_{NAME}
# 数据库
DATABASE_HOST
DATABASE_PORT
DATABASE_NAME
DATABASE_USERNAME
DATABASE_PASSWORD

# Redis
REDIS_HOST
REDIS_PASSWORD

# JWT
JWT_SECRET
JWT_EXPIRE_SECONDS

# 第三方服务
OSS_ACCESS_KEY
OSS_ACCESS_SECRET
OSS_BUCKET

# 微信支付
WECHAT_APP_ID
WECHAT_MCH_ID
WECHAT_API_KEY

# 支付宝
ALIPAY_APP_ID
ALIPAY_PRIVATE_KEY
ALIPAY_PUBLIC_KEY
```

### 1.3 .env 文件结构

```bash
# .env.example - 提交到版本控制，仅包含键名
DATABASE_HOST=
DATABASE_PORT=
DATABASE_USERNAME=
DATABASE_PASSWORD=
JWT_SECRET=

# .env - 本地开发使用，不提交
DATABASE_HOST=localhost
DATABASE_PORT=3306
DATABASE_USERNAME=root
DATABASE_PASSWORD=local_dev_pass
JWT_SECRET=dev-secret-key
```

---

## 2. JWT 安全实践

### 2.1 Token 生成

```typescript
// packages/common/src/jwt/index.ts
import jwt from 'jsonwebtoken'

// ✓ 使用环境变量
const JWT_SECRET = process.env.JWT_SECRET || '!@#$default-secret-change-me'
const JWT_EXPIRE_TIME = Number(process.env.JWT_EXPIRE_SECONDS || 30 * 24 * 3600)

export function create(payload: Record<string, unknown>): string {
  const p = { ...payload }
  delete p.iat
  delete p.exp
  return jwt.sign(p, JWT_SECRET, { expiresIn: JWT_EXPIRE_TIME })
}

export function decodeToken(token: string): unknown {
  try {
    return jwt.verify(token, JWT_SECRET)
  } catch {
    return null
  }
}
```

### 2.2 Token 刷新策略

```typescript
// Access Token：短期（15分钟）
// Refresh Token：长期（30天），存储在 httpOnly cookie 或安全存储

interface TokenPair {
  accessToken: string
  refreshToken: string
}

// 登录时返回 token 对
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
  "expiresIn": 900  // 15分钟
}

// 刷新 token
async function refreshTokens(refreshToken: string): Promise<TokenPair> {
  // 验证 refresh token
  const decoded = jwt.verify(refreshToken, JWT_SECRET)

  // 生成新的 access token
  const accessToken = jwt.sign(
    { sub: decoded.sub, type: 'access' },
    JWT_SECRET,
    { expiresIn: '15m' }
  )

  // 可选：刷新 refresh token（rotation）
  const newRefreshToken = jwt.sign(
    { sub: decoded.sub, type: 'refresh' },
    JWT_SECRET,
    { expiresIn: '30d' }
  )

  return { accessToken, refreshToken: newRefreshToken }
}
```

### 2.3 Token 验证中间件

```typescript
// NestJS Guard
@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private jwtService: JwtService) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest()
    const token = this.extractTokenFromHeader(request)

    if (!token) {
      throw new UnauthorizedException('Missing token')
    }

    try {
      const payload = this.jwtService.verify(token)
      request.user = payload
      return true
    } catch (error) {
      throw new UnauthorizedException('Invalid token')
    }
  }

  private extractTokenFromHeader(request: Request): string | undefined {
    const [type, token] = request.headers.authorization?.split(' ') ?? []
    return type === 'Bearer' ? token : undefined
  }
}
```

---

## 3. 敏感数据处理

### 3.1 密码加密

```typescript
// ✓ 使用 bcrypt 或 argon2
import bcrypt from 'bcrypt'

const SALT_ROUNDS = 12

async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, SALT_ROUNDS)
}

async function verifyPassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash)
}
```

### 3.2 敏感字段过滤

```typescript
// ✓ API 响应中过滤敏感字段
function sanitizeUser(user: User): User {
  const { password, salt, ...safeUser } = user
  return safeUser
}

// ✓ 使用 class-transformer
import { Exclude, Expose } from 'class-transformer'

class UserResponseDto {
  @Expose()
  id: number

  @Expose()
  username: string

  @Exclude()
  password: string  // 不会暴露
}
```

### 3.3 日志脱敏

```typescript
// ✓ 日志中不输出敏感信息
logger.info('User login', {
  userId: user.id,
  action: 'login'
  // ✗ 不要输出: password, token, creditCardNumber
})

// ✓ 脱敏处理
function maskSensitiveData(data: Record<string, unknown>): Record<string, unknown> {
  const sensitiveKeys = ['password', 'token', 'secret', 'creditCard']
  const masked = { ...data }

  for (const key of Object.keys(masked)) {
    if (sensitiveKeys.some(s => key.toLowerCase().includes(s))) {
      masked[key] = '***MASKED***'
    }
  }

  return masked
}
```

---

## 4. SQL 注入防护

### 4.1 参数化查询

```typescript
// ✓ 使用 ORM 的参数化查询
const user = await this.userRepository.findOne({
  where: { username }
})

// ✗ 绝对不要拼接 SQL
const query = `SELECT * FROM users WHERE username = '${username}'`  // 危险！

// ✓ 使用参数化查询（原生）
const [users] = await this.dataSource.query(
  'SELECT * FROM users WHERE username = ?',
  [username]
)
```

### 4.2 TypeORM 安全实践

```typescript
// ✓ 使用 findOne/find 等方法
const user = await this.userRepository.findOne({
  where: { id: userId }
})

// ✓ 使用 Select 指定字段
const users = await this.userRepository.find({
  select: ['id', 'username', 'email'],  // 只查询需要的字段
  where: { institutionId }
})

// ✓ 使用 Delete/SoftDelete
await this.userRepository.delete({ id: userId })
```

---

## 5. 依赖安全

### 5.1 依赖审计

```bash
# 安装后审计
npm audit

# 修复漏洞
npm audit fix

# 仅审计生产依赖
npm audit --production

# 输出 JSON 格式
npm audit --json > audit.json
```

### 5.2 package.json 配置

```json
{
  "engines": {
    "node": ">=20",
    "npm": ">=10"
  },
  "scripts": {
    "preinstall": "npx force-ssl-cert-check",
    "postinstall": "npm audit --production"
  }
}
```

### 5.3 禁止的依赖

```json
{
  "overrides": {
    // 禁止存在已知漏洞的包
    "lodash": ">=4.17.21",
    "minimist": ">=1.2.6",
    "acorn": ">=7.1.1"
  }
}
```

---

## 6. 输入验证

### 6.1 通用验证规则

```typescript
// ✓ 使用 class-validator
import { IsEmail, IsString, MinLength, MaxLength, IsEnum, IsOptional } from 'class-validator'

export class CreateUserDto {
  @IsString()
  @MinLength(2)
  @MaxLength(50)
  username: string

  @IsEmail()
  email: string

  @IsString()
  @MinLength(6)
  @MaxLength(100)
  password: string

  @IsEnum(UserRole)
  role: UserRole

  @IsOptional()
  @IsString()
  phone?: string
}
```

### 6.2 特殊字段验证

```typescript
// 手机号验证
@IsMobilePhone('zh-CN')
phone: string

// URL 验证
@IsUrl()
website: string

// 枚举值验证
@IsIn(['active', 'inactive', 'pending'])
status: string

// 数组验证
@IsArray()
@ArrayMinSize(1)
@ArrayMaxSize(100)
items: string[]
```

### 6.3 长度和范围验证

```typescript
// 字符串长度
@MinLength(1)
@MaxLength(255)

// 数字范围
@Min(0)
@Max(100)

// 日期范围
@IsDateString()
startDate: string

// 自定义验证
@Validate(IsExpiredDate, { message: 'Date must be in the future' })
endDate: Date
```

---

## 7. HTTPS 和传输安全

### 7.1 安全头

```typescript
// NestJS 中添加安全头
// main.ts
import helmet from 'helmet'

async function bootstrap() {
  const app = await NestFactory.create(AppModule)

  // 安全头
  app.use(helmet())

  // CORS 配置
  app.enableCors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') || [],
    credentials: true
  })

  // HSTS（生产环境）
  if (process.env.NODE_ENV === 'production') {
    app.use(helmet.hsts({
      maxAge: 31536000,
      includeSubDomains: true,
      preload: true
    }))
  }
}
```

### 7.2 CORS 配置

```typescript
// 仅允许可信域名
const allowedOrigins = [
  'https://admin.example.com',
  'https://student.example.com',
]

app.enableCors({
  origin: (origin, callback) => {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true)
    } else {
      callback(new Error('Not allowed by CORS'))
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization']
})
```

---

## 8. 安全检查清单

### 8.1 代码提交前检查

```markdown
- [ ] 无硬编码的 secrets、API keys、passwords
- [ ] 所有用户输入已验证
- [ ] 数据库查询使用参数化
- [ ] 敏感数据不在日志中输出
- [ ] 使用 HTTPS（生产环境）
- [ ] 密码已加密存储
- [ ] Token 设置了过期时间
```

### 8.2 依赖安全检查

```markdown
- [ ] 无已知 CVE 漏洞的依赖
- [ ] 使用 npm audit 检查
- [ ] 定期更新依赖
- [ ] 使用 lockfile 固定版本
```

### 8.3 部署前检查

```markdown
- [ ] 生产环境变量已正确配置
- [ ] DEBUG 模式已关闭
- [ ] 错误信息不暴露内部细节
- [ ] 备份已配置
- [ ] 监控告警已设置
```

---

## 9. 安全事件响应

### 9.1 漏洞报告

```markdown
# 安全漏洞请联系 security@iplayabc.com

# 报告内容
- 漏洞类型
- 复现步骤
- 影响范围
- 建议修复方案
```

### 9.2 应急响应流程

```markdown
1. 确认漏洞（24小时内）
2. 评估影响范围
3. 制定修复方案
4. 紧急修复发布
5. 通知受影响用户（如需要）
6. 事后分析报告
```
