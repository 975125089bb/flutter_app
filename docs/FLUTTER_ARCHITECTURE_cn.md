

# Flutter应用架构文档

## 概述
现代相亲应用遵循基于Flutter最佳实践的清洁、可扩展架构。应用结构旨在分离关注点、促进可重用性并确保可维护性。

## 架构模式
应用使用**面向服务的架构**，包含以下层次：
- **表示层**: 屏幕和小部件（UI）
- **业务逻辑层**: 服务和模型
- **数据层**: 数据模型和提供者

## 项目结构

### 根级结构
```
lib/
├── main.dart                    # 应用程序入口点
├── constants/                   # 应用程序范围的常量
├── data/                        # 数据模型和提供者
├── models/                      # 业务逻辑模型
├── screens/                     # 屏幕级小部件
├── services/                    # 业务逻辑服务
└── widgets/                     # 可重用UI组件
```

## 详细组件文档

### 1. 应用程序入口点

#### main.dart
**目的**: 应用程序引导和配置

**主要职责**:
- 初始化Flutter应用程序
- 配置主题和样式
- 设置路由
- 定义全局应用程序设置

**代码结构**:
```dart
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  // 应用程序配置和主题设置
  // Material 3主题与粉色配色方案
  // 全局应用程序设置和导航设置
}
```

**主题配置**:
- **主色**: 粉色400 (#EC407A)
- **设计系统**: Material 3
- **排版**: 现代、干净的字体与适当的权重
- **卡片设计**: 圆角（16px半径）带阴影
- **按钮样式**: 圆形按钮与一致的填充

### 2. 常量层

#### constants/routes.dart
**目的**: 集中化路由管理

**功能**:
- 命名路由定义
- 路由参数处理
- 导航工具
- 深度链接支持

### 3. 数据层

#### data/character.dart
**目的**: 核心角色数据模型

**属性**:
```dart
class Character {
  // 身份标识
  final String id;
  final String? gender;
  
  // 人口统计信息
  final int age;
  final int? height;
  final double? bmi;
  
  // 个性特征
  final String? zodiac;
  final String? mbti;
  
  // 位置信息
  final String? hometown;
  final String currentLocation;
  
  // 生活方式
  final String occupation;
  final List<String> interests;
  final bool? hasHouse;
  final bool? hasCar;
  final String? maritalStatus;
  
  // 内容
  final String rawText;
  final String? image;
  
  // 用户交互（可变的）
  bool isBookmarked;
  bool isLiked;
  bool isRejected;
  String note;
}
```

**主要方法**:
- `fromJson()`: JSON反序列化
- `toJson()`: JSON序列化
- `copyWith()`: 不可变更新
- `toMap()`: 数据持久化
- 用于数据格式化和验证的工具方法

#### data/characters_data.dart
**目的**: 静态角色数据提供者

**功能**:
- 预加载的角色数据集
- 数据初始化和缓存
- 多数据源支持
- 数据验证和完整性检查

### 4. 模型层

#### models/filter_options.dart
**目的**: 过滤和搜索配置

**类**:
```dart
class FilterOptions {
  // 年龄过滤
  final int minAge;
  final int maxAge;
  
  // 位置过滤
  final List<String> locations;
  final double? maxDistance;
  
  // 生活方式过滤
  final List<String> interests;
  final List<String> mbtiTypes;
  final List<String> zodiacSigns;
  
  // 资产过滤
  final bool? requiresHouse;
  final bool? requiresCar;
  
  // 状态过滤
  final List<String> maritalStatuses;
}
```

### 5. 服务层

#### services/character_service.dart
**目的**: 业务逻辑和数据管理

**主要职责**:
- 角色数据加载和缓存
- 过滤和搜索操作
- 用户交互管理（收藏、点赞）
- 数据持久化和状态管理
- 业务规则执行

**主要方法**:
```dart
class CharacterService {
  // 数据管理
  Future<List<Character>> loadCharacters();
  Future<void> saveCharacters(List<Character> characters);
  
  // 过滤
  List<Character> filterCharacters(List<Character> characters, FilterOptions options);
  List<Character> searchCharacters(String query);
  
  // 用户交互
  void toggleBookmark(String characterId);
  void likeCharacter(String characterId);
  void rejectCharacter(String characterId);
  void addNote(String characterId, String note);
  
  // 统计
  int getBookmarkCount();
  int getLikeCount();
  Map<String, int> getInterestStatistics();
}
```

### 6. 屏幕层

#### screens/home_screen.dart
**目的**: 主要角色发现界面

**功能**:
- 角色卡片显示
- 滑动手势处理
- 过滤器集成
- 搜索功能
- 导航控制

**状态管理**:
```dart
class _HomeScreenState extends State<HomeScreen> {
  List<Character> characters = [];
  List<Character> filteredCharacters = [];
  FilterOptions currentFilters = FilterOptions();
  int currentIndex = 0;
  bool isLoading = false;
}
```

**主要UI组件**:
- 角色卡片堆栈
- 过滤器按钮和对话框
- 搜索栏
- 导航抽屉
- 统计显示

#### screens/bookmarks_screen.dart
**目的**: 已保存资料管理

**功能**:
- 已收藏角色显示
- 笔记编辑功能
- 删除功能
- 排序和过滤选项

### 7. 小部件层

#### widgets/character_card.dart
**目的**: 单个角色资料显示

**功能**:
- 响应式卡片布局
- 图片显示与后备方案
- 全面的角色信息
- 交互元素（收藏、点赞按钮）
- 详细信息的可展开部分

**布局结构**:
```dart
Card(
  child: Column(
    children: [
      // 带图片和基本信息的标题
      CharacterHeader(),
      
      // 人口统计部分
      DemographicsSection(),
      
      // 兴趣和个性
      InterestsSection(),
      
      // 位置和生活方式
      LifestyleSection(),
      
      // 操作按钮
      ActionButtonsSection(),
    ],
  ),
)
```

#### widgets/sliding_widget.dart
**目的**: 滑动交互组件

**功能**:
- 手势检测（左右滑动）
- 流畅的动画和过渡
- 用户操作的视觉反馈
- 可自定义的滑动敏感度
- 支持各种滑动操作

**动画系统**:
```dart
class SlidingWidget extends StatefulWidget {
  // 用于流畅过渡的动画控制器
  late AnimationController _slideController;
  late AnimationController _scaleController;
  
  // 用于滑动检测的手势处理
  void _handlePanUpdate(DragUpdateDetails details);
  void _handlePanEnd(DragEndDetails details);
}
```

#### widgets/filter_dialog_enhanced.dart
**目的**: 高级过滤界面

**功能**:
- 多条件过滤
- 数值范围滑块
- 类别的多选选项
- 实时过滤预览
- 过滤器预设管理

**过滤类别**:
- 年龄范围选择
- 基于位置的过滤
- 兴趣匹配
- MBTI兼容性
- 星座偏好
- 资产要求（房屋、汽车）
- 婚姻状况选项

#### widgets/expanding_widget.dart
**目的**: 可展开内容部分

**功能**:
- 流畅的展开/收缩动画
- 内容溢出处理
- 可自定义的展开触发器
- 大内容的性能优化

#### widgets/page_indicator.dart
**目的**: 视觉导航指示器

**功能**:
- 基于点的页面指示
- 页面间的流畅过渡
- 可自定义的样式和颜色
- 触摸交互支持

#### widgets/stats_widget.dart
**目的**: 统计显示组件

**功能**:
- 数据可视化
- 实时统计更新
- 交互式图表和图形
- 导出功能

## 数据流架构

### 角色加载流程
```
应用启动
    ↓
CharacterService.loadCharacters()
    ↓
从 characters_data.dart 加载
    ↓
应用数据验证
    ↓
初始化用户交互状态
    ↓
缓存到内存
    ↓
更新UI (HomeScreen)
```

### 过滤流程
```
用户应用过滤器 (FilterDialog)
    ↓
创建 FilterOptions
    ↓
CharacterService.filterCharacters()
    ↓
应用过滤条件
    ↓
返回过滤后的列表
    ↓
更新 HomeScreen 状态
    ↓
重新渲染角色卡片
```

### 用户交互流程
```
用户操作 (点赞, 收藏, 笔记)
    ↓
调用 CharacterService 方法
    ↓
更新角色状态
    ↓
本地持久化更改
    ↓
通知UI状态变化
    ↓
更新视觉反馈
```

## 状态管理

### 本地状态
每个屏幕和小部件使用 `setState()` 管理自己的本地状态：
- UI特定状态（加载、错误状态）
- 表单数据和输入验证
- 动画状态和过渡

### 共享状态
角色数据和用户交互通过以下方式管理：
- **CharacterService**: 集中化业务逻辑
- **静态数据**: 预加载的角色信息
- **本地存储**: 持久化用户偏好和交互

### 状态持久化
```dart
// 保存用户交互
SharedPreferences prefs = await SharedPreferences.getInstance();
prefs.setStringList('bookmarked_ids', bookmarkedIds);
prefs.setString('user_filters', jsonEncode(filterOptions));
```

## 导航架构

### 路由结构
```dart
// 主要导航路由
static const String home = '/';
static const String bookmarks = '/bookmarks';
static const String profile = '/profile';
static const String settings = '/settings';
```

### 导航模式
应用使用以下组合：
- **抽屉导航**: 主要部分的侧边菜单
- **底部导航**: 核心功能的快速访问
- **堆栈导航**: 模态屏幕和详细视图

## 主题和样式

### 设计系统
```dart
ThemeData(
  // 配色方案
  primarySwatch: Colors.pink,
  primaryColor: Colors.pink.shade400,
  
  // 排版
  textTheme: TextTheme(
    headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
  ),
  
  // 组件主题
  cardTheme: CardThemeData(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
)
```

### 响应式设计
- **断点**: 支持移动端、平板和桌面
- **自适应布局**: 适应屏幕尺寸的响应式小部件
- **平台考虑**: iOS/Android特定的UI调整

## 性能优化

### 延迟加载
- 按需加载角色图片
- 大数据集的列表虚拟化
- 角色浏览的分页

### 内存管理
- 高效的图片缓存
- 释放未使用的资源
- 优化小部件重建

### 构建优化
```dart
// 尽可能使用const构造函数
const CharacterCard(character: character);

// 实现高效的shouldRebuild逻辑
@override
bool shouldRebuild(covariant CharacterCardDelegate oldDelegate) {
  return oldDelegate.character != character;
}
```

## 测试架构

### 单元测试
- 业务逻辑测试（CharacterService）
- 数据模型验证
- 工具函数测试

### 小部件测试
- UI组件测试
- 用户交互模拟
- 状态管理验证

### 集成测试
- 端到端用户流程
- 导航测试
- 数据持久化验证

## 平台考虑

### Android
- Material Design合规性
- 返回按钮处理
- Android特定权限

### iOS
- 适当时使用Cupertino设计元素
- iOS导航模式
- App Store合规性

### Web
- 响应式网页设计
- URL路由支持
- Web特定优化

### 桌面 (Windows/macOS/Linux)
- 键盘导航
- 窗口管理
- 桌面特定UI模式

---

*此架构文档提供了Flutter应用结构的全面概述。有关实现细节，请参考各个源文件和内联文档。*