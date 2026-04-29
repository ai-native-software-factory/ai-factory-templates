# Next.js Template

## 技术栈

- Next.js 15 (App Router)
- TypeScript
- Tailwind CSS
- React Server Components

## 项目结构

```
src/
├── app/
│   ├── layout.tsx
│   ├── page.tsx
│   └── globals.css
├── components/
└── lib/
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
4. build
