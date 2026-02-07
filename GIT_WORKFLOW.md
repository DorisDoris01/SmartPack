# SmartPack Git 版本管理工作流

## 分支结构

### 主分支
- **main**: 稳定发布分支，只包含经过测试的稳定版本
- **develop**: 日常开发分支，集成所有新功能

### 版本分支
- **v1.8**: 下一个版本开发分支（当前）
- **v1.9**: 未来版本分支（需要时创建）

### 功能分支（可选）
- **feature/功能名称**: 新功能开发分支
- **bugfix/问题描述**: 问题修复分支

## 版本标签

- **v1.7**: SmartPack v1.7 - Weather Integration Release

## 工作流程

### 日常开发
```bash
# 1. 切换到 develop 分支
git checkout develop

# 2. 创建功能分支（可选）
git checkout -b feature/新功能名称

# 3. 开发完成后提交
git add .
git commit -m "feat: 新功能描述"

# 4. 推送到远程
git push origin feature/新功能名称

# 5. 合并到 develop
git checkout develop
git merge feature/新功能名称
git push origin develop
```

### 版本发布
```bash
# 1. 切换到版本分支（如 v1.8）
git checkout v1.8

# 2. 从 develop 合并最新代码
git merge develop

# 3. 测试完成后合并到 main
git checkout main
git merge v1.8

# 4. 创建版本标签
git tag -a v1.8 -m "SmartPack v1.8 - 版本描述"

# 5. 推送到远程
git push origin main
git push origin v1.8
git push origin v1.8  # 推送标签
```

### 快速修复（Hotfix）
```bash
# 1. 从 main 创建修复分支
git checkout main
git checkout -b hotfix/问题描述

# 2. 修复问题并提交
git add .
git commit -m "fix: 问题描述"

# 3. 合并到 main 和 develop
git checkout main
git merge hotfix/问题描述
git checkout develop
git merge hotfix/问题描述

# 4. 推送
git push origin main
git push origin develop
```

## 提交信息规范

使用约定式提交（Conventional Commits）：

- `feat:` 新功能
- `fix:` 修复问题
- `docs:` 文档更新
- `style:` 代码格式调整
- `refactor:` 代码重构
- `test:` 测试相关
- `chore:` 构建/工具相关

示例：
```
feat: 添加天气卡片显示功能
fix: 修复物品删除确认对话框问题
docs: 更新 README 文档
```

## 当前分支说明

- **main**: 稳定版本 v1.7
- **develop**: 日常开发分支
- **v1.8**: 下一个版本开发分支

## 下一步

开始开发新功能时：
1. 切换到 `develop` 或 `v1.8` 分支
2. 创建功能分支（可选）
3. 开始开发
