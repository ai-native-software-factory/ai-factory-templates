# @iplayabc/common

iPlayABC 公共工具库，消除 30+ 项目中的代码重复。

## 安装

```bash
npm install @iplayabc/common
# 或
pnpm add @iplayabc/common
```

## 模块

### `oss` — 阿里云 OSS 文件上传

```typescript
import { oss } from '@iplayabc/common';

await oss.upload('file.txt', '/local/path/file.txt');
await oss.videoUpload('video.mp4', '/local/path/video.mp4');
await oss.audioUpload('audio.mp3', '/local/path/audio.mp3');
await oss.download(['file.txt'], '/tmp/download/');
```

需提前配置环境变量：
```bash
ALIYUN_OSS_ACCESS_KEY_ID=xxx
ALIYUN_OSS_ACCESS_KEY_SECRET=xxx
ALIYUN_OSS_BUCKET=xxx
ALIYUN_OSS_REGION=oss-cn-beijing
```

### `mysql` — MySQL 查询工具

```typescript
import { mysql } from '@iplayabc/common';

const db = mysql();
const rows = await db.select('users', { status: 1 });
const user = await db.selectOne('users', { id: 1 });
const id = await db.insert('users', { name: 'test' });
await db.update('users', { name: 'updated' }, { id: 1 });
const result = await db.pager('SELECT * FROM users', [], 1, 20);
```

### `log` — 日志

```typescript
import { log } from '@iplayabc/common';

log.init('my-module');
log.info('Hello %s', 'world');
log.error(new Error('oops'));
```

### `json` — JSON 工具

```typescript
import { parseUrls, isObject, isArray } from '@iplayabc/common';

parseUrls({ url: 'https://example.com/file.mp4' }); // Set of URLs
```

### `date` — 日期工具

```typescript
import { isDuringDate } from '@iplayabc/common';

isDuringDate('2024-01-01', '2024-12-31'); // boolean
```

### `jwt` — JWT 工具

```typescript
import { jwt } from '@iplayabc/common';

const token = jwt.create({ userId: 1, role: 'admin' });
const payload = jwt.decodeToken(token);
```

需配置环境变量 `JWT_SECRET`。

## 开发

```bash
pnpm install
pnpm build    # 编译 TS
pnpm test     # 测试
pnpm lint     # ESLint
```

## 发布

```bash
pnpm publish --access public
```
