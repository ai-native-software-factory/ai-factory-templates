# Code Style Guide

本文档定义 TypeScript、Node.js 代码的编码规范。

---

## 1. TypeScript 规范

### 1.1 命名规范

```typescript
// ✓ 变量和函数：camelCase
const userName = 'John'
function getUserInfo() { }

// ✓ 常量：UPPER_SNAKE_CASE
const MAX_RETRY_COUNT = 3
const API_BASE_URL = '/api'

// ✓ 类、接口、类型：PascalCase
class UserService { }
interface UserInfo { }
type UserRole = 'admin' | 'teacher' | 'student'

// ✓ 私有属性：前缀下划线或 #（TS 3.8+）
class Example {
  private _internalValue: string
  #privateField: number
}

// ✓ 枚举：PascalCase，成员 UPPER_SNAKE_CASE
enum OrderStatus {
  PENDING = 'pending',
  PAID = 'paid',
  REFUNDED = 'refunded'
}

// ✓ 布尔变量：前缀 is, has, should, can
const isActive = true
const hasPermission = false
const shouldUpdate = true
```

### 1.2 类型定义

```typescript
// ✓ 使用 interface 定义对象结构
interface User {
  id: number
  name: string
  email: string
  roles: string[]
  createdAt: Date
}

// ✓ 使用 type 定义联合类型、交叉类型
type UserRole = 'admin' | 'teacher' | 'student'
type UserWithProfile = User & Profile

// ✓ 避免使用 any，使用 unknown 代替
// ✗ 错误
function processData(data: any) {
  return data.value
}

// ✓ 正确
function processData(data: unknown) {
  if (typeof data === 'object' && data !== null && 'value' in data) {
    return (data as { value: unknown }).value
  }
  throw new Error('Invalid data format')
}

// ✓ 使用泛型约束
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key]
}
```

### 1.3 函数规范

```typescript
// ✓ 使用箭头函数
const multiply = (a: number, b: number): number => a * b

// ✓ 函数参数类型标注
function fetchUser(id: number): Promise<User> {
  return httpClient.get(`/users/${id}`)
}

// ✓ 返回类型标注（复杂函数必须标注）
function calculateTotal(items: CartItem[]): {
  subtotal: number
  discount: number
  total: number
} {
  const subtotal = items.reduce((sum, item) => sum + item.price, 0)
  const discount = subtotal > 100 ? subtotal * 0.1 : 0
  return { subtotal, discount, total: subtotal - discount }
}

// ✓ 默认参数值
function createUser(name: string, role: UserRole = 'student') {
  return { name, role }
}
```

---

## 2. NestJS 规范

### 2.1 模块结构

```typescript
// ✓ 目录结构
src/
├── api/
│   └── user/
│       ├── user.controller.ts    # 控制器
│       ├── user.service.ts       # 服务
│       ├── user.module.ts        # 模块
│       ├── user.repository.ts    # 数据访问
│       ├── dto/                   # 数据传输对象
│       │   ├── create-user.dto.ts
│       │   └── update-user.dto.ts
│       ├── entities/             # 实体定义
│       │   └── user.entity.ts
│       └── user.spec.ts          # 单元测试
```

### 2.2 控制器规范

```typescript
// ✓ 控制器示例
@ApiTags('用户管理')
@Controller('users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get()
  @ApiOperation({ summary: '获取用户列表' })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'pageSize', required: false })
  async findAll(
    @Query('page') page = 1,
    @Query('pageSize') pageSize = 10,
  ): Promise<PageResult<User>> {
    return this.userService.findAll({ page, pageSize })
  }

  @Get(':id')
  @ApiOperation({ summary: '获取用户详情' })
  async findOne(@Param('id', ParseIntPipe) id: number): Promise<User> {
    return this.userService.findOne(id)
  }

  @Post()
  @ApiOperation({ summary: '创建用户' })
  async create(@Body() createUserDto: CreateUserDto): Promise<User> {
    return this.userService.create(createUserDto)
  }

  @Put(':id')
  @ApiOperation({ summary: '更新用户' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateUserDto: UpdateUserDto,
  ): Promise<User> {
    return this.userService.update(id, updateUserDto)
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: '删除用户' })
  async remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.userService.remove(id)
  }
}
```

### 2.3 服务规范

```typescript
// ✓ 服务示例
@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly logger: Logger,
  ) {}

  async findAll(params: FindAllParams): Promise<PageResult<User>> {
    const { page, pageSize } = params
    const skip = (page - 1) * pageSize

    const [list, total] = await this.userRepository.findAndCount({
      skip,
      take: pageSize,
      order: { createdAt: 'DESC' },
    })

    return { list, total, page, pageSize }
  }

  async findOne(id: number): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id } })
    if (!user) {
      throw new NotFoundException(`User #${id} not found`)
    }
    return user
  }

  async create(dto: CreateUserDto): Promise<User> {
    const user = this.userRepository.create(dto)
    return this.userRepository.save(user)
  }
}
```

### 2.4 DTO 规范

```typescript
// ✓ DTO 示例
export class CreateUserDto {
  @ApiProperty({ description: '用户名' })
  @IsString()
  @MinLength(2)
  @MaxLength(50)
  username: string

  @ApiProperty({ description: '密码' })
  @IsString()
  @MinLength(6)
  password: string

  @ApiProperty({ description: '邮箱', required: false })
  @IsEmail()
  @IsOptional()
  email?: string

  @ApiProperty({ description: '角色' })
  @IsEnum(UserRole)
  role: UserRole
}
```

---

## 3. Vue 3 + TypeScript 规范

### 3.1 组件结构

```vue
<!-- ✓ 组件模板结构 -->
<template>
  <div class="user-list">
    <!-- 组件内容 -->
  </div>
</template>

<script setup lang="ts">
// ✓ 组件逻辑
import { ref, computed, onMounted } from 'vue'
import type { User } from '@/types'

// Props 定义
interface Props {
  users: User[]
  loading?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  loading: false,
})

// Emits 定义
const emit = defineEmits<{
  (e: 'select', user: User): void
  (e: 'refresh'): void
}>()

// Composables
const { list, total, setList } = usePagination<User>()

// Methods
function handleSelect(user: User) {
  emit('select', user)
}
</script>

<style scoped>
.user-list {
  padding: 16px;
}
</style>
```

### 3.2 Composable 规范

```typescript
// ✓ Composable 示例
export function usePagination<T>(options: UsePaginationOptions = {}) {
  const { immediate = false, onChange } = options

  const page = ref(options.page ?? 1)
  const pageSize = ref(options.pageSize ?? 10)
  const total = ref(0)
  const list = ref<T[]>([]) as Ref<T[]>

  // Computed
  const totalPages = computed(() => Math.ceil(total.value / pageSize.value))
  const hasNext = computed(() => page.value < totalPages.value)

  // Methods
  function setPage(newPage: number) {
    page.value = newPage
    onChange?.(page.value, pageSize.value)
  }

  return {
    page,
    pageSize,
    total,
    list,
    totalPages,
    hasNext,
    setPage,
    setList,
    setTotal,
    getParams: () => ({ page: page.value, pageSize: pageSize.value }),
  }
}
```

---

## 4. Import 顺序

```typescript
// 1. Node.js 内置模块
import { readFile } from 'fs'
import { join } from 'path'

// 2. 外部依赖
import axios from 'axios'
import { ElMessage } from 'element-plus'

// 3. 内部共享模块（@/ 开头的别名路径）
import { useAuth } from '@/composables/useAuth'
import { request } from '@/utils/request'

// 4. 父级目录导入
import { UserService } from '../user.service'
import type { User } from '../types'

// 5. 相对路径导入（当前目录）
import { formatDate } from './date'

// ✓ 同一个 package 的多个导出可以使用一行
import { ref, reactive, computed } from 'vue'

// ✗ 避免混乱的导入顺序
import { useAuth } from '@/composables'
import axios from 'axios'
import { readFile } from 'fs'
import type { User } from '../types'
```

---

## 5. 错误处理规范

```typescript
// ✓ 同步错误处理
try {
  const result = syncOperation()
} catch (error) {
  if (error instanceof CustomError) {
    logger.warn(`Business error: ${error.message}`)
  } else {
    logger.error(`Unexpected error: ${error}`)
    throw error
  }
}

// ✓ 异步错误处理
async function fetchData(): Promise<Result> {
  try {
    const response = await api.getData()
    return { success: true, data: response }
  } catch (error) {
    logger.error('Fetch data failed', { error })
    return { success: false, error: error.message }
  }
}

// ✓ 统一错误响应
class AppError extends Error {
  constructor(
    public code: number,
    message: string,
    public details?: Record<string, unknown>
  ) {
    super(message)
    this.name = 'AppError'
  }
}

// 使用
throw new AppError(400, 'Validation failed', { field: 'email' })
```

---

## 6. 日志规范

```typescript
// ✓ 日志级别使用
logger.debug('Debug information')      // 开发调试
logger.info('Operation completed', {  // 正常流程
  userId: 1,
  action: 'create',
  resource: 'order',
})
logger.warn('Potential issue', {       // 警告
  retryCount: 3,
  lastError: 'timeout',
})
logger.error('Operation failed', {    // 错误
  error: error.message,
  stack: error.stack,
})

// ✓ 避免日志中的敏感信息
// ✗ 错误
logger.info(`User ${user.email} logged in with password ${user.password}`)

// ✓ 正确
logger.info(`User ${user.id} logged in`, { email: user.email })
```

---

## 7. 测试要求

### 7.1 单元测试覆盖率要求

| 类型 | 最低覆盖率 |
|------|-----------|
| 语句 (Statements) | 80% |
| 分支 (Branches) | 75% |
| 函数 (Functions) | 80% |
| 行 (Lines) | 80% |

### 7.2 测试命名

```typescript
// ✓ 单元测试命名
describe('UserService', () => {
  describe('create', () => {
    it('should create a new user with valid data', async () => {
      // test implementation
    })

    it('should throw ValidationError when email is invalid', async () => {
      // test implementation
    })
  })
})

// ✓ E2E 测试命名
describe('User API', () => {
  describe('POST /api/users', () => {
    it('should create user and return 201', async () => {
      // test implementation
    })
  })
})
```

### 7.3 测试文件位置

```bash
# 单元测试：与源文件同目录
src/
├── user/
│   ├── user.service.ts
│   └── user.service.spec.ts

# E2E 测试：项目 test 目录
test/
├── user.e2e-spec.ts
└── jest-e2e.json
```

---

## 8. ESLint + Prettier 配置

### 8.1 .eslintrc.js

```javascript
module.exports = {
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: 'tsconfig.json',
    tsconfigRootDir: __dirname,
  },
  plugins: ['@typescript-eslint', 'prettier'],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:prettier/recommended',
  ],
  rules: {
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/no-explicit-any': 'warn',
    'no-console': 'warn',
    'prettier/prettier': 'error',
  },
}
```

### 8.2 .prettierrc

```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100,
  "bracketSpacing": true,
  "arrowParens": "avoid"
}
```
