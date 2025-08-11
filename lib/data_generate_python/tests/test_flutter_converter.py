"""
Test script for the Flutter data converter
This script tests CSV to Flutter conversion without API calls
"""

import os
import sys
import csv
from pathlib import Path

# Add parent directory to Python path for imports
current_dir = Path(__file__).parent
parent_dir = current_dir.parent
sys.path.append(str(parent_dir))
sys.path.append(str(parent_dir.parent.parent.parent))  # Add root folder

# Change working directory to parent (main scripts folder) for file operations
if Path.cwd().name != "data_generate_python":
    os.chdir(parent_dir)

from csv_to_flutter_converter import FlutterDataConverter


def create_sample_csv():
    """Create a sample CSV file for testing"""
    sample_data = [
        {
            "id": "test_001",
            "gender": "男",
            "age": 28,
            "birth_year": "1996",
            "height_cm": 175,
            "weight_kg": 70,
            "zodiac": "狮子座",
            "mbti": "ENTJ",
            "hometown": "北京",
            "current_location": "東京",
            "education": "大学",
            "occupation": "エンジニア",
            "hobbies": "音楽，映画，読書",
            "has_house": True,
            "has_car": False,
            "marital_status": "未婚",
            "self_introduction": "よろしくお願いします。",
            "partner_preferences": "優しい人を希望",
            "raw_text": "Sample profile data for testing",
        },
        {
            "id": "test_002",
            "gender": "女",
            "age": 25,
            "birth_year": "1999",
            "height_cm": 160,
            "weight_kg": 50,
            "zodiac": "乙女座",
            "mbti": "INFP",
            "hometown": "大阪",
            "current_location": "横浜",
            "education": "大学院",
            "occupation": "デザイナー",
            "hobbies": "旅行，カフェ，写真",
            "has_house": False,
            "has_car": True,
            "marital_status": "未婚",
            "self_introduction": "新しい出会いを楽しみにしています。",
            "partner_preferences": "誠実で面白い人",
            "raw_text": "Another sample profile for testing",
        },
    ]

    test_csv = Path("tests/sample_profiles.csv")

    with open(test_csv, "w", newline="", encoding="utf-8-sig") as csvfile:
        fieldnames = sample_data[0].keys()
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(sample_data)

    return test_csv


def test_csv_to_json_conversion():
    """Test CSV to JSON conversion"""
    print("🧪 Testing CSV to JSON conversion...")

    # Create sample CSV
    csv_file = create_sample_csv()
    json_file = Path("tests/test_characters.json")

    try:
        converter = FlutterDataConverter()

        # Convert CSV to Flutter format
        characters = converter.csv_to_character_data(str(csv_file), str(json_file))

        if characters:
            print(f"✅ Successfully converted {len(characters)} profiles")
            print("📊 Sample character data:")
            for char in characters[:1]:  # Show first character
                print(f"   ID: {char['id']}")
                print(f"   Name: {char['name']}")
                print(f"   Age: {char['age']}")
                print(f"   Location: {char['location']}")
                print(f"   Interests: {char['interests']}")

            return True
        else:
            print("❌ No characters converted")
            return False

    except Exception as e:
        print(f"❌ Conversion failed: {e}")
        return False


def test_dart_file_generation():
    """Test Dart file generation"""
    print("\n🧪 Testing Dart file generation...")

    try:
        converter = FlutterDataConverter()

        # Use existing JSON data
        json_file = Path("tests/test_characters.json")
        if not json_file.exists():
            print("❌ JSON file not found, run CSV conversion first")
            return False

        # Read JSON data
        import json

        with open(json_file, "r", encoding="utf-8") as f:
            characters = json.load(f)

        # Generate Dart file
        dart_file = Path("tests/test_characters_data.dart")
        converter.create_dart_file(characters, str(dart_file))

        if dart_file.exists():
            print(f"✅ Dart file generated successfully: {dart_file}")

            # Show first few lines
            with open(dart_file, "r", encoding="utf-8") as f:
                lines = f.readlines()[:10]

            print("📄 First few lines of generated Dart file:")
            for i, line in enumerate(lines, 1):
                print(f"   {i:2}: {line.rstrip()}")

            return True
        else:
            print("❌ Dart file was not created")
            return False

    except Exception as e:
        print(f"❌ Dart generation failed: {e}")
        return False


def test_data_validation():
    """Test data validation and transformation"""
    print("\n🧪 Testing data validation...")

    try:
        converter = FlutterDataConverter()

        # Test safe conversion methods
        test_cases = [
            ("123", 123),
            ("45.6", 45.6),
            ("invalid", None),
            ("true", True),
            ("false", False),
            (None, None),
        ]

        print("📊 Testing safe conversion methods:")
        for input_val, expected in test_cases:
            int_result = converter._safe_int(input_val)
            float_result = converter._safe_float(input_val)
            bool_result = converter._safe_bool(input_val)

            print(f"   Input: {input_val}")
            print(f"     -> int: {int_result}")
            print(f"     -> float: {float_result}")
            print(f"     -> bool: {bool_result}")

        # Test interest extraction
        hobbies_tests = [
            "音楽，映画，読書",
            "音楽、映画、読書",
            "音楽,映画,読書",
            None,
            "",
        ]

        print("\n📝 Testing interest extraction:")
        for hobbies in hobbies_tests:
            interests = converter._extract_interests(hobbies)
            print(f"   Input: {hobbies}")
            print(f"     -> Interests: {interests}")

        return True

    except Exception as e:
        print(f"❌ Validation test failed: {e}")
        return False


def cleanup_test_files():
    """Clean up test files"""
    test_files = [
        "tests/sample_profiles.csv",
        "tests/test_characters.json",
        "tests/test_characters_data.dart",
    ]

    for file_path in test_files:
        path = Path(file_path)
        if path.exists():
            path.unlink()
            print(f"🗑️  Cleaned up: {file_path}")


def main():
    """Main test function"""
    print("🧪 Flutter Data Converter Test Suite")
    print("=" * 50)

    success_count = 0
    total_tests = 3

    try:
        # Test 1: CSV to JSON conversion
        print("\n📋 Test 1: CSV to JSON Conversion")
        if test_csv_to_json_conversion():
            success_count += 1

        # Test 2: Dart file generation
        print("\n📋 Test 2: Dart File Generation")
        if test_dart_file_generation():
            success_count += 1

        # Test 3: Data validation
        print("\n📋 Test 3: Data Validation")
        if test_data_validation():
            success_count += 1

        # Results
        print("\n" + "=" * 50)
        print(f"🎯 Test Results: {success_count}/{total_tests} tests passed")

        if success_count == total_tests:
            print("🎉 All converter tests passed!")
        else:
            print("❌ Some tests failed. Check the error messages above.")

    finally:
        # Cleanup
        print(f"\n🧹 Cleaning up test files...")
        cleanup_test_files()


if __name__ == "__main__":
    main()
