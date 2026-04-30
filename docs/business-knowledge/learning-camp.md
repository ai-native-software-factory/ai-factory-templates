# 学习营（learning_camp）业务知识

## 一、核心概念

learning_camp 是剑津版本的**学习营产品**，比旧版 camp（打卡营）功能更丰富。

> **核心数据结构：** 学习营 → 阶段（Stage）→ 课件/图书馆内容
>
> 和旧版 camp 的关键区别：camp 用 syllabus 做每日解锁，learning_camp 用 stage 做阶段性学习。

---

## 二、与旧版 camp 的区别

| 特性 | 旧版 camp（tiger_clockincamp） | 新版 learning_camp（jj_learning_camp） |
|------|------------------------------|--------------------------------------|
| 粒度 | 天（day） | 阶段（stage） |
| 内容 | syllabus（图书） | courseware / eLibrary 混合 |
| 灵活性 | 每天一本图书 | 每个阶段可配置多个课件 |
| 权限控制 | 无 | 有 kind（pro/test）区分 |
| 课件粒度 | syllabus 级别 | 可细化到 courseware 内部（课件-ID-index） |

---

## 三、数据模型

### 3.1 学习营主表（jj_learning_camp）

| 字段 | 说明 |
|------|------|
| id | 主键 |
| name | 名称 |
| cover | 封面图 |
| status | 状态：1=未开始，2=进行中，3=已结束 |
| kind | 类型：pro=正式，test=测试 |
| duration | 总时长（天） |
| frequency | 频率（天/次） |
| description | 描述 |
| creator_id | 创建者 |

### 3.2 阶段表（jj_learning_camp_stage）

| 字段 | 说明 |
|------|------|
| id | 主键 |
| learning_camp_id | 关联的学习营 |
| number | 阶段序号（1, 2, 3...） |
| name | 阶段名称（如"第1阶段"） |
| courseware_list | 逗号分隔的内容ID列表 |
| status | 状态：1=未开始，2=进行中，3=已完成 |

---

## 四、阶段内容的三种类型

learning_camp 的内容有**三种类型**，通过 `courseware_list` 的 ID 前缀区分：

### 类型 1：课件级（courseware）
```
格式：{coursewareId}-{index}
示例：12345-3

含义：courseware ID = 12345，index = 3（第3个小节）
```

### 类型 2：课纲级（syllabus）
```
格式：{syllabusId}
示例：67890

含义：整个 syllabus 作为一个学习单元
```

### 类型 3：图书馆绘本（eLibrary）
```
格式：library:{pictureBookId}
示例：library:12345

含义：整本绘本作为一个学习单元
```

---

## 五、eLibrary 的四模块结构

eLibrary（电子图书馆）有**固定的四模块结构**，每个绘本包含：

| 模块 ID 后缀 | 名称 | 说明 |
|-------------|------|------|
| -word | 学单词 | 单词学习 |
| -listen | 听绘本 | 听音频 |
| -read | 读绘本 | 跟读练习 |
| -practice | 练绘本 | 课后练习 |

**数据结构：**
```javascript
pictureBookDefaultModules = [
  { id: `library:${pictureBookId}-word`, name: '学单词' },
  { id: `library:${pictureBookId}-listen`, name: '听绘本' },
  { id: `library:${pictureBookId}-read`, name: '读绘本' },
  { id: `library:${pictureBookId}-practice`, name: '练绘本' },
];
```

---

## 六、内容来源的 single_flag

learning_camp 从 syllabus 中筛选内容时，使用 **single_flag** 过滤：

| single_flag | 内容类型 |
|-------------|---------|
| `e34a9829-00ff-407e-9dc1-bfc07d3144c2` | 视频课 |
| `16c7f3b0-4c97-44ce-b61e-1eff7cb4648b` | 预组装 |
| `58e1f1ee-25e7-4ddc-8ff8-8e621847f70b` | 互动专区 |
| `5089bbeb-0af3-4a54-a0b1-8984c75de777` | 图书馆 |
| `30e48169-e3c6-4fae-a6d8-1c4abd71d4ad` | 音视频 |

---

## 七、kind：pro vs test

learning_camp 有 `kind` 字段区分两种类型：

| kind | 含义 | 可见范围 |
|------|------|---------|
| pro | 正式学习营 | 所有角色可见 |
| test | 测试学习营 | 仅机构所有者 + LCA 角色可见 |

---

## 八、业务流程

### 8.1 创建学习营

```
1. 填写名称、封面、描述
2. 设置 duration（总天数）和 frequency（几天一次）
3. 系统自动计算 stage 数量 = duration / frequency
4. 创建 jj_learning_camp + N 个 jj_learning_camp_stage
```

### 8.2 配置阶段内容

```
管理员为每个 stage 选择内容
    ↓
选择 syllabus / courseware / eLibrary
    ↓
保存到 jj_learning_camp_stage.courseware_list
    ↓
学生进入学习营时看到阶段 + 内容
```

### 8.3 上传封面

```
管理员上传图片
    ↓
保存到 OSS
    ↓
返回 URL
```

---

## 九、缺失的信息

1. **学生加入机制**：学生如何加入学习营？需要激活码吗？
2. **进度追踪**：学生完成 stage 后如何判定？是否有完成记录？
3. **kind=test 的用途**：测试学习营用于什么场景？内部测试？
4. **与打卡营的关系**：learning_camp 和旧版 camp 是并存还是替代关系？
5. **与 syllabus 的关系**：learning_camp 是否依赖 syllabus 作为内容容器？

---

## 十、相关文档

| 文档 | 关系 |
|------|------|
| 知识库-打卡营.md | 旧版 camp，learning_camp 是其升级版 |
| 知识库-电子书与图书馆.md | eLibrary 是 learning_camp 的内容来源之一 |
| 知识库-业务概念词汇表.md | learning_camp 是一种产品形态 |

---

*分析可信度: 中（数据结构清晰，学生的学习流程未知）*
