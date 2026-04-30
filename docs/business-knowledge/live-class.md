# 直播课(AirClass)业务知识库

## 1. 模块概述

### 1.1 模块定位
AirClass是iPlayABC在线教育平台的直播课/在线教室模块，支持多租户（机构/学校）场景下的课件浏览、在线授课、课时购买与消耗管理。

### 1.2 模块变体
| 模块名 | 标题 | 特点 |
|--------|------|------|
| airclass | 在线教室 | 基础版本 |
| airclass_jj | 剑津教育 | 完整版：会话追踪、信用额控制 |
| airclass_elite | 在线教室 | 专业版：支持课件分配给老师 |
| airclass_imman | 阳光全阅读课件 | 订单配额管理（imman_orders） |
| airclass_dfzx | Bricube | 东方之星课件集成、访客会话追踪 |

### 1.3 核心业务常量
```javascript
// common/constants.js
BUSINESS_TYPE: {
  ITEACHABC_COURSEWARE: 'iteachabc_courseware', // 云平台课件
  DFZX_ISTUDY_APP: 'dfzx_istudy_app', // 东方之星爱学习APP结构树
}
```

---

## 2. 核心数据模型

### 2.1 课件相关表

#### syllabus（课程大纲表）
```sql
CREATE TABLE `syllabus` (
  `id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `pid` INT(11) DEFAULT NULL,           -- 父节点ID
  `has_child` VARCHAR(2) DEFAULT NULL,   -- 是否有子节点：0没有，1有
  `root` VARCHAR(2) DEFAULT NULL,        -- 是否根节点：0不是，1是
  `seq` INT(11) DEFAULT NULL,           -- 排序号
  `name` VARCHAR(255) DEFAULT NULL,      -- 名称
  `description` VARCHAR(1000) DEFAULT NULL,
  `depth` INT(11) DEFAULT NULL,          -- 深度
  `org_id` INT(11) DEFAULT NULL,         -- 所属机构
  `has_courseware` INT(11) DEFAULT NULL, -- 是否存在课件：1是，0否
  `detail` VARCHAR(255) DEFAULT NULL,    -- 大纲明细表名
  `detail_id` INT(11) DEFAULT NULL,      -- 大纲明细ID
  `business_type` VARCHAR(64) NOT NULL DEFAULT 'iteachabc_courseware',
  `online_status` TINYINT(1) DEFAULT 0,  -- 发布状态
  `del` INT(11) DEFAULT 0                -- 是否删除
);
```

#### syllabus_book（课件封面表）
```sql
CREATE TABLE `syllabus_book` (
  `id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `syllabus_pid` INT(11) NOT NULL,
  `cover` VARCHAR(255) DEFAULT NULL,      -- 封面图
  `cw_type` INT(11) DEFAULT NULL        -- 课件类型
);
```

#### courseware（课件内容表）
```sql
-- 关键字段
`course_id` INT(11) NOT NULL,           -- 关联syllabus.id
`template_name` VARCHAR(255),             -- 模板名称
`data` JSON,                            -- 课件数据
`seq` INT(11) DEFAULT NULL,             -- 排序
`del` TINYINT(1) DEFAULT 0
```

#### user_syllabus（用户课件分配表-专业版）
```sql
CREATE TABLE `user_syllabus` (
  `user_id` INT(11),
  `syllabus_id` INT(11),
  ...
);
```

### 2.2 直播课相关表

#### live_org_extension（机构课时余额表）
```sql
CREATE TABLE `live_org_extension` (
  `id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `org_id` INT(11) DEFAULT NULL,         -- 机构ID
  `all_lessons` INT(11) DEFAULT 0,       -- 总课时
  `used_lessons` INT(11) DEFAULT 0,     -- 已用课时
  `free_trial` TIMESTAMP,                -- 免费试用期截止
  `createon` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### live_lessons_consume_details（课时消耗明细）
```sql
CREATE TABLE `live_lessons_consume_details` (
  `id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `date_key` CHAR(10),                   -- 日期如'2020-03-31'
  `org_id` INT(11),
  `user_id` INT(11),
  `user_name` VARCHAR(255),
  `phone` CHAR(11),
  `class_id` INT(11),
  `class_name` VARCHAR(255),
  `teacher_id` INT(11),
  `teacher_name` VARCHAR(255),
  `start` TIMESTAMP,
  `end` TIMESTAMP,
  `lessons` INT(11) NOT NULL             -- 本次消耗课时数
);
```

#### live_orders（直播订单表）
```sql
CREATE TABLE `live_orders` (
  `id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `org_id` INT(11),
  `product_id` INT(11) NOT NULL,
  `commission` INT(11) DEFAULT 0,        -- 分成比例（最大值100）
  `channel_id` INT(11) DEFAULT 0,        -- 渠道ID
  `total_price` INT(11),                 -- 总价（分）
  `total_lessons` INT(11),               -- 总课时
  `unit_price` INT(11),                  -- 单价
  `status` SMALLINT(6),                  -- 0:None, 1:未支付, 2:已支付, 3:过期, 4:转入退款, 5:已关闭, 6:已撤销, 7:用户支付中, 8:支付失败
  `is_manual` TINYINT(1) DEFAULT 0,      -- 是否人工补录
  `out_trade_no` CHAR(32),              -- 外部订单号
  `product_content` JSON,               -- 产品内容
  `prepay_id` VARCHAR(50),
  `wx_open_id` VARCHAR(50),
  `wx_transaction_id` VARCHAR(50),
  ...
);
```

#### live_channels（渠道表）
```sql
CREATE TABLE `live_channels` (
  `id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(255),
  `phone` CHAR(11),
  `ref_code` VARCHAR(255) UNIQUE,        -- 渠道推荐码
  `free_days` INT(11),                  -- 免费体验天数
  `validity_days` INT(11),              -- 有效期天数
  `commission` INT(11)                  -- 分成比例
);
```

#### live_products（直播产品表）
```sql
CREATE TABLE `live_products` (
  `id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `price` INT(11),                      -- 价格（分）
  `unit_price` INT(11),                 -- 单课时价格（分）
  `quantity` INT(11),                   -- 课时数
  `info` TEXT                           -- 描述
);
```

### 2.3 订单配额表（imman版本）

#### imman_orders（阳光全阅读订单）
```sql
CREATE TABLE `imman_orders` (
  `id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `out_trade_no` CHAR(32),
  `user_id` INT(11) NOT NULL,
  `school_id` INT(11) NOT NULL,
  `items` JSON,                         -- 购买项目 {"syllabus_id": {"id": xxx, "name": "xxx", "number": n}}
  `price` DECIMAL(10,2),
  `real_price` DECIMAL(10,2),
  `status` TINYINT(1),                 -- 0:None, 1:未支付, 2:已支付, 3:过期...
  `expired` DATETIME,                   -- 过期时间
  `transaction_id` VARCHAR(50),         -- 微信订单号
  `openid` VARCHAR(50),
  ...
);
```

### 2.4 访客会话表（JJ/DFZX版本）

#### dongfang_syllabus_visits（课件访问会话）
```sql
CREATE TABLE `dongfang_syllabus_visits` (
  `id` INT(11) PRIMARY KEY AUTO_INCREMENT,
  `session_id` VARCHAR(255) NOT NULL,    -- 浏览器TAB的SessionStorageID
  `user_name` VARCHAR(255),
  `org_id` INT(11),
  `user_id` INT(11),
  `school_id` INT(11),
  `syllabus_id` INT(11),                 -- 当前访问的课件
  `current_notify_at` TIMESTAMP,
  `next_notify_at` TIMESTAMP,            -- 心跳过期时间
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 3. 业务核心流程

### 3.1 课件浏览与进入教室

#### 教师端流程（airclass_jj/dfzx）
```
1. 教师登录 → 进入课件列表页（getList）
2. 选择课程体系（Super_Safari/Hello_Baby/Power_Up/Level_Up等）
3. 点击课件进入教室（enterClassroom）
4. 系统检查用户是否可访问（_checkUserCanAccess）
   - 检查用户角色（管理员直通过）
   - 检查是否试用课程（isForTrial）
   - 检查账户余额（dongfang_products_credits）
   - 检查并发会话数是否超限
5. 渲染教室页面（preview.ejs）
```

#### 访问控制核心逻辑（_checkUserCanAccess）
```javascript
// 检查逻辑
1. 管理员 -> 直接通过
2. 试用课程 -> 直接通过（isForTrial返回true）
3. 免费文件夹(OPEN_FOLDER/OPEN_FOLDER_2) -> 直接通过
4. 检查dongfang_products_credits余额
5. 检查当前在线会话数 < 账户余额
6. 通过则创建会话记录
```

#### 试用课程判定规则（isForTrial）
```javascript
// 试用条件：
- Super Safari/Hello Baby/Level Up/Power Up系列的前几个单元
- 以"*"开头的公开课
- 免费文件夹内的课程
```

### 3.2 课时购买与消耗

#### 购买流程
```
1. 机构管理员在后台选择直播产品（live_products）
2. 生成订单（live_orders），状态=1（未支付）
3. 唤起微信支付
4. 微信支付回调：
   - 验证签名和金额
   - 更新订单状态为2（已支付）
   - 更新live_org_extension表（增加all_lessons）
5. 机构获得对应课时
```

#### 课时消耗流程（finishFn）
```
1. 直播课结束，前端调用 /live_management/api/classroom/finish
2. 计算本次消耗课时数：
   - 每位学生：如果上课时长 >= minThreshold(默认10分钟)，至少消耗1课时
   - 每超过lessonUnit(30分钟)，额外增加1课时
3. 批量写入live_lessons_consume_details
4. 更新live_org_extension：
   - all_lessons -= 本次消耗
   - used_lessons += 本次消耗
5. 写入live_org_lessons_history（日表）
```

#### 课时计算公式
```javascript
// constants.js
LESSON_MINUTES = 30;        // 每课时标准时长
LESSON_MIN_THRESHOLD = 10;  // 最小上课时长才能计课时

// 计算逻辑
if (学生上课时长 >= LESSON_MIN_THRESHOLD) {
  let lessons = 1;  // 至少1课时
  if (上课时长 > LESSON_MINUTES) {
    lessons += Math.floor((上课时长 - LESSON_MINUTES) / 60);
  }
}
```

### 3.3 机构直播权限判断（canUseLive）
```javascript
// utils.js - canUseLive
async function canUseLive(org_id) {
  const org = await db.selectOne('live_org_extension', { org_id });
  const now = new Date();
  if (!org) return false;
  // 免费试用期内 或 有余额课时
  return org.free_trial > now || org.all_lessons > 0;
}
```

---

## 4. 核心API接口

### 4.1 AirClass模块

#### 获取课件列表
```
GET/POST /airclass/service?method=getList
Params: { pid?: number, isdfcourse?: boolean }
Return: { msg: "success", rows: [...] }
```

#### 进入教室
```
POST /airclass/service?method=enterClassroom
Params: { syllabusId, syllabus_sub_id, cw_id }
Return: { msg: "success", data: { content: HTML } }
```

#### 获取课件详情
```
POST /airclass/service?method=getCoursewareData
Params: { id: courseware_id }
Return: { msg: "success", data: {...} }
```

#### 获取课件列表（JJ版本）
```
POST /airclass_jj/service?method=getList
POST /airclass_jj/service?method=getOutterList  // 按类型获取
Params: { type: 'Super_Safari' | 'Hello_Baby' | 'Power_Up' | 'Level_Up' }
```

#### 专业版课件分配检查（Elite版本）
```javascript
// getList中判断用户是否能看到某个课件
if (needAssign(user)) {
  // 专业版机构内部的老师需看到不同的课件
  // 检查user_syllabus是否分配了该课件或其父级/子级
}
```

### 4.2 Live Management模块

#### 微信支付回调
```
POST /live_management/api/pay/wechat/notify
处理微信支付结果通知
```

#### Ping++支付回调
```
POST /live_management/api/pay/pingpp/notify
处理Ping++支付结果通知
```

#### 直播课结束
```
POST /live_management/api/classroom/finish
Body: {
  class_id: number,
  uid: number,           // 老师ID
  time: number,          // 课程总时长（毫秒）
  students: [
    { uid: number, time: number },  // 各学生时长
    ...
  ]
}
```

#### 检查能否进入直播
```
GET/POST /live_management/api/check
Header: { token: jwt }
Return: { code: 200, msg: "success" } | { code: 500, msg: "error" }
```

### 4.3 渠道管理API

#### 获取渠道列表
```
POST /live_management/service?method=getChannelList
Return: { msg: "success", rows: [...], total: number }
```

#### 添加/编辑渠道
```
POST /live_management/service?method=addChannel
Body: { id?, name, phone, free_days, validity_days, commission }
```

#### 删除渠道
```
POST /live_management/service?method=deleteChannel
Body: { id }
```

---

## 5. 前端页面

### 5.1 教室页面（preview.ejs）
- 画板工具：drawing board, palette, eraser, whiteboard
- 课件展示区
- 教师/学生端区分
- 心跳保活机制（dongfang_syllabus_visits）

### 5.2 课件列表页（index.ejs）
- 树形/矩阵视图切换
- 课程分类标签（Super_Safari等）
- 课件封面展示
- 购买状态/试用状态标识

---

## 6. 关键业务规则

### 6.1 并发控制（airclass_jj/dfzx）
- 机构购买的课件账户数 = dongfang_products_credits中有效账户之和
- 同时在线会话数 < 账户数
- 超出限制时提示"已达到所购使用数量，xxx正在使用"

### 6.2 试用课程规则
- 每个课程系列有指定的试用单元（如Unit Hello, Unit 1, Unit 5）
- 试用单元无需购买即可访问
- 试用判断基于课件名称

### 6.3 免费文件夹
```javascript
const OPEN_FOLDER = 16831;      // 节日庆祝文件夹
const OPEN_FOLDER_2 = 54571;    // 第二个免费文件夹
const OPEN_FOLDER_NAMES = [
  "Horray趣味英语活动",
  "Phonics自然拼读课程",
  "Polly陪你过暑假",
  "Polly陪你过寒假",
  "西方节庆活动方案",
  "六一演出剧目",
  "招生示范课"
];
```

### 6.4 渠道分成
- 渠道在创建时设定commission比例（0-100）
- 用户通过渠道链接注册，订单按渠道分成
- 管理员可人工补录课时（is_manual=1）

---

## 7. 配置文件

### 7.1 模块配置（setting.js）
```javascript
module.exports = {
  socketio: false,                    // 是否开启长连接
  header: '/airclass/web/header.ejs', // 个性化头部模板
  title: '在线教室',                  // 页面标题
};
```

### 7.2 课时常量（live_management/src/constants.js）
```javascript
const LESSON_MINUTES = 30;         // 每课时30分钟
const LESSON_MIN_THRESHOLD = 10;   // 最小10分钟才能计课时
```

---

## 8. 技术栈

- **后端框架**: Koa.js
- **模板引擎**: EJS
- **数据库**: MySQL
- **缓存/会话**: SessionStorage (前端), dongfang_syllabus_visits (后端)
- **支付**: 微信支付, Ping++
- **日志**: ElasticSearch (ESUtils)
- **存储**: OSS (ossTools)

---

## 9. 业务术语

| 术语 | 说明 |
|------|------|
| syllabus | 课程大纲/目录树 |
| courseware | 课件内容 |
| dongfang_products_credits | 东方之星产品账户余额 |
| live_org_extension | 机构直播课时扩展表 |
| dongfang_syllabus_visits | 课件访问会话表（心跳保活） |
| isForTrial | 判定是否为试用课程 |
| credit | 账户数/信用额 |
| channel | 销售渠道 |
| commission | 分成比例 |

---

## 10. 数据库索引

### 关键索引
```sql
-- live_org_extension
UNIQUE KEY `org_id` (`org_id`)

-- live_orders
UNIQUE KEY `prepay_id` (`preprep_id`)
UNIQUE KEY `out_trade_no` (`out_trade_no`)

-- live_channels
UNIQUE KEY `ref_code` (`ref_code`)

-- live_org_lessons_history
UNIQUE KEY `org_id` (`org_id`, `date_key`)

-- live_user_credits
UNIQUE KEY `date_key` (`date_key`, `user_id`)

-- dongfang_syllabus_visits
KEY `session_id` ... WHERE next_notify_at > NOW()
```
