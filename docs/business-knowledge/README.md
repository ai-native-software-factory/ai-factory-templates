# 业务知识库索引

本文档集包含 iPlayABC 产品的核心业务知识，**从代码逆向提取**，非占位符模板。

> ⚠️ 本文档集描述的是实际代码中的业务逻辑，商业条款（价格、账期等）不在代码中，请与运营团队核对。

---

## 业务知识 (Business Knowledge)

| 文档 | 描述 | 可信度 |
|------|------|--------|
| [business-model.md](./business-model.md) | **必读**：谁给谁钱、激活码作为商业道具 | 低-中 |
| [student-journey.md](./student-journey.md) | **必读**：学生视角的端到端流程 | 中 |
| [concept-glossary.md](./concept-glossary.md) | **索引**：所有核心业务概念总表 | 高 |
| [account-model.md](./account-model.md) | 完整 ER 图：机构-账号-产品关系 | 高 |
| [activation.md](./activation.md) | 激活码体系：扫码激活 vs 批量开通 | 高 |
| [live-class.md](./live-class.md) | 直播课：订单→课时包→消耗→对账 | 高 |
| [lexile-assessment.md](./lexile-assessment.md) | 蓝思值自适应测评体系 | 高 |
| [distribution.md](./distribution.md) | 三级分销：佣金体系与结算 | 高 |
| [homework.md](./homework.md) | 作业系统：布置→完成→AI批改 | 中 |
| [finance.md](./finance.md) | 财务对账：新旧两套体系 | 中 |
| [question-bank.md](./question-bank.md) | 题库：按蓝思值随机抽题 | 中 |
| [content-production.md](./content-production.md) | 模板 CI/CD：内容制作流程 | 高 |
| [camp.md](./camp.md) | 打卡营：周期学习活动 | 中 |
| [digital-library.md](./digital-library.md) | 图书馆/电子书激活码 | 中 |

## 参考文档

| 文档 | 描述 | 受众 |
|------|------|------|
| [business-framework.md](./business-framework.md) | 业务知识框架（5个核心问题驱动） | 技术团队 |
| [system-overview.md](./system-overview.md) | 系统架构全景（技术视角） | 技术团队 |

---

## 五大核心业务问题

学习顺序建议从这5个问题开始：

1. **内容**：机构要卖什么课？（Syllabus / Package / Courseware）
2. **授权**：学生怎么拿到课的访问权？（Activation / Entitlement）
3. **账号**：谁来学？怎么管理？（User / Student / Organization）
4. **测评**：学生水平怎么样？（Lexile / Assessment）
5. **钱**：谁拿了多少？（Order / Commission / Finance）

---

## 文档贡献指南

- 所有文档从代码逆向提取，标注**分析可信度**
- 缺失的商业信息（定价、账期等）在每个文档末尾列出
- 文档语言：中文；英文术语首次出现时标注原文

---

*最后更新: 2026-04-30*
*分析方法: 代码逆向 + service.js 逻辑抽取*
