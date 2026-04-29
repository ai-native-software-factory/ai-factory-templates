# 产品架构 (Product Architecture)

本文档描述 iPlayABC 产品的整体技术架构和设计方案。

---

## 1. 产品定位

### 1.1 B2B SaaS 教育平台

iPlayABC 是一款面向教育机构的 B2B SaaS 产品，提供在线教学管理的一站式解决方案。

```
┌─────────────────────────────────────────────────────────────┐
│                      iPlayABC Platform                       │
│                                                              │
│   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐         │
│   │ 机构 A  │  │ 机构 B  │  │ 机构 C  │  │ 机构 N  │         │
│   │ 小学    │  │ 幼儿园  │  │ 培训机构│  │ ...    │         │
│   └─────────┘  └─────────┘  └─────────┘  └─────────┘         │
│                                                              │
│              All Powered by iPlayABC                         │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 核心价值

- **降低技术门槛**: 机构无需自建技术团队
- **规模化运营**: 统一平台支持多机构高效管理
- **数据驱动**: 教学数据分析助力个性化教学
- **快速部署**: SaaS 模式即开即用

---

## 2. 技术架构

### 2.1 整体架构图

```
┌────────────────────────────────────────────────────────────────┐
│                         Clients                                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │ Web (Vue)│  │App ( RN )│  │App(Flutter│  │Mini Program│     │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘      │
└────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────────┐
│                      CDN / Static Assets                       │
└────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────────┐
│                      Load Balancer (Nginx)                     │
└────────────────────────────────────────────────────────────────┘
                              │
         ┌────────────────────┼────────────────────┐
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   API Gateway   │  │   API Gateway   │  │   API Gateway   │
│   (Default)     │  │   (Institution) │  │   (Admin)       │
└─────────────────┘  └─────────────────┘  └─────────────────┘
         │                    │                    │
         └────────────────────┼────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────────┐
│                     NestJS Microservices                        │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐  │
│  │  Auth     │  │  Student  │  │  Course   │  │  Order    │  │
│  │  Service  │  │  Service  │  │  Service  │  │  Service  │  │
│  └───────────┘  └───────────┘  └───────────┘  └───────────┘  │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐  │
│  │ Institution│  │ Content  │  │  Payment  │  │   Notify  │  │
│  │  Service  │  │  Service  │  │  Service  │  │  Service  │  │
│  └───────────┘  └───────────┘  └───────────┘  └───────────┘  │
└────────────────────────────────────────────────────────────────┘
                              │
         ┌────────────────────┼────────────────────┐
         │                    │                    │
         ▼                    ▼                    ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│     MySQL       │  │     Redis       │  │   OSS / OBS     │
│   (主库)        │  │   (缓存/会话)    │  │   (文件存储)    │
└─────────────────┘  └─────────────────┘  └─────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────────┐
│                    Third-party Services                         │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐  │
│  │ 微信支付   │  │ 支付宝    │  │  短信服务 │  │   邮件    │  │
│  └───────────┘  └───────────┘  └───────────┘  └───────────┘  │
└────────────────────────────────────────────────────────────────┘
```

### 2.2 技术栈

| 层级 | 技术 | 说明 |
|------|------|------|
| 前端 Web | Vue 3 + TypeScript | 管理后台、学生端 Web |
| 移动 App | React Native / Flutter | 跨平台移动应用 |
| 小程序 | 原生开发 | 微信小程序 |
| 后端 API | NestJS + TypeScript | 微服务架构 |
| 数据库 | MySQL 8.0 | 主数据存储 |
| 缓存 | Redis | 会话、缓存、限流 |
| 文件存储 | OSS / OBS | 对象存储 |
| 搜索引擎 | Elasticsearch | 全文搜索（可选） |
| 消息队列 | RabbitMQ / Kafka | 异步消息处理 |
| 容器化 | Docker + K8s | 容器编排 |
| CI/CD | GitHub Actions | 持续集成部署 |
| 日志 | ELK / Loki | 日志收集分析 |
| 监控 | Prometheus + Grafana | 指标监控 |

---

## 3. 多租户架构

### 3.1 租户隔离策略

```
┌──────────────────────────────────────────────────────────────┐
│                        Database                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                    Shared Tables                         │ │
│  │  - countries, regions, categories, subjects            │ │
│  └─────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 Institution A Schema                     │ │
│  │  - students, teachers, courses, orders                  │ │
│  └─────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 Institution B Schema                     │ │
│  │  - students, teachers, courses, orders                  │ │
│  └─────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

### 3.2 租户标识

```typescript
// 请求中的租户标识
interface TenantContext {
  institutionId: number    // 机构 ID
  userId: number          // 用户 ID
  roles: string[]         // 用户角色
}

// 通过以下方式传递
// 1. JWT Token 包含 institutionId
// 2. 请求头 X-Institution-Id
// 3. 子域名解析
```

### 3.3 数据权限控制

```typescript
// 伪代码示例
@Injectable()
export class TenantFilter implements NestInterceptor {
  intercept(context, next) {
    const request = context.switchToHttp().getRequest()
    const { institutionId } = request.user

    // 自动注入租户过滤条件
    request.query.institutionId = institutionId
    request.body.institutionId = institutionId

    return next.handle()
  }
}
```

---

## 4. 角色权限模型 (RBAC)

### 4.1 系统角色

| 角色 | 代码 | 描述 |
|------|------|------|
| 超级管理员 | super_admin | 系统最高权限，管理所有机构 |
| 机构管理员 | institution_admin | 管理本机构所有用户和业务 |
| 教师 | teacher | 管理自己的课程和学生 |
| 学生 | student | 学习课程、查看成绩 |
| 财务 | finance | 处理订单、退款、对账 |
| 运营 | operation | 内容审核、运营数据分析 |

### 4.2 权限层级

```
Super Admin
    │
    ├── Institution Admin
    │       │
    │       ├── Teacher
    │       │       │
    │       │       └── Student
    │       │
    │       ├── Finance
    │       │
    │       └── Operation
    │
    └── System Operation
```

### 4.3 权限控制实现

```typescript
// 路由守卫示例
@Injectable()
export class AuthGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest()
    const user = request.user
    const requiredRoles = this.reflector.get<string[]>('roles', context.getHandler())

    if (!requiredRoles) return true

    return requiredRoles.some(role => user.roles.includes(role))
  }
}

// 使用装饰器
@Get('students')
@Roles('teacher', 'institution_admin')
@UseGuards(AuthGuard)
getStudents() { }
```

---

## 5. 微服务划分

### 5.1 服务列表

| 服务 | 端口 | 职责 |
|------|------|------|
| auth-service | 3001 | 用户认证、权限 |
| student-service | 3002 | 学生管理 |
| teacher-service | 3003 | 教师管理 |
| course-service | 3004 | 课程管理 |
| order-service | 3005 | 订单、支付 |
| institution-service | 3006 | 机构管理 |
| content-service | 3007 | 内容管理 |
| notify-service | 3008 | 通知服务 |

### 5.2 服务间通信

```typescript
// 同步通信 - HTTP / gRPC
@Injectable()
export class CourseService {
  constructor(
    @Inject('STUDENT_SERVICE') private studentClient: ClientProxy
  ) {}

  async getCourseWithStudents(courseId: number) {
    const course = await this.courseRepo.findOne(courseId)
    const students = await this.studentClient
      .send('get-students-by-course', { courseId })
      .toPromise()
    return { course, students }
  }
}

// 异步通信 - 消息队列
@Injectable()
export class OrderService {
  constructor(
    private readonly eventBus: EventBus
  ) {}

  async createOrder(order: CreateOrderDto) {
    const result = await this.orderRepo.save(order)
    // 发布订单创建事件
    this.eventBus.publish(new OrderCreatedEvent(result))
    return result
  }
}
```

---

## 6. 部署架构

### 6.1 环境划分

| 环境 | 用途 | 部署方式 |
|------|------|----------|
| local | 本地开发 | docker-compose |
| dev | 开发测试 | K8s Dev Namespace |
| staging | 预发布 | K8s Staging Namespace |
| production | 生产环境 | K8s Production Namespace |

### 6.2 扩缩容策略

```yaml
# K8s HPA 配置示例
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-deployment
  minReplicas: 3
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

---

## 7. 安全架构

### 7.1 网络安全

```
Internet → WAF → Nginx → API Gateway → Internal Services
          │                            │
          └── DDoS Protection          └── Rate Limiting
```

### 7.2 应用安全

- **认证**: JWT + Refresh Token
- **加密**: TLS 1.3
- **敏感数据**: 加密存储
- **XSS/CSRF**: 请求头校验 + Token 验证
- **SQL 注入**: ORM 参数化查询

### 7.3 数据安全

- **备份**: 每日全量 + 实时增量
- **容灾**: 跨可用区部署
- **脱敏**: 生产数据脱敏后用于测试

---

## 8. 监控与告警

### 8.1 监控指标

| 类别 | 指标 |
|------|------|
| 基础设施 | CPU、内存、磁盘、网络 |
| 应用 | QPS、响应时间、错误率 |
| 业务 | 订单量、活跃用户、转化率 |
| 数据库 | 连接数、慢查询、锁等待 |

### 8.2 告警等级

| 等级 | 响应时间 | 场景 |
|------|----------|------|
| P0 | 5 分钟 | 服务不可用、数据丢失 |
| P1 | 15 分钟 | 功能受损、错误率 > 5% |
| P2 | 1 小时 | 性能下降、延迟增加 |
| P3 | 4 小时 | 异常波动、非关键告警 |
