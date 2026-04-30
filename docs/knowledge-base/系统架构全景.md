# iPlayABC 系统架构全景（Top-Down View）

> 生成时间: 2026-04-30
> 分析方法: 代码结构逆向 + LOC统计 + 技术栈分析
> 数据源: codebase-projects-report.json (73个项目)

---

## 一、整体规模

| 指标 | 数值 |
|------|------|
| 总项目数 | 73 |
| 总代码行数(估) | ~30,000 KLOC |
| 技术栈 | Node(42), Java(37), Flutter(32), Dart(32) |
| 活跃项目 | 60+ |
| 微服务数（jianjinjiaoyu内） | 26+ |

---

## 二、三层架构

```
┌─────────────────────────────────────────────────────────┐
│                    接入层（Client）                       │
│  Flutter App (32) │ React Web (9) │ Vue Web (11)       │
│  iOS Native (19)  │ Android (36)  │ UniApp (teach)    │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                    服务层（API）                        │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 剑津微服务体系（NestJS + NATS RPC）              │  │
│  │ jianjin-api / op / finance / user / school       │  │
│  │ jianjin-course-entitlement / lexico-assessment   │  │
│  │ game-campaign / opa / open-*                    │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 旧体系（Koa/Express 单体）                       │  │
│  │ digejiaoyu1/dige-server/teach/dpe/...           │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 独立产品线                                       │  │
│  │ haoqihao(分销) / lexile(测评) / news(内容)       │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                    数据层（Storage）                    │
│                                                          │
│  MySQL (主) ── TypeORM / 原生SQL / Koa-seq              │
│  Redis ── 缓存 / 会话 / NATS底层                        │
│  OSS/OSS兼容 ── 阿里云/自建（所有静态资源）             │
│  NATS ── 微服务间RPC（仅剑津新体系）                    │
└─────────────────────────────────────────────────────────┘
```

---

## 三、产品线地图

### 3.1 核心产品线（按代码量排序）

| 产品线 | 典型项目 | 规模 | 技术栈 | 定位 |
|--------|---------|------|--------|------|
| **剑津** | jianjinjiaoyu, jianjinxueshengduan | 4170KLOC | NestJS+Vue+Flutter | 全套教学生态 |
| **华为云教育** | huaweicloud | 2846KLOC | NestJS+Express+React | 定制大客户 |
| **新闻/内容** | news | 2244KLOC | Express+React+NestJS | 内容平台 |
| **iread系** | ireadabc_student | 1833KLOC | Flutter | 英语阅读 |
| **teach系** | teach | 1654KLOC | Koa+React+UniApp | 机构管理 |
| **dige系** | digejiaoyu1, dige, dige-server | 1194+522+504KLOC | Flutter+Koa | 英语启蒙 |
| **xueli** | xueli, xueli_flutter | 1068KLOC | React+Flutter | 雪梨App |
| **readingpartner** | readingpartner | 905KLOC | Koa+Flutter | 绘本阅读 |
| **haoqihao** | haoqihao | 452KLOC | Express+Flutter | 三级分销+电商 |
| **dpe** | dpe | 301KLOC | Koa+Vue+Flutter | 内容制作 |
| **lexile** | lexile | 111KLOC | Flutter | 阅读测评 |

### 3.2 共享基础设施

| 项目 | 作用 |
|------|------|
| `nestjs-common` | 共享库：TypeORM基类/装饰器/缓存/日志/鉴权 |
| `app-genesis` | Flutter App工厂脚手架 |
| `factory-cli` | CLI工具 |
| `smrt` | Flutter调试工具 |
| `tool` | 内部工具 |

---

## 四、模块领域划分（从 engine/ 目录看业务边界）

### digejiaoyu1/dige-manager/engine/（旧体系）
```
airclass*       ── 直播课（5个变体：通用/剑津/精英/阳光/Bricube）
application     ── APP发布管理
book_activation ── 图书激活
camp            ── 夏令营/活动
cartoon         ── 动漫内容
courseware      ── 课件管理
cps             ── ⚠️ 课件制作系统（不是分销）
digital_book    ── 数字图书
home*           ── 首页
jianjin_admin   ── 剑津管理后台
manage          ── 通用管理
mirror          ── 镜像
newstar         ── 新星
pearson_admin   ── 培生管理
question_bank   ── 题库
resource        ── 资源管理
share           ── 分享
syllabus        ── 课程大纲/产品包
template*       ── 模板
user_center     ── 用户中心
```

### jianjinjiaoyu/jianjin/engine/（剑津新体系）
```
airclass_jj       ── 剑津直播课
assessment        ── 测评
broadcast         ── 直播
campaigns         ── 活动
cps               ── 课件制作
digital_book      ── 数字图书
homework_package  ── 作业包
lexile_assessment ── Lexile测评
school_v2         ── 校区v2
template          ── 模板
user_center       ── 用户中心
```

### jianjinjiaoyu/（独立微服务，26+个）
```
jianjin-api         ── API网关
jianjin-user        ── 用户服务
jianjin-finance     ── 财务服务
jianjin-schoolyard  ── 校圈服务
jianjin-course-entitlement ── 课程授权
jianjin-schedule    ── 排课服务
jianjin-resource    ── 资源服务
lexile-assessment   ── Lexile测评服务
game-campaign       ── 游戏活动
opa                 ── 开放平台鉴权
open-*              ── 开放API系列
edu-analytics       ── 教育数据分析
content-risk-control ── 内容风控
media-sprite        ── 媒体处理
picturebook-hub     ── 绘本中心
```

---

## 五、关键发现：两代架构并存

### 旧体系（2018-2023）
- **架构**: 单体 Koa/Express
- **数据模型**: 直接操作 MySQL，大量跨库 JOIN
- **认证**: JWT，内嵌在业务代码
- **部署**: 多项目独立部署，公用 OSS
- **状态**: 仍在活跃维护，但停止新功能开发

### 新体系（2023+）- 剑津
- **架构**: 微服务 NestJS + NATS RPC
- **数据模型**: 每个服务独立 DB，通过 RPC 交互
- **认证**: 统一 OPA 服务，RPC 调用
- **部署**: 容器化，每个服务独立部署
- **状态**: 快速迭代中

### 迁移中发现的碎片化问题
```
旧: digejiaoyu1/dige-manager/engine/cps  ←→  新: jianjinjiaoyu/jianjin/engine/cps
旧: digejiaoyu1/dige-manager/engine/user_center  ←→  新: jianjin-user
旧: digejiaoyu1/dige-manager/engine/syllabus  ←→  新: jianjin-course-entitlement
旧: digejiaoyu1/dige-manager/engine/airclass  ←→  新: jianjin-schedule
```

---

## 六、缺失的框架层认知

### 6.1 没有全局视角文档
- ❌ 没有系统架构图（直到本文档）
- ❌ 没有产品线关系图
- ❌ 没有技术选型决策记录（为什么从 Koa 迁移到 NestJS？）
- ❌ 没有数据流全景图

### 6.2 没有明确的领域边界文档
- ❌ `digejiaoyu1` 到底是产品平台还是底座？
- ❌ 剑津新体系的 26 个微服务各自的职责是什么？
- ❌ `dige`（Flutter App）和 `dige-server`（Koa API）是否还维护？

### 6.3 没有基础设施文档
- ❌ OSS 域名体系和 bucket 划分（iplayabc.com 域下多少个 bucket？）
- ❌ 数据库连接配置管理（哪些项目连哪个库？）
- ❌ NATS 消息队列的 topic/queue 命名规范
- ❌ 多租户隔离机制（AppID 隔离 vs Organization 隔离）

### 6.4 产品语义层缺失
- ❌ 各产品线的目标客户是谁？（B2B机构？B2C家长？公办校？）
- ❌ 产品之间是什么关系？（雪梨和剑津共享哪些模块？）
- ❌ License/授权模型是什么？（按机构？按学生数？按功能模块？）

---

## 七、知识库文件索引

| 文件 | 范围 |
|------|------|
| 知识库-系统架构全景.md | **本文档** — 30,000ft 全视图 |
| 知识库-业务概念词汇表.md | 核心领域概念 + 产品线差异 |
| 知识库-机构账号产品数据模型.md | 旧体系 ER 图（digejiaoyu1） |
| 知识库-直播课(airclass).md | 直播课业务流程 |
| 知识库-Lexile分值体系.md | 阅读能力测评 |
| 知识库-分销系统.md | 三级分销（haoqihao） |
| 公共组件分析报告.md | 工具函数重复问题 |

---

## 八、建议下一步"见树木"的方向

按优先级排序（基于商业价值和风险）：

| 优先级 | 模块 | 为什么重要 |
|--------|------|-----------|
| P0 | **剑津微服务全图** | 26个服务，没有任何文档 |
| P0 | **账号与授权体系** | 安全风险 + 多产品线复用 |
| P1 | **Payment/支付流** | 钱的事不能糊涂 |
| P1 | ** Syllabus=产品包=License** | 商业模式核心 |
| P2 | **Content/题库/课件制作** | 内容是核心资产 |
| P2 | **教育数据分析** | edu-analytics 做什么？ |

---

*文档版本: v1.0*
*分析可信度: 高（基于代码结构统计）*
*待验证: 微服务间 RPC 调用依赖关系、AppID 多租户隔离机制*
