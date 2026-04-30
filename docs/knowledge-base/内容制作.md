# 内容制作（cps / template_ci）业务知识

## 一、CPS 是什么

**CPS = Courseware Production System = 课件制作系统**

注意：`dpe/dpe/engine/cps/` 的 CPS 不是"分销"，而是"内容制作"。

---

## 二、课件制作的核心：模板（Template）

### 2.1 概念

课件制作系统围绕 **Template（模板）** 展开：

```
Template = 一个可配置的课件"模板"
    ├── 有 Git 仓库（存放源码）
    ├── 有版本号（last_version）
    ├── 有多种题型（JM-09 = 习题模板、阅读理解等）
    └── 发布后生成可播放的 H5 页面
```

### 2.2 模板表（template）

| 字段 | 说明 |
|------|------|
| id | 主键 |
| name | 模板名称（如 `JM-09`） |
| description | 描述 |
| type | 类型：2=习题，3=...，4=... |
| developer_id | 开发者 ID |
| last_version | 最新版本号 |
| git | Git 配置（JSON，存放仓库信息） |
| play_url | 播放页路径 |
| form_url | 表单页路径 |
| publish | 是否已发布 |

---

## 三、模板制作 CI/CD 流程（template_ci）

这是整个内容制作系统最核心的部分——**自动化构建和发布**：

### 3.1 流程图

```
开发者提交"发布"请求
    ↓
创建 template_ci 记录（status_=1，pending）
    ↓
ci_factory.js 守护进程轮询
    ↓
发现 pending 任务，状态改为 2（compiling）
    ↓
从 Git 克隆模板源码
    ↓
安装依赖（npm install）
    ↓
构建（编译、打包）
    ↓
发布到 OSS（阿里云对象存储）
    ↓
状态改为 3（success）
    ↓
更新 template.last_version
    ↓
加入 org_template（授权给机构）
    ↓
异步同步到剑津（jianjin）
```

### 3.2 CI 状态机

| status_ | 名称 | 说明 |
|---------|------|------|
| 1 | Pending | 等待处理 |
| 2 | Compiling | 构建中 |
| 3 | Success | 构建成功 |
| 4 | Failed | 构建失败（超时/错误） |
| 5 | Killed | 被强制终止 |

### 3.3 关键机制

**超时保护：** 构建超过 30 分钟自动终止

**Kill 机制：** 开发者可以随时终止正在构建的任务

**日志：** 每一步都写入 Elasticsearch（`template_{name}_ci` index），可以在后台看到实时构建日志

**异步同步：** 构建成功后，异步同步到剑津平台（`staging-jianj.iteachabc.com/v1/template/sync/{name}`）

---

## 四、开发者 vs 机构

| 角色 | 表 | 操作 |
|------|------|------|
| 开发者 | template | 创建/编辑模板、发起发布 |
| 机构 | org_template | 获得模板的使用授权 |

**授权流程：**
```
模板发布成功（status_=3）
    ↓
自动写入 org_template（org_id=9，template_id=模板ID）
    ↓
机构通过 loadTemplate() 看到可用模板
    ↓
机构用模板创建 courseware / question_bank
```

---

## 五、内容制作的完整链路

```
开发者：创建模板（template）
    ↓
开发者：发起发布（template_ci → CI/CD）
    ↓
构建成功 → 模板版本更新
    ↓
授权给机构（org_template）
    ↓
机构：用模板创建 courseware（课件）
    ↓
机构：在 syllabus 中挂载 courseware
    ↓
机构：发布 syllabus
    ↓
学生：可以看到并学习这门课
```

---

## 六、gitTools：VCS 集成

template 模块还负责从 Git 拉取模板源码：

| 功能 | 说明 |
|------|------|
| clone | 克隆模板仓库 |
| checkout | 切换分支/版本 |
| install | 安装依赖 |
| build | 构建 |
| publish | 发布到 OSS |

---

## 七、缺失的信息

1. **模板市场**：是否有模板商店？开发者能否收费？
2. **题库录入的完整流程**：题目是手动录入还是批量导入？
3. **蓝思值标注**：lexile 值是谁填的？算法还是人工？
4. **课件内容如何生产**：courseware 的 data JSON 是怎么填写的？
5. **审核流程**：模板发布后需要审核吗？

---

## 八、相关文档

| 文档 | 关系 |
|------|------|
| 知识库-题库.md | 题目使用 template 模板创建 |
| 知识库-业务概念词汇表.md | template 是内容生产侧的核心概念 |

---

*分析可信度: 高（CI/CD 流程逻辑清晰，核心代码已读）*
