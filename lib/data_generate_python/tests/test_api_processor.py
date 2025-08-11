"""
Test script for the DeepSeek data processor
This script processes a small sample to verify the API integration works
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

from deepseek_data_processor import DeepSeekProcessor, ProcessedPerson


def test_single_extraction():
    """Test the API extraction with a single sample"""

    # Sample text from your data
    sample_text = """
出生：81
身高：180
体重：85
性别：男
地区：松户
家乡：沈阳
学历：大学
职业：软件
星座：天蝎
房车：有房无车
婚史：离婚
爱好：书法，摄影，户外，运动，音乐，旅行
人格：ENTJ

自我介绍
你好，我是一个真诚、有责任感,阳光自信的男生，81年生，
目前从事IT行业，平时工作虽然有点忙，
但我始终相信生活不仅只有工作，更需要有人一起分享喜怒哀乐。
性格稳重但不失幽默，爱好广泛，喜欢互相尊重，鼓励，支持的交流和交往,
并喜欢美食、看电影，同时享受安静宅家的时光。

择偶要求
希望遇到一个善良、皮肤白净，有爱心、懂得沟通的你，不需要完美，
但愿彼此有共同话题，有心走进对方的世界。
两个人一起努力、一起成长，携手走过未来的每一个春夏秋冬。
"""

    API_KEY = "sk-d17e63eeef2d46f4bb404b2a05f125ce"

    processor = DeepSeekProcessor(
        api_key=API_KEY,
        max_requests_per_minute=5,  # Very conservative for testing
        delay_between_requests=2.0,
    )

    print("🧪 Testing single extraction...")
    print("=" * 40)

    result = processor.call_api(sample_text)

    if result:
        print("✅ API call successful!")
        print("📊 Extracted data:")
        for key, value in result.items():
            print(f"   {key}: {value}")

        # Test creating ProcessedPerson object
        result["id"] = "test_98"
        result["raw_text"] = sample_text

        try:
            person = ProcessedPerson(**result)
            print(f"\n✅ ProcessedPerson created successfully!")
            print(f"   ID: {person.id}")
            print(f"   Gender: {person.gender}")
            print(f"   Age: {person.age}")
            print(f"   BMI: {person.bmi}")
            return True
        except Exception as e:
            print(f"❌ Error creating ProcessedPerson: {e}")
            return False
    else:
        print("❌ API call failed")
        return False


def test_small_batch():
    """Test processing a small batch from one file"""

    API_KEY = "sk-d17e63eeef2d46f4bb404b2a05f125ce"

    processor = DeepSeekProcessor(
        api_key=API_KEY, max_requests_per_minute=5, delay_between_requests=3.0
    )

    # Process just the first few entries from one file
    input_folder = Path("raw_data")
    output_file = Path("tests/test_output.csv")

    if not input_folder.exists():
        print(f"❌ Input folder {input_folder} not found!")
        print("💡 Make sure you're running from the correct directory")
        return False

    print("\n🔄 Testing small batch processing...")
    print("=" * 40)

    # Find a test file
    test_files = list(input_folder.glob("*.md"))
    if not test_files:
        print("❌ No test files found!")
        return False

    # Filter out non-profile files - keep only men_*.md and women_*.md
    profile_files = [
        f
        for f in test_files
        if f.name.startswith(("men_", "women_")) and f.name.endswith(".md")
    ]

    if not profile_files:
        print("❌ No profile files found!")
        print("💡 Looking for files like men_100.md, women_100.md, etc.")
        print(f"   Available files: {[f.name for f in test_files]}")
        return False

    # Sort to get consistent results
    profile_files.sort()
    test_file = profile_files[0]
    print(f"📄 Testing with file: {test_file.name}")

    try:
        # Read and process just the first 2 entries
        with open(test_file, "r", encoding="utf-8") as f:
            content = f.read()

        person_blocks = processor.extract_person_blocks(content)
        print(f"📊 Found {len(person_blocks)} person blocks")

        # Process only first 2 to save costs
        test_blocks = person_blocks[:2]
        print(f"🎯 Testing with first {len(test_blocks)} entries")

        processed_people = []
        for block in test_blocks:
            person_id = block["id"]
            text = block["content"]

            print(f"\n🔄 Processing person {person_id}...")

            extracted_info = processor.call_api(text)

            if extracted_info:
                extracted_info["id"] = person_id
                extracted_info["raw_text"] = text

                person = ProcessedPerson(**extracted_info)
                processed_people.append(person)
                print(f"✅ Successfully processed person {person_id}")
            else:
                print(f"❌ Failed to extract info for person {person_id}")

        if processed_people:
            processor.save_to_csv(processed_people, output_file)
            print(
                f"\n🎉 Test completed! Saved {len(processed_people)} entries to {output_file}"
            )
            return True
        else:
            print("\n❌ No profiles processed successfully")
            return False

    except Exception as e:
        print(f"❌ Test failed: {e}")
        return False


def main():
    """Main test function"""
    print("🧪 DeepSeek Data Processor Test Suite")
    print("=" * 50)

    success_count = 0
    total_tests = 2

    # Test 1: Single extraction
    print("\n📋 Test 1: Single API Extraction")
    if test_single_extraction():
        success_count += 1

    # Test 2: Small batch processing
    print("\n📋 Test 2: Small Batch Processing")
    if test_small_batch():
        success_count += 1

    # Results
    print("\n" + "=" * 50)
    print(f"🎯 Test Results: {success_count}/{total_tests} tests passed")

    if success_count == total_tests:
        print("🎉 All tests completed successfully!")
        print("\n💡 Next steps:")
        print("   1. Run the full pipeline: python data_pipeline.py")
        print("   2. Or run batch processing: python batch_processor.py")
    else:
        print("❌ Some tests failed. Check the error messages above.")
        print("\n💡 Troubleshooting:")
        print("   1. Verify API key is correct")
        print("   2. Check internet connection")
        print("   3. Ensure raw_data folder exists with .md files")


if __name__ == "__main__":
    main()
