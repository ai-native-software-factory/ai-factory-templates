# 电子书/绘本（digital_book）业务知识

## 一、核心概念

digital_book 模块是**电子书/绘本的管理后台**，核心功能是管理**图书馆激活码**。

> 机构可以为学生批量生成图书馆的访问激活码，学生扫码后可以访问图书馆（e-library）里的绘本内容。

---

## 二、digital_book 的本质

这个模块的 service.js 实际上**复用了 book_activation 的逻辑**——它是激活码管理系统的一个特定视图，面向"图书馆/电子书"这个场景。

核心表：`jj_book_code`（剑津的激活码表）

---

## 三、激活码类型（剑津版本）

剑津版本定义了**7种激活码类型**：

| type | 名称 | 说明 |
|------|------|------|
| 1 | 普通激活码 | 对应单个 syllabus |
| 2 | AI 激活码 | 可访问 AI 批改功能 |
| 3 | 一码通激活码 | 一个码激活多个 syllabus |
| 4 | 自定义组合激活码 | 按配置组合多个 syllabus |
| 5 | 词汇闯关激活码 | 专门用于词汇闯关产品 |
| 6 | 图书馆激活码 | 用于图书馆（e-library）产品 |
| 7 | 蓝思测评激活码 | 用于 Lexile 测评 |

---

## 四、图书馆激活码（type=6）

### 4.1 生成流程

```
管理员选择：
  - 数量（amount）
  - 有效期（days，1-30天）
  - 码类型（正式/体验）
    ↓
系统查询：
  - single_flag = '5089bbeb-0af3-4a54-a0b1-8984c75de777' 的 syllabus
    ↓
为每个 syllabus 生成一个主激活码
    ↓
返回激活码列表（每4位空格分隔，便于抄写）
    ↓
格式示例：ABCD EFGH IJKL MNOP
```

### 4.2 正式 vs 体验

| 类型 | days 限制 | 用途 |
|------|-----------|------|
| 正式 | 无限制 | 正式销售 |
| 体验 | 1-30天 | 试用/引流 |

---

## 五、一码通激活码（type=3）和自定义组合（type=4）

### 5.1 一码通（ALL_IN_ONE）

一个激活码 → 激活**多个 syllabus**

```
生成时：
  1. 创建一个主激活码（type=3，syllabus_id=0）
  2. 为每个 syllabus 生成一个子激活码（ai_active_code = 主码）
  ↓
学生激活时：
  输入主码 → 系统自动查找所有 ai_active_code = 主码的子码 → 全部激活
```

### 5.2 自定义组合（CUSTOM）

和 ALL_IN_ONE 类似，但组合方式更灵活（可能按配置决定哪些 syllabus）。

---

## 六、AI 激活码（type=2）

AI 激活码除了开通 syllabus，还有一个额外的关联：

```javascript
// 作废时
case BOOK_CODE_TYPE.AI:
  // 作废激活码本身
  await mysql.run(`update jj_book_code set del=1... where ai_active_code=?`, [主码]);
  // 作废关联的 AI 评测订单
  await mysql.run(`update jj_ai_evaluator_active_order set status=-1 where code=?`, [主码]);
```

这说明 AI 激活码和 `jj_ai_evaluator_active_order`（AI 评测激活订单）有关联。

---

## 七、权限控制

生成激活码需要特定角色：

```javascript
const isERG = admin.roles.find(item => item.code === 'ERG_TEA');
if (!admin.is_org_owner && !admin.is_principal && !isERG) {
  return ctx.body = { msg: "error", data: '无权操作' };
}
```

**有权限的角色：**
- 机构所有者（is_org_owner）
- 校长（is_principal）
- ERG 教师（ERG_TEA）

---

## 八、缺失的信息

1. **图书馆内容**：图书馆里有哪些绘本？内容从哪里来？
2. **AI 评测**：jj_ai_evaluator_active_order 是什么？AI 评测的完整流程？
3. **电子书的播放**：学生如何阅读电子书？有专门的阅读器吗？
4. **退款/作废的联动**：作废 AI 激活码会影响已激活的课程吗？

---

## 九、相关文档

| 文档 | 关系 |
|------|------|
| 知识库-激活与授权.md | digital_book 本质上是激活码管理的图书馆视图 |
| 知识库-商业模式画布.md | 激活码是商业模式的核心道具 |
| 知识库-学生使用旅程.md | 学生通过激活码访问图书馆 |

---

*分析可信度: 中（核心类型系统和生成逻辑清晰，图书馆内容来源未知）*
