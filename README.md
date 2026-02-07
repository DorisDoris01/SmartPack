# SmartPack - 智能打包清单

一个基于 SwiftUI 和 SwiftData 的智能旅行打包清单应用，支持天气集成和 Live Activity。

## ✨ 主要功能

- 📋 **智能打包清单** - 根据旅行类型、时长、标签自动生成打包清单
- 🌤️ **天气集成** - 根据目的地和日期查询天气，智能调整携带物品
- 📱 **Live Activity** - 在锁屏实时显示打包进度
- 🌍 **多语言支持** - 支持中文和英文
- ✏️ **清单编辑** - 添加/删除物品，Reminders 风格的简洁 UI
- 🎯 **分类管理** - 按类别组织物品（证件、衣物、洗漱用品等）

## 🛠️ 技术栈

- **SwiftUI** - 用户界面
- **SwiftData** - 数据持久化
- **ActivityKit** - Live Activity 支持
- **OpenWeatherMap API** - 天气数据

## 📦 版本历史

### v1.8 (当前稳定版)
- ✅ 代码重构：应用设计系统常量
- ✅ 文件组织优化：统一命名和结构
- ✅ 本地化重构：优化多语言支持
- ✅ 项目清理：移除旧的 Widget 实现
- ✅ 配置优化：更新 .gitignore 和项目设置

### v1.7
- ✅ 天气集成功能
- ✅ Live Activity 支持
- ✅ Reminders 风格 UI
- ✅ 多语言支持
- ✅ 清单编辑功能

## 🚀 快速开始

### 环境要求

- iOS 16.1+
- Xcode 15.0+
- Swift 5.9+

### 安装步骤

1. 克隆仓库
```bash
git clone https://github.com/DorisDoris01/SmartPack.git
cd SmartPack
```

2. 打开项目
```bash
open SmartPack/SmartPack.xcodeproj
```

3. 配置天气 API Key
   - 参考 `docs/WEATHER_API_SETUP.md`
   - 在 `WeatherService.swift` 中设置你的 OpenWeatherMap API Key

4. 运行项目
   - 选择目标设备或模拟器
   - 点击运行按钮 (⌘R)

## 📁 项目结构

```
SmartPack/
├── SmartPack/
│   ├── Activity/          # Live Activity 相关
│   ├── Data/             # 数据层
│   ├── Models/            # 数据模型
│   ├── Services/          # 服务层（天气服务等）
│   ├── Views/             # 视图层
│   └── WidgetExtension/   # Widget Extension
└── docs/                  # 文档
```

## 🔧 开发

### 分支管理

- `main` - 稳定发布分支
- `develop` - 日常开发分支
- `v1.9` - 下一个版本开发分支

详细工作流请参考 [GIT_WORKFLOW.md](./GIT_WORKFLOW.md)

### 提交规范

使用约定式提交（Conventional Commits）：
- `feat:` 新功能
- `fix:` 修复问题
- `docs:` 文档更新
- `refactor:` 代码重构

## 📄 文档

- [天气 API 设置指南](./docs/WEATHER_API_SETUP.md)
- [天气集成规范](./docs/SPEC-Weather-Integration.md)
- [清单编辑功能规范](./docs/SPEC-Trip-Edit-Feature-v1.7.md)
- [Git 工作流](./GIT_WORKFLOW.md)

## 📝 许可证

[添加你的许可证]

## 👤 作者

DorisDoris01

## 🙏 致谢

- OpenWeatherMap API
- Apple SwiftUI & SwiftData
