# Dating Profile Data Processing Pipeline

A comprehensive Python pipeline to process dating profile data from markdown files using the DeepSeek API and convert it to Flutter-ready format.



## run data_pipeline.py to pass data to flutter**



## 📁 Project Structure

```
data_generate_python/
├── README.md                      # This file
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

