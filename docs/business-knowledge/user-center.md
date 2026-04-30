# 用户中心（user_center）业务知识

## 一、核心概念

user_center 是 iPlayABC 的**用户个人中心**，主要功能是：
1. **邀请记录**：我邀请了谁注册
2. **访问记录**：谁看过了我分享的课件

---

## 二、邀请功能（invite.js）

### 邀请流程

```
用户 A 分享邀请链接
    ↓
用户 B 通过链接注册
    ↓
系统记录 user_invite（邀请关系）
    ↓
用户 A 的邀请列表显示用户 B
```

### 邀请表（user_invite）

| 字段 | 说明 |
|------|------|
| invite_user_id | 邀请人 ID（用户 A） |
| user_id | 被邀请人 ID（用户 B） |
| created_date | 邀请时间 |

### 邀请链接生成

```javascript
// 使用 XOR 混淆用户 ID + 时间戳
inviteUrl = common.xorConvert(`${user.id}.${parseInt(Date.now() / 1000)}`);
```

**安全机制：** 链接中不直接暴露用户 ID，使用 XOR 编码，防止伪造。

### 查询邀请列表

```sql
SELECT u.created_date, u.phone
FROM user_invite ui
LEFT JOIN user u ON ui.user_id = u.id
WHERE ui.invite_user_id = ?
ORDER BY created_date
```

**隐私处理：** 手机号脱敏显示（`138****1234`）

---

## 三、访问记录（visits.js）

### 课件访客追踪

这是一个**社交发现**功能——用户分享自己的课件后，可以看到谁看过：

```
用户 A 分享了某个课件链接
    ↓
用户 B 访问了（通过 cookie 记录 visited_shared_cw）
    ↓
系统写入 courseware_visitor 表
    ↓
用户 A 看到：谁访问了我的课件
```

### 访客表（courseware_visitor）

| 字段 | 说明 |
|------|------|
| looker_id | 访问者 ID |
| course_id | 被访问的课件/大纲 ID |
| course_owner_id | 课件所有者 ID |
| reviews | 访问次数（重复访问累加） |

### 访问计数逻辑

```sql
INSERT INTO courseware_visitor (looker_id, course_id, course_owner_id)
VALUES (...)
ON DUPLICATE KEY UPDATE reviews = reviews + 1
```

**关键点：** 同一个人多次访问同一个课件，reviews 累加而不是创建多条记录。

### 查询我的访客

```sql
SELECT sb.id, sb.name, cv.course_owner_id, cv.updateon, u.phone
FROM syllabus sb
LEFT JOIN courseware_visitor cv ON sb.id = cv.course_id
LEFT JOIN user u ON u.id = cv.course_owner_id
WHERE looker_id = ?  -- 只看"我"访问过的
ORDER BY cv.updateon DESC
```

---

## 四、与分销的区别

user_center 的邀请和分销系统的邀请**不是同一套**：

| 功能 | 模块 | 表 |
|------|------|---|
| 用户邀请（社交） | user_center | user_invite |
| 分销商邀请（商业） | shopro_commission | shopro_agent |

user_center 的邀请更像是"社交分享"，没有佣金逻辑。

---

## 五、缺失的信息

1. **邀请奖励**：邀请用户注册后，邀请人有什么好处？（目前代码只记录关系，没有奖励逻辑）
2. **访问通知**：课件所有者能否收到访问通知？
3. **隐私控制**：被访问者能看到访问者的哪些信息？只有手机号脱敏？

---

## 六、相关文档

| 文档 | 关系 |
|------|------|
| 知识库-分销系统.md | 分销的邀请（shopro_agent）是另一套体系 |
| 知识库-业务概念词汇表.md | user 是账号体系的一部分 |
| 知识库-商业模式画布.md | 邀请是获客渠道之一，但没有佣金逻辑 |

---

*分析可信度: 中（功能逻辑清晰，邀请奖励机制未知）*
