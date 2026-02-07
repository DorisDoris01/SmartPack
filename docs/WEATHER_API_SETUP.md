# 天气 API 配置说明

## OpenWeatherMap API 设置

### 1. 注册 API Key

1. 访问 [OpenWeatherMap](https://openweathermap.org/api)
2. 注册账号并登录
3. 进入 API Keys 页面
4. 创建一个新的 API Key（免费版每天 1000 次调用）

### 2. 配置 API Key

**方法 1：直接在代码中配置（仅用于开发）**

编辑 `SmartPack/SmartPack/Services/WeatherService.swift`：

```swift
private let apiKey = "YOUR_ACTUAL_API_KEY_HERE"
```

**方法 2：使用环境变量（推荐用于生产）**

1. 在 Xcode 中，选择项目 Target
2. 进入 "Build Settings"
3. 添加 User-Defined Setting：`WEATHER_API_KEY`
4. 在代码中读取：

```swift
private let apiKey: String = {
    if let key = ProcessInfo.processInfo.environment["WEATHER_API_KEY"] {
        return key
    }
    // 从 Info.plist 读取
    return Bundle.main.object(forInfoDictionaryKey: "WeatherAPIKey") as? String ?? ""
}()
```

### 3. 测试天气功能

1. 创建新行程时，输入目的地（如"北京"）
2. 选择出发和返回日期
3. 生成行程后，天气卡片会自动显示在清单页面顶部

### 4. 注意事项

- **免费版限制**：每天 1000 次 API 调用
- **API Key 安全**：不要将 API Key 提交到公开代码仓库
- **错误处理**：如果 API Key 未配置或查询失败，会使用模拟数据，不影响核心功能

### 5. 备选方案

如果不想使用 OpenWeatherMap，可以修改 `WeatherService.swift` 使用其他天气 API：

- **WeatherAPI**: https://www.weatherapi.com/
- **AccuWeather**: https://developer.accuweather.com/

只需修改 `fetchWeatherForecast` 方法的实现即可。
