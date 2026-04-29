# React Native Template

## 技术栈

- React Native (latest)
- TypeScript
- React Navigation
- Zustand (状态管理)

## 项目结构

```
src/
├── App.tsx
├── screens/
├── components/
├── stores/
└── utils/
```

## 开发

```bash
npm install
npm run ios    # iOS 开发
npm run android # Android 开发
npm test
npm run lint
```

## CI/CD

GitHub Actions workflow 自动运行：
1. lint
2. test
3. build:ios
4. build:android
