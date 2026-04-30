# 题库（question_bank）业务知识

## 一、核心概念

题库（question_bank）是 iPlayABC 的**习题管理系统**，但它不是一个完整的题目录入工具——它的核心功能是：

> **根据蓝思值（Lexile）随机抽取一道习题，返回给前端展示**

这是一个**习题获取接口**，而不是题库 CRUD 系统。

---

## 二、题库的数据模型

### 核心表：question_bank

| 字段 | 说明 |
|------|------|
| id | 主键 |
| uuid | 唯一标识 |
| org_id | 所属机构（goldmall=绘玩云平台方） |
| syllabus_id | 关联的 syllabus（可为空） |
| template_name | 模板名称（如 `JM-09`） |
| content | JSON 格式的题目内容 |
| lexile | 蓝思值（题目难度） |
| source | 来源（`question_bank_add` = 手动录入） |
| tag | 标签 |
| del | 删除标记（0=正常，1=删除） |

### content 字段的结构

```json
{
  "title": "Read and tell true or false.",
  "lens": 550,
  "contents": "...文章内容...",
  "questions": [
    {
      "questionTitle": "Don't share your feelings with others.",
      "questionAnswer": 0,
      "questionExplain": "..."
    },
    {
      "questionTitle": "Before you share your feelings with others, you should focus on your feelings.",
      "questionAnswer": 1,
      "questionExplain": "..."
    }
  ]
}
```

- `questionAnswer`: 0=False, 1=True（判断题）
- `questionExplain`: 题目解析

### template 表（模板定义）

| 字段 | 说明 |
|------|------|
| name | 模板名称（如 `JM-09`） |
| description | 模板描述 |
| last_version | 最新版本号 |
| form_url | 表单页 URL |
| play_url | 播放页 URL（如 `index.html`） |
| publish | 是否发布（1=发布） |
| type | 模板类型：2=习题，3=...，4=... |

---

## 三、业务流程

### 3.1 习题录入（CRUD）

管理员在题库管理后台：
1. 选择模板（template）
2. 填写题目内容（JSON）
3. 设置蓝思值（lexile）
4. 保存

**数据流：**
```
管理员填写表单
    ↓
list.js → save() 
    ↓
INSERT into question_bank (uuid, org_id, content, template_name, source, lexile)
    ↓
题目入库，可被查询
```

### 3.2 随机抽题（核心接口）

这是题库模块最重要的功能——**按难度抽题**：

```
POST /api/question_bank/v1/goldmall/random
Body: { min_lexile: 550, max_lexile: 600, template_name: 'JM-09' }
    ↓
SELECT * FROM question_bank 
  WHERE del=0 
    AND org_id=494（goldmall）
    AND lexile BETWEEN 550 AND 600
    AND template_name='JM-09'
    ↓
随机选一条
    ↓
拼接播放 URL（OSS 域名 + 模板路径 + 版本号）
    ↓
返回题目
```

**为什么是 org_id=494？**
- 494 = `goldmall`（绘玩云平台方）
- 这个接口从平台方的题库里抽题，而不是从机构自己的题库

### 3.3 习题查询

```
GET /list（list.js → getList()）
    ↓
SELECT * FROM question_bank 
  WHERE org_id=? AND del=0
  ORDER BY lexile ASC
    ↓
返回机构自己的所有题目
```

### 3.4 模板选择

```
loadTemplate()
    ↓
SELECT * FROM template 
  WHERE publish=1 
    AND del=0 
    AND type IN (2,3,4)
    AND id IN (机构已购买的模板列表)
    ↓
返回可用模板列表
```

---

## 四、题目与蓝思值的关系

蓝思值（Lexile）是题目的核心属性：

```
lexile 值低 → 题目简单 → 适合低年级/初学者
lexile 值高 → 题目困难 → 适合高年级/进阶者
```

**用途：** 在 Lexile 自适应测试中，根据学生当前的 Lexile 水平，动态从题库里抽取对应难度的题目。

---

## 五、缺失的信息

1. **题目的完整生命周期**：谁负责录入题目？录入后的审核流程是什么？
2. **题目类型**：目前只看到 True/False 判断题，其他类型（选择题、填空题、跟读题）在哪里？
3. **蓝思值如何确定**：给定一篇文章，如何计算出它的蓝思值？是人工标注还是算法？
4. **template_name 的命名规则**：`JM-09` 是什么意思？是否有模板市场？

---

## 六、相关文档

| 文档 | 关系 |
|------|------|
| 知识库-Lexile分值体系.md | 蓝思测试依赖题库的随机抽题功能 |
| 知识库-业务概念词汇表.md | question_bank 是内容生产侧的组件 |

---

*分析可信度: 中（核心 API 逻辑清晰，但题目录入流程、审核流程未找到）*
