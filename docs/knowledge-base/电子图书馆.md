# 电子图书馆（e-library）业务知识

## 一、核心概念

e-library 是 iPlayABC 的**绘本图书馆管理后台**，管理电子绘本的内容、分类和级别。

> **核心数据：** 绘本（picture_book）+ 分类（category）+ 类型（type）+ 级别（level）

---

## 二、数据模型

### 核心表

| 表 | 说明 |
|---|---|
| factory_picture_book | 绘本基础信息（来自 factory 平台） |
| jj_picture_book | 剑津的绘本配置（关联、级别、权重、状态） |
| jj_picture_book_category | 绘本分类树 |
| jj_picture_book_type | 绘本类型 |
| jj_picture_book_level | 绘本级别定义 |
| jj_picture_book_exercises | 绘本配套练习 |

---

## 三、绘本的两层架构

| 层级 | 表 | 说明 |
|------|---|------|
| 基础层 | factory_picture_book | 绘本基础信息（来自 factory 平台共享） |
| 应用层 | jj_picture_book | 剑津的个性化配置（级别、权重、状态） |

**关联关系：**
```sql
jj_picture_book.picture_book_id → factory_picture_book.id
```

---

## 四、分类体系

### 分类表（jj_picture_book_category）

树形结构，典型的"父-子"分类：

```javascript
// 构建分类树
const buildTree = (items, pid = 0) => {
  // pid = 0 → 一级分类
  // pid = 父分类ID → 二级/三级分类
};
```

**字段：**
| 字段 | 说明 |
|------|------|
| id | 主键 |
| pid | 父分类 ID（0 = 一级分类） |
| name | 分类名称 |
| sort | 排序号 |
| status | 状态 |
| icon | 图标 |

### 多级分类查询

支持三种学段的多选分类：

```javascript
const multipleKinds = ['primary_school', 'junior_school', 'senior_school'];
```

查询时动态 JOIN 多个分类表，使用 OR 条件匹配任意一个分类。

---

## 五、类型体系（jj_picture_book_type）

| 字段 | 说明 |
|------|------|
| name | 类型名称 |
| category_ids | 关联的分类 ID 列表（逗号分隔） |
| sort | 排序号 |
| kind | 类型种类 |
| icon | 图标 |

**类型和分类是多对多关系：**
- 一个类型可以关联多个分类
- 查询时用 `FIND_IN_SET` 匹配

---

## 六、级别体系（jj_picture_book_level）

| 字段 | 说明 |
|------|------|
| name | 级别名称 |
| type | 类型（哪个维度的级别） |
| value | 级别值 |
| description | 描述 |
| sort | 排序号 |
| status | 状态 |

**约束：** 同 type 下 value 不能重复。

---

## 七、绘本配套练习（jj_picture_book_exercises）

每个绘本可以有配套练习：

| type | 名称 | 说明 |
|------|------|------|
| 1 | 跟读 | 跟读练习 |
| 2 | 听力 | 听力练习 |
| 3 | 阅读理解 | 阅读理解题 |
| 4 | 口语评测 | AI 口语评分 |

**筛选条件：** `type != 4` 时才显示（练习类型才显示，AI评测类型不显示）

---

## 八、绘本与 eLibrary 的关系

learning_camp 文档提到的 eLibrary 四模块，其内容来源就是 e-library 中的绘本：

```
电子图书馆（e-library）
  └── 绘本（picture_book）
        ├── 学单词（word）
        ├── 听绘本（listen）
        ├── 读绘本（read）
        └── 练绘本（practice）
```

---

## 九、缺失的信息

1. **factory_picture_book 的来源**：factory 平台是什么？绘本内容从哪里来？
2. **TTS（语音合成）**：tts.js 的功能是什么？用于绘本朗读？
3. **picture_book_hub**：绘本中心是什么功能？
4. **审核流程**：绘本上架需要审核吗？

---

## 十、相关文档

| 文档 | 关系 |
|------|------|
| 知识库-学习营.md | learning_camp 的 eLibrary 内容来源 |
| 知识库-打卡营.md | 旧版打卡营的 syllabus 来自 e-library |
| 知识库-电子书与图书馆.md | digital_book 的 type=6 图书馆激活码关联 e-library |

---

*分析可信度: 中（CRUD 逻辑清晰，factory 平台来源未知）*
