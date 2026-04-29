# @iplayabc/nestjs-common

iPlayABC NestJS 公共模块库，提供 Database、Cache、Logger、Auth、Health、Remote 模块。

## 安装

```bash
npm install @iplayabc/nestjs-common
# 或
pnpm add @iplayabc/nestjs-common
```

需要 peerDependencies：

```bash
npm install @nestjs/common @nestjs/core @nestjs/typeorm typeorm ioredis passport passport-jwt
```

## 模块

### Database — TypeORM Repository 模块

```typescript
// app.module.ts
import { DatabaseModule } from '@iplayabc/nestjs-common/database';

@Module({
  imports: [
    DatabaseModule.forRoot({
      type: 'mysql',
      host: process.env.DB_HOST,
      port: Number(process.env.DB_PORT || 3306),
      username: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      entities: [__dirname + '/**/*.entity{.ts,.js}'],
      synchronize: false,
    }),
  ],
})
export class AppModule {}
```

### Cache — Redis 缓存模块

```typescript
// app.module.ts
import { CacheModule } from '@iplayabc/nestjs-common/cache';

@Module({
  imports: [
    CacheModule.forRoot({
      host: process.env.REDIS_HOST || 'localhost',
      port: Number(process.env.REDIS_PORT || 6379),
      password: process.env.REDIS_PASSWORD,
      db: Number(process.env.REDIS_DB || 0),
    }),
  ],
})
export class AppModule {}
```

### Logger — Pino 日志模块

```typescript
// app.module.ts
import { LoggerModule } from '@iplayabc/nestjs-common/logger';

@Module({
  imports: [
    LoggerModule.forRoot({
      level: process.env.LOG_LEVEL || 'info',
      prettyPrint: process.env.NODE_ENV !== 'production',
    }),
  ],
})
export class AppModule {}
```

### Auth — JWT 认证 Guard

```typescript
// main.ts
import { JwtAuthGuard } from '@iplayabc/nestjs-common/auth';

app.useGlobalGuards(new JwtAuthGuard());
```

### Health — 健康检查模块

```typescript
// app.module.ts
import { HealthModule } from '@iplayabc/nestjs-common/health';

@Module({
  imports: [HealthModule],
})
export class AppModule {}
```

访问 `GET /health` 查看健康状态。

## 开发

```bash
pnpm install
pnpm build
pnpm test
pnpm lint
```

## 发布

```bash
pnpm publish --access public
```
