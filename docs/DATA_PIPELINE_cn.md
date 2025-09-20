
# 数据处理管道文档

## 概述
数据处理管道负责将原始角色数据从markdown文件转换为可被Flutter应用使用的结构化JSON格式。它由多个Python模块组成，这些模块协同工作来提取、处理和增强角色信息。

## 管道架构

```
原始Markdown文件 (men_*.md, women_*.md)
          ↓
    数据管道 (data_pipeline.py)
          ↓
    DeepSeek处理器 (deepseek_data_processor.py)
          ↓
    CSV到Flutter转换器 (csv_to_flutter_converter.py)
          ↓
    Flutter Dart数据文件 (characters_data.dart)
```

## 核心组件

### 1. data_pipeline.py
**目的**: 处理markdown文件并提取结构化角色数据的主要编排器。

**主要功能**:
- 从指定目录读取markdown文件
- 使用正则表达式和NLP技术提取角色信息
- 基于文件名模式确定性别 (men_*.md → 男性, women_*.md → 女性)
- 处理人口统计信息（年龄、身高、位置等）
- 提取兴趣、MBTI类型和星座
- 根据身高和体重数据计算BMI
- 处理资产信息（房屋、汽车所有权）

**配置**:
```python
# 目录路径
INPUT_DIRS = ['path/to/men/profiles', 'path/to/women/profiles']
OUTPUT_FILE = 'processed_characters.csv'

# 处理选项
ENABLE_GENDER_DETECTION = True
INCLUDE_BMI_CALCULATION = True
PROCESS_INTERESTS = True
```

**性别检测逻辑**:
```python
def determine_gender_from_filename(filename):
    """
    根据文件名模式确定性别：
    - men_*.md 文件 → "male"
    - women_*.md 文件 → "female"
    - 默认: None
    """
    if filename.lower().startswith('men_'):
        return "male"
    elif filename.lower().startswith('women_'):
        return "female"
    return None
```

### 2. deepseek_data_processor.py
**目的**: 使用DeepSeek API进行AI增强的数据处理，以进行高级角色分析。

**主要功能**:
- 使用AI提取额外的角色洞察
- 增强个性分析
- 提供更准确的兴趣分类
- 处理复杂的文本解析场景
- 使用中文字符的替代性别检测（男/女）

**AI处理流程**:
1. 将原始角色文本发送到DeepSeek API
2. 接收结构化JSON响应
3. 验证和清理提取的数据
4. 与现有角色信息合并
5. 应用一致性检查

**配置**:
```python
# API设置
DEEPSEEK_API_KEY = "your-api-key"
MODEL_NAME = "deepseek-chat"
MAX_TOKENS = 2048

# 处理参数
BATCH_SIZE = 10
RETRY_ATTEMPTS = 3
TIMEOUT_SECONDS = 30
```

### 3. csv_to_flutter_converter.py
**目的**: 将处理后的CSV数据转换为Flutter兼容的Dart代码。

**主要功能**:
- 读取包含角色数据的CSV文件
- 生成Dart数据结构
- 创建格式正确的Dart列表
- 处理数据类型转换
- 生成可直接使用的Flutter代码

**输出格式**:
```dart
final List<Map<String, dynamic>> charactersData = [
  {
    'id': '1',
    'gender': 'male',
    'age': 28,
    'height': 175,
    'currentLocation': 'Beijing',
    'occupation': 'Software Engineer',
    'interests': ['Programming', 'Gaming', 'Travel'],
    // ... 更多字段
  },
  // ... 更多角色
];
```

## 数据流和处理步骤

### 步骤1: 文件发现
```python
# 扫描目录中的markdown文件
markdown_files = scan_directories([
    'data/men_profiles/',
    'data/women_profiles/'
])
```

### 步骤2: 内容提取
```python
# 提取原始文本内容
for file_path in markdown_files:
    raw_content = read_markdown_file(file_path)
    gender = determine_gender_from_filename(file_path.name)
```

### 步骤3: 信息解析
```python
# 解析结构化信息
character_data = {
    'gender': gender,
    'age': extract_age(raw_content),
    'height': extract_height(raw_content),
    'location': extract_location(raw_content),
    'occupation': extract_occupation(raw_content),
    'interests': extract_interests(raw_content),
    'mbti': extract_mbti(raw_content),
    'zodiac': extract_zodiac(raw_content),
}
```

### 步骤4: 数据增强
```python
# 计算派生字段
character_data['bmi'] = calculate_bmi(height, weight)
character_data['age_group'] = categorize_age(age)
character_data['location_type'] = categorize_location(location)
```

### 步骤5: 质量保证
```python
# 验证和清理数据
validated_data = validate_character_data(character_data)
cleaned_data = clean_and_normalize(validated_data)
```

### 步骤6: 输出生成
```python
# 生成Flutter兼容的输出
dart_code = generate_flutter_data(cleaned_data)
write_dart_file('lib/data/characters_data.dart', dart_code)
```

## 配置和设置

### 环境要求
```bash
pip install pandas
pip install requests  # 用于DeepSeek API
pip install regex
pip install pathlib
```

### 目录结构
```
lib/data_generate_python/
├── data_pipeline.py           # 主要处理逻辑
├── deepseek_data_processor.py # AI增强
├── csv_to_flutter_converter.py # Dart代码生成
├── config.py                  # 配置设置
├── utils.py                   # 工具函数
├── requirements.txt           # Python依赖
└── README.md                 # 此文档
```

### 运行管道

**完整管道执行**:
```bash
cd lib/data_generate_python
python data_pipeline.py --input-dir ../../../data --output-dir ../data/
```

**单独组件**:
```bash
# 仅运行数据提取
python data_pipeline.py --extract-only

# 仅运行AI增强
python deepseek_data_processor.py --input processed_data.csv

# 仅生成Flutter代码
python csv_to_flutter_converter.py --input final_data.csv --output ../data/characters_data.dart
```

## 数据模式

### 输入格式 (Markdown)
```markdown
# 角色姓名
年龄: 28
身高: 175cm
位置: 北京 → 上海
职业: 软件工程师
兴趣: 编程, 游戏, 旅行
MBTI: INTJ
星座: 水瓶座
有房: 是
有车: 否
婚姻状况: 单身
```

### 中间格式 (CSV)
```csv
id,gender,age,height,hometown,currentLocation,occupation,interests,mbti,zodiac,hasHouse,hasCar,maritalStatus,rawText
1,male,28,175,北京,上海,软件工程师,"编程,游戏,旅行",INTJ,水瓶座,true,false,单身,"完整角色描述..."
```

### 输出格式 (Dart)
```dart
Character(
  id: '1',
  gender: 'male',
  age: 28,
  height: 175,
  hometown: '北京',
  currentLocation: '上海',
  occupation: '软件工程师',
  interests: ['编程', '游戏', '旅行'],
  mbti: 'INTJ',
  zodiac: '水瓶座',
  hasHouse: true,
  hasCar: false,
  maritalStatus: '单身',
  rawText: '完整角色描述...',
)
```

## 错误处理和验证

### 数据验证规则
- 年龄必须在18-100之间
- 身高必须在140-220厘米之间
- 性别必须是"male"或"female"
- MBTI必须是有效的4字母类型
- 兴趣必须是非空列表

### 错误恢复
```python
try:
    processed_data = process_character_file(file_path)
except ValidationError as e:
    log_error(f"验证失败 {file_path}: {e}")
    processed_data = apply_default_values()
except ParsingError as e:
    log_error(f"解析失败 {file_path}: {e}")
    processed_data = manual_review_queue.add(file_path)
```

## 性能考虑

### 优化策略
- **批处理**: 批量处理文件以减少I/O开销
- **缓存**: 缓存正则表达式模式和常见提取
- **并行处理**: 对独立文件处理使用多进程
- **内存管理**: 流式处理大数据集而不是全部加载到内存

### 性能指标
- 处理速度: 每分钟约50-100个文件
- 内存使用: 10K角色<500MB
- API速率限制: 遵循DeepSeek API配额

## 维护和故障排除

### 常见问题
1. **文件编码问题**: 确保所有输入文件使用UTF-8编码
2. **API速率限制**: 实施适当的退避策略
3. **数据格式不一致**: 添加更强大的解析逻辑
4. **内存问题**: 以更小的批次处理文件

### 监控和日志记录
```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('pipeline.log'),
        logging.StreamHandler()
    ]
)
```

### 数据质量指标
- 解析成功率: >95%
- 数据完整性: >90%的字段已填充
- 验证通过率: >98%
- 处理时间: 每个文件<5秒

## 未来增强

### 计划功能
- [ ] 实时数据处理
- [ ] 数据管理的Web界面
- [ ] 基于高级ML的数据提取
- [ ] 多语言支持
- [ ] 自动化数据质量监控
- [ ] 与外部数据源集成

### 技术改进
- [ ] 更好的错误处理和恢复
- [ ] 性能优化
- [ ] 单元测试覆盖率
- [ ] CI/CD管道集成
- [ ] Docker容器化

---

*有关技术支持或问题，请参阅主项目文档或在仓库中创建问题。*