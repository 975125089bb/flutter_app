#!/usr/bin/env python3
"""
Quick Setup and Validation Script
Validates the data processing setup and runs a minimal test
"""
import sys
import os
from pathlib import Path

# Add current directory and parent directory to Python path
current_dir = Path(__file__).parent
sys.path.append(str(current_dir))
sys.path.append(str(current_dir.parent.parent.parent))  # Add root folder

# Change working directory to script location if running from elsewhere
if Path.cwd() != current_dir:
    print(f"Changing working directory to: {current_dir}")
    os.chdir(current_dir)


def check_files():
    """Check if all required files exist"""
    required_files = [
        "deepseek_data_processor.py",
        "csv_to_flutter_converter.py",
        "data_pipeline.py",
    ]

    missing_files = []
    for file in required_files:
        if not Path(file).exists():
            missing_files.append(file)

    if missing_files:
        print(f"❌ Missing files: {missing_files}")
        return False

    print("✅ All Python files found")
    return True


def check_dependencies():
    """Check if required dependencies are available"""
    try:
        import requests
        import pandas as pd

        print("✅ Dependencies OK (requests, pandas)")
        return True
    except ImportError as e:
        print(f"❌ Missing dependency: {e}")
        print("💡 Run: pip install requests pandas")
        return False


def check_data_folder():
    """Check if raw_data folder exists and has files"""
    data_path = Path("raw_data")

    if not data_path.exists():
        print("❌ raw_data folder not found")
        print("💡 Create the folder and add your .md data files")
        return False

    md_files = list(data_path.glob("*.md"))
    if not md_files:
        print("❌ No .md files found in raw_data")
        print("💡 Add your dating profile .md files to raw_data folder")
        return False

    print(f"✅ Found {len(md_files)} data files:")
    for file in md_files[:5]:  # Show first 5
        print(f"   - {file.name}")
    if len(md_files) > 5:
        print(f"   ... and {len(md_files) - 5} more")

    return True


def check_api_key():
    """Check if API key is configured"""
    try:
        from data_pipeline import DataPipeline

        pipeline = DataPipeline("test-key")

        if pipeline.api_key == "your-api-key-here" or not pipeline.api_key:
            print("⚠️  API key not configured")
            print("💡 Edit the API_KEY in data_pipeline.py")
            return False

        print("✅ API key configured")
        return True

    except Exception as e:
        print(f"❌ Error checking API key: {e}")
        return False


def run_quick_test():
    """Run a quick test without API calls"""
    try:
        print("\n🧪 Running quick test...")

        # Test data processor instantiation
        from deepseek_data_processor import DeepSeekProcessor

        processor = DeepSeekProcessor("test-key")
        print("✅ DeepSeekProcessor OK")

        # Test converter instantiation
        from csv_to_flutter_converter import FlutterDataConverter

        converter = FlutterDataConverter()
        print("✅ FlutterDataConverter OK")

        # Test pipeline instantiation
        from data_pipeline import DataPipeline

        pipeline = DataPipeline("test-key")
        print("✅ DataPipeline OK")

        print("✅ All components working!")
        return True

    except Exception as e:
        print(f"❌ Test failed: {e}")
        return False


def main():
    """Main validation function"""
    print("🔧 Data Processing Setup Validator")
    print("=" * 40)

    all_good = True

    # Check files
    print("\n📁 Checking files...")
    if not check_files():
        all_good = False

    # Check dependencies
    print("\n📦 Checking dependencies...")
    if not check_dependencies():
        all_good = False

    # Check data folder
    print("\n📊 Checking data folder...")
    if not check_data_folder():
        all_good = False

    # Check API key
    print("\n🔑 Checking API configuration...")
    if not check_api_key():
        all_good = False

    # Run quick test
    if all_good:
        if run_quick_test():
            print(f"\n🎉 Setup Complete!")
            print("Ready to process data!")
            print(f"\n🧪 For comprehensive testing:")
            print(f"   python tests/run_all_tests.py")
            print(f"\n🚀 Next steps:")
            print(f"1. Run: python data_pipeline.py (interactive)")
            print(f"2. Or: python tests/test_api_processor.py (API test)")
        else:
            all_good = False

    if not all_good:
        print(f"\n❌ Setup issues found. Please fix them before proceeding.")
        return False

    return True


if __name__ == "__main__":
    main()
