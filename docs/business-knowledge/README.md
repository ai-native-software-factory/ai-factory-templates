# 业务知识库

> iPlayABC 产品业务知识，基于代码逆向提取。

## 索引

### 必读

| 文档 | 描述 | 可信度 |
|------|--------|--------|
| [business-model.md](./business-model.md) | **B2B2C 商业模式**：谁给谁钱、激活码作为商业道具 | 中 |
| [student-journey.md](./student-journey.md) | **学生全旅程**：App → 学习 → 作业 → 完成 | 中 |

### 核心业务域

| 文档 | 描述 | 可信度 |
|------|--------|--------|
| [account-model.md](./account-model.md) | 机构-账号-产品 ER 图 | 高 |
| [activation.md](./activation.md) | 激活码体系 + 7种类型 | 高 |
| [live-class.md](./live-class.md) | 直播课：课时包→消耗→对账 | 高 |
| [lexile-assessment.md](./lexile-assessment.md) | **重大发现**：Lexile 独立数据库架构 | 高 |
| [lexile.md](./lexile-assessment.md) | 蓝思自适应测评算法 | 高 |
| [distribution.md](./distribution.md) | 三级分销佣金体系 | 高 |
| [ai-evaluator.md](./ai-evaluator.md) | AI 评测余额制 | 中 |
| [homework.md](./homework.md) | 两套作业系统 | 中 |
| [finance.md](./finance.md) | 新旧两套财务体系 | 中 |

### 内容与产品

| 文档 | 描述 | 可信度 |
|------|--------|--------|
| [question-bank.md](./question-bank.md) | 按蓝思值随机抽题 | 中 |
| [content-production.md](./content-production.md) | 模板 CI/CD 流水线 | 高 |
| [assessment-papers.md](./assessment-papers.md) | 测评试卷 CRUD | 中 |
| [learning-camp.md](./learning-camp.md) | 新版学习营（stage 机制） | 中 |
| [camp.md](./camp.md) | 旧版打卡营 | 中 |
| [e-library.md](./e-library.md) | 绘本分类/级别体系 | 中 |
| [digital-library.md](./digital-library.md) | 激活码类型详解 | 中 |

### 用户与账号

| 文档 | 描述 | 可信度 |
|------|--------|--------|
| [user-center.md](./user-center.md) | 邀请 + 访客追踪 | 中 |

### 参考

| 文档 | 描述 | 受众 |
|------|--------|------|
| [concept-glossary.md](./concept-glossary.md) | 核心概念总表 + 文件索引 | 所有 |
| [business-framework.md](./business-framework.md) | 5个核心业务问题 | 技术团队 |
| [system-overview.md](./system-overview.md) | 技术架构（技术视角） | 技术团队 |

---

## 五大核心业务问题

1. **内容**：机构要卖什么课？（Syllabus / Package / Courseware）
2. **授权**：学生怎么拿到课？（Activation / Entitlement）
3. **账号**：谁来学？怎么管？（User / Student / Organization）
4. **测评**：学生水平怎么样？（Lexile / Assessment）
5. **钱**：谁拿了多少？（Order / Commission / Finance）

---

*分析工具: 代码逆向*
*可信度: 高=直接读源码，中=逻辑推断*
