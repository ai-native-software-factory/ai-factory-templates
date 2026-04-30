# 分销系统 (Shopro Commission) 知识库

## 1. 系统概述

分销系统是一个基于 ThinkPHP 5 + FastAdmin 框架的三级分销系统，用于管理分销商、佣金计算和结算。

**代码位置**: `application/admin/controller/shopro/commission/`

## 2. 核心数据表

### 2.1 分销商表 (shopro_commission_agent)
| 字段 | 类型 | 说明 |
|------|------|------|
| user_id | int | 用户ID (主键) |
| level | int | 分销商等级 |
| parent_agent_id | int | 上级分销商ID |
| status | tinyint | 状态: 0=审核中, 1=正常, 2=冻结, 3=禁用, 4=完善资料, 5=审核驳回 |
| apply_info | text | 申请资料JSON |
| upgrade_lock | int | 升级锁定: 0=未锁定, 1=锁定 |
| level_status | int | 待审核等级 |
| child_agent_level | text | 下级分销商等级分布JSON |
| child_agent_level_1 | text | 直接下级分销商等级分布JSON |
| createtime | int | 创建时间 |
| updatetime | int | 更新时间 |

**状态常量** (AgentLibrary):
- `AGENT_STATUS_NORMAL = 1` 正常
- `AGENT_STATUS_PENDING = 0` 审核中
- `AGENT_STATUS_FREEZE = 2` 冻结
- `AGENT_STATUS_FORBIDDEN = 3` 禁用
- `AGENT_STATUS_NEEDINFO = 4` 完善资料
- `AGENT_STATUS_REJECT = 5` 审核驳回

### 2.2 分销商等级表 (shopro_commission_agent_level)
| 字段 | 类型 | 说明 |
|------|------|------|
| level | int | 等级值 (主键) |
| name | varchar | 等级名称 |
| image | varchar | 等级图标 |
| commission_rules | text | 佣金规则JSON: {"commission_1":"0.00","commission_2":"0.00","commission_3":"0.00"} |
| createtime | int | 创建时间 |

**默认等级**: Level 1 为默认等级，初始创建

### 2.3 分销订单表 (shopro_commission_order)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 主键 |
| order_id | int | 商城订单ID |
| order_item_id | int | 订单商品ID |
| agent_id | int | 推广分销商ID (直接推荐人) |
| buyer_id | int | 购买人ID |
| amount | decimal | 分销订单金额 |
| commission_reward_status | tinyint | 佣金处理状态 |
| commission_order_status | tinyint | 业绩状态 |
| commission_event | varchar | 佣金结算事件 |
| commission_price_type | varchar | 价格类型: pay_price/goods_price |
| event | varchar | 触发事件 |
| createtime | int | 创建时间 |
| updatetime | int | 更新时间 |

**佣金处理状态**:
- `COMMISSION_REWARD_STATUS_WAITING = 0` 未结算、待入账
- `COMMISSION_REWARD_STATUS_ACCOUNTED = 1` 已结算、已入账
- `COMMISSION_REWARD_STATUS_BACK = -1` 已退回
- `COMMISSION_REWARD_STATUS_CANCEL = -2` 已取消

**业绩状态**:
- `COMMISSION_ORDER_STATUS_NO = 0` 不计入
- `COMMISSION_ORDER_STATUS_YES = 1` 已计入
- `COMMISSION_ORDER_STATUS_BACK = -1` 已扣除
- `COMMISSION_ORDER_STATUS_CANCEL = -2` 已取消

**佣金结算事件**:
- `COMMISSION_EVENT_PAYED = 'payed'` 支付后结算
- `COMMISSION_EVENT_CONFIRM = 'confirm'` 确认收货后结算
- `COMMISSION_EVENT_FINISH = 'finish'` 订单完成结算
- `COMMISSION_EVENT_ADMIN = 'admin'` 手动打款

### 2.4 佣金明细表 (shopro_commission_reward)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 主键 |
| commission_order_id | int | 分销订单ID |
| order_id | int | 商城订单ID |
| agent_id | int | 收款分销商ID |
| buyer_id | int | 购买人ID |
| commission | decimal | 佣金金额 |
| status | tinyint | 状态: 0=待结算, 1=已结算, -1=已退回, -2=已取消 |
| type | varchar | 类型: money/score/cash/change/bank |
| level | int | 分销层级: 1/2/3 |
| createtime | int | 创建时间 |
| updatetime | int | 更新时间 |

**状态常量**:
- `COMMISSION_REWARD_STATUS_WAITING = 0` 待结算
- `COMMISSION_REWARD_STATUS_ACCOUNTED = 1` 已结算
- `COMMISSION_REWARD_STATUS_BACK = -1` 已退回
- `COMMISSION_REWARD_STATUS_CANCEL = -2` 已取消

### 2.5 分销商品表 (shopro_commission_goods)
| 字段 | 类型 | 说明 |
|------|------|------|
| goods_id | int | 商品ID (主键) |
| status | tinyint | 是否参与分销: 0=不参与, 1=参与 |
| self_rules | int | 自购规则: 0=默认规则, 1=自定义规则 |
| commission_rules | text | 自定义佣金规则JSON |
| commission_config | text | 佣金配置JSON |
| commission_level | int | 佣金层级 |

### 2.6 分销配置表 (shopro_commission_config)
| 字段 | 类型 | 说明 |
|------|------|------|
| name | varchar | 配置名称 |
| value | text | 配置值 |

**关键配置项**:
- `commission_level` - 佣金层级数
- `self_buy` - 是否允许自购
- `commission_price_type` - 佣金计算价格类型 (pay_price/goods_price)
- `commission_event` - 佣金结算触发事件

### 2.7 分销动态表 (shopro_commission_log)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 主键 |
| agent_id | int | 关联分销商ID |
| oper_id | int | 操作人ID |
| oper_type | varchar | 操作类型: user/admin/system |
| event | varchar | 事件类型 |
| detail | text | 事件详情JSON |
| createtime | int | 创建时间 |

**事件类型**:
- `agent` - 分销商变更
- `level` - 等级变动
- `order` - 分销业绩
- `team` - 团队变动
- `reward` - 佣金变动
- `share` - 绑定关系变动

## 3. 分销商入驻流程

### 3.1 成为分销商的条件
1. 用户注册并完成必要的认证信息
2. 通过管理员审核或满足自动升级条件

### 3.2 分销商状态流转
```
申请(pending) → 审核通过(normal) / 审核拒绝(reject)
                ↓
              正常(normal) ↔ 冻结(freeze)
                ↓
              禁用(forestalled)
```

### 3.3 变更分销商上级
- 支持管理员修改分销商的上级
- 防止出现推荐闭环 (递归检查)
- 变更后触发原上级和新上级的升级检查

## 4. 分销等级体系

### 4.1 等级定义
- 支持多级分销等级
- 每个等级可配置不同的三级佣金比例
- `commission_rules` 格式:
```json
{
  "commission_1": "10.00",  // 一级佣金比例%
  "commission_2": "5.00",   // 二级佣金比例%
  "commission_3": "2.00"    // 三级佣金比例%
}
```

### 4.2 等级升级
- 支持手动升级 (管理员操作)
- 支持审核升级 (用户申请)
- `level_status` 字段记录待审核等级

## 5. 佣金计算公式 (三级分销)

### 5.1 佣金计算逻辑
```
订单金额 = 商品实际支付金额 (或商品标价金额)

一级佣金 = 订单金额 × 等级.commission_1%
二级佣金 = 订单金额 × 等级.commission_2%
三级佣金 = 订单金额 × 等级.commission_3%

总佣金 = 一级佣金 + 二级佣金 + 三级佣金
```

### 5.2 佣金层级说明
- **一级佣金**: 直接推荐人 (agent_id) 获得
- **二级佣金**: 上级的直接推荐人 获得
- **三级佣金**: 二级的直接推荐人 获得

### 5.3 自购佣金
- 如果开启自购 (self_buy 配置)，购买人可获得自身层级佣金

## 6. 订单追踪和佣金结算流程

### 6.1 订单创建时
1. 生成 `shopro_commission_order` 记录
2. 根据购买人链路，查找一级/二级/三级分销商
3. 生成对应的 `shopro_commission_reward` 记录
4. 初始状态为 `status=0` (待结算)

### 6.2 佣金结算触发
根据 `commission_event` 配置:
1. **payed (支付后)**: 支付完成即结算佣金
2. **confirm (确认收货)**: 收货后结算佣金
3. **finish (订单完成)**: 订单完成后结算
4. **admin (手动)**: 管理员手动打款

### 6.3 佣金退回/取消
- **backCommission**: 退回已结算佣金，status=-1
- **cancelCommission**: 取消未结算佣金，status=-2
- 支持同时删除/保留业绩

## 7. 核心功能模块

### 7.1 Agent (分销商管理)
| 方法 | 说明 |
|------|------|
| index | 分销商列表查询 |
| team | 查看团队成员 |
| profile | 分销商详情 |
| update | 更新分销商信息 (状态/等级/上级等) |
| select | 选择分销商 |

### 7.2 Level (等级管理)
| 方法 | 说明 |
|------|------|
| index | 等级列表 |
| add | 添加等级 |
| edit | 编辑等级 |

### 7.3 Order (分销订单)
| 方法 | 说明 |
|------|------|
| index | 分销订单列表 (含统计) |
| runCommission | 结算佣金 |
| backCommission | 退回佣金 |
| cancelCommission | 取消佣金 |

### 7.4 Reward (佣金明细)
| 方法 | 说明 |
|------|------|
| index | 佣金明细列表 |
| edit | 修改佣金金额 |
| runCommission | 结算佣金 |
| backCommission | 退回佣金 |
| cancelCommission | 取消佣金 |

### 7.5 Goods (分销商品)
| 方法 | 说明 |
|------|------|
| index | 分销商品列表 |
| edit | 编辑商品分销规则 |
| commission_status | 设置参与状态 |

### 7.6 Config (分销配置)
| 方法 | 说明 |
|------|------|
| index | 查看配置 |
| save | 保存配置 |

### 7.7 Log (分销动态)
| 方法 | 说明 |
|------|------|
| index | 动态列表 |
| getEventAll | 获取所有事件类型 |

## 8. 关键业务逻辑

### 8.1 佣金计算入口
```php
// 控制器调用
(new \addons\shopro\library\commission\Reward)->runCommissionRewardByOrder('admin', $order);
```

### 8.2 分销商升级检查
```php
$agent = new \addons\shopro\library\commission\Agent($userId);
$agent->asyncAgentUpgrade($userId);
```

### 8.3 绑定关系建立
当订单完成时:
1. 如果购买人没有上级，建立绑定关系
2. 如果购买人已是分销商，更新其上级信息
3. 记录分销动态 (share 事件)

### 8.4 团队统计
- `child_user_count`: 全部下级用户数
- `child_user_count_1`: 直接下级用户数
- `child_user_count_2`: 二级下级用户数
- `total_consume`: 下级用户总消费额

## 9. 关联关系

### 9.1 模型关联
```
User (用户)
  └── hasOne → Agent (分销商)
        ├── belongsTo → AgentLevel (分销商等级)
        ├── belongsTo → parentAgent (上级分销商)
        └── hasMany → Rewards (佣金记录)

Agent (分销商)
  └── belongsTo → User

CommissionOrder (分销订单)
  ├── belongsTo → Order (商城订单)
  ├── belongsTo → OrderItem (订单商品)
  ├── belongsTo → Agent (推广人)
  ├── belongsTo → Buyer (购买人)
  └── hasMany → Rewards (佣金明细)

CommissionReward (佣金明细)
  ├── belongsTo → Agent (收款分销商)
  ├── belongsTo → CommissionOrder (分销订单)
  └── belongsTo → Order (商城订单)
```

## 10. 配置项说明

### 10.1 佣金相关配置
| 配置名 | 说明 | 可选值 |
|--------|------|--------|
| commission_level | 佣金层级数 | 1/2/3 |
| self_buy | 是否自购返佣 | 0/1 |
| commission_price_type | 计算价格类型 | pay_price/goods_price |
| commission_event | 结算时机 | payed/confirm/finish/admin |

### 10.2 商品分销配置
| 配置名 | 说明 |
|--------|------|
| status | 是否参与分销 |
| self_rules | 是否使用自定义规则 |
| commission_rules | 自定义佣金比例 |

## 11. 文件路径

### 控制器 (Controller)
- `application/admin/controller/shopro/commission/Agent.php` - 分销商管理
- `application/admin/controller/shopro/commission/Level.php` - 等级管理
- `application/admin/controller/shopro/commission/Order.php` - 分销订单
- `application/admin/controller/shopro/commission/Reward.php` - 佣金明细
- `application/admin/controller/shopro/commission/Goods.php` - 分销商品
- `application/admin/controller/shopro/commission/Config.php` - 分销配置
- `application/admin/controller/shopro/commission/Log.php` - 分销动态

### 模型 (Model)
- `application/admin/model/shopro/commission/Agent.php`
- `application/admin/model/shopro/commission/Level.php`
- `application/admin/model/shopro/commission/Order.php`
- `application/admin/model/shopro/commission/Reward.php`
- `application/admin/model/shopro/commission/Goods.php`
- `application/admin/model/shopro/commission/Config.php`
- `application/admin/model/shopro/commission/Log.php`

### 视图 (View)
- `application/admin/view/shopro/commission/` - 分销模块视图

### 核心库 (Library)
- `addons/shopro/library/commission/Agent.php` - 分销商核心逻辑
- `addons/shopro/library/commission/Reward.php` - 佣金核心逻辑
- `addons/shopro/library/commission/Log.php` - 日志记录

## 12. 注意事项

1. **分销闭环检测**: 修改上级分销商时，会递归检查防止出现推荐闭环
2. **事务处理**: 所有佣金操作都在事务中执行，确保数据一致性
3. **升级锁定**: `upgrade_lock=1` 时不触发自动升级
4. **佣金状态机**: 佣金状态只能从待结算(0)→已结算(1)，或退回(-1)/取消(-2)
5. **层级限制**: 最大支持三级分销，超出层级不计算佣金
