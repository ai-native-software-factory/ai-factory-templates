# 核心业务域 (Core Business Domains)

本文档描述 iPlayABC 产品中的六大核心业务域及其典型操作模式。

---

## 1. 学生 (Student)

### 1.1 关键实体

| 字段 | 类型 | 描述 |
|------|------|------|
| id | bigint | 主键 |
| name | varchar(100) | 姓名 |
| phone | varchar(20) | 手机号 |
| email | varchar(100) | 邮箱 |
| avatar | varchar(500) | 头像 URL |
| institutionId | bigint | 所属机构 ID |
| grade | varchar(20) | 年级 |
| status | enum | 状态：active/inactive |
| createdAt | datetime | 创建时间 |
| updatedAt | datetime | 更新时间 |

### 1.2 典型 CRUD 操作

```typescript
// 查询学生列表（分页）
GET /api/students?page=1&pageSize=20&institutionId=1

// 获取学生详情
GET /api/students/:id

// 创建学生
POST /api/students
{
  "name": "张三",
  "phone": "13800138000",
  "institutionId": 1,
  "grade": "grade_3"
}

// 更新学生
PUT /api/students/:id
{
  "name": "张三丰",
  "grade": "grade_4"
}

// 删除学生（软删除）
DELETE /api/students/:id
```

### 1.3 集成模式

- **归属机构**: 每个学生必须属于一个机构 (Institution)
- **选课**: 学生通过订单 (Order) 购买课程 (Course)
- **学习记录**: 记录学生的学习进度和成绩
- **多角色**: 学生可能同时是其他系统的教师

---

## 2. 教师 (Teacher)

### 2.1 关键实体

| 字段 | 类型 | 描述 |
|------|------|------|
| id | bigint | 主键 |
| name | varchar(100) | 姓名 |
| phone | varchar(20) | 手机号 |
| email | varchar(100) | 邮箱 |
| avatar | varchar(500) | 头像 URL |
| institutionId | bigint | 所属机构 ID |
| subject | varchar(50) | 教授科目 |
| title | varchar(50) | 职称 |
| status | enum | 状态：active/inactive |
| createdAt | datetime | 创建时间 |

### 2.2 典型 CRUD 操作

```typescript
// 查询教师列表
GET /api/teachers?institutionId=1&subject=math

// 获取教师详情（含课程列表）
GET /api/teachers/:id

// 创建教师
POST /api/teachers
{
  "name": "李老师",
  "phone": "13900139000",
  "institutionId": 1,
  "subject": "english"
}

// 更新教师信息
PUT /api/teachers/:id

// 批量导入教师
POST /api/teachers/batch
```

### 2.3 集成模式

- **课程管理**: 教师创建和管理自己的课程
- **机构归属**: 教师归属于机构，可跨机构授课
- **学生管理**: 查看选修自己课程的学生
- **评价系统**: 接收来自学生的评分和反馈

---

## 3. 课程 (Course)

### 3.1 关键实体

| 字段 | 类型 | 描述 |
|------|------|------|
| id | bigint | 主键 |
| title | varchar(200) | 课程标题 |
| description | text | 课程描述 |
| coverImage | varchar(500) | 封面图 |
| teacherId | bigint | 授课教师 ID |
| institutionId | bigint | 所属机构 ID |
| category | varchar(50) | 分类 |
| price | decimal(10,2) | 价格 |
| discountPrice | decimal(10,2) | 折扣价 |
| duration | int | 总时长（分钟） |
| lessonsCount | int | 课时数 |
| status | enum | 状态：draft/published/offline |
| createdAt | datetime | 创建时间 |
| publishedAt | datetime | 发布时间 |

### 3.2 典型 CRUD 操作

```typescript
// 查询课程列表
GET /api/courses?page=1&pageSize=10&category=english&teacherId=1

// 获取课程详情（含课时列表）
GET /api/courses/:id

// 创建课程
POST /api/courses
{
  "title": "少儿英语入门",
  "description": "适合零基础学生",
  "teacherId": 1,
  "price": 299.00,
  "category": "english"
}

// 发布课程
POST /api/courses/:id/publish

// 更新课程
PUT /api/courses/:id

// 下架课程
POST /api/courses/:id/offline
```

### 3.3 集成模式

- **内容关联**: 课程包含多个课时 (Lesson)
- **教师所有**: 课程归属于创建它的教师
- **订单购买**: 学生通过订单购买课程
- **学习进度**: 记录学生的课程学习进度
- **评价系统**: 学生可对课程进行评价

---

## 4. 订单 (Order)

### 4.1 关键实体

| 字段 | 类型 | 描述 |
|------|------|------|
| id | bigint | 主键 |
| orderNo | varchar(64) | 订单号 |
| studentId | bigint | 学生 ID |
| courseId | bigint | 课程 ID |
| institutionId | bigint | 机构 ID |
| originalPrice | decimal(10,2) | 原价 |
| actualPrice | decimal(10,2) | 实付金额 |
| discount | decimal(10,2) | 优惠金额 |
| couponId | bigint | 使用的优惠券 ID |
| paymentMethod | enum | 支付方式：wechat/alipay/card |
| paymentStatus | enum | 支付状态：pending/paid/refunded/cancelled |
| paidAt | datetime | 支付时间 |
| status | enum | 订单状态 |
| createdAt | datetime | 创建时间 |
| updatedAt | datetime | 更新时间 |

### 4.2 典型 CRUD 操作

```typescript
// 查询订单列表
GET /api/orders?studentId=1&paymentStatus=paid&page=1&pageSize=20

// 获取订单详情
GET /api/orders/:id

// 创建订单
POST /api/orders
{
  "studentId": 1,
  "courseId": 1,
  "couponId": null
}

// 支付订单
POST /api/orders/:id/pay
{
  "paymentMethod": "wechat"
}

// 取消订单
POST /api/orders/:id/cancel

// 申请退款
POST /api/orders/:id/refund
{
  "reason": "课程不合适"
}
```

### 4.3 集成模式

- **学生购买**: 订单关联学生和课程
- **支付集成**: 对接微信支付、支付宝等
- **优惠系统**: 支持优惠券、折扣活动
- **财务对账**: 机构财务报表的数据来源
- **课程授权**: 支付成功后学生获得课程学习权限

---

## 5. 机构 (Institution)

### 5.1 关键实体

| 字段 | 类型 | 描述 |
|------|------|------|
| id | bigint | 主键 |
| name | varchar(200) | 机构名称 |
| code | varchar(50) | 机构代码（唯一） |
| logo | varchar(500) | logo URL |
| description | text | 机构描述 |
| contact | varchar(100) | 联系人 |
| phone | varchar(20) | 联系电话 |
| address | varchar(500) | 地址 |
| domain | varchar(100) | 独立域名 |
| packageType | enum | 套餐类型 |
| expireTime | datetime | 套餐过期时间 |
| status | enum | 状态：active/suspended/expired |
| createdAt | datetime | 创建时间 |
| updatedAt | datetime | 更新时间 |

### 5.2 典型 CRUD 操作

```typescript
// 查询机构列表（超级管理员）
GET /api/institutions?page=1&pageSize=20&status=active

// 获取机构详情
GET /api/institutions/:id

// 创建机构
POST /api/institutions
{
  "name": "北京市第一小学",
  "code": "bjdyxx",
  "contact": "王校长",
  "phone": "010-12345678"
}

// 更新机构信息
PUT /api/institutions/:id

// 开通套餐
POST /api/institutions/:id/package
{
  "packageType": "enterprise",
  "duration": 365
}

// 禁用/启用机构
POST /api/institutions/:id/suspend
```

### 5.3 集成模式

- **多租户**: 机构是独立的租户，数据隔离
- **管理员**: 机构管理员管理本机构用户
- **套餐管理**: 不同套餐对应不同功能权限
- **数据统计**: 机构维度的业务数据分析
- **域名隔离**: 支持机构独立域名

---

## 6. 内容 (Content)

### 6.1 关键实体

| 字段 | 类型 | 描述 |
|------|------|------|
| id | bigint | 主键 |
| title | varchar(200) | 标题 |
| type | enum | 类型：video/audio/document/image |
| url | varchar(500) | 资源 URL |
| coverUrl | varchar(500) | 封面 URL |
| duration | int | 时长（秒） |
| size | bigint | 文件大小（字节） |
| mimeType | varchar(100) | MIME 类型 |
| courseId | bigint | 所属课程 ID |
| lessonId | bigint | 所属课时 ID |
| teacherId | bigint | 上传教师 ID |
| institutionId | bigint | 所属机构 ID |
| status | enum | 状态：uploading/ready/failed |
| createdAt | datetime | 创建时间 |

### 6.2 典型 CRUD 操作

```typescript
// 查询内容列表
GET /api/contents?courseId=1&type=video

// 获取内容详情
GET /api/contents/:id

// 上传内容
POST /api/contents
{
  "title": "第一课视频",
  "type": "video",
  "courseId": 1,
  "lessonId": 1
}

// 获取上传凭证（用于直传 OSS）
GET /api/contents/:id/upload-token

// 删除内容
DELETE /api/contents/:id
```

### 6.3 集成模式

- **OSS 存储**: 内容存储在对象存储服务
- **课时关联**: 内容归属于课程下的课时
- **CDN 加速**: 内容通过 CDN 分发
- **转码处理**: 视频上传后自动转码
- **版权保护**: 支持视频加密和防下载

---

## 域间关系图

```
┌─────────────┐     ┌─────────────┐
│ Institution │────<│   Teacher   │
└─────────────┘     └─────────────┘
       │                  │
       │                  │
       ▼                  ▼
┌─────────────┐     ┌─────────────┐
│   Student   │     │    Course   │
└─────────────┘     └─────────────┘
       │                  │
       │                  │
       ▼                  │
┌─────────────┐           │
│    Order    │───────────┘
└─────────────┘
       │
       ▼
┌─────────────┐     ┌─────────────┐
│   Content   │<────│    Lesson   │
└─────────────┘     └─────────────┘
```

---

## 通用 CRUD 模式

所有业务域遵循统一的 RESTful API 模式：

```typescript
// 列表查询（支持分页、筛选、排序）
GET /api/{resource}?page=1&pageSize=20&field=value&sort=createdAt:desc

// 详情查询
GET /api/{resource}/:id

// 创建
POST /api/{resource}

// 批量创建
POST /api/{resource}/batch

// 更新
PUT /api/{resource}/:id

// 批量更新
PUT /api/{resource}/batch

// 删除（软删除）
DELETE /api/{resource}/:id

// 批量删除
DELETE /api/{resource}/batch
```
