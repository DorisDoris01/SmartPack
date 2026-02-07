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
- **调试提示**：如果天气功能不工作，请查看 Xcode 控制台的警告信息

### 5. 故障排除

如果天气 API 不工作，请检查以下几点：

1. **检查 API Key 配置**
   - 确认 `Info.plist` 中有 `WEATHER_API_KEY` 键
   - 确认 API Key 值不为空且不是占位符

2. **检查 API Key 有效性**
   - 在终端运行以下命令测试：
   ```bash
   curl "https://api.openweathermap.org/data/2.5/forecast?q=Beijing&appid=YOUR_API_KEY&units=metric&lang=zh_cn"
   ```
   - 如果返回 `{"cod":401,"message":"Invalid API key"}`，说明 API Key 无效

3. **查看控制台日志**
   - 运行应用时，查看 Xcode 控制台
   - 如果看到 `⚠️` 警告信息，说明遇到了问题但已自动使用模拟数据
   - 常见的警告信息：
     - `⚠️ 警告: WEATHER_API_KEY 未配置` - API Key 未找到
     - `⚠️ API Key 无效` - API Key 无效或过期
     - `⚠️ 网络错误` - 网络连接问题
     - `⚠️ 未找到城市` - 城市名称无法识别

4. **使用模拟数据**
   - 如果 API 不可用，应用会自动使用模拟数据
   - 模拟数据会显示随机温度（15-25°C）和天气状况
   - 这不会影响应用的正常使用

### 6. 备选方案

如果不想使用 OpenWeatherMap，可以修改 `WeatherService.swift` 使用其他天气 API：

- **WeatherAPI**: https://www.weatherapi.com/
- **AccuWeather**: https://developer.accuweather.com/

只需修改 `fetchWeatherForecast` 方法的实现即可。
