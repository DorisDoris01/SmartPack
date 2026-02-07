# SmartPack 天气集成功能需求规格说明 (Spec)

> **文档版本**：v1.0  
> **创建日期**：2026-02-07  
> **状态**：待实现

---

## 1. 需求概述

集成天气查询功能，根据用户输入的旅行时间和目的地，自动查询天气信息，并根据天气情况智能调整打包清单，同时在界面中以美观、简约的方式展示天气信息。

---

## 2. 功能需求详情

### 2.1 天气查询功能

| ID | 功能点 | 优先级 | 详细描述 |
|----|--------|--------|----------|
| **F-1.1** | **天气 API 集成** | **P0** | 集成天气 API（推荐使用 OpenWeatherMap 或 WeatherAPI），根据目的地和日期范围查询天气。 |
| **F-1.2** | **天气数据存储** | **P0** | 将查询到的天气数据存储到 Trip 模型中，包括：日期、温度、天气状况、降水概率等。 |
| **F-1.3** | **天气缓存** | **P1** | 实现天气数据缓存机制，避免重复查询相同目的地的天气。 |
| **F-1.4** | **查询时机** | **P0** | 在用户创建 Trip 时，如果有目的地和日期范围，自动查询天气。 |

### 2.2 天气展示功能

| ID | 功能点 | 优先级 | 详细描述 |
|----|--------|--------|----------|
| **F-2.1** | **天气卡片展示** | **P0** | 在 PackingListView 的进度头部下方，以卡片形式展示天气信息，设计简约美观。 |
| **F-2.2** | **多日天气展示** | **P0** | 如果行程多天，展示每日天气（最多显示 7 天），支持横向滚动。 |
| **F-2.3** | **天气图标** | **P0** | 使用 SF Symbols 或自定义图标展示天气状况（晴天、雨天、多云等）。 |
| **F-2.4** | **温度显示** | **P0** | 显示最高温度和最低温度，使用合适的颜色（冷色/暖色）。 |

### 2.3 智能物品调整功能

| ID | 功能点 | 优先级 | 详细描述 |
|----|--------|--------|----------|
| **F-3.1** | **雨天物品** | **P0** | 如果预报有雨，自动添加雨伞、雨衣等物品。 |
| **F-3.2** | **温度相关物品** | **P0** | 根据温度范围调整衣物建议（如低温添加保暖衣物，高温添加防晒用品）。 |
| **F-3.3** | **天气标签** | **P1** | 在生成的物品上标记天气原因（如"雨天建议"），方便用户了解添加原因。 |

---

## 3. 技术实现

### 3.1 天气 API 选择

**推荐方案：OpenWeatherMap**
- 免费额度：1000 次/天
- 支持多日预报
- 文档完善，易于集成

**备选方案：WeatherAPI**
- 免费额度：100 万次/月
- 支持历史天气和预报
- 响应速度快

### 3.2 数据模型扩展

**Trip 模型扩展**：
```swift
@Model
final class Trip {
    // ... 现有字段
    
    var destination: String = ""  // 目的地
    var startDate: Date? = nil   // 出发日期
    var endDate: Date? = nil     // 返回日期
    var weatherData: Data? = nil  // 天气数据（序列化的 [WeatherForecast]）
    
    /// 获取天气预报
    var weatherForecasts: [WeatherForecast] {
        get {
            guard let data = weatherData else { return [] }
            return (try? JSONDecoder().decode([WeatherForecast].self, from: data)) ?? []
        }
        set {
            weatherData = try? JSONEncoder().encode(newValue)
        }
    }
}
```

**WeatherForecast 模型**：
```swift
struct WeatherForecast: Codable, Identifiable {
    let id: UUID
    let date: Date
    let highTemp: Double      // 最高温度（摄氏度）
    let lowTemp: Double       // 最低温度（摄氏度）
    let condition: String     // 天气状况（如 "clear", "rain", "cloudy"）
    let conditionDescription: String  // 天气描述（如 "晴天", "小雨"）
    let precipitationChance: Double   // 降水概率（0-1）
    let icon: String          // 天气图标名称
    
    var displayCondition: String {
        // 根据 condition 返回本地化描述
    }
    
    var weatherIcon: String {
        // 根据 condition 返回 SF Symbol 名称
    }
}
```

### 3.3 天气服务实现

**WeatherService**：
```swift
class WeatherService {
    static let shared = WeatherService()
    private let apiKey = "YOUR_API_KEY"
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    
    /// 查询天气预报
    func fetchWeatherForecast(
        city: String,
        startDate: Date,
        endDate: Date
    ) async throws -> [WeatherForecast] {
        // 实现天气查询逻辑
    }
    
    /// 根据天气调整物品
    func adjustItemsForWeather(
        items: [TripItem],
        forecasts: [WeatherForecast]
    ) -> [TripItem] {
        var adjustedItems = items
        
        // 检查是否有雨天
        let hasRain = forecasts.contains { $0.precipitationChance > 0.3 }
        if hasRain {
            // 添加雨具
            adjustedItems.append(createRainItem())
        }
        
        // 检查温度范围
        let avgTemp = forecasts.map { ($0.highTemp + $0.lowTemp) / 2 }.reduce(0, +) / Double(forecasts.count)
        if avgTemp < 10 {
            // 添加保暖物品
            adjustedItems.append(contentsOf: createWarmItems())
        } else if avgTemp > 25 {
            // 添加防晒物品
            adjustedItems.append(contentsOf: createSunProtectionItems())
        }
        
        return adjustedItems
    }
}
```

---

## 4. UI 设计

### 4.1 天气卡片设计（简约美观）

```
┌─────────────────────────────────────┐
│  🌤️  北京                           │
│  2月7日 - 2月10日                   │
│                                     │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ │
│  │ 7日 │ │ 8日 │ │ 9日 │ │10日 │ │
│  │ ☀️  │ │ 🌧️  │ │ ☁️  │ │ ☀️  │ │
│  │ 8°  │ │ 5°  │ │ 6°  │ │ 9°  │ │
│  │ 2°  │ │ 1°  │ │ 2°  │ │ 3°  │ │
│  └─────┘ └─────┘ └─────┘ └─────┘ │
└─────────────────────────────────────┘
```

### 4.2 实现位置

在 `PackingListView` 的 `progressHeader` 下方添加天气卡片：

```swift
VStack(spacing: 0) {
    progressHeader
    weatherCard  // 新增天气卡片
    List { ... }
}
```

---

## 5. 实现步骤

### Phase 1: 天气 API 集成
1. 注册 OpenWeatherMap API Key
2. 创建 WeatherService
3. 实现天气查询功能
4. 创建 WeatherForecast 模型

### Phase 2: 数据模型扩展
1. 扩展 Trip 模型，添加天气相关字段
2. 在创建 Trip 时查询天气
3. 实现天气数据存储

### Phase 3: UI 实现
1. 创建 WeatherCard 组件
2. 在 PackingListView 中集成天气卡片
3. 实现多日天气展示

### Phase 4: 智能调整
1. 实现根据天气调整物品的逻辑
2. 在生成清单时应用天气调整
3. 添加天气标签说明

---

## 6. 注意事项

1. **API Key 安全**：API Key 应存储在安全位置，不要提交到代码仓库
2. **错误处理**：网络错误或 API 限制时应优雅降级，不影响核心功能
3. **性能优化**：天气查询应在后台进行，不阻塞 UI
4. **国际化**：天气描述需要支持中英文
5. **隐私保护**：天气查询需要用户授权（可选）

---

*文档维护：实现时请同步更新本 Spec 与主 PRD，并标注完成状态。*
