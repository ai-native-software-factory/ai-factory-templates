# 客户端产品矩阵

## 一、产品线全景

iPlayABC 的客户端分为**三大端**，每个端都有多个应用：

```
┌─────────────────────────────────────────────────────────────────┐
│                        硬件端 (Hard Devices)                    │
│  点读笔 / 扫描翻译笔 / 墨水屏学习平板 等实体设备                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                         APP 端 (Mobile)                         │
│                                                                  │
│  ┌─ 学生端 ─────────────────────────────────────────────────┐   │
│  │ ireadabc_student/ireadabc_student      (Flutter 主学生端)│   │
│  │ jianjinxueshengduan/jianjin_student    (Flutter 剑津学生)│   │
│  │ dige-student-app                       (旧版学生端)        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─ 教师端 ─────────────────────────────────────────────────┐   │
│  │ jianjinxueshengduan/jianjin_teacher   (Flutter 剑津教师)│   │
│  │ jianjinxueshengduan/jj_teacher        (Flutter 剑津教师2)│   │
│  │ xueli/xueli_flutter_teacher           (Flutter 雪梨教师) │   │
│  │ dige-teacher-app                      (旧版教师端)       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─ 商城端 ─────────────────────────────────────────────────┐   │
│  │ haoqihao/haoqihao-app               (Flutter 好齐好商城)  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─ 特殊 APP ──────────────────────────────────────────────┐   │
│  │ LumoClass/ai_foreign_teacher         (外教 APP)          │   │
│  │ ireadabc_student/ireadabc_lexile    (蓝思专项 APP)      │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                         Web 端 (Browser)                        │
│                                                                  │
│  ┌─ 管理后台 (Admin) ──────────────────────────────────────┐   │
│  │ dige-manager/xie-cn                    (Vue2 管理后台)   │   │
│  │ jianjin/xie-cn                         (Vue2 剑津后台)   │   │
│  │ jianjinjiaoyu/jianjin-api              (NestJS API)      │   │
│  │ jianjinjiaoyu/jianjin-teacher          (NestJS 教师API)  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─ 教师端 (Web) ──────────────────────────────────────────┐   │
│  │ jianjinjiaoyu/jianjin-teacher/apps      (Angular 教师端) │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─ 学生端 (H5/小程序) ──────────────────────────────────── ┐   │
│  │ jianjinxueshengduan/jianjin_share_h5   (Vue3 学生H5)     │   │
│  │ digejiaoyu1/dige-manager/h5template   (H5 模板)         │   │
│  │ haoqihao/haoqihao-uniapp-shop          (UniApp 商城)     │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 二、APP 端详解

### 2.1 学生端 APP

| 应用 | 技术栈 | 说明 |
|------|--------|------|
| `ireadabc_student/ireadabc_student` | **Flutter** | **主学生端 APP**，主要功能：首页/班级/作业/测评 |
| `jianjinxueshengduan/jianjin_student` | **Flutter** | **剑津学生端 APP**，独立于旧版 |
| `dige-student-app` | ? | **旧版学生端**，已被 ireadabc 替代 |

**学生端 APP 的典型页面结构（Flutter）：**
```
lib/
  pages/
    about_page          # 关于
    create_homework_page  # 创建作业（教师视角）
    home_page           # 首页
    homework_report_page # 作业报告
    login_page          # 登录
    play_video_and_audio_page  # 播放页
    privacy_policy_page  # 隐私政策
    select_homework_page # 选择作业
    speech_evaluation_template_page  # 语音评测
    student_select_page  # 学生选择
```

### 2.2 教师端 APP

| 应用 | 技术栈 | 说明 |
|------|--------|------|
| `jianjinxueshengduan/jianjin_teacher` | **Flutter** | **主教师端 APP** |
| `jianjinxueshengduan/jj_teacher` | **Flutter** | 教师端 APP（另一个） |
| `xueli/xueli_flutter_teacher` | **Flutter** | **雪梨教师端** |
| `dige-teacher-app` | ? | 旧版教师端 |

### 2.3 商城 APP

| 应用 | 技术栈 | 说明 |
|------|--------|------|
| `haoqihao/haoqihao-app` | **Flutter** | 好齐好商城 APP（商品/订单/佣金/提现） |

---

## 三、Web 端详解

### 3.1 管理后台（Admin）

**技术栈：Vue 2 + Element UI**

| 应用 | 说明 |
|------|------|
| `jianjin/xie-cn` | **剑津管理后台**（Vue 2，单页应用） |
| `digejiaoyu1/dige-manager/xie-cn` | **旧版管理后台** |
| `jianjinjiaoyu/jianjin-api` | **NestJS API**（管理后台后端） |

**jianjin/xie-cn 的结构：**
```
xie-cn/
  web/
    lib/            # Vue 2 + jQuery + Element UI
    skyframe/       # 模板引擎（EJS）
  src/              # 后端逻辑
  package.json      # xie-cn 1.0.7
```

**是否分教师端和学生端？**
> **jianjin/xie-cn 是一个综合管理后台**，管理老师和学生都在里面，没有分开。Web 端**没有独立的教师 Portal**，教师端 Web 功能可能在 `jianjinjiaoyu/jianjin-teacher/apps` 里。

### 3.2 教师端 Web

| 应用 | 技术栈 | 说明 |
|------|--------|------|
| `jianjinjiaoyu/jianjin-teacher/apps` | **Angular** | **剑津教师端 Web**（不同于 Flutter 教师端 APP） |

### 3.3 学生端 H5

| 应用 | 技术栈 | 说明 |
|------|--------|------|
| `jianjinxueshengduan/jianjin_share_h5` | **Vue 3** | **学生 H5**（用于微信/浏览器打开） |
| `haoqihao/haoqihao-uniapp-shop` | **UniApp** | 商城 H5/小程序 |

---

## 四、关键结论

### Web 端是否分教师端和学生端？

**答案：部分分开**

| 端 | 是否有独立 Portal |
|----|------------------|
| **管理后台** | ✅ 综合后台（jianjin/xie-cn），管理员/教师/校长都在一个系统 |
| **教师端 Web** | ✅ 有 Angular APP（jianjin-teacher/apps），但主要在 Flutter APP |
| **学生端 Web** | ✅ 有 Vue3 H5（jianjin_share_h5），但主要在 Flutter APP |

**总结：**
- APP 是最重要的端：**学生用 Flutter APP，教师用 Flutter APP**
- Web 端主要是**管理后台**（jianjin/xie-cn），不是给学生/老师用的学习界面
- 学生如果不用 APP，可以通过 **H5（jianjin_share_h5）** 在浏览器学习

---

## 五、相关文档

| 文档 | 关系 |
|------|------|
| 知识库-业务概念词汇表.md | user = 管理员/教师账号，student = 学生账号 |
| 知识库-机构账号产品数据模型.md | 账号体系统一，但客户端分家 |

---

*分析可信度: 高（从代码目录结构直接提取）*
