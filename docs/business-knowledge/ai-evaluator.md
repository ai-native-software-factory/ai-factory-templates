# AI 评测（ai_evaluator）业务知识

## 一、核心概念

AI 评测是 iPlayABC 的**口语/写作评测产品**，学生在手机上录制口语回答或上传写作，系统用 AI 自动评分。

> 关键表：`jj_ai_evaluator_active_order` — 学生 AI 评测的"钱包"

---

## 二、AI 评测的"余额"模型

AI 评测不是一次性购买，而是**余额制**：

```
学生购买 AI 评测包
    ↓
创建 jj_ai_evaluator_active_order 记录
    ↓
每种评测类型有独立余额：
  ├── speak_balance        ── 口语评测余额
  ├── write_balance        ── 写作评测余额
  ├── speak_exam_balance   ── 口语考试余额
  ├── write_correct_balance ── 写作批改余额
  └── simulated_dialogue_balance ── 模拟对话余额
    ↓
学生做评测 → 扣减对应类型的余额
```

### 充值（recharge）

| 字段 | 类型 | 说明 |
|------|------|------|
| speakAmount | int | 口语评测次数 |
| writeAmount | int | 写作评测次数 |
| speakExamAmount | int | 口语考试次数 |
| writeCorrectAmount | int | 写作批改次数 |
| simulatedDialogueAmount | int | 模拟对话次数 |

**充值规则：**
- 过期时间 = 充值时间 + 1095 天（3年）
- 每个学生同一种 level 只能有一条 active order（status=1）
- 充值 code 格式：`recharge||{userId}{timestamp}{4位随机数}`

---

## 三、AI 评测与激活码的关系

digital_book 文档提到 type=2 是"AI 激活码"，它和 AI 评测的关联：

```javascript
// 作废 AI 激活码时
case BOOK_CODE_TYPE.AI:
  // 作废激活码本身
  await mysql.run(`update jj_book_code set del=1... where ai_active_code=?`, [主码]);
  // 作废关联的 AI 评测订单
  await mysql.run(`update jj_ai_evaluator_active_order set status=-1 where code=?`, [主码]);
```

**含义：** AI 激活码激活时，系统会创建一个 `jj_ai_evaluator_active_order` 记录，用激活码作为 code。作废激活码时同时作废订单。

---

## 四、level（级别）体系

| level | 含义 | 说明 |
|-------|------|------|
| trial | 试用 | 限一次 |
| 其他 | 正式级别 | 按配置收费 |

---

## 五、充值日志

每次充值都记录日志 `jj_ai_evaluator_recharge_log`：
- 操作人（operator_id / operator_name）
- 各类余额充值数量
- 备注

---

## 六、缺失的信息

1. **AI 评分逻辑**：口语/写作的评分算法在哪里？
2. **评测流程**：学生具体如何做 AI 评测？上传什么？系统返回什么？
3. **与 Lexile 的关系**：AI 评测的结果会更新 Lexile 值吗？
4. **退款**：评测余额可以退吗？

---

## 七、相关文档

| 文档 | 关系 |
|------|------|
| 知识库-激活与授权.md | AI 激活码 type=2 关联 AI 评测订单 |
| 知识库-电子书与图书馆.md | digital_book 中有 AI 评测的作废联动 |
| 知识库-学生使用旅程.md | AI 评测是学生的学习活动之一 |

---

*分析可信度: 中（余额和充值逻辑清晰，AI 评分算法未知）*
