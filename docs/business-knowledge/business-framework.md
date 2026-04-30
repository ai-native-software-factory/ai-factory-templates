# iPlayABC 业务知识框架

> 生成时间: 2026-04-30
> 分析方法: 从代码中逆向提取业务逻辑
> 视角: 业务人员能看懂，业务问题驱动

---

## 一、业务全景：从业务问题出发

整个平台在回答 **5 个核心业务问题**：

```
1. 【内容】我机构要卖什么课？（Syllabus / 产品包）
2. 【授权】学生怎么拿到课的访问权？（Activation / Entitlement）
3. 【账号】谁来学？怎么管理？（User / Student / Organization）
4. 【测评】学生水平怎么样？（Lexile / Assessment）
5. 【钱】谁拿了多少钱？（Order / Commission / Finance）
```

---

## 二、五大业务领域

### 领域 1：内容与产品（ Syllabus = 产品包 = 课程大纲）

**业务含义**：Syllabus 是"产品"的基本单元。它是一棵**树**，组织课件（courseware）的结构。

**关键洞察**：
- 一个 Syllabus = 一个可销售的产品（图书、系列课程、会员）
- 树形结构是为了方便**按章节/模块**销售或赠送
- 叶子节点是具体的 courseware（视频、练习、游戏）
- `business_type` 区分内容来源：
  - `iteachabc_courseware` = 绘玩云自制内容
  - `dfzx_istudy_app` = 东方之星（爱学习）内容集成

**业务流程**：
```
运营创建 Syllabus（建树）
    ↓
挂载 courseware（装内容）
    ↓
发布上线（online_status=1）
    ↓
学生可购买/激活
```

**核心数据表**：
- `syllabus` — 树形目录（id, pid, name, org_id, business_type, online_status）
- `syllabus_book` — 封面信息（封面图、课件类型）
- `courseware` — 具体课件内容（template_name, data JSON）

---

### 领域 2：激活与授权（Activation = 访问权发放）

**业务含义**：学生付费后，如何获得课程的访问权？通过"激活码"或"直接开通"。

**关键洞察**：
- 激活码是**离线销售**场景（图书附赠、代理分销）
- 批量激活是**批量开通**场景（机构采购后给全班开通）
- 激活有**有效期**（days 字段，常见 14天试用 / 365天包年）
- 激活码格式：`{org_prefix}||{16位UUID}`（如 `dige||a1b2c3d4e5f6...`）
- 激活码可以作废（del=1），但已激活的**不追溯**——即作废后已开通的仍有效

**业务流程**：

*场景 A：图书激活（学生扫码）*
```
学生购买实体书
    ↓
刮开激活码
    ↓
扫码 / 输入激活码
    ↓
系统校验（机构prefix + 码是否存在 + 是否已用）
    ↓
开通课程 + 关联学生账号
    ↓
生成开通记录（book_code表，关联syllabus_id + user_id + 日期）
```

*场景 B：批量激活（机构操作）*
```
机构管理员选择产品（syllabus）
    ↓
输入学生手机号（或自动注册）
    ↓
批量开通，设置有效期
    ↓
系统生成激活记录
```

**核心数据表**：
- `{prefix}_book_code` — 激活码表（code, syllabus_id, user_id, days, active_date, end_date, del）
- `dongfang_products` — 机构产品授权表
- `dongfang_products_credits` — 产品账户余额

**重要业务规则**：
- `tag` 字段标记特殊销售策略（如 `buy_540` 影响有效期计算）
- 14 天试用只能激活一次（同一个 syllabus 不能重复 14 天试用）
- 激活码数量上限：一次批量最多 300 个

---

### 领域 3：账号与权限（User = 学生/教师/管理员）

**业务含义**：iPlayABC 是一个多租户 B2B 平台，账号体系必须支持**机构隔离**。

**关键洞察**：
- `user` 表：教师/管理员
- `student` 表：学生（独立账号体系，不走 user 表）
- `organization` 表：机构（客户）
- 机构有类型：个人版(1) / 标准版(2) / 专业版(3)
- 机构有业务开关：`is_course`（课件）、`is_live`（直播课）
- **学生和用户是分开的两套账号**，用 `dfzx_user_uuid` 关联

**账号层级**：
```
Organization（机构）
  ├── user（教师/管理员）
  │     └── org_user（归属关系：owner=机构owner，user=普通用户）
  └── student（学生）
        └── user_class（班级归属）
              └── classroom（班级）
                    └── school（校区）
```

**RBAC 权限体系**：
- `roles` → `roles_permission` ← `permission`
- 用户类型：admin（平台）/ org（机构）/ developer（开发者）

---

### 领域 4：测评体系（Lexile = 阅读能力分级）

**业务含义**：在让学生学习内容之前，先知道他的阅读水平在哪里。

**关键洞察**：
- Lexile 分值 = 阅读能力分值（蓝思值），格式 `数字+L`（如 `820L`）
- BR（Beginning Reader）= 初级读者，BR 200L = 0L
- 分值换算年级：除以 100 取整（820L → 8年级）
- **自适应测试**：根据答题情况动态调整难度
- **等级测试**：固定难度，按学期节点（BOY/MOY/EOY）测评
- 测试结果输出：**分值 + 领域分析**（基础阅读/信息类/文学类）

**业务流程**：
```
开始测试 → Locator定位题（快速确定起始难度）
    ↓
自适应推进（答对→更难，答错→更简单）
    ↓
连续答对2道非Locator题 → 测试结束
    ↓
生成 LexileReport（分数 + 领域得分）
    ↓
可用于内容推荐和学习路径规划
```

---

### 领域 5：财务与分销（Order + Commission）

**业务含义**：钱怎么收、分销商怎么赚。

**关键洞察**：
- `live_orders` — 直播课订单（课时包购买）
- `live_org_extension` — 机构课时余额（总课时/已用）
- `live_lessons_consume_details` — 每节课的消耗明细
- **三级分销**（haoqihao/shopro）：
  - commission_1 = 直接推荐人佣金
  - commission_2 = 上级的直接推荐人佣金
  - commission_3 = 二级推荐人的直接推荐人佣金
- 佣金结算时机：`payed`（支付后）/ `confirm`（确认收货）/ `finish`（完成）/ `admin`（手动）
- 分销商有状态机：审核中→正常→冻结/禁用/完善资料/驳回

**直播课课时消耗模型**：
```
机构购买课时 → live_org_extension（总 - 已用）
    ↓
学生上课（心跳保活，30秒一次）
    ↓
按实际上课分钟数扣减（最小计费10分钟）
    ↓
记录到 live_lessons_consume_details
```

---

## 三、产品线差异（同一套代码，不同配置）

### 直播课模块（airclass*）

| 产品 | 模块名 | 特点 |
|------|--------|------|
| 通用 | airclass | 基础版 |
| 剑津 | airclass_jj | 会话追踪、信用额控制 |
| 阳光 | airclass_imman | 订单配额管理 |
| Bricube | airclass_dfzx | 访客会话追踪 |

**差异本质**：同一个代码 fork出去，配不同的 `business_type` 和访问控制规则。

### 内容来源差异

| 来源 | business_type | 说明 |
|------|--------------|------|
| 绘玩云自制 | `iteachabc_courseware` | iPlayABC 自研 |
| 东方之星集成 | `dfzx_istudy_app` | 第三方内容接入 |

---

## 四、仍未覆盖的业务知识

以下领域在代码中存在，但本次分析**没有提取到足够业务逻辑**：

| 领域 | 模块 | 缺失原因 |
|------|------|---------|
| **题库** | question_bank | service.js 为空（实际业务可能在其他地方） |
| **内容制作** | cps（课件制作） | 已有文档但业务逻辑不清晰 |
| **游戏/活动** | camp, game-campaign | 未分析 |
| **数字图书** | digital_book | 未分析 |
| **作业/练习** | homework_package | 未分析 |
| **电子图书馆** | e-library | 未分析 |
| **财务（剑津）** | jianjin-finance | 未分析（NestJS微服务） |
| **内容风控** | content-risk-control | 未分析 |

---

## 五、已有知识库索引

| 文件 | 覆盖领域 |
|------|---------|
| 知识库-业务概念词汇表.md | 总览：核心概念 + 关系图 |
| 知识库-机构账号产品数据模型.md | 领域3：账号体系 |
| 知识库-激活与授权.md | 领域2：激活流程（本文档补充） |
| 知识库-Lexile分值体系.md | 领域4：测评 |
| 知识库-直播课(airclass).md | 领域5：直播课 |
| 知识库-分销系统.md | 领域5：三级分销 |
| 知识库-系统架构全景.md | 技术视角（可跳过） |

---

*文档版本: v1.0*
*分析可信度: 高（直接从源码提取）*
