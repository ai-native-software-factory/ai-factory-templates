# iPlayABC 机构-账号-产品数据模型

## 概述

本文档描述 iPlayABC（绘玩云平台）系统中机构、账号（用户）、产品三大核心数据模型及其之间的关系。

---

## 一、机构 (Organization)

机构是 iPlayABC 平台的核心实体，代表使用平台的教育组织（如学校、培训机构、教育集团）。

### 1.1 数据表结构

**表名: `organization`**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INT | 主键，自增 |
| `uuid` | VARCHAR(64) | 唯一标识符 |
| `name` | VARCHAR(255) | 机构名称 |
| `description` | VARCHAR(1000) | 机构描述 |
| `is_customized` | INT | 是否定制客户：1=定制客户，其他=非定制 |
| `org_type` | INT | 机构类型：1=个人版，2=标准版，3=专业版 |
| `is_course` | INT | 是否有课件业务 |
| `is_live` | INT | 是否有直播课业务 |
| `status_` | INT | 机构状态：0=停用，1=启用，2=试用 |
| `probation` | INT | 试用期限（天） |
| `channel` | VARCHAR(255) | 推荐渠道 |
| `org_airclass` | VARCHAR(255) | 自定义教室模块 |
| `org_logo` | VARCHAR(255) | 机构自定义Logo |
| `org_login_bgimage` | VARCHAR(255) | 机构自定义登录页背景图 |
| `org_login_bgcolor` | VARCHAR(255) | 机构自定义登录页背景色 |
| `org_client_name` | VARCHAR(255) | 机构自定义客户端名称 |
| `org_domain` | VARCHAR(255) | 机构自定义域名 |
| `created_date` | DATETIME | 创建时间 |
| `updated_date` | DATETIME | 更新时间 |

### 1.2 机构类型说明

- **个人版 (org_type=1)**: 面向个人用户
- **标准版 (org_type=2)**: 面向普通机构用户（默认）
- **专业版 (org_type=3)**: 面向大型机构，支持更多定制功能

### 1.3 业务标志

- `is_course`: 标识机构是否开通课件业务
- `is_live`: 标识机构是否开通直播课业务
- `is_customized`: 标识是否为定制客户

---

## 二、账号体系

iPlayABC 采用多层次账号体系，区分不同角色和用途。

### 2.1 用户表 (user)

**表名: `user`**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INT | 主键 |
| `uuid` | VARCHAR(64) | 唯一标识符 |
| `username` | VARCHAR(255) | 用户名 |
| `phone` | VARCHAR(32) | 手机号（登录账号） |
| `password` | VARCHAR(255) | 密码（加密存储） |
| `solt` | VARCHAR(255) | 盐值 |
| `nick_name` | VARCHAR(255) | 昵称 |
| `user_type` | VARCHAR(255) | 用户类型：admin/org/developer |
| `org_id` | INT | 所属机构ID |
| `school_id` | INT | 所属学校ID（可选） |
| `class_id` | INT | 所属班级ID（可选） |
| `git_user_id` | INT | 关联的Git用户ID（开发者账号） |
| `dfzx_user_uuid` | VARCHAR(64) | 东方之星用户中心关联ID |
| `del` | INT | 是否删除：0=未删除，1=已删除 |
| `created_date` | DATETIME | 创建时间 |
| `updated_date` | DATETIME | 更新时间 |

### 2.2 用户类型 (user_type)

- **admin**: 超级管理员（平台级别）
- **org**: 机构用户（机构管理员或教师）
- **developer**: 模板开发者

### 2.3 学生表 (student)

**表名: `student`**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INT | 主键 |
| `uuid` | VARCHAR(64) | 唯一标识符 |
| `phone` | VARCHAR(32) | 手机号 |
| `password` | VARCHAR(255) | 密码 |
| `solt` | VARCHAR(255) | 盐值 |
| `nick_name` | VARCHAR(255) | 昵称 |
| `org_id` | INT | 所属机构ID |
| `school_id` | INT | 所属学校ID |
| `class_id` | INT | 所属班级ID |
| `dfzx_inclass_status` | INT | 东方之星学生自主注册加班状态：0=未允许，1=已允许 |
| `dfzx_user_uuid` | VARCHAR(64) | 关联东方之星用户ID |
| `del` | INT | 是否删除 |
| `created_date` | DATETIME | 创建时间 |
| `updated_date` | DATETIME | 更新时间 |

### 2.4 机构用户关系表 (org_user)

**表名: `org_user`**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INT | 主键 |
| `user_id` | INT | 用户ID |
| `org_id` | INT | 机构ID |
| `org_type` | VARCHAR(255) | 用户在机构中的角色：owner=机构拥有者，user=机构用户 |

### 2.5 用户班级关系表 (user_class)

**表名: `user_class`**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INT | 主键 |
| `user_id` | INT | 用户ID |
| `class_id` | INT | 班级ID |
| `org_id` | INT | 机构ID |

### 2.6 角色表 (roles)

**表名: `roles`**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INT | 主键 |
| `code` | VARCHAR(64) | 角色代码 |
| `name` | VARCHAR(255) | 角色名称 |
| `description` | VARCHAR(1000) | 描述 |
| `r_type` | VARCHAR(32) | 角色类型：predefine=预定义，customize=自定义 |
| `enter_url` | VARCHAR(255) | 首页路径 |
| `org_id` | INT | 所属机构（自定义角色归属） |
| `del` | INT | 是否删除 |

#### 预定义角色示例

| code | name | 说明 |
|------|------|------|
| TEACHER | 教师 | 全局教师角色 |
| ERG_TEA | 教研 | 课件制作团队 |
| DFZX_TEACHER | 教师-东方之星 | 东方之星机构教师 |
| GK_TEACHER | 教师-广锴 | 广锴机构教师 |

### 2.7 权限表 (permission)

**表名: `permission`**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INT | 主键 |
| `code` | VARCHAR(255) | 权限代码 |
| `name` | VARCHAR(255) | 权限名称 |
| `description` | VARCHAR(1000) | 描述 |
| `module_name` | VARCHAR(255) | 所属模块名称 |
| `module_router` | VARCHAR(255) | 模块路由 |
| `methods` | VARCHAR(255) | 可访问的方法（逗号分隔） |
| `del` | INT | 是否删除 |

### 2.8 用户权限关系表 (user_permission)

**表名: `user_permission`**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INT | 主键 |
| `user_id` | INT | 用户ID |
| `permission_id` | INT | 权限ID |

### 2.9 用户角色关系表 (user_roles)

**表名: `user_roles`**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INT | 主键 |
| `user_id` | INT | 用户ID |
| `role_id` | INT | 角色ID |

### 2.10 角色权限关系表 (roles_permission)

**表名: `roles_permission`**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INT | 主键 |
| `role_id` | INT | 角色ID |
| `permission_id` | INT | 权限ID |

---

## 三、校区与班级

### 3.1 学校/校区表 (school)

**表名: `school`**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INT | 主键 |
| `uuid` | VARCHAR(64) | 唯一标识符 |
| `name` | VARCHAR(255) | 学校名称 |
| `description` | VARCHAR(1000) | 描述 |
| `org_id` | INT | 所属机构ID |
| `address` | TEXT | 学校地址 |
| `allow_buy` | TINYINT | 是否允许购买 |
| `s_type` | INT | 学校类型：1=直营校，2=加盟校 |
| `s_status` | INT | 状态：0=待审核，1=启用，2=停用，3=审核不通过 |
| `del` | INT | 是否删除：0=未删除，1=删除 |
| `end_date` | DATETIME | 结束日期 |
| `created_date` | DATETIME | 创建时间 |
| `updated_date` | DATETIME | 更新时间 |

### 3.2 班级表 (classroom)

**表名: `classroom`**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INT | 主键 |
| `uuid` | VARCHAR(64) | 唯一标识符 |
| `name` | VARCHAR(255) | 班级名称 |
| `grade` | VARCHAR(255) | 年级 |
| `school_id` | INT | 所属学校ID |
| `org_id` | INT | 所属机构ID |
| `auto_allow` | INT | 是否允许学生自动加入：0=不允许，1=允许 |
| `jc_id` | INT | 关联教材ID（对应syllabus的ID） |
| `jc_arr` | VARCHAR(255) | 关联教材ID列表（逗号分隔） |
| `del` | INT | 是否删除 |
| `created_date` | DATETIME | 创建时间 |
| `updated_date` | DATETIME | 更新时间 |

---

## 四、产品与教材体系

### 4.1 教学大纲/课程体系表 (syllabus)

**表名: `syllabus`**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INT | 主键 |
| `pid` | INT | 父节点ID |
| `has_child` | VARCHAR(2) | 是否有子节点：0=没有，1=有 |
| `root` | VARCHAR(2) | 是否根节点：0=不是，1=是 |
| `seq` | INT | 排序号 |
| `name` | VARCHAR(255) | 名称 |
| `description` | VARCHAR(1000) | 描述 |
| `depth` | INT | 深度/层级 |
| `org_id` | INT | 所属机构 |
| `has_courseware` | INT | 是否存在课件：1=是，0=否 |
| `detail` | VARCHAR(255) | 大纲明细表名称 |
| `detail_id` | INT | 大纲明细ID |
| `business_type` | VARCHAR(64) | 业务类型：iteachabc_courseware/dfzx_istudy_app |
| `online_status` | TINYINT | 发布状态 |
| `source` | VARCHAR(255) | 数据来源 |
| `sid` | INT | 原始ID |
| `created_date` | TIMESTAMP | 创建时间 |
| `updated_date` | TIMESTAMP | 更新时间 |
| `del` | INT | 是否删除 |

### 4.2 课件表 (courseware)

**表名: `courseware`**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INT | 主键 |
| `uuid` | VARCHAR(255) | 唯一标识符 |
| `course_id` | INT | 所属课程ID |
| `name` | VARCHAR(255) | 课件名称 |
| `discription` | VARCHAR(1000) | 描述 |
| `tip` | VARCHAR(8000) | 提示信息 |
| `cw_cover` | VARCHAR(255) | 课件封面 |
| `template_id` | INT | 模板ID |
| `template_name` | VARCHAR(255) | 模板名称 |
| `template_version` | INT | 模板版本 |
| `data` | TEXT | 课件数据（JSON结构） |
| `developer_id` | INT | 课件制作者 |
| `seq` | INT | 顺序 |
| `del` | INT | 是否删除 |

### 4.3 机构产品表 (dongfang_products)

**表名: `dongfang_products`**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INT | 主键 |
| `name` | VARCHAR(255) | 课程名称 |
| `price` | INT | 总价 |
| `days` | INT | 可用天数 |
| `org_id` | INT | 关联机构ID |
| `syllabus_id` | INT | 关联根教学大纲ID |
| `created_at` | TIMESTAMP | 创建时间 |
| `updated_at` | TIMESTAMP | 更新时间 |

### 4.4 产品账户余额表 (dongfang_products_credits)

**表名: `dongfang_products_credits`**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INT | 主键 |
| `name` | VARCHAR(255) | 课程名称 |
| `user_id` | INT | 下单人ID |
| `school_id` | INT | 下单学校ID |
| `syllabus_id` | INT | 教学大纲ID |
| `dongfang_product_id` | INT | 东方之星产品ID |
| `org_id` | INT | 关联机构ID |
| `days` | INT | 可用天数 |
| `price` | INT | 总价 |
| `credit` | INT | 使用账户数 |
| `status` | INT | 状态：0=未使用，1=已使用，2=已过期 |
| `applied_at` | TIMESTAMP | 使用时间 |
| `valid_until` | TIMESTAMP | 有效期至 |
| `created_at` | TIMESTAMP | 创建时间 |
| `updated_at` | TIMESTAMP | 更新时间 |

### 4.5 学校App账号表 (dongfang_school_app_account)

**表名: `dongfang_school_app_account`**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INT | 主键 |
| `org_id` | INT | 机构ID |
| `school_id` | INT | 学校ID |
| `account_type` | INT | 账号类型：1=免费账号，2=付费账号 |
| `count` | INT | 账号数量 |
| `free_count` | INT | 账号剩余数量 |
| `days` | INT | 使用天数 |

### 4.6 学校教学大纲关系表 (school_syllabus)

**表名: `school_syllabus`**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INT | 主键 |
| `school_id` | INT | 学校ID |
| `syllabus_id` | INT | 教学大纲ID |
| `created_date` | DATETIME | 创建时间 |
| `updated_date` | DATETIME | 更新时间 |

---

## 五、应用/产品包

### 5.1 应用发布表 (application_table)

**表名: `application_table`**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INT | 主键 |
| `file_name` | VARCHAR(255) | 文件名 |
| `pkg_name` | VARCHAR(255) | 包名（如 com.iplayabc.jianjin） |
| `platform` | VARCHAR(32) | 平台：android/ios |
| `version` | VARCHAR(255) | 版本号 |
| `ver` | VARCHAR(255) | 版本号（内部） |
| `store_url` | VARCHAR(255) | 应用商店URL |
| `pub_date` | DATETIME | 发布日期 |
| `store_list` | JSON | 商店列表 |
| `change_log` | TEXT | 更新日志 |
| `force_update` | INT | 强制升级：0=不强制，1=强制 |
| `updateon` | DATETIME | 更新时间 |

### 5.2 Pad应用表 (reading_pad_application)

**表名: `reading_pad_application`**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INT | 主键 |
| `uuid` | VARCHAR(64) | 唯一标识符 |
| `pkg_name` | VARCHAR(255) | 包名 |
| `pkgsize` | INT | 包大小 |
| `version` | VARCHAR(255) | 版本号 |
| `ver` | INT | 内部版本号 |
| `url` | VARCHAR(255) | 下载URL |
| `tips` | VARCHAR(255) | 提示 |
| `title` | VARCHAR(255) | 标题 |
| `file_name` | VARCHAR(255) | 文件名 |
| `pad_type` | VARCHAR(255) | 机型（incar_710_R20/incar_R20/unisoc_X20） |
| `app_type` | VARCHAR(255) | 发布类型：1=正常发布，2=白名单发布 |
| `status_` | VARCHAR(255) | 状态：testing/testpass/published |
| `whites` | VARCHAR(255) | 白名单 |
| `created_date` | TIMESTAMP | 创建时间 |
| `updated_date` | TIMESTAMP | 更新时间 |
| `del` | INT | 是否删除 |

### 5.3 直播产品表 (live_products)

**表名: `live_products`**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | INT | 主键 |
| `price` | INT | 总价（分） |
| `unit_price` | INT | 单价（分） |
| `quantity` | INT | 数量 |
| `info` | TEXT | 产品信息 |
| `createon` | TIMESTAMP | 创建时间 |

---

## 六、数据模型关系图

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           Organization (机构)                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │
│  │ id (PK)    │  │ org_type    │  │ is_course   │  │ is_live     │   │
│  │ uuid       │  │ name        │  │ is_customized│ │ status_     │   │
│  │ description│  │ channel     │  │ ...         │  │ ...         │   │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘   │
└────────────────────────────────┬────────────────────────────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │ 1:N                   │ 1:N                   │ 1:N
         ▼                       ▼                       ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  School (校区)   │     │  User (用户)     │     │  dongfang_products│
│  ┌───────────┐  │     │  ┌───────────┐  │     │  (机构产品)       │
│  │ id (PK)   │  │     │  │ id (PK)   │  │     │  ┌───────────┐  │
│  │ org_id    │◄─┼─────┼──│ org_id    │  │     │  │ id (PK)   │  │
│  │ name      │  │     │  │ user_type │  │     │  │ org_id    │◄─┤
│  │ s_type    │  │     │  │ phone     │  │     │  │ syllabus_id│  │
│  │ s_status  │  │     │  │ school_id │  │     │  │ price     │  │
│  │ ...       │  │     │  │ class_id  │  │     │  │ days      │  │
│  └───────────┘  │     │  └───────────┘  │     │  └───────────┘  │
└────────┬────────┘     └────────┬────────┘     └─────────────────┘
         │                       │
         │ 1:N                   │ 1:N
         ▼                       ▼
┌─────────────────┐     ┌─────────────────┐
│  Classroom      │     │  org_user        │
│  (班级)          │     │  (机构用户关系)    │
│  ┌───────────┐  │     │  ┌───────────┐  │
│  │ id (PK)   │  │     │  │ user_id   │  │
│  │ school_id │◄─┘     │  │ org_id    │◄─┘
│  │ org_id    │        │  │ org_type  │  (owner/user)
│  │ grade     │        │  └───────────┘  │
│  │ jc_id     │        │                 │
│  │ jc_arr    │        │  ┌──────────────┴───────────────┐
│  │ auto_allow│        │  │                              │
│  └───────────┘        │  ▼                              ▼
└─────────────────┘     ┌─────────────────┐     ┌─────────────────┐
                        │  user_roles      │     │  user_permission │
                        │  (用户角色关系)    │     │  (用户权限关系)   │
                        │  ┌───────────┐   │     │  ┌───────────┐  │
                        │  │ user_id   │   │     │  │ user_id   │  │
                        │  │ role_id   │   │     │  │ permission_id│
                        │  └───────────┘   │     │  └───────────┘  │
                        └────────┬────────┘     └─────────────────┘
                                 │
                                 ▼
                        ┌─────────────────┐     ┌─────────────────┐
                        │  roles          │     │  permission      │
                        │  (角色)           │     │  (权限)           │
                        │  ┌───────────┐   │     │  ┌───────────┐  │
                        │  │ id (PK)   │   │     │  │ id (PK)   │  │
                        │  │ code      │   │     │  │ code      │  │
                        │  │ name      │   │     │  │ name      │  │
                        │  │ r_type    │   │     │  │ module_name│  │
                        │  │ enter_url │   │     │  │ module_router│
                        │  │ org_id    │   │     │  └───────────┘  │
                        │  └───────────┘   │     └─────────────────┘
                        └────────┬────────┘
                                 │
                                 ▼
                        ┌─────────────────┐
                        │  roles_permission│
                        │  (角色权限关系)   │
                        │  ┌───────────┐  │
                        │  │ role_id   │  │
                        │  │ permission_id│
                        │  └───────────┘  │
                        └─────────────────┘
```

---

## 七、核心业务流程

### 7.1 账号与机构的关系

1. **用户登录时**: 根据 `user.org_id` 确定用户所属机构
2. **机构管理员**: `org_user.org_type = 'owner'` 的用户为机构拥有者
3. **机构用户**: `org_user.org_type = 'user'` 的用户为普通机构用户
4. **权限校验**: 通过 `user_roles` → `roles` → `roles_permission` 确定用户的菜单和操作权限

### 7.2 产品购买与使用流程

1. 机构管理员购买 `dongfang_products` 中的产品
2. 购买后生成 `dongfang_products_credits` 记录，记录可用账户数 (credit)
3. 学生账号通过班级 (`classroom`) 关联的教材 (`syllabus`) 使用产品
4. 系统校验 `dongfang_products_credits` 中的 `valid_until` 和 `credit` 判断是否可用

### 7.3 课件与课程体系

1. `syllabus` 定义树形课程体系结构
2. `courseware` 属于特定 `course_id`（课程）
3. `school_syllabus` 关联学校和可用的课程体系
4. 班级通过 `jc_id` 或 `jc_arr` 关联教材/课程

---

## 八、数据表清单

| 表名 | 说明 |
|------|------|
| `organization` | 机构表 |
| `user` | 用户表 |
| `student` | 学生表 |
| `org_user` | 机构用户关系表 |
| `user_class` | 用户班级关系表 |
| `roles` | 角色表 |
| `permission` | 权限表 |
| `user_permission` | 用户权限关系表 |
| `user_roles` | 用户角色关系表 |
| `roles_permission` | 角色权限关系表 |
| `school` | 学校/校区表 |
| `classroom` | 班级表 |
| `syllabus` | 教学大纲/课程体系表 |
| `courseware` | 课件表 |
| `dongfang_products` | 机构产品表 |
| `dongfang_products_credits` | 产品账户余额表 |
| `dongfang_school_app_account` | 学校App账号表 |
| `school_syllabus` | 学校教学大纲关系表 |
| `application_table` | 应用发布表 |
| `reading_pad_application` | Pad应用表 |
| `live_products` | 直播产品表 |

---

## 九、相关文件路径

- 数据库初始化脚本: `dige-manager/db-init/teach.sql`
- 机构管理相关代码: `dige-manager/engine/user_center/`
- 应用管理相关代码: `dige-manager/engine/application/`
- 拦截器(权限校验): `dige-manager/interceptor/`
