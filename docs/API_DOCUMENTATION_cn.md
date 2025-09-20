
# API和数据模型文档

## 概述
本文档为现代相亲应用中使用的所有数据模型、API和数据结构提供全面文档。涵盖了角色数据模式、服务API和数据流模式。

## 核心数据模型

### 1. 角色模型

#### 模式定义
```dart
class Character {
  // 身份字段
  final String id;                    // 唯一角色标识符
  final String? gender;               // "male", "female", 或 null
  
  // 人口统计信息
  final int age;                      // 年龄（18-100）
  final int? height;                  // 身高（厘米）
  final double? bmi;                  // 体质指数
  
  // 个性特征
  final String? zodiac;               // 星座
  final String? mbti;                 // 迈尔斯-布里格斯类型指标
  
  // 位置信息
  final String? hometown;             // 出生地/原籍地
  final String currentLocation;       // 现居住地
  
  // 职业信息
  final String occupation;            // 职业/专业
  
  // 兴趣和爱好
  final List<String> interests;       // 兴趣/爱好列表
  
  // 生活方式信息
  final bool? hasHouse;               // 房产所有权状态
  final bool? hasCar;                 // 汽车所有权状态
  final String? maritalStatus;        // "single", "divorced" 等
  
  // 内容
  final String rawText;               // 原始角色描述
  final String? image;                // 头像URL/路径
  
  // 用户交互状态（可变的）
  bool isBookmarked;                  // 用户收藏状态
  bool isLiked;                       // 用户点赞状态
  bool isRejected;                    // 用户拒绝状态
  String note;                        // 用户添加的笔记
}
```

#### 数据验证规则
```dart
// 年龄验证
assert(age >= 18 && age <= 100, '年龄必须在18到100之间');

// 身高验证（如果提供）
if (height != null) {
  assert(height >= 140 && height <= 220, '身高必须在140-220cm之间');
}

// 性别验证（如果提供）
if (gender != null) {
  assert(['male', 'female'].contains(gender), '性别必须是male或female');
}

// MBTI验证（如果提供）
if (mbti != null) {
  final validMbti = RegExp(r'^[EI][NS][TF][JP]$');
  assert(validMbti.hasMatch(mbti), 'MBTI格式无效');
}

// 兴趣验证
assert(interests.isNotEmpty, '兴趣列表不能为空');
```

#### JSON序列化
```dart
// 从JSON
factory Character.fromJson(Map<String, dynamic> json) {
  return Character(
    id: json['id'] as String,
    gender: json['gender'] as String?,
    age: json['age'] as int,
    height: json['height'] as int?,
    zodiac: json['zodiac'] as String?,
    mbti: json['mbti'] as String?,
    rawText: json['rawText'] as String,
    image: json['image'] as String?,
    bmi: json['bmi']?.toDouble(),
    hometown: json['hometown'] as String?,
    currentLocation: json['currentLocation'] as String,
    occupation: json['occupation'] as String,
    interests: List<String>.from(json['interests'] ?? []),
    hasHouse: json['hasHouse'] as bool?,
    hasCar: json['hasCar'] as bool?,
    maritalStatus: json['maritalStatus'] as String?,
    // 用户交互状态默认为false/空
    isBookmarked: json['isBookmarked'] ?? false,
    isLiked: json['isLiked'] ?? false,
    isRejected: json['isRejected'] ?? false,
    note: json['note'] ?? '',
  );
}

// 转JSON
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'gender': gender,
    'age': age,
    'height': height,
    'zodiac': zodiac,
    'mbti': mbti,
    'rawText': rawText,
    'image': image,
    'bmi': bmi,
    'hometown': hometown,
    'currentLocation': currentLocation,
    'occupation': occupation,
    'interests': interests,
    'hasHouse': hasHouse,
    'hasCar': hasCar,
    'maritalStatus': maritalStatus,
    'isBookmarked': isBookmarked,
    'isLiked': isLiked,
    'isRejected': isRejected,
    'note': note,
  };
}
```

### 2. 过滤选项模型

#### 模式定义
```dart
class FilterOptions {
  // 年龄过滤
  final int minAge;                   // 最小年龄（默认：18）
  final int maxAge;                   // 最大年龄（默认：100）
  
  // 位置过滤
  final List<String> selectedLocations; // 首选位置
  final double? maxDistance;          // 最大距离（公里）
  
  // 兴趣过滤
  final List<String> requiredInterests; // 必须的兴趣
  final List<String> preferredInterests; // 首选兴趣
  
  // 个性过滤
  final List<String> mbtiTypes;       // 首选MBTI类型
  final List<String> zodiacSigns;     // 首选星座
  
  // 生活方式过滤
  final bool? requiresHouse;          // 必须有房
  final bool? requiresCar;            // 必须有车
  final List<String> maritalStatuses; // 可接受的婚姻状况
  
  // 身体属性
  final int? minHeight;               // 最小身高（cm）
  final int? maxHeight;               // 最大身高（cm）
  final double? minBmi;               // 最小BMI
  final double? maxBmi;               // 最大BMI
  
  // 高级过滤器
  final List<String> excludedOccupations; // 排除的职业
  final bool showBookmarkedOnly;      // 仅显示收藏的资料
  final bool hideRejected;            // 隐藏被拒绝的资料
}
```

#### 默认值
```dart
static FilterOptions get defaultOptions => FilterOptions(
  minAge: 18,
  maxAge: 100,
  selectedLocations: [],
  requiredInterests: [],
  preferredInterests: [],
  mbtiTypes: [],
  zodiacSigns: [],
  maritalStatuses: ['single', 'divorced'],
  showBookmarkedOnly: false,
  hideRejected: true,
);
```

### 3. 统计模型

#### 模式定义
```dart
class AppStatistics {
  // 资料计数
  final int totalProfiles;            // 总资料数
  final int maleProfiles;             // 男性资料数
  final int femaleProfiles;           // 女性资料数
  
  // 用户交互统计
  final int bookmarkedCount;          // 已收藏资料数
  final int likedCount;               // 已点赞资料数
  final int rejectedCount;            // 已拒绝资料数
  final int profilesWithNotes;       // 有用户笔记的资料
  
  // 年龄分布
  final Map<String, int> ageGroups;   // 年龄组分布
  
  // 地点分布
  final Map<String, int> locationStats; // 地点流行度
  
  // 兴趣流行度
  final Map<String, int> interestStats; // 最受欢迎的兴趣
  
  // MBTI分布
  final Map<String, int> mbtiStats;   // MBTI类型分布
  
  // 活动指标
  final DateTime lastActivity;        // 上次用户活动
  final int dailyViews;              // 今日查看资料数
  final int weeklyViews;             // 本周查看资料数
}
```

## 服务API

### 1. 角色服务API

#### 核心方法

##### `loadCharacters()`
```dart
/// 从数据源加载所有角色数据
/// 返回: Future<List<Character>>
/// 抛出: 加载失败时抛出DataLoadException
Future<List<Character>> loadCharacters() async {
  try {
    // 从本地数据源加载
    final List<Map<String, dynamic>> rawData = await _loadRawData();
    
    // 转换为Character对象
    final characters = rawData.map((json) => Character.fromJson(json)).toList();
    
    // 应用验证
    characters.forEach(_validateCharacter);
    
    return characters;
  } catch (e) {
    throw DataLoadException('加载角色失败: $e');
  }
}
```

##### `filterCharacters()`
```dart
/// 根据提供的条件过滤角色
/// 参数:
///   - characters: 要过滤的角色列表
///   - options: 包含过滤条件的FilterOptions
/// 返回: List<Character> - 过滤后的角色列表
List<Character> filterCharacters(
  List<Character> characters, 
  FilterOptions options,
) {
  return characters.where((character) {
    // 年龄过滤器
    if (character.age < options.minAge || character.age > options.maxAge) {
      return false;
    }
    
    // 性别过滤器（如果指定）
    if (options.genderPreference != null && 
        character.gender != options.genderPreference) {
      return false;
    }
    
    // 位置过滤器
    if (options.selectedLocations.isNotEmpty && 
        !options.selectedLocations.contains(character.currentLocation)) {
      return false;
    }
    
    // 兴趣过滤器
    if (options.requiredInterests.isNotEmpty && 
        !_hasRequiredInterests(character.interests, options.requiredInterests)) {
      return false;
    }
    
    // 身高过滤器
    if (character.height != null) {
      if (options.minHeight != null && character.height! < options.minHeight!) {
        return false;
      }
      if (options.maxHeight != null && character.height! > options.maxHeight!) {
        return false;
      }
    }
    
    // MBTI过滤器
    if (options.mbtiTypes.isNotEmpty && 
        (character.mbti == null || !options.mbtiTypes.contains(character.mbti))) {
      return false;
    }
    
    // 资产过滤器
    if (options.requiresHouse == true && character.hasHouse != true) {
      return false;
    }
    if (options.requiresCar == true && character.hasCar != true) {
      return false;
    }
    
    // 用户交互过滤器
    if (options.showBookmarkedOnly && !character.isBookmarked) {
      return false;
    }
    if (options.hideRejected && character.isRejected) {
      return false;
    }
    
    return true;
  }).toList();
}
```

##### `searchCharacters()`
```dart
/// 基于文本查询搜索角色
/// 参数:
///   - query: 搜索查询字符串
///   - characters: 要搜索的角色列表
/// 返回: List<Character> - 匹配的角色
List<Character> searchCharacters(String query, List<Character> characters) {
  if (query.isEmpty) return characters;
  
  final lowercaseQuery = query.toLowerCase();
  
  return characters.where((character) {
    // 在多个字段中搜索
    final searchableText = [
      character.occupation.toLowerCase(),
      character.currentLocation.toLowerCase(),
      character.hometown?.toLowerCase() ?? '',
      character.interests.join(' ').toLowerCase(),
      character.mbti?.toLowerCase() ?? '',
      character.zodiac?.toLowerCase() ?? '',
      character.rawText.toLowerCase(),
    ].join(' ');
    
    return searchableText.contains(lowercaseQuery);
  }).toList();
}
```

##### 用户交互方法
```dart
/// 切换角色的收藏状态
/// 参数:
///   - characterId: 要收藏/取消收藏的角色ID
/// 返回: bool - 新的收藏状态
bool toggleBookmark(String characterId) {
  final character = _findCharacterById(characterId);
  if (character != null) {
    character.isBookmarked = !character.isBookmarked;
    _persistUserInteraction(characterId, 'bookmark', character.isBookmarked);
    return character.isBookmarked;
  }
  return false;
}

/// 标记角色为已点赞
/// 参数:
///   - characterId: 要点赞的角色ID
void likeCharacter(String characterId) {
  final character = _findCharacterById(characterId);
  if (character != null) {
    character.isLiked = true;
    character.isRejected = false; // 不能同时点赞和拒绝
    _persistUserInteraction(characterId, 'like', true);
  }
}

/// 标记角色为已拒绝
/// 参数:
///   - characterId: 要拒绝的角色ID
void rejectCharacter(String characterId) {
  final character = _findCharacterById(characterId);
  if (character != null) {
    character.isRejected = true;
    character.isLiked = false; // 不能同时点赞和拒绝
    _persistUserInteraction(characterId, 'reject', true);
  }
}

/// 为角色添加或更新笔记
/// 参数:
///   - characterId: 角色ID
///   - note: 要添加的笔记文本
void addNote(String characterId, String note) {
  final character = _findCharacterById(characterId);
  if (character != null) {
    character.note = note;
    _persistUserInteraction(characterId, 'note', note);
  }
}
```

### 2. 统计服务API

#### 方法
```dart
class StatisticsService {
  /// 生成全面的应用统计信息
  AppStatistics generateStatistics(List<Character> characters) {
    return AppStatistics(
      totalProfiles: characters.length,
      maleProfiles: characters.where((c) => c.gender == 'male').length,
      femaleProfiles: characters.where((c) => c.gender == 'female').length,
      bookmarkedCount: characters.where((c) => c.isBookmarked).length,
      likedCount: characters.where((c) => c.isLiked).length,
      rejectedCount: characters.where((c) => c.isRejected).length,
      profilesWithNotes: characters.where((c) => c.note.isNotEmpty).length,
      ageGroups: _calculateAgeGroups(characters),
      locationStats: _calculateLocationStats(characters),
      interestStats: _calculateInterestStats(characters),
      mbtiStats: _calculateMbtiStats(characters),
      lastActivity: DateTime.now(),
      dailyViews: _getDailyViews(),
      weeklyViews: _getWeeklyViews(),
    );
  }
}
```

## 数据流模式

### 1. 角色加载流程
```
应用初始化
        ↓
CharacterService.loadCharacters()
        ↓
从 characters_data.dart 加载
        ↓
解析JSON为Character对象
        ↓
应用数据验证
        ↓
加载用户交互状态
        ↓
缓存到内存
        ↓
通知UI组件
```

### 2. 过滤流程
```
用户输入 (FilterDialog)
        ↓
创建 FilterOptions 对象
        ↓
CharacterService.filterCharacters()
        ↓
依次应用过滤条件
        ↓
返回过滤后的角色列表
        ↓
更新UI状态
        ↓
重新渲染角色卡片
```

### 3. 用户交互流程
```
用户操作 (点赞/收藏/笔记)
        ↓
调用相应的服务方法
        ↓
更新角色对象状态
        ↓
持久化到本地存储
        ↓
通知UI状态变化
        ↓
更新视觉反馈
        ↓
可选择与远程服务同步
```

## 错误处理

### 异常类型
```dart
class DataException implements Exception {
  final String message;
  const DataException(this.message);
}

class DataLoadException extends DataException {
  const DataLoadException(String message) : super(message);
}

class ValidationException extends DataException {
  const ValidationException(String message) : super(message);
}

class PersistenceException extends DataException {
  const PersistenceException(String message) : super(message);
}
```

### 错误处理模式
```dart
try {
  final characters = await characterService.loadCharacters();
  setState(() {
    _characters = characters;
    _isLoading = false;
  });
} on DataLoadException catch (e) {
  _showErrorDialog('加载资料失败: ${e.message}');
} on ValidationException catch (e) {
  _showErrorDialog('数据验证错误: ${e.message}');
} catch (e) {
  _showErrorDialog('意外错误: $e');
} finally {
  setState(() => _isLoading = false);
}
```

## 数据持久化

### 本地存储模式
```dart
// SharedPreferences键
static const String keyBookmarkedIds = 'bookmarked_character_ids';
static const String keyLikedIds = 'liked_character_ids';
static const String keyRejectedIds = 'rejected_character_ids';
static const String keyCharacterNotes = 'character_notes';
static const String keyUserFilters = 'user_filter_preferences';
static const String keyLastActivity = 'last_activity_timestamp';
```

### 存储操作
```dart
// 保存用户交互
Future<void> _persistUserInteraction(
  String characterId, 
  String action, 
  dynamic value,
) async {
  final prefs = await SharedPreferences.getInstance();
  
  switch (action) {
    case 'bookmark':
      final bookmarked = prefs.getStringList(keyBookmarkedIds) ?? [];
      if (value as bool) {
        bookmarked.add(characterId);
      } else {
        bookmarked.remove(characterId);
      }
      await prefs.setStringList(keyBookmarkedIds, bookmarked);
      break;
      
    case 'note':
      final notes = prefs.getString(keyCharacterNotes);
      final notesMap = notes != null ? jsonDecode(notes) : <String, String>{};
      notesMap[characterId] = value as String;
      await prefs.setString(keyCharacterNotes, jsonEncode(notesMap));
      break;
  }
}
```

## 性能考虑

### 缓存策略
```dart
class DataCache {
  static final Map<String, List<Character>> _cache = {};
  static DateTime? _lastUpdated;
  static const Duration cacheTimeout = Duration(hours: 1);
  
  static bool get isValid => 
      _lastUpdated != null && 
      DateTime.now().difference(_lastUpdated!) < cacheTimeout;
      
  static List<Character>? get characters => 
      isValid ? _cache['characters'] : null;
      
  static void update(List<Character> characters) {
    _cache['characters'] = characters;
    _lastUpdated = DateTime.now();
  }
}
```

### 延迟加载
```dart
// 按需加载角色图片
Widget _buildCharacterImage(Character character) {
  return FadeInImage(
    placeholder: AssetImage('assets/images/placeholder.png'),
    image: character.image != null 
        ? NetworkImage(character.image!) 
        : AssetImage('assets/images/default_avatar.png'),
    fadeInDuration: Duration(milliseconds: 300),
  );
}
```

### 内存管理
```dart
// 不需要时释放资源
@override
void dispose() {
  _characterController.dispose();
  _filteredCharacters.clear();
  super.dispose();
}
```

## API集成（未来）

### REST API端点（计划中）
```
GET    /api/characters              # 获取所有角色
GET    /api/characters/:id          # 获取特定角色
POST   /api/characters              # 创建新角色
PUT    /api/characters/:id          # 更新角色
DELETE /api/characters/:id          # 删除角色

GET    /api/characters/search       # 搜索角色
POST   /api/characters/filter       # 过滤角色

GET    /api/users/:id/bookmarks     # 获取用户收藏
POST   /api/users/:id/bookmarks     # 添加收藏
DELETE /api/users/:id/bookmarks/:id # 移除收藏

GET    /api/statistics              # 获取应用统计
```

### WebSocket事件（计划中）
```dart
// 实时更新
socket.on('character_updated', (data) => _updateCharacter(data));
socket.on('new_character', (data) => _addCharacter(data));
socket.on('character_deleted', (data) => _removeCharacter(data));
```

---

*此API文档提供了所有数据模型和服务接口的完整覆盖。有关实现示例，请参考源代码和单元测试。*