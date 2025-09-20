# Data Processing Pipeline Documentation

## Overview
The data processing pipeline is responsible for converting raw character data from markdown files into structured JSON format that can be consumed by the Flutter application. It consists of several Python modules that work together to extract, process, and enhance character information.

## Pipeline Architecture

```
Raw Markdown Files (men_*.md, women_*.md)
          ↓
    Data Pipeline (data_pipeline.py)
          ↓
    DeepSeek Processor (deepseek_data_processor.py)
          ↓
    CSV to Flutter Converter (csv_to_flutter_converter.py)
          ↓
    Flutter Dart Data Files (characters_data.dart)
```

## Core Components

### 1. data_pipeline.py
**Purpose**: Main orchestrator that processes markdown files and extracts structured character data.

**Key Features**:
- Reads markdown files from specified directories
- Extracts character information using regex and NLP techniques
- Determines gender based on filename patterns (men_*.md → male, women_*.md → female)
- Processes demographic information (age, height, location, etc.)
- Extracts interests, MBTI types, and zodiac signs
- Calculates BMI from height and weight data
- Handles asset information (house, car ownership)

**Configuration**:
```python
# Directory paths
INPUT_DIRS = ['path/to/men/profiles', 'path/to/women/profiles']
OUTPUT_FILE = 'processed_characters.csv'

# Processing options
ENABLE_GENDER_DETECTION = True
INCLUDE_BMI_CALCULATION = True
PROCESS_INTERESTS = True
```

**Gender Detection Logic**:
```python
def determine_gender_from_filename(filename):
    """
    Determines gender based on filename pattern:
    - men_*.md files → "male"
    - women_*.md files → "female"
    - Default: None
    """
    if filename.lower().startswith('men_'):
        return "male"
    elif filename.lower().startswith('women_'):
        return "female"
    return None
```

### 2. deepseek_data_processor.py
**Purpose**: AI-enhanced data processing using DeepSeek API for advanced character analysis.

**Key Features**:
- Uses AI to extract additional character insights
- Enhances personality analysis
- Provides more accurate interest categorization
- Handles complex text parsing scenarios
- Alternative gender detection using Chinese characters (男/女)

**AI Processing Flow**:
1. Send raw character text to DeepSeek API
2. Receive structured JSON response
3. Validate and clean the extracted data
4. Merge with existing character information
5. Apply consistency checks

**Configuration**:
```python
# API settings
DEEPSEEK_API_KEY = "your-api-key"
MODEL_NAME = "deepseek-chat"
MAX_TOKENS = 2048

# Processing parameters
BATCH_SIZE = 10
RETRY_ATTEMPTS = 3
TIMEOUT_SECONDS = 30
```

### 3. csv_to_flutter_converter.py
**Purpose**: Converts processed CSV data into Flutter-compatible Dart code.

**Key Features**:
- Reads CSV files with character data
- Generates Dart data structures
- Creates properly formatted Dart lists
- Handles data type conversions
- Produces ready-to-use Flutter code

**Output Format**:
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
    // ... more fields
  },
  // ... more characters
];
```

## Data Flow and Processing Steps

### Step 1: File Discovery
```python
# Scan directories for markdown files
markdown_files = scan_directories([
    'data/men_profiles/',
    'data/women_profiles/'
])
```

### Step 2: Content Extraction
```python
# Extract raw text content
for file_path in markdown_files:
    raw_content = read_markdown_file(file_path)
    gender = determine_gender_from_filename(file_path.name)
```

### Step 3: Information Parsing
```python
# Parse structured information
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

### Step 4: Data Enhancement
```python
# Calculate derived fields
character_data['bmi'] = calculate_bmi(height, weight)
character_data['age_group'] = categorize_age(age)
character_data['location_type'] = categorize_location(location)
```

### Step 5: Quality Assurance
```python
# Validate and clean data
validated_data = validate_character_data(character_data)
cleaned_data = clean_and_normalize(validated_data)
```

### Step 6: Output Generation
```python
# Generate Flutter-compatible output
dart_code = generate_flutter_data(cleaned_data)
write_dart_file('lib/data/characters_data.dart', dart_code)
```

## Configuration and Setup

### Environment Requirements
```bash
pip install pandas
pip install requests  # For DeepSeek API
pip install regex
pip install pathlib
```

### Directory Structure
```
lib/data_generate_python/
├── data_pipeline.py           # Main processing logic
├── deepseek_data_processor.py # AI enhancement
├── csv_to_flutter_converter.py # Dart code generation
├── config.py                  # Configuration settings
├── utils.py                   # Utility functions
├── requirements.txt           # Python dependencies
└── README.md                 # This documentation
```

### Running the Pipeline

**Full Pipeline Execution**:
```bash
cd lib/data_generate_python
python data_pipeline.py --input-dir ../../../data --output-dir ../data/
```

**Individual Components**:
```bash
# Run only data extraction
python data_pipeline.py --extract-only

# Run only AI enhancement
python deepseek_data_processor.py --input processed_data.csv

# Generate Flutter code only
python csv_to_flutter_converter.py --input final_data.csv --output ../data/characters_data.dart
```

## Data Schema

### Input Format (Markdown)
```markdown
# Character Name
Age: 28
Height: 175cm
Location: Beijing → Shanghai
Occupation: Software Engineer
Interests: Programming, Gaming, Travel
MBTI: INTJ
Zodiac: Aquarius
Has House: Yes
Has Car: No
Marital Status: Single
```

### Intermediate Format (CSV)
```csv
id,gender,age,height,hometown,currentLocation,occupation,interests,mbti,zodiac,hasHouse,hasCar,maritalStatus,rawText
1,male,28,175,Beijing,Shanghai,Software Engineer,"Programming,Gaming,Travel",INTJ,Aquarius,true,false,Single,"Full character description..."
```

### Output Format (Dart)
```dart
Character(
  id: '1',
  gender: 'male',
  age: 28,
  height: 175,
  hometown: 'Beijing',
  currentLocation: 'Shanghai',
  occupation: 'Software Engineer',
  interests: ['Programming', 'Gaming', 'Travel'],
  mbti: 'INTJ',
  zodiac: 'Aquarius',
  hasHouse: true,
  hasCar: false,
  maritalStatus: 'Single',
  rawText: 'Full character description...',
)
```

## Error Handling and Validation

### Data Validation Rules
- Age must be between 18-100
- Height must be between 140-220 cm
- Gender must be "male" or "female"
- MBTI must be valid 4-letter type
- Interests must be non-empty list

### Error Recovery
```python
try:
    processed_data = process_character_file(file_path)
except ValidationError as e:
    log_error(f"Validation failed for {file_path}: {e}")
    processed_data = apply_default_values()
except ParsingError as e:
    log_error(f"Parsing failed for {file_path}: {e}")
    processed_data = manual_review_queue.add(file_path)
```

## Performance Considerations

### Optimization Strategies
- **Batch Processing**: Process files in batches to reduce I/O overhead
- **Caching**: Cache regex patterns and common extractions
- **Parallel Processing**: Use multiprocessing for independent file processing
- **Memory Management**: Stream large datasets instead of loading everything into memory

### Performance Metrics
- Processing speed: ~50-100 files per minute
- Memory usage: <500MB for 10K characters
- API rate limits: Respect DeepSeek API quotas

## Maintenance and Troubleshooting

### Common Issues
1. **File encoding problems**: Ensure UTF-8 encoding for all input files
2. **API rate limits**: Implement proper backoff strategies
3. **Inconsistent data formats**: Add more robust parsing logic
4. **Memory issues**: Process files in smaller batches

### Monitoring and Logging
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

### Data Quality Metrics
- Parsing success rate: >95%
- Data completeness: >90% of fields populated
- Validation pass rate: >98%
- Processing time: <5 seconds per file

## Future Enhancements

### Planned Features
- [ ] Real-time data processing
- [ ] Web interface for data management
- [ ] Advanced ML-based data extraction
- [ ] Multi-language support
- [ ] Automated data quality monitoring
- [ ] Integration with external data sources

### Technical Improvements
- [ ] Better error handling and recovery
- [ ] Performance optimization
- [ ] Unit test coverage
- [ ] CI/CD pipeline integration
- [ ] Docker containerization

---

*For technical support or questions, please refer to the main project documentation or create an issue in the repository.*

---
