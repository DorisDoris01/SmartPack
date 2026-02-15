# SmartPack 打包清单界面优化 PRD

> **文档类型**：产品需求文档 (PRD)  
> **版本**：v1.1  
> **创建日期**：2026-02-15  
> **最后更新**：2026-02-15  
> **状态**：待评审  
> **基于**：PRD-SmartPack-v1.0.md

## 版本历史

- **v1.1** (2026-02-15)：新增 Trip 设置 Section 编辑功能、收起/展开功能，标签不分组显示
- **v1.0** (2026-02-15)：初始版本，简化进度显示、Weather Section 收起/展开、新增 Trip 设置 Section

---

## 1. 需求背景

### 1.1 当前状态

SmartPack 应用的打包清单页面（PackingListView）目前包含以下主要区域：
- **打包进度 Section**：显示"打包进度"标题、进度条、"还剩 xx 件物品"文本
- **Weather Section**：显示目的地天气信息（如果可用）
- **物品清单 Section**：按分类展示所有物品

### 1.2 改动动机

用户希望优化打包清单页面的界面布局和交互体验，以：
- **简化进度显示**：减少不必要的文字信息，让进度条更紧凑
- **增强天气区域灵活性**：允许用户根据需求收起/展开天气信息
- **提升信息透明度**：让用户清楚了解当前清单是基于哪些场景设置生成的
- **增强可编辑性**：允许用户从设置入口直接编辑和更新 Trip 设置

---

## 2. 需求范围

### 2.1 功能需求

#### 需求 1：简化打包进度 Section

**描述**：缩小打包进度 Section 的显示区域，去掉"打包进度"标题和"还剩 xx 件物品"文本，将计数文字叠加显示在进度条上。

**具体要求**：
- **移除内容**：
  - 移除"打包进度" / "Progress" 标题文字
  - 移除"还剩 xx 件物品" / "xx items remaining" 文本
- **保留内容**：
  - 保留进度条本身（带圆角矩形背景和填充色）
  - 保留"全部打包完成！" / "All packed!" 的完成状态提示（当 `isAllChecked = true` 时）
  - 保留"已归档"标签（如果 Trip 已归档）
- **布局调整**：
  - 进度条高度保持不变（`Spacing.sm`）
  - Section 的内边距可以适当减小，使整体更紧凑
  - 进度条左右边距保持与现有一致
  - **计数显示**：将"已勾选/总数"（`checkedCount/totalCount`）文字叠加显示在进度条上（overlap），使用合适的文字颜色和背景以确保可读性

**用户流程**：
1. 用户进入打包清单页面
2. 看到简化的进度条（无标题和剩余物品提示）
3. 进度条上叠加显示"已勾选/总数"计数
4. 进度条清晰显示当前打包进度百分比（通过填充长度）

**视觉设计**：
```
[========== 3/10]  ← 进度条上叠加显示计数
```

#### 需求 2：Weather Section 可收起/展开

**描述**：Weather Section 支持收起和展开功能，**以每个清单（Trip）为单位独立管理收起/展开状态**。首次进入某个 Trip 的打包清单页面时默认展开，用户收起后该 Trip 的 Weather Section 保持收起状态（需要持久化），直到用户再次展开。不同 Trip 之间的收起/展开状态互不影响。

**具体要求**：
- **默认状态**：
  - **每个 Trip 独立管理**：首次进入某个 Trip 的打包清单页面时，Weather Section 默认展开显示
  - **状态独立保存**：如果用户之前已经收起过该 Trip 的 Weather Section，则保持收起状态
  - **不同 Trip 互不影响**：Trip A 的 Weather Section 收起状态不会影响 Trip B 的 Weather Section 状态
- **交互方式**：
  - 在 Weather Section 头部添加展开/收起按钮（chevron.up / chevron.down 图标）
  - 点击按钮可以切换展开/收起状态
  - 收起时隐藏天气详情内容，只显示标题栏
- **显示内容调整**：
  - **移除日期范围显示**：Weather Section 头部不再显示"几号到几号"的日期范围
  - 只显示目的地名称（如果可用）
- **状态持久化**：
  - **必须使用 Trip 特定设置**：使用 `UserDefaults` 保存每个 Trip 的收起/展开状态
  - **Key 格式**：`"weatherSectionCollapsed_\(trip.id.uuidString)"`，确保每个 Trip 有独立的 Key
  - **重要**：每个 Trip 的 Weather Section 收起状态独立保存，互不影响
- **动画效果**：
  - 展开/收起时使用平滑的动画过渡（`.animation(.spring())`）
  - 动画时长约 0.3 秒

**用户流程**：
1. 用户首次进入 Trip A 的打包清单页面
2. Trip A 的 Weather Section 默认展开显示天气信息
3. 用户点击收起按钮
4. Trip A 的 Weather Section 收起，只显示标题栏
5. 用户离开页面后再次进入 Trip A，Weather Section 保持收起状态
6. 用户点击展开按钮，Trip A 的 Weather Section 重新展开
7. **关键**：用户切换到 Trip B 时，Trip B 的 Weather Section 状态独立管理（如果之前未收起过，则默认展开）

**视觉设计**：
```
展开状态：
┌─────────────────────────┐
│ 📍 目的地            ▼ │
│ [天气卡片1] [天气卡片2] │
└─────────────────────────┘

收起状态：
┌─────────────────────────┐
│ 📍 目的地            ▲ │
└─────────────────────────┘
```

#### 需求 3：新增 Trip 基本设置 Section（v1.0）

**描述**：在生成清单之后，在进度条和天气之间新增一个 Section，显示本次 Trip 的基本设置信息，让用户清楚了解清单是基于哪些场景生成的。

**具体要求**：
- **显示位置**：
  - 位于进度条（ProgressHeader）下方
  - 位于 Weather Section 上方
  - 只在清单已生成后显示（即 `trip.items.count > 0`）
- **显示内容**：
  - **行程日期范围**：显示行程的日期范围（几号到几号），格式如"2026/02/15 - 2026/02/18"或根据当前语言格式化
  - **选择的场景标签**：显示用户选择的所有标签（按分组显示）
    - 旅行活动标签（如：跑步、攀岩、潜水等）
    - 特定场合标签（如：宴会、商务会议、自驾等）
    - 出行配置标签（如：国际旅行、带娃、带宠物等）
- **布局设计**：
  - 使用卡片式设计，与 Weather Section 风格一致
  - 标题："清单设置" / "List Settings"
  - 使用图标和标签展示各项设置
  - 标签使用 Chip/Pill 样式，带图标和文字
  - **排版紧凑**：标签之间间距较小，分组标题与标签之间间距紧凑，整体布局节省空间
- **显示逻辑**：
  - 始终显示行程日期范围（如果 Trip 有 `startDate` 和 `endDate`）
  - 如果用户没有选择任何标签，只显示日期范围
  - 如果用户选择了标签，按分组显示（旅行活动、特定场合、出行配置）
  - 标签显示对应的图标和名称（中英文根据当前语言）

**用户流程**：
1. 用户创建 Trip 并选择场景标签
2. 生成清单后进入打包清单页面
3. 在进度条下方看到"清单设置" Section
4. 清楚看到本次清单的日期范围和场景标签（按分组显示）
5. 用户可以据此理解为什么清单中包含了某些物品

**视觉设计**（v1.0）：
```
┌─────────────────────────┐
│ ⚙️ 清单设置              │
│ 📅 2026/02/15 - 02/18   │
│ 旅行活动: 🏃跑步 🧗攀岩  │
│ 特定场合: 🎉宴会 💼商务   │
│ 出行配置: ✈️国际旅行     │
└─────────────────────────┘
```

#### 需求 3.1：Trip 设置 Section 增强（v1.1）

**描述**：在 v1.0 的基础上，增强 Trip 设置 Section 的功能和体验。

**v1.1 新增功能**：

1. **标签显示不分组**：
   - 移除分组标题（旅行活动、特定场合、出行配置）
   - 直接展示所有选定的标签，如：🏃跑步、🎉宴会、✈️国际旅行
   - 标签按选择顺序排列

2. **Trip 设置 Section 可收起/展开**：
   - **以每个清单（Trip）为单位独立管理**收起/展开状态
   - 首次进入某个 Trip 的打包清单页面时默认展开
   - 如果用户之前已经收起过该 Trip 的设置 Section，则保持收起状态
   - 不同 Trip 之间的收起/展开状态互不影响
   - 使用 `UserDefaults` 保存每个 Trip 的收起/展开状态，Key：`"tripSettingsSectionCollapsed_\(trip.id.uuidString)"`

3. **从设置入口编辑 Trip**：
   - 在 Trip 设置 Section 头部添加编辑按钮（pencil 图标）
   - 点击编辑按钮后，进入编辑页面（Sheet 形式）
   - 编辑页面预填充当前 Trip 的设置（日期、标签）
   - 可以修改日期范围和标签（添加/删除）
   - 编辑完成后，Trip 设置更新，物品清单重新生成
   - 自动返回打包清单页面

**视觉设计**（v1.1）：
```
展开状态：
┌─────────────────────────┐
│ ⚙️ 清单设置      ✏️  ▼ │
│ 📅 2026/02/15 - 02/18   │
│ 🏃跑步 🎉宴会 ✈️国际旅行 │
└─────────────────────────┘

收起状态：
┌─────────────────────────┐
│ ⚙️ 清单设置      ✏️  ▲ │
└─────────────────────────┘
```

---

## 3. 功能详细设计

### 3.1 简化打包进度 Section 设计

#### 3.1.1 UI/UX 设计

**修改前**：
```
┌─────────────────────────┐
│ 打包进度          3/10  │
│ [==========]            │
│ 还剩 7 件物品           │
└─────────────────────────┘
```

**修改后**：
```
┌─────────────────────────┐
│ [========== 3/10]       │
│ （或：全部打包完成！）   │
└─────────────────────────┘
```

**完成状态**：
```
┌─────────────────────────┐
│ [========== 10/10]      │
│ ✓ 全部打包完成！        │
└─────────────────────────┘
```

#### 3.1.2 技术实现要点

**文件**：`SmartPack/SmartPack/Components/PackingList/ProgressHeader.swift`

**需要修改**：
- 移除 `HStack` 中的标题显示
- 移除底部的"还剩 xx 件物品"文本
- 保留进度条和完成状态提示
- **将计数文字叠加在进度条上**：使用 `ZStack` 将 `checkedCount/totalCount` 文字叠加显示在进度条上方
- 调整 `VStack` 的 `spacing` 和内边距，使布局更紧凑

**关键代码逻辑**：
```swift
var body: some View {
    VStack(spacing: Spacing.xs) {
        // 进度条，叠加显示计数
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景进度条
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(Color(.systemGray5))
                    .frame(height: Spacing.sm)
                
                // 填充进度条
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(trip.isAllChecked ? AppColors.success : AppColors.primary)
                    .frame(width: geometry.size.width * trip.progress, height: Spacing.sm)
                    .animation(.spring(response: 0.3), value: trip.progress)
                
                // 叠加显示计数文字（居中）
                HStack {
                    Spacer()
                    Text("\(trip.checkedCount)/\(trip.totalCount)")
                        .font(Typography.caption.weight(.semibold))
                        .foregroundColor(trip.isAllChecked ? AppColors.success : AppColors.primary)
                        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 0.5)
                    Spacer()
                }
            }
        }
        .frame(height: Spacing.sm)
        
        // 保留完成状态提示
        if trip.isAllChecked {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppColors.success)
                Text(language == .chinese ? "全部打包完成！" : "All packed!")
                    .foregroundColor(AppColors.success)
            }
            .font(Typography.subheadline.bold())
            .padding(.vertical, Spacing.xxs)
        }
    }
    .padding(Spacing.md) // 可以减小为 Spacing.sm
    .background(trip.isAllChecked ? AppColors.success.opacity(0.08) : AppColors.background)
}
```

### 3.2 Weather Section 可收起/展开设计

#### 3.2.1 UI/UX 设计

**展开状态**：
- 显示完整的天气卡片内容
- 头部右侧显示向下箭头（chevron.down）表示可收起

**收起状态**：
- 只显示头部（目的地名称）
- 头部右侧显示向上箭头（chevron.up）表示可展开
- 天气详情内容隐藏

#### 3.2.2 技术实现要点

**文件**：
- `SmartPack/SmartPack/Views/Trip/PackingListView.swift` - 添加状态管理
- `SmartPack/SmartPack/Views/Shared/WeatherCard.swift` - 添加收起/展开功能

**实现方案：使用 Trip 特定设置（必须）**
```swift
// PackingListView.swift
@State private var isWeatherCollapsed = false

.onAppear {
    // 从 UserDefaults 读取该 Trip 的收起状态
    // 每个 Trip 使用独立的 Key，确保状态互不影响
    let key = "weatherSectionCollapsed_\(trip.id.uuidString)"
    isWeatherCollapsed = UserDefaults.standard.bool(forKey: key)
}

.onChange(of: isWeatherCollapsed) { newValue in
    // 保存到 UserDefaults
    // 使用 Trip ID 作为 Key 的一部分，确保每个 Trip 的状态独立保存
    let key = "weatherSectionCollapsed_\(trip.id.uuidString)"
    UserDefaults.standard.set(newValue, forKey: key)
}

// WeatherCard 调用
WeatherCard(
    forecasts: trip.weatherForecasts,
    destination: trip.destination,
    startDate: trip.startDate,
    endDate: trip.endDate,
    isCollapsed: $isWeatherCollapsed
)
```

**WeatherCard 修改**：
```swift
struct WeatherCard: View {
    let forecasts: [WeatherForecast]
    let destination: String
    let startDate: Date?
    let endDate: Date?
    @Binding var isCollapsed: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 头部（始终显示）
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Image(systemName: "location.fill")
                Text(destination.isEmpty ? "目的地" : destination)
                // 移除日期范围显示
                
                Spacer()
                
                // 收起/展开按钮
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        isCollapsed.toggle()
                    }
                } label: {
                    Image(systemName: isCollapsed ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            
            // 天气详情（根据 isCollapsed 显示/隐藏）
            if !isCollapsed {
                ScrollView(.horizontal, showsIndicators: false) {
                    // ... 天气卡片内容
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
            }
        }
        .background(...)
    }
}
```

### 3.3 Trip 基本设置 Section 设计

#### 3.3.1 UI/UX 设计（v1.0）

**布局结构**（v1.0 - 分组显示）：
```
┌─────────────────────────┐
│ ⚙️ 清单设置              │
│ 📅 2026/02/15 - 02/18   │
│ 旅行活动: 🏃跑步 🧗攀岩  │
│ 特定场合: 🎉宴会 💼商务   │
│ 出行配置: ✈️国际旅行     │
└─────────────────────────┘
```

**布局结构**（v1.1 - 不分组，可收起/展开）：
```
展开状态：
┌─────────────────────────┐
│ ⚙️ 清单设置      ✏️  ▼ │
│ 📅 2026/02/15 - 02/18   │
│ 🏃跑步 🎉宴会 ✈️国际旅行 │
└─────────────────────────┘

收起状态：
┌─────────────────────────┐
│ ⚙️ 清单设置      ✏️  ▲ │
└─────────────────────────┘
```

#### 3.3.2 技术实现要点

**文件**：创建新组件 `SmartPack/SmartPack/Components/PackingList/TripSettingsCard.swift`

**组件结构**（v1.1）：
```swift
struct TripSettingsCard: View {
    @Bindable var trip: Trip
    @EnvironmentObject var localization: LocalizationManager
    @State private var isCollapsed = false
    @State private var showEditSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) { // 紧凑：减小整体间距
            // 头部（始终显示）
            HStack {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                Text(localization.currentLanguage == .chinese ? "清单设置" : "List Settings")
                    .font(.system(size: 15, weight: .semibold))
                
                Spacer()
                
                // 编辑按钮（v1.1）
                Button {
                    showEditSheet = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                
                // 收起/展开按钮（v1.1）
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        isCollapsed.toggle()
                        // 保存状态
                        let key = "tripSettingsSectionCollapsed_\(trip.id.uuidString)"
                        UserDefaults.standard.set(isCollapsed, forKey: key)
                    }
                } label: {
                    Image(systemName: isCollapsed ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            
            // 设置详情（根据 isCollapsed 显示/隐藏，v1.1）
            if !isCollapsed {
                VStack(alignment: .leading, spacing: 6) { // 紧凑：减小内容间距
                    // 行程日期范围
                    if let startDate = trip.startDate, let endDate = trip.endDate {
                        HStack(spacing: 6) { // 紧凑：减小图标和文字间距
                            Image(systemName: "calendar")
                                .font(.system(size: 13))
                            Text(formatDateRange(start: startDate, end: endDate))
                                .font(.system(size: 13, weight: .regular))
                        }
                    }
                    
                    // 标签（v1.1：不分组，直接展示所有标签）
                    if !trip.selectedTags.isEmpty {
                        FlowLayout(spacing: 4) { // 紧凑：减小标签间距
                            ForEach(allSelectedTags) { tag in
                                TagChip(tag: tag)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
            }
        }
        .background(...)
        .onAppear {
            // 读取该 Trip 的收起状态（v1.1）
            let key = "tripSettingsSectionCollapsed_\(trip.id.uuidString)"
            isCollapsed = UserDefaults.standard.bool(forKey: key)
        }
        .sheet(isPresented: $showEditSheet) {
            // 编辑 Trip 设置的页面（v1.1）
            EditTripSettingsView(trip: trip)
        }
    }
    
    // 获取所有选定的标签（v1.1：不分组）
    private var allSelectedTags: [Tag] {
        trip.selectedTags.compactMap { tagId in
            PresetData.shared.allTags[tagId]
        }
    }
    
    private func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = localization.currentLanguage == .chinese ? "yyyy/MM/dd" : "MMM d, yyyy"
        let startStr = formatter.string(from: start)
        let endStr = formatter.string(from: end)
        return "\(startStr) - \(endStr)"
    }
}

struct TagChip: View {
    let tag: Tag
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        HStack(spacing: 3) { // 紧凑：减小图标和文字间距
            Image(systemName: tag.icon)
                .font(.system(size: 10)) // 紧凑：减小图标尺寸
            Text(tag.displayName(language: localization.currentLanguage))
                .font(.system(size: 11, weight: .medium)) // 紧凑：减小文字尺寸
        }
        .padding(.horizontal, 8) // 紧凑：减小水平内边距
        .padding(.vertical, 4) // 紧凑：减小垂直内边距
        .background(Color(.systemGray6))
        .cornerRadius(6) // 紧凑：减小圆角
    }
}
```

**编辑 Trip 设置页面（v1.1）**：
```swift
struct EditTripSettingsView: View {
    @Bindable var trip: Trip
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var localization: LocalizationManager
    
    // 编辑状态
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var selectedActivityTags: Set<String>
    @State private var selectedOccasionTags: Set<String>
    @State private var selectedConfigTags: Set<String>
    
    init(trip: Trip) {
        self.trip = trip
        // 初始化编辑状态，预填充当前 Trip 的设置
        _startDate = State(initialValue: trip.startDate ?? Date())
        _endDate = State(initialValue: trip.endDate ?? Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date())
        
        // 根据当前选定的标签，分类到不同的 Set
        var activityTags: Set<String> = []
        var occasionTags: Set<String> = []
        var configTags: Set<String> = []
        
        for tagId in trip.selectedTags {
            if let tag = PresetData.shared.allTags[tagId] {
                switch tag.group {
                case .activity: activityTags.insert(tagId)
                case .occasion: occasionTags.insert(tagId)
                case .config: configTags.insert(tagId)
                }
            }
        }
        
        _selectedActivityTags = State(initialValue: activityTags)
        _selectedOccasionTags = State(initialValue: occasionTags)
        _selectedConfigTags = State(initialValue: configTags)
    }
    
    var body: some View {
        NavigationStack {
            // 复用创建 Trip 的页面组件，但预填充当前设置
            TripConfigView(
                startDate: $startDate,
                endDate: $endDate,
                selectedActivityTags: $selectedActivityTags,
                selectedOccasionTags: $selectedOccasionTags,
                selectedConfigTags: $selectedConfigTags,
                isEditing: true
            )
            .navigationTitle(localization.currentLanguage == .chinese ? "编辑清单设置" : "Edit Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localization.currentLanguage == .chinese ? "取消" : "Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.currentLanguage == .chinese ? "完成" : "Done") {
                        updateTrip()
                    }
                }
            }
        }
    }
    
    private func updateTrip() {
        // 更新 Trip 的日期
        trip.startDate = startDate
        trip.endDate = endDate
        
        // 合并所有选定的标签
        let allSelectedTags = selectedActivityTags.union(selectedOccasionTags).union(selectedConfigTags)
        trip.selectedTags = Array(allSelectedTags)
        
        // 重新生成物品清单
        let gender = Gender(rawValue: trip.gender) ?? .male
        let newItems = PresetData.shared.generatePackingList(
            tagIds: Array(allSelectedTags),
            gender: gender
        )
        
        // 更新 Trip 的物品列表
        trip.items = newItems
        
        // 保存到 SwiftData
        try? modelContext.save()
        
        // 返回清单页面
        dismiss()
    }
}
```

**在 PackingListView 中使用**：
```swift
Section {
    VStack(spacing: 0) {
        progressHeader
        
        // 新增：Trip 基本设置 Section（v1.0/v1.1）
        if trip.totalCount > 0 {
            TripSettingsCard(trip: trip)
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.xs)
        }
        
        // Weather Section
        if trip.hasWeatherData {
            WeatherCard(...)
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.xs)
        }
    }
    ...
}
```

---

## 4. 改动影响范围

### 4.1 涉及文件

- **`SmartPack/SmartPack/Components/PackingList/ProgressHeader.swift`**
  - 简化进度显示，移除标题和剩余物品文本
  - 将计数文字叠加显示在进度条上
  - 调整布局和内边距

- **`SmartPack/SmartPack/Views/Shared/WeatherCard.swift`**
  - 添加收起/展开功能
  - 添加收起/展开按钮
  - 添加状态绑定参数
  - 移除日期范围显示（不再显示"几号到几号"）

- **`SmartPack/SmartPack/Views/Trip/PackingListView.swift`**
  - 添加 Weather Section 收起状态管理
  - 添加 Trip 基本设置 Section 的显示逻辑
  - 调整 Section 顺序和布局

- **新建文件：`SmartPack/SmartPack/Components/PackingList/TripSettingsCard.swift`**
  - 创建 Trip 基本设置展示组件
  - v1.0：显示行程日期范围、场景标签（按分组）
  - v1.1：标签不分组显示，添加收起/展开功能，添加编辑功能

- **新建文件（v1.1）：`SmartPack/SmartPack/Views/Trip/EditTripSettingsView.swift`**
  - 创建 Trip 设置编辑页面
  - 预填充当前 Trip 的设置（日期、标签）
  - 允许用户修改设置
  - 更新 Trip 并重新生成清单

### 4.2 数据模型

- **`Trip` 模型**：无需修改，已有 `startDate`、`endDate`、`selectedTags`、`items` 字段
- **`Tag` 模型**：无需修改，已有 `group`、`icon`、`displayName` 方法
- **`PresetData`**：无需修改，已有 `allTags` 字典和 `generatePackingList()` 方法
- **`TripConfigView` 或类似组件（v1.1）**：可能需要修改以支持编辑模式（预填充设置）

### 4.3 用户体验影响

- **正面影响**：
  - 进度显示更简洁，减少视觉干扰
  - 天气信息可根据需求收起，节省屏幕空间
  - 新增的设置展示让用户清楚了解清单生成依据
  - 提升信息透明度和用户信任度
  - v1.1：用户可以随时编辑和更新 Trip 设置，提升灵活性
  - v1.1：标签不分组显示，更简洁直观

- **注意事项**：
  - **Weather Section 收起状态需要以每个 Trip 为单位独立持久化**，避免用户每次进入都需要重新收起，同时确保不同 Trip 之间的状态互不影响
  - **Trip 基本设置 Section 收起状态也需要以每个 Trip 为单位独立持久化**（v1.1）
  - Trip 基本设置 Section 只在清单生成后显示，避免空状态
  - 标签显示需要支持多行布局（FlowLayout），避免标签过多时溢出
  - **编辑 Trip 设置后，需要重新生成物品清单**，确保清单与设置一致（v1.1）
  - 编辑时需要考虑已勾选的物品状态（可能需要清空或保留，根据产品策略决定）（v1.1）

---

## 5. 验收标准

### 5.1 功能验收

- ✅ **简化打包进度 Section**：
  - 进度条正常显示，无标题和剩余物品文本
  - 计数文字正确叠加显示在进度条上
  - 计数文字可读性良好（颜色对比度足够）
  - 完成状态提示正常显示
  - 进度条动画流畅
  - 布局紧凑，视觉简洁

- ✅ **Weather Section 可收起/展开**：
  - **每个 Trip 独立管理**：首次进入某个 Trip 的页面时默认展开
  - 点击收起按钮后，天气详情隐藏
  - 点击展开按钮后，天气详情显示
  - **状态独立持久化**：每个 Trip 的收起状态正确持久化（刷新页面后保持）
  - **状态互不影响**：Trip A 的收起状态不影响 Trip B 的状态
  - 展开/收起动画流畅
  - 头部不显示日期范围（"几号到几号"）

- ✅ **Trip 基本设置 Section（v1.0）**：
  - 在进度条和天气之间正确显示
  - 只在清单生成后显示（`trip.items.count > 0`）
  - 正确显示行程日期范围（几号到几号）
  - 正确显示场景标签（按分组显示）
  - 标签按分组正确显示
  - 标签图标和名称正确显示
  - 支持中英文切换
  - **紧凑排版**：标签之间间距较小，分组标题和标签在同一行显示，整体布局节省空间

- ✅ **Trip 基本设置 Section（v1.1 增强）**：
  - 标签不分组显示，直接展示所有选定的标签
  - **收起/展开功能**：
    - 每个 Trip 独立管理收起/展开状态
    - 首次进入某个 Trip 的页面时默认展开
    - 收起状态正确持久化（刷新页面后保持）
    - 不同 Trip 之间的收起/展开状态互不影响
    - 展开/收起动画流畅
  - **编辑功能**：
    - 编辑按钮正确显示在 Section 头部
    - 点击编辑按钮后，正确进入编辑页面（Sheet）
    - 编辑页面预填充当前 Trip 的设置（日期、标签）
    - 可以修改日期范围
    - 可以添加或删除标签
    - 编辑完成后，Trip 正确更新
    - 物品清单根据新设置重新生成
    - 编辑后自动返回清单页面
    - 取消编辑时，Trip 设置保持不变

### 5.2 用户体验验收

- ✅ 进度条简洁清晰，不占用过多空间
- ✅ Weather Section 收起/展开操作流畅，状态持久化正常
- ✅ Trip 基本设置 Section 信息清晰，帮助用户理解清单生成依据
- ✅ Trip 基本设置 Section 排版紧凑，节省屏幕空间
- ✅ v1.1：Trip 基本设置 Section 收起/展开操作流畅，状态持久化正常
- ✅ v1.1：Trip 基本设置 Section 编辑功能正常，更新后清单正确重新生成
- ✅ 所有 Section 布局协调，视觉统一

### 5.3 边界情况验收

- ✅ 没有选择任何标签时，Trip 基本设置 Section 只显示日期范围
- ✅ 选择了大量标签时，标签正确换行显示，不溢出
- ✅ Weather Section 收起后，页面布局正常，无空白区域
- ✅ Trip 设置 Section 收起后，页面布局正常，无空白区域（v1.1）
- ✅ 进度为 0% 或 100% 时，进度条显示正常
- ✅ 已归档的 Trip 显示正常（保留"已归档"标签）
- ✅ **关键测试：不同 Trip 的 Weather Section 状态独立**
  - 测试场景 1：收起 Trip A 的 Weather Section，切换到 Trip B，Trip B 的 Weather Section 状态不受影响
  - 测试场景 2：收起 Trip A 的 Weather Section，退出应用后重新进入 Trip A，Weather Section 保持收起状态
  - 测试场景 3：Trip A 收起，Trip B 展开，两个状态互不影响
- ✅ **关键测试：不同 Trip 的 Trip 设置 Section 状态独立（v1.1）**
  - 测试场景 1：收起 Trip A 的设置 Section，切换到 Trip B，Trip B 的设置 Section 状态不受影响
  - 测试场景 2：收起 Trip A 的设置 Section，退出应用后重新进入 Trip A，设置 Section 保持收起状态
  - 测试场景 3：Trip A 收起，Trip B 展开，两个状态互不影响
- ✅ **关键测试：编辑 Trip 设置功能（v1.1）**
  - 测试场景 1：编辑日期范围，Trip 正确更新，清单重新生成
  - 测试场景 2：添加标签，新标签的物品正确添加到清单
  - 测试场景 3：删除标签，对应标签的物品正确从清单移除
  - 测试场景 4：同时修改日期和标签，所有更改正确应用
  - 测试场景 5：编辑后取消，Trip 设置保持不变
  - 测试场景 6：编辑后删除所有标签，清单正确更新（只保留基础物品）

---

## 6. 技术实现建议

### 6.1 代码组织

- 保持现有代码风格和命名规范
- 新建 `TripSettingsCard` 组件，保持组件化设计
- v1.1：新建 `EditTripSettingsView` 组件，用于编辑 Trip 设置
- **必须使用 Trip 特定设置**：
  - Weather Section 收起状态：使用 `UserDefaults` 管理，Key：`"weatherSectionCollapsed_\(trip.id.uuidString)"`
  - Trip 设置 Section 收起状态（v1.1）：使用 `UserDefaults` 管理，Key：`"tripSettingsSectionCollapsed_\(trip.id.uuidString)"`
  - 确保每个 Trip 的状态独立保存，互不影响
- 添加适当的注释说明新功能，强调每个 Trip 的状态独立管理
- v1.1：编辑功能可以复用现有的 Trip 创建页面组件，或创建独立的编辑视图

### 6.2 布局建议

- 使用 `FlowLayout` 或 `LazyVGrid` 实现标签的多行布局
- **紧凑排版**：
  - 减小 VStack/HStack 的 spacing 值（建议 4-6pt）
  - v1.0：分组标题和标签在同一行显示（使用 HStack），节省垂直空间
  - v1.1：标签不分组显示，直接展示所有标签
  - 标签 Chip 使用较小的 padding（水平 8pt，垂直 4pt）
  - 标签之间间距较小（建议 4pt）
  - 字体和图标尺寸适当减小，保持可读性的同时节省空间
- 保持与现有 Section 的视觉风格一致（圆角、内边距、背景色）
- 考虑使用 `DisclosureGroup` 实现 Weather Section 和 Trip 设置 Section 的收起/展开（如果 SwiftUI 版本支持）

### 6.3 性能考虑

- Weather Section 和 Trip 设置 Section 收起状态使用轻量级存储（`UserDefaults`）
- Trip 基本设置 Section 只在需要时渲染（`if trip.totalCount > 0`）
- 标签渲染使用 `ForEach`，支持大量标签的场景
- v1.1：编辑 Trip 设置时，需要重新生成物品清单，注意性能影响
- v1.1：编辑页面可以延迟加载，只在用户点击编辑按钮时才创建

---

## 7. 后续优化建议（可选）

### 7.1 用户体验优化

- v1.1：考虑在编辑 Trip 设置时，保留已勾选的物品状态（如果物品在新清单中仍然存在）
- v1.1：考虑添加编辑确认提示，告知用户编辑后清单会重新生成
- 考虑在 Weather Section 收起时显示简要天气信息（如最高温/最低温）

### 7.2 功能扩展

- 考虑添加设置项的复制功能（复制为新的 Trip）
- 考虑添加设置历史记录（查看之前使用的设置）
- 考虑添加设置模板功能（保存常用设置组合）

---

## 8. 附录

### 8.1 相关文档

- `PRD-SmartPack-v1.0.md` - 主 PRD 文档
- `PRD-Trip-Settings-Enhancement.md` - Trip 设置增强独立 PRD（v1.1 功能的详细版本）
- `ProgressHeader.swift` - 进度头部组件
- `WeatherCard.swift` - 天气卡片组件
- `PackingListView.swift` - 打包清单页面
- `Trip.swift` - Trip 模型定义
- `Tag.swift` - 标签模型定义

### 8.2 参考资源

- SwiftUI DisclosureGroup 文档
- SwiftUI Sheet 文档
- SwiftUI AppStorage 文档
- iOS Human Interface Guidelines

---

**文档状态**：待评审  
**下一步**：评审通过后，按照本 PRD 进行技术实现。
