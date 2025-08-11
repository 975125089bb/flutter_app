"""
Complete Dating App Data Pipeline
This script orchestrates the complete process from raw data to Flutter-ready format
"""

import os
import sys
import json
from pathlib import Path
from typing import Optional, List

# Add current directory and parent directory to Python path
current_dir = Path(__file__).parent
sys.path.append(str(current_dir))
sys.path.append(str(current_dir.parent.parent.parent))  # Add root folder

# Change working directory to script location if running from elsewhere
if Path.cwd() != current_dir:
    print(f"Changing working directory to: {current_dir}")
    os.chdir(current_dir)

from deepseek_data_processor import DeepSeekProcessor
from csv_to_flutter_converter import FlutterDataConverter


class DataPipeline:
    """Complete data processing pipeline"""

    def __init__(self, api_key: str):
        self.api_key = api_key
        self.processor = DeepSeekProcessor(
            api_key=api_key,
            max_requests_per_minute=10,  # Conservative rate
            delay_between_requests=6.0,  # 6-second delays
        )
        self.converter = FlutterDataConverter()

    def check_prerequisites(self) -> bool:
        """Check if all required files and dependencies are available"""
        print("🔍 Checking prerequisites...")

        # Check if raw_data folder exists
        raw_data_path = Path("raw_data")
        if not raw_data_path.exists():
            print("❌ raw_data folder not found!")
            return False

        # Check if there are data files
        data_files = list(raw_data_path.glob("*.md"))
        if not data_files:
            print("❌ No markdown data files found in raw_data folder!")
            return False

        print(f"✅ Found {len(data_files)} data files")

        # Check API key
        if not self.api_key or self.api_key == "your-api-key-here":
            print("❌ Please set a valid API key!")
            return False

        print("✅ All prerequisites met")
        return True

    def estimate_cost(self, file_patterns: Optional[List[str]] = None) -> dict:
        """Estimate the processing cost and time"""
        if file_patterns is None:
            file_patterns = ["*.md"]

        total_profiles = 0
        files_to_process = []

        raw_data_path = Path("raw_data")

        for pattern in file_patterns:
            files = list(raw_data_path.glob(pattern))
            for file_path in files:
                if file_path.name in ["__init__.py", "tinder.md"]:
                    continue

                with open(file_path, "r", encoding="utf-8") as f:
                    content = f.read()

                person_blocks = self.processor.extract_person_blocks(content)
                total_profiles += len(person_blocks)
                files_to_process.append(
                    {"file": file_path.name, "profiles": len(person_blocks)}
                )

        # Estimate time and cost
        seconds_per_request = self.processor.delay_between_requests
        estimated_minutes = (total_profiles * seconds_per_request) / 60

        return {
            "total_profiles": total_profiles,
            "files": files_to_process,
            "estimated_time_minutes": round(estimated_minutes, 1),
            "estimated_requests": total_profiles,
        }

    def run_full_pipeline(
        self,
        input_folder: str = "raw_data",
        csv_output: str = "processed_dating_profiles.csv",
        json_output: str = "flutter_characters.json",
    ):
        """Run the complete data processing pipeline"""

        print("🚀 Starting Dating App Data Pipeline")
        print("=" * 50)

        # Step 1: Process raw data with DeepSeek API
        print("\n📊 Step 1: Processing raw data with DeepSeek API...")

        input_path = Path(input_folder)
        csv_path = Path(csv_output)

        if not input_path.exists():
            print(f"❌ Input folder {input_folder} not found!")
            return False

        try:
            # Process with API (gender is automatically determined from filename)
            all_people = self.processor.process_all_files(
                input_folder=input_path,
                output_file=csv_path,
                file_patterns=["men_*.md", "women_*.md"],  # Process all profile files
            )

            if not all_people:
                print("❌ No data was processed successfully!")
                return False

            print(f"✅ Successfully processed {len(all_people)} profiles")
            print(f"✅ CSV saved to: {csv_output}")

        except Exception as e:
            print(f"❌ Error in data processing: {e}")
            return False

        # Step 2: Convert CSV to Flutter format
        print(f"\n🔄 Step 2: Converting to Flutter format...")

        try:
            # Convert to Flutter format
            characters = self.converter.csv_to_character_data(csv_output, json_output)

            print(f"✅ Converted {len(characters)} profiles to Flutter format")
            print(f"✅ JSON saved to: {json_output}")

        except Exception as e:
            print(f"❌ Error in conversion: {e}")
            return False

        # Step 3: Summary and integration instructions
        print(f"\n🎉 Pipeline Complete!")
        print("=" * 50)
        print(f"📈 Total profiles processed: {len(characters)}")
        print(f"📁 Files created:")
        print(f"   - {csv_output} (CSV data)")
        print(f"   - {json_output} (JSON data)")

        print(f"\n📱 Flutter Integration:")
        print(f"   1. Import in your Dart file:")
        print(f"      import 'data/generated_characters_data.dart';")
        print(f"   2. Use the data:")
        print(
            f"      List<Character> characters = GeneratedCharactersData.getCharacters();"
        )

        return True

    def save_progress(
        self, processed_data: dict, filename: str = "pipeline_progress.json"
    ):
        """Save pipeline progress for resume capability"""
        with open(filename, "w", encoding="utf-8") as f:
            json.dump(processed_data, f, indent=2, default=str)

    def load_progress(self, filename: str = "pipeline_progress.json") -> Optional[dict]:
        """Load previous pipeline progress"""
        if Path(filename).exists():
            with open(filename, "r", encoding="utf-8") as f:
                return json.load(f)
        return None

    def run_full_pipeline_with_resume(
        self,
        input_folder: str = "raw_data",
        csv_output: str = "processed_dating_profiles.csv",
        json_output: str = "flutter_characters.json",
        resume: bool = True,
    ):
        """Run pipeline with resume capability"""

        if not self.check_prerequisites():
            return False

        # Show cost estimation
        estimate = self.estimate_cost(["men_*.md", "women_*.md"])
        print(f"\n💰 Cost Estimation:")
        print(f"   📊 Total profiles: {estimate['total_profiles']}")
        print(f"   ⏱️  Estimated time: {estimate['estimated_time_minutes']} minutes")
        print(f"   🔥 API requests: {estimate['estimated_requests']}")

        for file_info in estimate["files"]:
            print(f"   📄 {file_info['file']}: {file_info['profiles']} profiles")

        # Check for existing progress
        progress_data = None
        if resume:
            progress_data = self.load_progress()
            if progress_data:
                print(
                    f"\n🔄 Found previous progress: {len(progress_data.get('completed_profiles', []))} profiles completed"
                )
                resume_choice = input("Resume from previous progress? (y/N): ")
                if resume_choice.lower() != "y":
                    progress_data = None

        return self.run_full_pipeline(input_folder, csv_output, json_output)

    def run_test_pipeline(self, test_file: str = "men_100.md", max_profiles: int = 5):
        """Run a small test of the pipeline"""

        print("🧪 Running Test Pipeline")
        print("=" * 30)

        input_path = Path("raw_data") / test_file
        if not input_path.exists():
            print(f"❌ Test file {input_path} not found!")
            return False

        print(f"📄 Processing first {max_profiles} profiles from {test_file}")

        try:
            # Read and extract limited profiles
            with open(input_path, "r", encoding="utf-8") as f:
                content = f.read()

            person_blocks = self.processor.extract_person_blocks(content)
            test_blocks = person_blocks[:max_profiles]  # Limit for testing

            print(
                f"📊 Found {len(person_blocks)} total profiles, testing with {len(test_blocks)}"
            )

            # Process limited profiles
            processed_people = []
            for block in test_blocks:
                person_id = block["id"]
                text = block["content"]

                print(f"🔄 Processing person {person_id}...")

                extracted_info = self.processor.call_api(text)

                if extracted_info:
                    from deepseek_data_processor import ProcessedPerson

                    extracted_info["id"] = person_id
                    extracted_info["raw_text"] = text

                    person = ProcessedPerson(**extracted_info)
                    processed_people.append(person)
                    print(f"✅ Successfully processed person {person_id}")
                else:
                    print(f"❌ Failed to extract info for person {person_id}")

            if processed_people:
                # Save test results
                test_csv = "test_profiles.csv"
                test_json = "test_characters.json"
                test_dart = "test_characters_data.dart"

                self.processor.save_to_csv(processed_people, Path(test_csv))

                # Convert CSV to Flutter format
                try:
                    characters = self.converter.csv_to_character_data(
                        test_csv, test_json
                    )
                    print(f"✅ JSON saved to: {test_json}")
                except Exception as e:
                    print(f"❌ Error creating JSON: {e}")

                print(f"\n✅ Test completed successfully!")
                print(f"📊 Processed {len(processed_people)} profiles")
                print(f"📁 Test files: {test_csv}, {test_json}, {test_dart}")
                return True
            else:
                print("❌ No profiles were processed successfully")
                return False

        except Exception as e:
            print(f"❌ Test failed: {e}")
            return False


def main():
    """Main function with user interaction"""

    print("📱 Dating App Data Pipeline")
    print("=" * 40)

    # Configuration
    API_KEY = "sk-d17e63eeef2d46f4bb404b2a05f125ce"

    pipeline = DataPipeline(API_KEY)

    print("\nChoose an option:")
    print("1. Run test pipeline (5 profiles, minimal cost)")
    print("2. Run full pipeline with cost estimation")
    print("3. Run custom pipeline (specify parameters)")
    print("4. Check prerequisites and estimate costs only")

    try:
        choice = input("\nEnter your choice (1-4): ").strip()

        if choice == "1":
            print("\n🧪 Running test pipeline...")
            success = pipeline.run_test_pipeline()

        elif choice == "2":
            print("\n💰 Checking costs and prerequisites...")
            if not pipeline.check_prerequisites():
                return

            estimate = pipeline.estimate_cost(["men_*.md", "women_*.md"])
            print(f"\n📊 Full Pipeline Estimation:")
            print(f"   Total profiles: {estimate['total_profiles']}")
            print(f"   Estimated time: {estimate['estimated_time_minutes']} minutes")
            print(f"   API requests: {estimate['estimated_requests']}")

            confirm = input(
                f"\n⚠️  This will process {estimate['total_profiles']} profiles. Continue? (y/N): "
            )
            if confirm.lower() == "y":
                print("\n🚀 Running full pipeline with resume capability...")
                success = pipeline.run_full_pipeline_with_resume()
            else:
                print("❌ Operation cancelled.")
                return

        elif choice == "3":
            print("\n⚙️  Custom pipeline options:")

            # Get custom parameters
            input_folder = (
                input("Input folder (default: raw_data): ").strip() or "raw_data"
            )
            max_profiles = input("Max profiles to process (default: all): ").strip()

            if max_profiles:
                print(f"\n🔧 Running custom test with {max_profiles} profiles...")
                success = pipeline.run_test_pipeline(max_profiles=int(max_profiles))
            else:
                print(f"\n🚀 Running full pipeline with custom folder: {input_folder}")
                success = pipeline.run_full_pipeline_with_resume(
                    input_folder=input_folder
                )

        elif choice == "4":
            print("\n🔍 Prerequisites and Cost Estimation:")
            if pipeline.check_prerequisites():
                estimate = pipeline.estimate_cost(["*.md"])
                print(f"\n📊 Cost Estimation for all files:")
                print(f"   Total profiles: {estimate['total_profiles']}")
                print(
                    f"   Estimated time: {estimate['estimated_time_minutes']} minutes"
                )
                print(f"   Files breakdown:")
                for file_info in estimate["files"]:
                    print(
                        f"     - {file_info['file']}: {file_info['profiles']} profiles"
                    )

                print(f"\n💡 Recommendations:")
                if estimate["total_profiles"] > 100:
                    print("   - Consider running test pipeline first")
                    print("   - Process in batches to control costs")
                if estimate["estimated_time_minutes"] > 60:
                    print(
                        f"   - Pipeline will take ~{estimate['estimated_time_minutes']/60:.1f} hours"
                    )
                    print("   - Consider running overnight or in background")
            return
        else:
            print("❌ Invalid choice!")
            return

        if success:
            print("\n🎉 Pipeline completed successfully!")
            print("\nNext steps:")
            print("1. Copy the generated Dart file to your Flutter project")
            print("2. Import and use the data in your app")
            print("3. Test the integration")
        else:
            print("\n❌ Pipeline failed. Check the error messages above.")

    except KeyboardInterrupt:
        print("\n\n❌ Operation cancelled by user.")
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")


if __name__ == "__main__":
    main()
