# API 契约标准 (API Contracts)

本文档定义 iPlayABC 产品中所有 API 的通用契约规范。

---

## 1. 标准响应格式

### 1.1 成功响应

```typescript
// 通用成功响应
{
  "code": 0,
  "message": "success",
  "data": T,
  "timestamp": 1704067200000
}

// 列表响应
{
  "code": 0,
  "message": "success",
  "data": {
    "list": T[],
    "total": number,
    "page": number,
    "pageSize": number
  },
  "timestamp": 1704067200000
}

// 分页响应（PageResult）
{
  "code": 0,
  "message": "success",
  "data": {
    "list": [],
    "total": 100,
    "page": 1,
    "pageSize": 10
  },
  "timestamp": 1704067200000
}
```

### 1.2 错误响应

```typescript
{
  "code": number,      // 错误码，非 0 表示失败
  "message": string,   // 错误信息（供用户展示）
  "data": null,        // 失败时为 null
  "timestamp": number
}
```

### 1.3 错误码定义

| 错误码 | 含义 | HTTP Status | 说明 |
|--------|------|-------------|------|
| 0 | 成功 | 200 | 操作成功 |
| 400 | 请求参数错误 | 400 | 参数校验失败 |
| 401 | 未认证 | 401 | 未登录或 Token 过期 |
| 403 | 无权限 | 403 | 无权访问该资源 |
| 404 | 资源不存在 | 404 | 找不到请求的资源 |
| 409 | 资源冲突 | 409 | 资源已存在或状态冲突 |
| 422 | 业务逻辑错误 | 422 | 业务规则不允许 |
| 429 | 请求过于频繁 | 429 | 触发限流 |
| 500 | 服务器内部错误 | 500 | 服务端异常 |
| 503 | 服务不可用 | 503 | 服务维护或过载 |

### 1.4 业务错误码（子错误码）

```typescript
{
  "code": 422,
  "message": "余额不足，无法完成支付",
  "data": {
    "subCode": "INSUFFICIENT_BALANCE",
    "required": 299.00,
    "current": 99.00
  }
}
```

---

## 2. 分页规范

### 2.1 分页请求参数

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| page | number | 否 | 1 | 当前页码 |
| pageSize | number | 否 | 10 | 每页条数，最大 100 |
| sort | string | 否 | - | 排序字段，格式：`field:asc` 或 `field:desc` |

```typescript
// 请求示例
GET /api/students?page=1&pageSize=20&sort=createdAt:desc
```

### 2.2 分页响应结构

```typescript
// PageResult<T> 类型定义
interface PageResult<T> {
  list: T[]           // 当前页数据
  total: number      // 总记录数
  page: number        // 当前页码
  pageSize: number    // 每页条数
}

// 可能包含的扩展字段
interface PageResultExt<T> extends PageResult<T> {
  totalPages: number // 总页数
  hasNext: boolean   // 是否有下一页
  hasPrev: boolean   // 是否有上一页
}
```

### 2.3 前端分页 Hook

```typescript
// Vue Web 中的 usePagination 使用示例
import { usePagination } from '@/composables/usePagination'

const {
  page,
  pageSize,
  total,
  list,
  setPage,
  setPageSize,
  setTotal,
  setList,
  getParams
} = usePagination({
  page: 1,
  pageSize: 20,
  immediate: false,
  onChange: (page, pageSize) => {
    fetchStudents(getParams())
  }
})
```

---

## 3. 认证模式

### 3.1 认证流程

```
┌──────────┐     ┌──────────┐     ┌──────────┐
│  Client  │────>│  Server  │────>│   JWT    │
│          │<────│          │<────│  Verify │
└──────────┘     └──────────┘     └──────────┘
```

### 3.2 认证请求头

```typescript
Authorization: Bearer <token>
```

### 3.3 登录流程

```typescript
// POST /api/auth/login
// 请求
{
  "username": "teacher001",
  "password": "encrypted_password"
}

// 响应
{
  "code": 0,
  "message": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": 1,
      "username": "teacher001",
      "roles": ["teacher"]
    }
  }
}
```

### 3.4 JWT Token 结构

```typescript
// Payload 包含
{
  "sub": "user_id",
  "username": "teacher001",
  "roles": ["teacher"],
  "institutionId": 1,
  "iat": 1704067200,    // 签发时间
  "exp": 1704153600     // 过期时间（30天）
}
```

### 3.5 Token 刷新

```typescript
// 方式一：被动刷新（通过 401 响应触发）
// 服务端返回 401，前端清除本地 token 并跳转登录页

// 方式二：主动刷新
// POST /api/auth/refresh
{
  "code": 0,
  "data": {
    "token": "new_token..."
  }
}
```

---

## 4. 常见 API 模式

### 4.1 文件上传

```typescript
// 获取上传凭证
GET /api/contents/:id/upload-token

// 响应
{
  "code": 0,
  "data": {
    "uploadUrl": "https://oss.example.com/upload",
    "token": "OSS_TOKEN",
    "expireTime": "2024-01-01T12:00:00Z"
  }
}

// 直传 OSS 后回调
POST /api/contents/:id/complete
{
  "code": 0,
  "data": {
    "url": "https://cdn.example.com/video.mp4"
  }
}
```

### 4.2 批量操作

```typescript
// 批量创建
POST /api/students/batch
{
  "students": [
    { "name": "张三", "phone": "13800138001" },
    { "name": "李四", "phone": "13800138002" }
  ]
}

// 响应
{
  "code": 0,
  "data": {
    "successCount": 2,
    "failCount": 0,
    "results": [
      { "id": 1, "name": "张三", "success": true },
      { "id": 2, "name": "李四", "success": true }
    ]
  }
}
```

### 4.3 导出功能

```typescript
// 发起导出请求
POST /api/students/export
{
  "filters": { "institutionId": 1 },
  "fields": ["name", "phone", "grade"]
}

// 响应（异步任务）
{
  "code": 0,
  "data": {
    "taskId": "export_20240101_001",
    "status": "processing"
  }
}

// 查询导出进度
GET /api/tasks/export_20240101_001

// 响应
{
  "code": 0,
  "data": {
    "taskId": "export_20240101_001",
    "status": "completed",
    "downloadUrl": "https://cdn.example.com/exports/students.xlsx",
    "expireTime": "2024-01-02T12:00:00Z"
  }
}
```

---

## 5. HTTP 状态码使用规范

| 状态码 | 场景 |
|--------|------|
| 200 OK | GET/PUT/DELETE 成功，批量操作全部成功 |
| 201 Created | POST 创建资源成功 |
| 204 No Content | DELETE 成功且无返回 body |
| 400 Bad Request | 请求参数格式错误、校验失败 |
| 401 Unauthorized | 未认证或 Token 无效 |
| 403 Forbidden | 已认证但无权限 |
| 404 Not Found | 资源不存在 |
| 409 Conflict | 资源已存在、状态冲突 |
| 422 Unprocessable Entity | 业务逻辑不允许 |
| 429 Too Many Requests | 请求频率超限 |
| 500 Internal Server Error | 服务端未知错误 |
| 502 Bad Gateway | 上游服务错误 |
| 503 Service Unavailable | 服务不可用（维护、过载） |

---

## 6. 请求超时规范

| 环境 | 超时时间 |
|------|----------|
| 前端请求 | 15 秒 (15000ms) |
| 后端内部调用 | 10 秒 |
| 文件上传 | 60 秒 |
| 异步任务查询 | 5 秒 |

---

## 7. 国际化支持

```typescript
// 请求头携带语言
Accept-Language: zh-CN,en-US

// 错误响应使用请求语言
{
  "code": 404,
  "message": "资源不存在",  // 或 "Resource not found"
  "data": null
}
```
