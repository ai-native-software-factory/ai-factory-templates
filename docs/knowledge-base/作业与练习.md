# 作业/练习（Homework）业务知识

## 一、核心概念

iPlayABC 有**两套**作业/练习系统，分别在不同产品线中：

| 产品 | 系统 | 说明 |
|------|------|------|
| 剑津 | homework_package | 作业包管理（CRUD） |
| 阅读伙伴 | emahomework | 完整作业流程（布置→学生完成→AI批改） |

---

## 二、作业包系统（homework_package — 剑津）

### 2.1 数据模型

```
jj_homework_package（作业包）
  └── jj_homework_sub_package（子作业包）
        └── content（JSON，包含 sectors 列表）
              └── sector
                    └── coursewareList（课件列表）
```

### 2.2 作业包类型（type）

| type | 名称 | 包含模块 |
|------|------|---------|
| 1 | 家庭版-今日作业 | 图书馆 + 互动专区 + 视频课程 |
| 2 | 校园版-今日作业 | 图书馆 + 互动专区 |
| 3 | 家庭版-陪跑营 | 图书馆 + 互动专区 + 视频课程 + 音视频 |
| 4 | 校园版-陪跑营 | 图书馆 + 互动专区 + 音视频 |

**Sector 概念**：每个 sector 是一个内容区域（图书馆/互动专区/视频课程），每个 sector 下有具体的 coursewareList。

### 2.3 作业包 CRUD

- **创建/编辑**：设置名称、类型、状态
- **复制**：一键复制整个作业包（包括所有子包）
- **删除**：逻辑删除（status=0）
- **子包管理**：每个子包有独立 content（JSON），记录该模块下的课件

---

## 三、完整作业流程（emahomework — 阅读伙伴）

这是更完整的作业系统，核心流程：

```
教师布置作业
    ↓
选择课程（从 syllabus 树选）
    ↓
选择学生（按班级选）
    ↓
设置发送方式
    ↓
生成学生作业明细（ema_homework_student_detail）
    ↓
学生完成作业
    ↓
AI批改（部分类型支持）
    ↓
成绩/反馈
```

### 3.1 发送方式（send_type）

| send_type | 名称 | 说明 |
|-----------|------|------|
| 1 | 周期发送 | 按周几重复（如每周一三五） |
| 其他 | 一次性发送 | 在指定日期发送所有课程 |

### 3.2 作业类型（homework_type）

| 类型 | tag | 说明 |
|------|-----|------|
| mc | mc_main/mc_image/mc_explain | 跟读练习（主练习/图片/讲解） |
| ques | - | 问答 |
| listen | - | 听力 |
| word | - | 单词 |
| cartoon | - | 动漫 |
| video | - | 视频 |

### 3.3 学生作业状态

- **进行中**：未完成且未到期
- **逾期未完成**：未完成但已到期
- **已完成**：已完成（无论是否到期）

### 3.4 核心数据表

| 表名 | 说明 |
|------|------|
| ema_homework | 作业主记录 |
| ema_homework_classes | 作业关联的班级 |
| ema_homework_student_detail | 每个学生的作业明细（包含完成状态、成绩） |

### 3.5 AI批改

支持 AI 自动批改的作业类型：
- `mc`（跟读练习）：学生上传音频，系统评分

不支持 AI 批改的类型：`ques`, `listen`, `word`, `cartoon`, `video`, `mc_main`, `mc_image`, `mc_explain`

---

## 四、关键业务规则

### 4.1 作业创建时的数据展开

当教师选择了 N 个课程 + M 个学生时，系统会展开生成 N×M 条学生作业明细记录，每条记录包含：
- homework_id
- class_id
- student_id
- syllabus_id
- send_date
- end_date
- owner_type（1=机构拥有/2=教师布置）

### 4.2 周期发送逻辑

- 根据配置的"周几发送"（week_send），计算每个发送日
- 每次发送日创建当天的作业明细
- 结束日期按周结算（周日为一周结束）

### 4.3 mc（跟读）专题处理

mc 类型有特殊的子结构：
- `mc_main`：主跟读内容
- `mc_image`：图片题
- `mc_explain`：讲解题

这三个子标签在数据库中存储为 syllabus 的 tag 字段。

---

## 五、缺失的内容

以下业务逻辑**没有在代码中找到足够信息**：

1. **题目来源**：题库（question_bank）的 service.js 是空的，题目从哪里录入？
2. **审核流程**：作业布置后需要审核吗？
3. **作业与课程的关系**：homework_package 和 syllabus 的关系是什么？作业是 syllabus 的叶子节点吗？
4. **完成判定**：学生做了什么算"完成"？是否需要看完视频/做完练习/答对题？

---

## 六、核心 API（emahomework）

| 方法 | 路径 | 用途 |
|------|------|------|
| POST /api/homework/create | 创建作业 | 选择课程+学生+发送方式 |
| GET /api/homework/list | 作业列表 | 分页筛选 |
| GET /api/homework/detail/:id | 作业详情 | 含学生完成情况 |
| POST /api/homework/submit | 提交作业 | 学生完成作业 |
| GET /api/homework/student/list | 学生作业列表 | 按状态筛选 |

---

*分析可信度: 中（基于代码推断，部分业务规则需要实际用户验证）*
