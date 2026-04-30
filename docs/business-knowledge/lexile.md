# Lexile 分值体系知识库

## 一、项目概述

Lexile（蓝思）分值体系是一个阅读能力测评解决方案，用于评估学生的阅读水平并推荐合适的阅读内容。项目位于 `~/Documents/Projects/Areas/iplayabc-codebase/lexile/`。

### 项目结构
```
lexile/
├── lexile_test_package/     # 核心Flutter测试包
│   └── lib/
│       ├── core/           # 核心配置、网络、工具类
│       ├── features/
│       │   ├── paper/      # 测试相关（题目、答题）
│       │   ├── report/     # 报告相关（结果展示）
│       │   └── introduction/  # 介绍页
│       └── lexile_test_package.dart  # 主入口
├── lexile_bookschina/      # 书籍中国相关
└── lexile_ios/             # iOS相关
```

---

## 二、Lexile 分值体系核心概念

### 2.1 Lexile 分值（蓝思值）

- **格式**：`数字 + L`（如 `820L`）
- **范围**：0L - 2000L+
- **BR前缀**：Beginning Reader，表示初级读者（BR 200L = 0L处理）

### 2.2 分值与年级对应关系

Lexile 分值通过除以100取整映射到年级索引（0-12）：
```dart
value = value ~/ 100;  // 820L -> 8
// 上限为12
if (value > 12) value = 12;
```

| Lexile 分值 | 年级索引 | 大致年级 |
|-------------|---------|---------|
| BR-200L | 0 | 学前班 |
| 300L-500L | 3-5 | 幼儿园-小学低年级 |
| 600L-900L | 6-9 | 小学中高年级 |
| 1000L-1300L | 10-12 | 初高中 |
| 1400L-2000L | 12+ | 高中及以上 |

---

## 三、测试类型

### 3.1 词汇能力测试（LexileTest - 自适应测试）

- **特点**：根据用户答题情况自适应调整题目难度
- **配置类**：`LexileTestConfig`
- **参数**：
  - `isStrictMode`：严格模式（1-严格，0-普通）
  - `grade`：年级
  - `showLocatorOverPage`：是否显示定级结束页面

```dart
LexileTestConfig(
  isStrictMode: 1,    // 1-严格模式，0-普通模式
  grade: 3,           // 测试年级
  showLocatorOverPage: true,
  onTestResult: (result) {
    print('testId: ${result['testId']}');
    print('score: ${result['score']}');
  },
);
```

### 3.2 等级测试（LevelTest - 固定难度测试）

- **特点**：固定难度，针对特定时间点的测评
- **配置类**：`LexileLevelTestConfig`
- **参数**：
  - `testType`：测评时间点（BOY/MOY/EOY）
  - `grade`：年级（G0-G12）
  - `testLimitTime`：时间限制（毫秒）

```dart
LexileLevelTestConfig(
  testType: LexileLevelTestType.boy,  // BOY/MOY/EOY
  grade: 'G3',                         // G0-G12
  testLimitTime: 1800000,             // 30分钟
);
```

**时间点类型**：
- **BOY**（Beginning of Year）：学年初，8-9月
- **MOY**（Middle of Year）：学年中，12-1月
- **EOY**（End of Year）：学年末，5-6月

---

## 四、测试流程

### 4.1 自适应测试流程（LexileTest）

```
开始测试 → 题目1（Locator题）→ 题目2 → ... → 答对继续 ←→ 答错降级 → 结束 → 报告
```

1. **开始测试**：`POST /open/api/lexile/v1/starttest`
   - 传入 `grade` 和 `is_strict_mode`
   - 返回第一道题目

2. **提交答案**：`POST /open/api/lexile/v1/submit`
   - 传入 `test_id`、`question_id`、`user_chose`
   - 答对返回下一题，答错返回更简单题目
   - 当 `score` 字段不为空时，表示测试结束

3. **强制结束**：`POST /open/api/lexile/v1/submit/force`
   - 用于倒计时结束等场景

### 4.2 等级测试流程（LevelTest）

```
开始测试 → 固定难度题目组 → 完成所有题目 → 提交 → 报告
```

1. **开始测试**：`POST /open/api/lexile/v1/gradetest`
   - 传入 `form`（BOY/MOY/EOY）、`grade`、`test_limit_time`

2. **提交测试**：`POST /open/api/lexile/v1/gradetest/submit`
   - 传入 `test_id`、`question_id`、`user_chose`
   - 所有题目完成后返回 `score`

---

## 五、题目结构

### 5.1 题目数据模型

```dart
class Question {
  final int questionId;        // 题目ID
  final String grade;          // 年级（含"Locator"标记）
  final String? passageText;  // 阅读短文
  final QuestionItem? stem;   // 题干
  final QuestionItem? optionA; // 选项A
  final QuestionItem? optionB; // 选项B
  // ... 最多9个选项
}

class QuestionItem {
  final String? text;   // 文本内容
  final String? audio;  // 音频URL
  final String? image;  // 图片URL
}
```

### 5.2 题目类型

| 布局类型 | 说明 | 触发条件 |
|---------|------|---------|
| `PaperType.leftRight` | 左右布局（题目左，选项右） | 无图片选项 |
| `PaperType.topBottom` | 上下布局（题目上，选项下） | 任一选项包含图片 |

### 5.3 Locator 题目

- `isLocator = true` 表示这是定位题（用于确定初始难度）
- Locator 题目显示背景图片
- 连续两道非Locator题后，显示定级结束页面

---

## 六、报告数据结构

### 6.1 LexileReportModel

```dart
class LexileReportModel {
  final String score;        // 蓝思分数（格式如"820L"）
  final String testDate;    // 评测日期
  final String testType;     // 评测类型（free-自适应，grade-等级）
  final Report? report;      // 详细报告
}

class Report {
  final List<String>? lexileRange;      // 蓝思范围
  final GradePosition? gradePosition;   // 年级位置
  final String? surpassPercent;         // 超越百分比
  final DomainAnalysis? domainAnalysis; // 领域分析
}

class GradePosition {
  final String grade;  // 蓝思等级
  final String form;   // 阶段（BOY/MOY/EOY）
}

class DomainAnalysis {
  final FoundationalReading? foundationalReading;  // 基础阅读
  final ReadingForInformation? readingForInformation; // 信息类阅读
  final ReadingForLiterature? readingForLiterature;    // 文学类阅读
}
```

### 6.2 领域分析评分

每个领域有三种等级：
- **Below**：低于标准（绿色30%透明度）
- **Meets**：达到标准（绿色70%透明度）
- **Exceeds**：超越标准（绿色100%）

---

## 七、API 端点

| 方法 | 端点 | 用途 |
|------|------|------|
| POST | `/open/api/lexile/v1/starttest` | 开始自适应测试 |
| POST | `/open/api/lexile/v1/submit` | 提交自适应测试答案 |
| POST | `/open/api/lexile/v1/gradetest` | 开始等级测试 |
| POST | `/open/api/lexile/v1/gradetest/submit` | 提交等级测试答案 |
| POST | `/open/api/lexile/v1/submit/force` | 强制结束测试 |
| GET | `/open/api/lexile/v1/history` | 获取蓝思历史记录 |
| GET | `/open/api/lexile/v1/recommend/books` | 获取推荐书籍 |
| GET | `/open/api/lexile/v1/lexile/latest` | 获取最新报告 |
| GET | `/open/api/lexile/v1/lexile/{testId}/report` | 获取指定测试报告 |

---

## 八、核心类一览

### 8.1 配置类

| 类名 | 文件 | 用途 |
|------|------|------|
| `LexileConfig` | `core/config/lexile_config.dart` | 主配置类，单例模式 |
| `LexileTestConfig` | `core/config/lexile_config.dart` | 自适应测试配置 |
| `LexileLevelTestConfig` | `core/config/lexile_config.dart` | 等级测试配置 |
| `ReportConfig` | `core/config/lexile_config.dart` | 报告页配置 |

### 8.2 数据模型

| 类名 | 文件 | 用途 |
|------|------|------|
| `QuestionModel` | `features/paper/data/models/question_model.dart` | API返回题目数据 |
| `Paper` | `features/paper/domain/entities/paper.dart` | 题目领域实体 |
| `LexileReportModel` | `features/paper/data/models/lexile_report_model.dart` | 报告数据模型 |
| `ReportData` | `features/report/domain/entities/report_entities.dart` | 报告领域实体 |

### 8.3 服务类

| 类名 | 文件 | 用途 |
|------|------|------|
| `LexileTestService` | `features/paper/data/service/lexile_api_service.dart` | API服务 |
| `PaperRepositoryImpl` | `features/paper/data/repositories/paper_repository_impl.dart` | 数据仓库 |
| `ReportApiService` | `features/report/data/service/report_api_service.dart` | 报告API服务 |

### 8.4 状态管理

| 类名 | 文件 | 用途 |
|------|------|------|
| `PaperNotifier` | `features/paper/presentation/notifiers/paper_notifiers.dart` | 测试状态管理 |
| `ReportNotifier` | `features/report/presentation/notifiers/report_notifier.dart` | 报告状态管理 |
| `CountdownNotifier` | `features/paper/presentation/notifiers/countdown_notifier.dart` | 倒计时管理 |

---

## 九、使用示例

### 9.1 初始化并启动完整测试

```dart
final success = await LexileTestPackage.initialize(
  userSign: 'user_unique_id',
  appKey: 'your_app_key',
  appSecret: 'your_app_secret',
);

LexileTestPackage.updateConfig(
  testPaperConfig: LexileTestConfig(
    isStrictMode: 1,
    grade: 3,
    onTestResult: (result) {
      print('Test completed!');
      print('TestId: ${result['testId']}');
      print('Score: ${result['score']}');
    },
  ),
);

// 跳转到测试页面
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LexileTestPackage.mainTestPages(),
  ),
);
```

### 9.2 仅使用报告页

```dart
LexileTestPackage.updateConfig(
  lexileType: LexileType.report,
  reportConfig: ReportConfig(
    testId: 12345,
    onReportResult: (reportData) {
      print('Score: ${reportData.lexileMeasure?.score}');
    },
  ),
);
```

---

## 十、业务流程图

```
┌─────────────────────────────────────────────────────────────────┐
│                        用户流程                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐       │
│  │   介绍页     │ -> │   测试页     │ -> │   报告页     │       │
│  │ Introduction │    │   Paper      │    │   Report     │       │
│  └──────────────┘    └──────────────┘    └──────────────┘       │
│         │                   │                   │                │
│         v                   v                   v                │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐       │
│  │ 选择年级     │    │  答题/提交   │    │  展示结果    │       │
│  │ (可选)       │    │  自适应算法  │    │  推荐书籍    │       │
│  └──────────────┘    └──────────────┘    └──────────────┘       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      自适应算法流程                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  开始 -> 题目1(Locator) -> 答对 -> 题目2(更难) -> ...           │
│                    │                                           │
│                    答错 -> 降一级难度 -> ...                    │
│                                                                 │
│  结束条件：                                                      │
│  1. 连续答对2道非Locator题 -> 测试结束                           │
│  2. 倒计时结束 -> 强制提交                                       │
│  3. 用户主动退出                                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 十一、注意事项

1. **单例模式**：`LexileConfig` 使用单例模式，通过 `LexileConfig.getInstance()` 获取
2. **testId 管理**：测试ID通过 `LexileConfig.updateTestId()` 更新，报告页通过 `LexileConfig.currentTestId` 获取
3. **严格模式**：`isStrictMode=1` 时，测评更加严格，题目难度调整更敏感
4. **倒计时**：只有非Locator题目计时，Locator题目不受时间限制
5. **语言切换**：报告页支持中英文切换，通过 `AppTexts.setCurrentLanguage()` 设置
