# Clawhand iOS 开发规范

## 项目结构
```
clawhand-ios/
├── Sources/
│   ├── App/           # App entry, SceneDelegate
│   ├── Models/        # 数据模型 (Core Data)
│   ├── Views/         # SwiftUI 视图
│   ├── ViewModels/    # MVVM ViewModels
│   ├── Services/      # 网络、WebSocket 服务
│   └── Utils/         # 工具类
├── Resources/         # Assets, Localizations
└── Tests/
```

## 技术栈
- **UI**: SwiftUI (iOS 16+)
- **网络**: URLSession + Starscream (WebSocket)
- **存储**: Core Data
- **状态管理**: Combine
- **语音**: Speech Framework
- **推送**: APNs + UserNotifications

## 代码规范
- SwiftLint 检查
- SwiftUI View 不超过 200 行
- 业务逻辑放入 ViewModel
- 模型与服务层分离
