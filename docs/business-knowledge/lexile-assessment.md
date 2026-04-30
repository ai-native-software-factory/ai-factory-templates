# 蓝思测评（lexile_assessment）业务知识

## 一、核心发现：Lexile 是独立数据库

这是本次分析最重要的架构发现：

> **蓝思测评（lexile_assessment）有自己独立的数据库**，与剑津（jianjin）主数据库完全隔离。

```
剑津主数据库（jianjin）
  └── jj_book_code
  └── jj_user
  └── jj_syllabus
       ↓ 蓝思激活码（type=7）关联
       ↓
lexile_assessment 数据库（独立）
  └── jj_lexile_activation_order  ── 蓝思激活订单
  └── jj_lexile_assessment_report  ── 测评报告
```

**影响：**
- 蓝思的测评数据不在剑津主库
- 蓝思的激活码虽然存在 `jj_book_code`（type=7），但激活后的行为在另一个库
- 两套系统通过 `activation_code` 字段关联

---

## 二、蓝思测评激活码

### 关键常量

| 常量 | 值 | 说明 |
|------|---|------|
| LEXILE_SYLLABUS_ID | 130141 | 蓝思测评专属 syllabus |
| LEXILE_TYPE | 7 | 激活码类型（7=蓝思测评） |
| MAX_GENERATE_COUNT | 50,000 | 单机构最大生成数量 |

### 生成规则

```javascript
// 批量生成
batchGeneratedLexile({ amount, days, codeKind })
    ↓
校验：days 必须等于 365
    ↓
校验：amount ≤ 剩余可生成数（50,000 - 已生成数）
    ↓
为每个码生成 UUID（16位）
    ↓
格式：jj||{UUID}（如 jj||a1b2c3d4e5f6g7h8）
    ↓
显示格式：XXXX XXXX XXXX XXXX XXXX（每4位空格分隔）
```

**约束：**
- 单次生成上限：50,000 个
- 总上限：50,000 个（所有机构共享）
- 有效期：固定 365 天

### 权限控制

和 digital_book 一样：
- 机构所有者（is_org_owner）
- 校长（is_principal）
- ERG 教师（ERG_TEA）

---

## 三、激活订单（jj_lexile_activation_order）

| 字段 | 说明 |
|------|------|
| activation_code | 激活码 |
| status | 订单状态 |
| allowed_count | 允许测评次数 |
| remaining_count | 剩余测评次数 |
| current_round | 当前轮次 |
| last_assessment_at | 最近测评时间 |

**测评次数模型：**
- 一个蓝思激活码有 `allowed_count` 次测评机会
- 每次测评扣减 `remaining_count`
- 用完后需要重新激活（或其他方式补充次数）

---

## 四、测评报告（jj_lexile_assessment_report）

| 字段 | 说明 |
|------|------|
| activation_id | 关联的激活订单 ID |
| user_id | 学生 ID |
| test_date | 测评日期 |
| score | 得分 |
| lexile_range | Lexile 值范围 |
| grade | 年级 |
| status | 状态（COMPLETED=已完成） |

---

## 五、完整流程

```
1. 机构批量生成蓝思激活码（type=7）
    ↓
2. 学生获得激活码，扫码激活
    ↓
3. 系统在 lexile_assessment 库创建激活订单（allowed_count = ?）
    ↓
4. 学生开始蓝思测评
    ↓
5. 每完成一轮测评：
    - remaining_count - 1
    - current_round + 1
    - 生成 jj_lexile_assessment_report
    ↓
6. 测评结果：
    - score（分数）
    - lexile_range（蓝思值范围）
    - grade（对应年级）
    ↓
7. 测评结果是否更新学生的 lexile_value？代码中未找到
```

---

## 六、与旧版 Lexile 的关系

旧版 dige-manager 中的 lexile 模块（`digejiaoyu1/dige-manager/engine/lexile/`）是**旧版实现**，而 `jianjin/engine/lexile_assessment/` 是**剑津版本的实现**。

两者的关键区别：
- 旧版：蓝思值计算在主库
- 新版（剑津）：蓝思测评在独立库，测评数据与主库隔离

---

## 七、缺失的信息

1. **测评算法**：蓝思值（lexile_range）是如何计算的？输入是什么？
2. **allowed_count**：每次激活给多少次测评机会？
3. **lexile_value 更新**：测评结果会回写到学生的 lexile_value 字段吗？回写的逻辑在哪里？
4. **跨库关联**：剑津主库如何获取蓝思测评结果？（是通过 user_id 关联查询，还是有同步机制？）
5. **与题库的关系**：蓝思测评使用题库的随机抽题吗？用的是哪套题库？

---

## 八、相关文档

| 文档 | 关系 |
|------|------|
| 知识库-Lexile分值体系.md | 需要更新：Lexile 是独立数据库架构 |
| 知识库-电子书与图书馆.md | type=7 激活码是蓝思测评激活码 |
| 知识库-激活与授权.md | 蓝思激活码走的是标准激活流程 |

---

*分析可信度: 高（service.js 逻辑清晰，跨库关联是关键架构发现）*
