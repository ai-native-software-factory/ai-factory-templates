# 测评试卷（assessment）业务知识

## 一、核心概念

assessment 是 iPlayABC 的**测评试卷管理后台**，用于创建、管理定级测评和能力测评的试卷。

> **核心表：** `jj_test_paper`（试卷）+ `jj_test_paper_detail`（题目）+ `jj_test_paper_record`（学生作答记录）

---

## 二、试卷类型体系

### 测评类型（evaluating_type）

| type | 名称 | 说明 |
|------|------|------|
| LevelAssessment | 定级测评 | 确定学生当前水平 |
| AbilityAssessment | 能力测评 | 测试特定能力 |
| StarterPackAssessment | 启蒙包测评 | 面向幼儿启蒙 |

### 试卷级别（test_paper_level）

| level | 名称 | 说明 |
|-------|------|------|
| YoungLearner | 学前 | 幼儿园阶段 |
| ForSchools | 上学 | 小学及以上 |

### 测评阶段（stage）

| stage | 名称 |
|-------|------|
| FirstStage | 第一阶段 |
| SecondStage | 第二阶段 |
| ThirdStage | 第三阶段 |

---

## 三、题型（question_lib_type）

| type | 名称 | 说明 |
|------|------|------|
| singleChoice | 单选 | 四选一 |
| clozeTest | 完形填空 | 选词填空 |

### 选项类型（option_type）

| type | 名称 |
|------|------|
| text | 文字选项 |
| image | 图片选项 |

---

## 四、试卷数据结构

### 试卷主表（jj_test_paper）

| 字段 | 说明 |
|------|------|
| id | 主键 |
| test_paper_name | 试卷名称 |
| evaluating_type | 测评类型 |
| test_paper_level | 试卷级别 |
| seq | 排序号 |
| total_score | 总分 |
| del | 删除标记 |

### 题目表（jj_test_paper_detail）

| 字段 | 说明 |
|------|------|
| test_paper_id | 所属试卷 |
| question_type | 题型 |
| question_content | 题目内容（JSON） |
| options | 选项（JSON） |
| answer | 正确答案 |
| score | 分值 |
| status | 状态 |

### 作答记录表（jj_test_paper_record）

| 字段 | 说明 |
|------|------|
| id | 主键 |
| test_paper_id | 试卷 ID |
| user_id | 学生 ID |
| score | 得分 |
| create_time | 作答时间 |

---

## 五、查询学生作答情况

assessment 提供了按试卷查看学生列表的功能：

```sql
-- 学生最近一次作答
SELECT user_id, score, create_time
FROM jj_test_paper_record
WHERE test_paper_id = ? AND user_id = ?
ORDER BY create_time DESC LIMIT 1

-- 学生第一次作答
SELECT score, create_time
FROM jj_test_paper_record
WHERE test_paper_id = ? AND user_id = ?
ORDER BY create_time ASC LIMIT 1
```

**关键信息：**
- 一个学生可以多次作答同一份试卷（允许多次尝试）
- 最近一次成绩 = 当前水平
- 第一次成绩 = 进步对比

---

## 六、统计数据

| 指标 | SQL 来源 |
|------|---------|
| totalQuestions | COUNT(jj_test_paper_detail) WHERE status != 'deleted' |
| completedStudents | COUNT(DISTINCT user_id) FROM jj_test_paper_record |
| totalAttempts | COUNT(*) FROM jj_test_paper_record |

---

## 七、与 Lexile 的关系

定级测评（LevelAssessment）的结果很可能用于确定学生的 **Lexile 值**。

Lexile 文档提到：
- 测试报告生成后更新学生的 lexile_value
- 测评使用题库的随机抽题功能

这说明 assessment 和 lexile_assessment 是**同一套流程的两个阶段**：
1. assessment：管理试卷 CRUD
2. lexile_assessment：根据测评结果计算 Lexile 值

---

## 八、缺失的信息

1. **AI 批改**：口语/写作题型如何自动评分？
2. **评测流程**：学生具体如何做测评？做完后看到什么？
3. **定级算法**：LevelAssessment 的结果如何映射到 Lexile 值？
4. **试卷创建**：管理员如何创建一份新试卷？需要手动录入题目吗？
5. **与题库的集成**：试卷题目是从 question_bank 抽取还是手动录入？

---

## 九、相关文档

| 文档 | 关系 |
|------|------|
| 知识库-Lexile分值体系.md | assessment 提供测评数据，lexile_assessment 计算结果 |
| 知识库-题库.md | 测评题目来源 |
| 知识库-学生使用旅程.md | 测评是学生的学习环节之一 |

---

*分析可信度: 中（试卷 CRUD 逻辑清晰，测评流程和评分算法未知）*
