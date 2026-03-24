# Baby Tracker | 宝宝成长记录

[![Build Status](https://github.com/JunbiaoXue/baby-tracker/actions/workflows/android.yml/badge.svg)](https://github.com/JunbiaoXue/baby-tracker)
[![GitHub release](https://img.shields.io/github/v/release/JunbiaoXue/baby-tracker)](https://github.com/JunbiaoXue/baby-tracker/releases)

[English](#english) | [中文](#中文)

---

## English

### About

Baby Tracker is a comprehensive Flutter-based Android application designed to help parents track their baby's daily activities, growth, and milestones. With an intuitive interface and rich features, it makes parenting a little easier.

### Features

- **🍼 Feeding Tracker** — Log breast-feeding, bottle-feeding, and solid food meals with duration and quantity
- **👶 Diaper Tracker** — Record wet/dirty diapers with timestamps and notes
- **😴 Sleep Tracker** — Track naps and nighttime sleep with duration and quality
- **📈 Growth Tracker** — Record weight, height, and head circumference with WHO percentile references
- **🏆 Milestone Tracker** — Document first smiles, words, steps, and other important moments
- **💊 Supplement Tracker** — Log vitamins, medicine, and other supplements
- **📊 Statistics** — Beautiful charts showing daily, weekly, and monthly trends
- **📱 Bilingual** — Full Chinese/English support, switch anytime in settings

### Screenshots

> (Add screenshots after building)

### Tech Stack

| Component | Technology |
|-----------|-----------|
| Framework | Flutter 3.19 |
| State Management | Provider |
| Charts | fl_chart |
| UUID | uuid |
| Date/Time | intl |

### Installation

#### From Release (Recommended)
Download the latest APK from [Releases](https://github.com/JunbiaoXue/baby-tracker/releases/latest)

#### Build from Source
```bash
git clone https://github.com/JunbiaoXue/baby-tracker.git
cd baby-tracker
flutter pub get
flutter build apk --debug
# APK at: build/app/outputs/flutter-apk/app-debug.apk
```

### Architecture

```
lib/
├── main.dart              # App entry, Provider setup
├── models/               # Data models (feeding, diaper, sleep, growth, milestone, supplement)
├── screens/               # UI screens (home, feeding, diaper, sleep, growth, milestone, history, stats, settings)
└── services/
    ├── data_service.dart  # In-memory data storage with CRUD operations
    └── l10n_service.dart  # Localization (Chinese/English) service
```

### Data Model

| Model | Fields |
|-------|--------|
| FeedingRecord | id, type(bottle/breast/solid), amount, duration, startTime, notes |
| DiaperRecord | id, type(wet/dirty/both), time, notes |
| SleepRecord | id, startTime, endTime, duration, quality, notes |
| GrowthRecord | id, date, weight, height, headCircumference |
| MilestoneRecord | id, title, description, date, category |
| SupplementRecord | id, name, dosage, time, notes |

### Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0.0 | 2026-03-24 | Added bilingual Chinese/English support, language switch in settings |
| 1.0.0 | 2024 | Initial release with feeding, diaper, sleep, growth, milestone tracking |

### License

MIT License

---

## 中文

### 关于

宝宝成长记录是一款基于 Flutter 的安卓应用，帮助父母记录宝宝的每日活动、生长发育和重要里程碑。直观的界面和丰富的功能，让育儿更轻松。

### 功能特点

- **🍼 喂养记录** — 记录母乳、奶瓶、辅食，支持时长和奶量
- **👶 尿布记录** — 记录湿尿布、大便尿布及时间备注
- **😴 睡眠记录** — 追踪小睡和夜间睡眠，支持时长和质量
- **📈 生长发育** — 记录体重、身高、头围，对照WHO百分位
- **🏆 里程碑** — 记录第一次微笑、说话、走路等重要时刻
- **💊 营养补充** — 记录维生素、药物等补充剂
- **📊 统计图表** — 展示日/周/月趋势的精美图表
- **🌐 中英双语** — 随时在设置中切换语言

### 技术栈

| 组件 | 技术 |
|------|------|
| 框架 | Flutter 3.19 |
| 状态管理 | Provider |
| 图表 | fl_chart |
| UUID | uuid |
| 日期时间 | intl |

### 从源码构建

```bash
git clone https://github.com/JunbiaoXue/baby-tracker.git
cd baby-tracker
flutter pub get
flutter build apk --debug
```

### 项目结构

```
lib/
├── main.dart              # 应用入口，Provider 注册
├── models/               # 数据模型（喂养、尿布、睡眠、生长、里程碑、营养补充）
├── screens/               # 界面屏幕（首页、喂养、尿布、睡眠、生长、里程碑、历史、统计、设置）
└── services/
    ├── data_service.dart  # 内存数据存储与 CRUD 操作
    └── l10n_service.dart  # 国际化服务（中英文切换）
```

### 数据模型

| 模型 | 字段 |
|------|------|
| FeedingRecord | id, type(奶瓶/母乳/辅食), amount, duration, startTime, notes |
| DiaperRecord | id, type(湿/脏/两者都有), time, notes |
| SleepRecord | id, startTime, endTime, duration, quality, notes |
| GrowthRecord | id, date, weight, height, headCircumference |
| MilestoneRecord | id, title, description, date, category |
| SupplementRecord | id, name, dosage, time, notes |

### 版本历史

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| 2.0.0 | 2026-03-24 | 新增中英双语切换功能 |
| 1.0.0 | 2024 | 首次发布，包含喂养、尿布、睡眠、生长、里程碑记录 |

### 许可证

MIT License
