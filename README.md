# NotionCard

[English](#english) | [中文](#chinese)

<a name="english"></a>
## NotionCard - Your Notion Database Card Viewer

NotionCard is a macOS application that allows you to view and manage your Notion database content in a card-based interface. It provides a seamless experience for browsing and organizing your Notion pages.

### Features

- Card-based interface for Notion database content
- Real-time synchronization with Notion
- Rich text support with formatting
- Tag filtering and organization
- Offline access to cached content
- Network status monitoring
- Automatic retry mechanism for API requests

### Requirements

- macOS
- Notion API Key
- Notion Database ID

### Configuration

1. Create a `.env` file in the project root directory
2. Add the following environment variables:

```plaintext
NOTION_API_KEY=your_api_key_here
NOTION_DATABASE_ID=your_database_id_here
```

Or configure them in Xcode:
1. Open the scheme editor
2. Add environment variables under "Run" -> "Arguments"

### Development

1. Clone the repository
2. Open `NotionCard.xcodeproj` in Xcode
3. Configure the environment variables
4. Build and run the project

---

<a name="chinese"></a>
## NotionCard - Notion数据库卡片查看器

NotionCard 是一个macOS应用程序，允许您以卡片界面查看和管理Notion数据库内容。它为浏览和组织Notion页面提供了流畅的体验。

### 功能特点

- 卡片式界面展示Notion数据库内容
- 与Notion实时同步
- 支持富文本格式化
- 标签筛选和组织
- 离线访问缓存内容
- 网络状态监控
- API请求自动重试机制

### 系统要求

- macOS系统
- Notion API密钥
- Notion数据库ID

### 配置说明

1. 在项目根目录创建 `.env` 文件
2. 添加以下环境变量：

```plaintext
NOTION_API_KEY=你的API密钥
NOTION_DATABASE_ID=你的数据库ID
```

或在Xcode中配置：
1. 打开scheme编辑器
2. 在"Run" -> "Arguments"下添加环境变量

### 开发说明

1. 克隆仓库
2. 在Xcode中打开 `NotionCard.xcodeproj`
3. 配置环境变量
4. 构建并运行项目