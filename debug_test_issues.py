"""
Debug script to identify test issues
"""

import sys
from pathlib import Path

print("🔍 Debug Information:")
print(f"Python version: {sys.version}")
print(f"Current working directory: {Path.cwd()}")
print(f"Python executable: {sys.executable}")

print("\n📦 Checking imports...")
try:
    import requests

    print("✅ requests imported")
except ImportError as e:
    print(f"❌ requests failed: {e}")

try:
    import pandas as pd

    print("✅ pandas imported")
except ImportError as e:
    print(f"❌ pandas failed: {e}")

print("\n📁 Checking file structure...")
data_gen_path = Path("lib/data_generate_python")
if data_gen_path.exists():
    print(f"✅ {data_gen_path} exists")
    files = list(data_gen_path.glob("*.py"))
    print(f"   Found {len(files)} Python files:")
    for file in files:
        print(f"   - {file.name}")
else:
    print(f"❌ {data_gen_path} not found")

# Check raw_data
raw_data_path = Path("lib/data_generate_python/raw_data")
if raw_data_path.exists():
    md_files = list(raw_data_path.glob("*.md"))
    print(f"✅ raw_data found with {len(md_files)} .md files")
else:
    print("❌ raw_data folder not found")

print("\n🧪 Testing imports from data_generate_python...")
sys.path.append(str(Path("lib/data_generate_python")))

try:
    from deepseek_data_processor import DeepSeekProcessor

    print("✅ DeepSeekProcessor imported")
except ImportError as e:
    print(f"❌ DeepSeekProcessor failed: {e}")

try:
    from csv_to_flutter_converter import FlutterDataConverter

    print("✅ FlutterDataConverter imported")
except ImportError as e:
    print(f"❌ FlutterDataConverter failed: {e}")

print("\n🎯 Test Result Summary:")
print("If you see ❌ errors above, those are likely causing your test failures.")
print("Most common fixes:")
print("1. Install missing packages: pip install requests pandas")
print("2. Check file paths and working directory")
print("3. Verify all Python files are present")
