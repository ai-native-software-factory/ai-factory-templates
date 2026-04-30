# iPlayABC 业务概念词汇表 & 关系图谱

> 生成时间: 2026-04-30
> 数据来源: 代码库逆向分析（lexile/、digejiaoyu1/、haoqihao/）

---

## 一、核心实体一览

```
Platform（平台）
  └── Organization（机构）— 客户单位，如"雪梨教育"、"剑津"
        ├── user（用户账号）— 管理员/教师
        │     └── org_user（归属关系：owner/user）
        ├── student（学生账号）
        │     └── user_class（班级归属）
        ├── school（校区）
        │     └── classroom（班级）
        ├── syllabus（课程大纲/产品包）
        │     └── courseware（课件内容）
        ├── dongfang_products（机构产品授权）
        │     └── dongfang_products_credits（产品余额）
        ├── live_org_extension（直播课时余额）
        └── [License/授权配置]
```

---

## 二、核心概念解释

### 2.1 机构与产品层级

#### Organization（机构）
| 字段 | 说明 |
|------|------|
| org_type | 1=个人版，2=标准版，3=专业版 |
| is_course | 是否开通课件业务 |
| is_live | 是否开通直播课业务 |
| is_customized | 是否定制客户 |
| status_ | 0=停用，1=启用，2=试用 |

**业务含义**: 机构是 iPlayABC 的最高计费/授权单元。每个机构有独立的域名、品牌定制、课程内容、课时余额。

#### Syllabus（课程大纲/产品包）
**也叫**: Package、课程树

 Syllabus 是将 courseware（课件）组织成树形结构的目录系统。一个 Syllabus 代表一个完整的产品/课程体系，学生购买后获得浏览权限。

关键字段：
- `business_type`: `iteachabc_courseware`（绘玩云平台课件）| `dfzx_istudy_app`（东方之星爱学习APP）
- `online_status`: 发布状态
- `detail_id`: 关联具体的课件内容

#### Courseware（课件）
**也叫**: 数字内容、学习材料

 Syllabus 的叶子节点是具体的课件内容，支持多种模板（游戏、阅读、练习等）。

---

### 2.2 账号体系

#### user（用户账号）
| 类型 | user_type | 说明 |
|------|-----------|------|
| 平台管理员 | admin | 超级管理员 |
| 机构用户 | org | 机构管理员或教师 |
| 模板开发者 | developer | 开发课程模板 |

#### student（学生账号）
学生账号与机构、学校、班级关联。学生通过家长手机号注册，由机构/班级管理员分配。

#### 账号归属关系
```
org_user表: user_id → org_id（owner=机构拥有者，user=普通用户）
user_class表: user_id → class_id（班级归属）
```

---

### 2.3 Lexile 分值体系（阅读能力测评）

#### 什么是 Lexile 分值
- **格式**: `数字 + L`（如 `820L`）
- **范围**: 0L ~ 2000L+
- **BR前缀**: Beginning Reader，初级读者（BR 200L = 0L）
- **到年级**: `lexile_value ~/ 100` 取整

#### Lexile 分值与年级对照
| 分值范围 | 年级索引 | 大致年级 |
|---------|---------|---------|
| BR-200L | 0 | 学前班 |
| 300L-500L | 3-5 | 幼儿园-小学低年级 |
| 600L-900L | 6-9 | 小学中高年级 |
| 1000L-1300L | 10-12 | 初高中 |
| 1400L-2000L | 12+ | 高中及以上 |

#### 两种测试类型
1. **LexileTest（自适应测试）**: 根据答题情况动态调整难度，Locator定位算法，连续答对2道非Locator题结束
2. **LevelTest（等级测试）**: 固定难度，按时间点测评（BOY/MOY/EOY）

#### 核心 API
- `POST /open/api/lexile/v1/starttest` — 开始自适应测试
- `POST /open/api/lexile/v1/submit` — 提交答案
- `POST /open/api/lexile/v1/gradetest` — 开始等级测试

---

### 2.4 直播课（AirClass）

#### 模块变体（同一套代码，不同配置）
| 模块 | 客户 | 特点 |
|------|------|------|
| airclass | 通用 | 基础版本 |
| airclass_jj | 剑津教育 | 完整版：会话追踪、信用额控制 |
| airclass_elite | 专业版 | 支持课件分配给老师 |
| airclass_imman | 阳光全阅读 | 订单配额管理 |
| airclass_dfzx | Bricube | 东方之星课件集成 |

#### 课时消耗模型
```
机构购买课时 → live_org_extension（总课时/已用课时）
                │
                └── live_lessons_consume_details（每节课消耗明细）
                     └── 最小计费单位：10分钟/课时
```

#### 访问控制
- 访客心跳保活（`dongfang_syllabus_visits`，30秒间隔）
- 并发数量控制
- 试用课程判定
- 账户余额检查

---

### 2.5 三级分销系统（Shopro Commission）

#### 分销商状态机
```
审核中(0) → 正常(1) → 冻结(2)
              ↓
           禁用(3) / 完善资料(4) / 审核驳回(5)
```

#### 三级佣金结构
| 层级 | 受益人 | 触发条件 |
|------|--------|---------|
| commission_1 | 直接推荐人 | 买家首次购买 |
| commission_2 | 上级的直接推荐人 | 买家首次购买 |
| commission_3 | 二级推荐人的直接推荐人 | 买家首次购买 |

#### 佣金结算时机
- `payed`: 支付后
- `confirm`: 确认收货后
- `finish`: 订单完成后
- `admin`: 手动打款

#### 核心数据表
- `shopro_commission_agent` — 分销商
- `shopro_commission_agent_level` — 分销等级配置
- `shopro_commission_order` — 分销订单
- `shopro_commission_reward` — 佣金明细
- `shopro_commission_goods` — 分销商品

---

## 三、关键业务关系图

### 3.1 机构-校区-班级-学生 层级
```
Organization（机构）
  └── School（校区）
        └── Classroom（班级）
              └── Student（学生）
```

> 注意：student 和 user 是两套独立的账号体系：
> - user: 教师/管理员账号
> - student: 学生账号

### 3.2 内容分发模型
```
Syllabus（课程大纲/产品包）
  ├── SyllabusBook（封面信息）
  └── Courseware（课件内容）
        └── UserSyllabus（专业版：课件分配给教师）
```

### 3.3 直播课业务流
```
机构开通直播 → 购买课时包 → live_org_extension 余额
                        ↓
               排课（syllabus + schedule）
                        ↓
               学生上课 → live_lessons_consume_details
                        ↓
               课时消耗扣减（每10分钟计1课时）
```

### 3.4 分销裂变模型
```
分销商A（level_1）
  └── 分销商B（level_2）— parent: A
        └── 分销商C（level_3）— parent: B
              └── 买家X
                   ├── A拿一级佣金
                   ├── B拿二级佣金
                   └── A拿三级佣金（因为A是B的上级）
```

---

## 四、产品线差异速查

| 产品 | 特点 | 关键模块 |
|------|------|---------|
| 雪梨 | B2C为主 | user_center, courseware |
| 阳光 | B2B阅读 | airclass_imman, school管理 |
| 剑津 | 全套教学生态 | airclass_jj, game-campaign, OPA鉴权 |
| 凯狮 | 定制客户 | is_customized=true, 独立部署 |
| 廖氏英语 | 新项目 | 基于剑津fork定制 |

---

## 五、待补充的业务知识

以下模块在本次逆向分析中未覆盖，需要进一步挖掘：

| 模块 | 优先级 | 说明 |
|------|--------|------|
| book_activation（图书激活） | 高 | 激活码体系，客户感知最强 |
| question_bank（题库） | 高 | 题目录入、审核、上架流程 |
| CPS（资源制作系统） | 中 | 注意：这是"课件制作系统"，不是分销 |
| digital_book（数字图书） | 中 | 电子书阅读器相关 |
| camp（夏令营） | 低 | 活动营销 |
| cps分销（haoqihao） | 中 | 三级分销完整逻辑 |

---

## 六、知识库文件索引

| 文件 | 内容 | 相关文档 |
|------|------|---------|
| 知识库-商业模式画布.md | **必读**：谁给谁钱、激活码作为商业道具 | 激活与授权、直播课 |
| 知识库-学生使用旅程.md | **必读**：学生视角的端到端流程 | 激活与授权、作业 |
| 知识库-Lexile分值体系.md | 蓝思阅读能力测评详细逻辑 | 学生使用旅程 |
| 知识库-机构账号产品数据模型.md | 完整 ER 图和数据表结构 | 商业模式画布 |
| 知识库-激活与授权.md | 激活码完整业务流程 | 商业模式画布、学生使用旅程 |
| 知识库-直播课(airclass).md | 直播课业务流程详解 | 商业模式画布 |
| 知识库-分销系统.md | 三级分销完整逻辑 | 商业模式画布 |
| 知识库-作业与练习.md | 作业布置与完成流程 | 学生使用旅程 |
| 知识库-财务与对账.md | 财务对账模块 | 商业模式画布 |

---

*文档版本: v1.1（加入商业模式 + 学生视角 + 交叉引用）*
*分析工具: 代码逆向 + 知识抽取*
*可信度: 中（商业条款不在代码中，需与运营团队核对）*
