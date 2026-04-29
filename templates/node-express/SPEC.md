# Node Express Template

## 技术栈

- Node.js (latest)
- Express
- TypeScript
- Prisma (ORM)
- PostgreSQL

## 项目结构

```
src/
├── index.ts
├── routes/
├── controllers/
├── services/
├── middlewares/
└── utils/
```

## 开发

```bash
npm install
npm run dev    # 开发模式
npm run build  # 构建
npm start      # 生产模式
npm test
npm run lint
```

## CI/CD

GitHub Actions workflow 自动运行：
1. lint
2. type-check
3. test
