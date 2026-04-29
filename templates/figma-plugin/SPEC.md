# Figma Plugin Template

## 技术栈

- Figma Plugin SDK
- React 19
- TypeScript
- Vite

## 项目结构

```
src/
├── code.ts         # Figma 插件主代码
├── ui.tsx          # React UI
└── styles.css
```

## 开发

```bash
npm install
npm run dev    # 开发模式（watch + build）
npm run build  # 构建发布版本
npm test
npm run lint
```

## CI/CD

GitHub Actions workflow 自动运行：
1. lint
2. test
3. build:plugin

## 发布

构建后的文件在 `dist/` 目录，可直接上传到 Figma。
