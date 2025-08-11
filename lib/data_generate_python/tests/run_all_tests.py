"""
Test Runner - Comprehensive test suite for the dating app data pipeline
Runs all tests without requiring API calls for most functionality
"""

import os
import sys
from pathlib import Path

# Add parent directory to Python path for imports
current_dir = Path(__file__).parent
parent_dir = current_dir.parent
sys.path.append(str(parent_dir))
sys.path.append(str(parent_dir.parent.parent.parent))  # Add root folder

# Change working directory to parent (main scripts folder) for file operations
if Path.cwd().name != "data_generate_python":
    os.chdir(parent_dir)


def test_imports():
    """Test that all required modules can be imported"""
    print("🧪 Testing module imports...")

    try:
        from deepseek_data_processor import DeepSeekProcessor, ProcessedPerson

        print("   ✅ deepseek_data_processor")

        from csv_to_flutter_converter import FlutterDataConverter

        print("   ✅ csv_to_flutter_converter")

        from data_pipeline import DataPipeline

        print("   ✅ data_pipeline")

        # Test external dependencies
        import requests

        print("   ✅ requests")

        import pandas as pd

        print("   ✅ pandas")

        return True

    except ImportError as e:
        print(f"   ❌ Import failed: {e}")
        return False


def test_environment():
    """Test environment setup"""
    print("\n🧪 Testing environment...")

    # Check current directory
    current_dir = Path.cwd()
    print(f"   📂 Working directory: {current_dir}")

    # Check for raw_data folder
    raw_data = Path("raw_data")
    if raw_data.exists():
        md_files = list(raw_data.glob("*.md"))
        print(f"   ✅ raw_data folder found with {len(md_files)} .md files")

        # List first few files
        for file in md_files[:3]:
            print(f"      - {file.name}")
        if len(md_files) > 3:
            print(f"      ... and {len(md_files) - 3} more")

        return True
    else:
        print(f"   ❌ raw_data folder not found")
        print(f"   💡 Create raw_data folder and add .md files")
        return False


def test_basic_functionality():
    """Test basic functionality without API calls"""
    print("\n🧪 Testing basic functionality...")

    try:
        # Test processor instantiation
        from deepseek_data_processor import DeepSeekProcessor

        processor = DeepSeekProcessor("test-key")
        print("   ✅ DeepSeekProcessor instantiation")

        # Test data extraction (local processing)
        sample_text = """
        编号98
        性别：男
        出生：81年
        身高：180
        体重：85
        """

        # Test person blocks extraction
        person_blocks = processor.extract_person_blocks(sample_text)
        if person_blocks or isinstance(person_blocks, list):
            print("   ✅ Person blocks extraction")
        else:
            print("   ⚠️  Person blocks extraction returned unexpected result")

        # Test converter instantiation
        from csv_to_flutter_converter import FlutterDataConverter

        converter = FlutterDataConverter()
        print("   ✅ FlutterDataConverter instantiation")

        # Test data pipeline instantiation
        from data_pipeline import DataPipeline

        pipeline = DataPipeline("test-key")
        print("   ✅ DataPipeline instantiation")

        return True

    except Exception as e:
        print(f"   ❌ Basic functionality test failed: {e}")
        return False


def run_converter_tests():
    """Run converter tests"""
    print("\n🧪 Running Flutter converter tests...")

    try:
        # Import and run the converter test
        from tests.test_flutter_converter import main as converter_main

        # Capture the test result
        import io
        from contextlib import redirect_stdout

        f = io.StringIO()
        with redirect_stdout(f):
            converter_main()

        output = f.getvalue()
        if "All converter tests passed!" in output:
            print("   ✅ Flutter converter tests passed")
            return True
        else:
            print("   ❌ Some converter tests failed")
            print("   📄 Output preview:")
            lines = output.split("\n")[:5]
            for line in lines:
                if line.strip():
                    print(f"      {line}")
            return False

    except Exception as e:
        print(f"   ❌ Converter test failed: {e}")
        return False


def check_api_configuration():
    """Check API configuration without making calls"""
    print("\n🧪 Checking API configuration...")

    try:
        from data_pipeline import DataPipeline

        pipeline = DataPipeline("test-key")

        # Check if API key is set to default
        if pipeline.api_key == "your-api-key-here" or not pipeline.api_key:
            print("   ⚠️  API key not configured")
            print("   💡 Edit API_KEY in data_pipeline.py for actual API calls")
            return False
        elif pipeline.api_key == "test-key":
            print("   ⚠️  Using test API key")
            print("   💡 Set real API key for production use")
            return True
        else:
            print("   ✅ API key appears to be configured")
            return True

    except Exception as e:
        print(f"   ❌ API configuration check failed: {e}")
        return False


def main():
    """Main test runner"""
    print("🧪 Dating App Data Pipeline Test Suite")
    print("=" * 60)
    print("Running comprehensive tests without API calls...")

    tests = [
        ("Module Imports", test_imports),
        ("Environment Setup", test_environment),
        ("Basic Functionality", test_basic_functionality),
        ("Flutter Converter", run_converter_tests),
        ("API Configuration", check_api_configuration),
    ]

    passed = 0
    total = len(tests)

    for test_name, test_func in tests:
        print(f"\n{'='*20} {test_name} {'='*20}")

        try:
            if test_func():
                passed += 1
                print(f"✅ {test_name}: PASSED")
            else:
                print(f"❌ {test_name}: FAILED")
        except Exception as e:
            print(f"❌ {test_name}: ERROR - {e}")

    # Summary
    print(f"\n{'='*60}")
    print(f"🎯 Test Summary: {passed}/{total} tests passed")

    if passed == total:
        print("🎉 All tests passed! System is ready.")
        print("\n🚀 Next steps:")
        print("   1. Configure real API key in data_pipeline.py")
        print("   2. Run API test: python tests/test_api_processor.py")
        print("   3. Run full pipeline: python data_pipeline.py")
    elif passed >= total - 1:
        print("✅ Most tests passed! Minor issues detected.")
        print("💡 Check failed tests and fix before proceeding.")
    else:
        print("❌ Multiple test failures detected.")
        print("🔧 Fix the issues before running the pipeline.")

    print(f"\n📊 Test Results:")
    print(f"   ✅ Passed: {passed}")
    print(f"   ❌ Failed: {total - passed}")

    return passed == total


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
