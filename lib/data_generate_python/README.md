# Dating Profile Data Processing Pipeline

A comprehensive Python pipeline to process dating profile data from markdown files using the DeepSeek API and convert it to Flutter-ready format.

## 🚀 Quick Start

1. **Validate Setup (from root folder):**
   ```bash
   python lib/data_generate_python/validate_setup.py
   ```

2. **Run Interactive Pipeline (from root folder):**
   ```bash
   python lib/data_generate_python/data_pipeline.py
   ```

3. **Run Batch Processing (from root folder):**
   ```bash
   python lib/data_generate_python/batch_processor.py
   ```

**Note**: All scripts automatically handle path detection and can be run from either:
- Root folder: `python lib/data_generate_python/script_name.py`
- Script folder: `cd lib/data_generate_python && python script_name.py`

## 📁 Project Structure

```
data_generate_python/
├── README.md                      # This file
├── requirements.txt               # Python dependencies
├── validate_setup.py             # Setup validation script
├── data_pipeline.py              # Main interactive pipeline
├── batch_processor.py            # Batch processing for cost control
├── deepseek_data_processor.py    # Core API processing logic
├── csv_to_flutter_converter.py   # CSV to Flutter conversion
├── tests/                        # Test scripts (separated)
│   ├── __init__.py               # Tests package
│   ├── run_all_tests.py          # Comprehensive test runner
│   ├── test_api_processor.py     # API integration tests
│   └── test_flutter_converter.py # Converter tests
└── raw_data/                     # Input markdown files
    ├── men_100.md
    ├── women_100.md
    └── ... (other data files)
```

## ⚡ Features

### 🎯 Core Features
- **AI-Powered Extraction**: Uses DeepSeek API for intelligent data extraction
- **Cost Control**: Rate limiting, batching, and progress saving
- **Flutter Integration**: Direct conversion to Dart objects
- **Resume Capability**: Continue from where you left off
- **Batch Processing**: Process files in controlled batches

### 🛡️ Safety Features
- **Prerequisites Check**: Validates setup before processing
- **Cost Estimation**: Shows time and API usage estimates
- **Progress Saving**: Auto-saves after each file/batch
- **Error Handling**: Graceful failure recovery
- **Test Mode**: Minimal-cost testing with sample data

## 🔧 Setup

### 1. Install Dependencies
```bash
pip install requests pandas
```

### 2. Configure API Key
Edit `data_pipeline.py` and set your DeepSeek API key:
```python
API_KEY = "your-deepseek-api-key-here"
```

### 3. Prepare Data
Place your markdown data files in the `raw_data/` folder:
- `men_100.md`, `men_200.md`, etc.
- `women_100.md`, `women_200.md`, etc.

### 4. Validate Setup
```bash
python validate_setup.py
```

## 🎮 Usage Options

### Option 1: Interactive Pipeline (Recommended)
```bash
python data_pipeline.py
```
- Guided interface with cost estimation
- Resume capability
- Multiple processing options

### Option 2: Batch Processing
```bash
python batch_processor.py
```
- Process files in controlled batches
- Fine-grained cost control
- Progress saving after each batch

### Option 3: Testing Suite
```bash
# Comprehensive tests (no API cost)
python tests/run_all_tests.py

# API integration test (costs money)
python tests/test_api_processor.py

# Converter tests only (no API cost)
python tests/test_flutter_converter.py
```

## 📊 Data Processing Flow

```
Raw Data (.md files)
       ↓
DeepSeek API Processing
       ↓
Structured CSV Data
       ↓
Flutter JSON/Dart Conversion
       ↓
Ready for Flutter App
```

### Extracted Fields
- **Basic Info**: gender, age, birth_year, zodiac, mbti
- **Physical**: height_cm, weight_kg, bmi (calculated)
- **Location**: hometown, current_location
- **Career**: education, occupation, annual_income
- **Lifestyle**: hobbies, personality, smoking, drinking
- **Assets**: has_house, has_car
- **Relationships**: marital_status, partner_preferences
- **Text**: self_introduction, raw_text

## 💰 Cost Management

### Rate Limiting
- Default: 10 requests/minute (6-second delays)
- Configurable in each script
- Conservative settings to minimize costs

### Batch Processing
- Process files individually
- Save progress after each batch
- Resume from interruption
- Cost estimation before processing

### Test Options
- Single profile test
- Small batch test (5-10 profiles)
- Full estimation without processing

## 📱 Flutter Integration

### Generated Files
1. **CSV**: `processed_dating_profiles.csv` - Raw structured data
2. **JSON**: `flutter_characters.json` - Flutter-ready format
3. **Dart**: `lib/data/generated_characters_data.dart` - Direct import

### Usage in Flutter
```dart
import 'data/generated_characters_data.dart';

// Get all characters
List<Character> characters = GeneratedCharactersData.getCharacters();

// Use in your app
ListView.builder(
  itemCount: characters.length,
  itemBuilder: (context, index) {
    return CharacterCard(character: characters[index]);
  },
)
```

## 🛠️ Configuration Options

### Processing Settings
```python
# In data_pipeline.py or batch_processor.py
processor = DeepSeekProcessor(
    api_key="your-key",
    max_requests_per_minute=10,    # Adjust rate limit
    delay_between_requests=6.0     # Seconds between calls
)
```

### File Patterns
```python
# Process specific files
file_patterns = ['men_*.md']        # Only men's profiles  
file_patterns = ['women_*.md']      # Only women's profiles
file_patterns = ['men_100.md']      # Single specific file
```

### Batch Size
```python
# In batch_processor.py
batch_processor = BatchProcessor(
    api_key="your-key",
    batch_size=10    # Profiles per batch
)
```

## 🚨 Troubleshooting

### Common Issues

1. **"No data files found"**
   - Ensure .md files are in `raw_data/` folder
   - Check file naming convention (*.md)

2. **"API request failed"**
   - Verify API key is correct
   - Check internet connection
   - Ensure sufficient API credits

3. **"JSON decode error"**
   - API response format issue
   - Try reducing batch size
   - Check API rate limits

4. **"Missing dependencies"**
   ```bash
   pip install requests pandas
   ```

### Debug Mode
Add debug prints in processing functions:
```python
print(f"Processing profile: {person_id}")
print(f"API response: {extracted_info}")
```

## 📈 Performance Tips

1. **Start Small**: Use test mode first
2. **Batch Wisely**: 10-20 profiles per batch
3. **Monitor Costs**: Check API usage regularly
4. **Save Progress**: Don't process everything at once
5. **Resume Feature**: Use for large datasets

## 🔄 Resume Processing

If processing is interrupted:
1. Check for existing CSV files
2. Use batch processor to continue
3. Or run pipeline with resume option

## 📋 Example Workflow

```bash
# 1. Validate everything is set up correctly
python lib/data_generate_python/validate_setup.py

# 2. Run comprehensive tests (no API cost)
python lib/data_generate_python/tests/run_all_tests.py

# 3. Test API integration (minimal cost)
python lib/data_generate_python/tests/test_api_processor.py

# 4. Run full pipeline with cost estimation
python lib/data_generate_python/data_pipeline.py
# Choose option 2: Full pipeline with estimation

# 5. Integrate into Flutter app
# Copy generated Dart file to your Flutter project
```

## 🤝 Contributing

1. Add new extraction patterns to `deepseek_data_processor.py`
2. Enhance Flutter conversion in `csv_to_flutter_converter.py`
3. Improve cost control in `batch_processor.py`

## ⚠️ Important Notes

- **API Costs**: Monitor your DeepSeek API usage
- **Data Privacy**: Ensure compliance with data protection laws
- **Backup**: Keep original data files safe
- **Testing**: Always test with small batches first
