"""
Complete Dating App Data Pipeline
This script orchestrates the complete process from raw data to Flutter-ready format
"""

import os
import sys
import json
import time
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
            max_retries=3,  # Add retry logic
            retry_delay=5.0,  # 5-second initial delay
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

    def run_full_pipeline_with_retry(
        self,
        input_folder: str = "raw_data",
        csv_output: str = "output/processed_dating_profiles.csv",
        json_output: str = "output/flutter_characters.json",
        resume: bool = True,
        save_progress_interval: int = 10,
    ):
        """Run the complete pipeline with comprehensive retry logic and progress saving"""

        print("🚀 Starting Dating App Data Pipeline with Retry Logic")
        print("=" * 60)

        # Initialize progress tracking variables at function start
        total_profiles_processed = 0
        total_profiles_failed = 0
        completed_profiles = set()
        failed_profiles = []

        if not self.check_prerequisites():
            return False

        # Show cost estimation
        estimate = self.estimate_cost(["men_*.md", "women_*.md"])
        print(f"\n💰 Cost Estimation:")
        print(f"   📊 Total profiles: {estimate['total_profiles']}")
        print(f"   ⏱️  Estimated time: {estimate['estimated_time_minutes']} minutes")
        print(f"   🔥 API requests: {estimate['estimated_requests']}")

        # Load previous progress if resuming
        progress_data = None
        completed_profiles = []
        failed_profiles = []

        if resume:
            progress_data = self.load_progress()
            if progress_data:
                completed_profiles = progress_data.get("completed_profiles", [])
                failed_profiles = progress_data.get("failed_profiles", [])
                print(f"\n🔄 Found previous progress:")
                print(f"   ✅ Completed: {len(completed_profiles)} profiles")
                print(f"   ❌ Failed: {len(failed_profiles)} profiles")

                resume_choice = input("Resume from previous progress? (y/N): ")
                if resume_choice.lower() != "y":
                    completed_profiles = []
                    failed_profiles = []

        try:
            # Step 1: Process raw data with enhanced error handling
            input_path = Path(input_folder)
            all_processed_people = []
            # Variables already initialized at function start

            print(
                f"\n🔐 Data Protection: CSV will be saved incrementally every {save_progress_interval} profiles"
            )
            print("   This prevents data loss if the process is interrupted")

            # Load previously processed people if resuming
            if resume and completed_profiles and Path(csv_output).exists():
                print(f"\n🔄 Loading previously processed data from {csv_output}...")
                try:
                    import csv
                    from deepseek_data_processor import ProcessedPerson

                    def convert_csv_row(row):
                        """Convert CSV row strings back to proper types for ProcessedPerson"""
                        converted = {}
                        for key, value in row.items():
                            if value == "" or value == "None" or value is None:
                                converted[key] = None
                            elif key == "age" and value:
                                converted[key] = (
                                    int(value) if str(value).isdigit() else None
                                )
                            elif key == "height_cm" and value:
                                converted[key] = (
                                    int(value) if str(value).isdigit() else None
                                )
                            elif key == "weight_kg" and value:
                                converted[key] = (
                                    int(value) if str(value).isdigit() else None
                                )
                            elif key == "bmi" and value:
                                try:
                                    converted[key] = float(value)
                                except (ValueError, TypeError):
                                    converted[key] = None
                            elif key in ["has_house", "has_car"] and value:
                                converted[key] = str(value).lower() in [
                                    "true",
                                    "1",
                                    "yes",
                                ]
                            else:
                                converted[key] = value
                        return converted

                    previously_loaded = 0
                    with open(csv_output, "r", encoding="utf-8", newline="") as f:
                        reader = csv.DictReader(f)
                        for row in reader:
                            converted_row = convert_csv_row(row)
                            person = ProcessedPerson(**converted_row)
                            all_processed_people.append(person)
                            previously_loaded += 1

                    print(
                        f"   ✅ Loaded {previously_loaded} previously processed profiles"
                    )
                    total_profiles_processed = previously_loaded

                except Exception as e:
                    print(f"   ⚠️  Warning: Could not load previous data from CSV: {e}")
                    print(
                        "   🔄 Starting fresh (previous progress tracking will still work)"
                    )
                    all_processed_people = []
                    total_profiles_processed = 0

            # Get all files to process
            file_patterns = ["men_*.md", "women_*.md"]
            files_to_process = []
            for pattern in file_patterns:
                files_to_process.extend(list(input_path.glob(pattern)))

            total_profiles_processed = 0
            total_profiles_failed = 0

            for file_path in files_to_process:
                if file_path.name in ["__init__.py", "tinder.md"]:
                    continue

                print(f"\n📄 Processing file: {file_path.name}")

                try:
                    with open(file_path, "r", encoding="utf-8") as f:
                        content = f.read()

                    person_blocks = self.processor.extract_person_blocks(content)
                    print(
                        f"   📊 Found {len(person_blocks)} profiles in {file_path.name}"
                    )

                    # Process each person with retry logic
                    for i, block in enumerate(person_blocks, 1):
                        person_id = f"{file_path.stem}_{block['番号']}"

                        # Skip if already completed
                        if person_id in [p.get("id") for p in completed_profiles]:
                            print(f"   ⏭️  Skipping {person_id} (already completed)")
                            continue

                        # Skip if previously failed and max retries exceeded
                        failed_entry = next(
                            (f for f in failed_profiles if f.get("id") == person_id),
                            None,
                        )
                        if failed_entry and failed_entry.get("attempts", 0) >= 3:
                            print(f"   ⏭️  Skipping {person_id} (max retries exceeded)")
                            continue

                        print(
                            f"   🔄 Processing {person_id} ({i}/{len(person_blocks)})..."
                        )

                        # Determine gender from filename
                        gender = "female" if "women_" in file_path.name else "male"

                        try:
                            extracted_info = self.processor.call_api(block["content"])

                            if extracted_info:
                                extracted_info["id"] = person_id
                                extracted_info["raw_text"] = block["content"]
                                extracted_info["gender"] = gender

                                from deepseek_data_processor import ProcessedPerson

                                person = ProcessedPerson(**extracted_info)
                                all_processed_people.append(person)
                                completed_profiles.append(
                                    {"id": person_id, "timestamp": time.time()}
                                )
                                total_profiles_processed += 1

                                print(f"   ✅ Successfully processed {person_id}")

                                # Remove from failed list if it was there
                                failed_profiles = [
                                    f
                                    for f in failed_profiles
                                    if f.get("id") != person_id
                                ]

                            else:
                                # Add to failed list
                                attempts = (
                                    failed_entry.get("attempts", 0) + 1
                                    if failed_entry
                                    else 1
                                )
                                failed_profiles = [
                                    f
                                    for f in failed_profiles
                                    if f.get("id") != person_id
                                ]
                                failed_profiles.append(
                                    {
                                        "id": person_id,
                                        "attempts": attempts,
                                        "timestamp": time.time(),
                                        "error": "No data extracted",
                                    }
                                )
                                total_profiles_failed += 1
                                print(
                                    f"   ❌ Failed to extract info for {person_id} (attempt {attempts})"
                                )

                        except Exception as e:
                            # Add to failed list
                            attempts = (
                                failed_entry.get("attempts", 0) + 1
                                if failed_entry
                                else 1
                            )
                            failed_profiles = [
                                f for f in failed_profiles if f.get("id") != person_id
                            ]
                            failed_profiles.append(
                                {
                                    "id": person_id,
                                    "attempts": attempts,
                                    "timestamp": time.time(),
                                    "error": str(e),
                                }
                            )
                            total_profiles_failed += 1
                            print(
                                f"   ❌ Error processing {person_id}: {e} (attempt {attempts})"
                            )

                        # Save progress periodically
                        if (
                            total_profiles_processed + total_profiles_failed
                        ) % save_progress_interval == 0:
                            # Save progress state
                            self.save_progress(
                                {
                                    "completed_profiles": completed_profiles,
                                    "failed_profiles": failed_profiles,
                                    "last_updated": time.time(),
                                    "total_processed": total_profiles_processed,
                                    "total_failed": total_profiles_failed,
                                }
                            )

                            # Save CSV incrementally to prevent data loss
                            if all_processed_people:
                                print(
                                    f"   💾 Saving incremental CSV with {len(all_processed_people)} profiles..."
                                )
                                self.processor.save_to_csv(
                                    all_processed_people, Path(csv_output)
                                )

                            print(
                                f"   💾 Progress saved ({total_profiles_processed} completed, {total_profiles_failed} failed)"
                            )

                except Exception as e:
                    print(f"   ❌ Error processing file {file_path.name}: {e}")
                    continue

            # Final progress save
            self.save_progress(
                {
                    "completed_profiles": completed_profiles,
                    "failed_profiles": failed_profiles,
                    "last_updated": time.time(),
                    "total_processed": total_profiles_processed,
                    "total_failed": total_profiles_failed,
                }
            )

            # Save final CSV before analysis
            if all_processed_people:
                print(
                    f"💾 Saving final CSV with {len(all_processed_people)} profiles..."
                )
                self.processor.save_to_csv(all_processed_people, Path(csv_output))

            if not all_processed_people:
                print("❌ No profiles were processed successfully!")
                return False

            print(f"\n📊 Processing Summary:")
            print(f"   ✅ Successfully processed: {total_profiles_processed}")
            print(f"   ❌ Failed: {total_profiles_failed}")

            # Step 2: Final CSV verification (data saved incrementally during processing)
            print(f"\n💾 Finalizing CSV...")
            self.processor.save_to_csv(all_processed_people, Path(csv_output))
            print(f"✅ Final CSV saved to: {csv_output}")

            # Step 3: Convert to Flutter format
            print(f"\n🔄 Converting to Flutter format...")
            characters = self.converter.csv_to_character_data(csv_output, json_output)
            print(f"✅ JSON saved to: {json_output}")

            # Step 4: Summary
            print(f"\n🎉 Pipeline Complete!")
            print("=" * 50)
            print(f"📈 Total profiles processed: {len(characters)}")
            print(f"📁 Files created:")
            print(f"   - {csv_output} (CSV data)")
            print(f"   - {json_output} (JSON data)")

            if failed_profiles:
                print(f"\n⚠️  Some profiles failed to process:")
                for failed in failed_profiles:
                    print(
                        f"   - {failed['id']}: {failed.get('error', 'Unknown error')} (attempts: {failed.get('attempts', 1)})"
                    )

            return True

        except KeyboardInterrupt:
            print(f"\n\n⚠️  Pipeline interrupted by user")
            try:
                print(
                    f"📊 Progress: {total_profiles_processed} completed, {total_profiles_failed} failed"
                )
            except NameError:
                print("📊 Progress: Pipeline interrupted early")

            # Save current progress if variables exist
            try:
                # Check if we have progress variables before using them
                if "completed_profiles" in locals() and "failed_profiles" in locals():
                    # Save progress state
                    self.save_progress(
                        {
                            "completed_profiles": completed_profiles,
                            "failed_profiles": failed_profiles,
                            "last_updated": time.time(),
                            "total_processed": total_profiles_processed,
                            "total_failed": total_profiles_failed,
                            "interrupted": True,
                        }
                    )

                    # Save CSV data to prevent loss on interruption
                    if "all_processed_people" in locals() and all_processed_people:
                        print(
                            f"💾 Saving {len(all_processed_people)} processed profiles to CSV before exit..."
                        )
                        try:
                            self.processor.save_to_csv(
                                all_processed_people, Path(csv_output)
                            )
                            print("✅ CSV data saved successfully")
                        except Exception as csv_error:
                            print(f"⚠️  Failed to save CSV: {csv_error}")

                    print("💾 Progress saved. You can resume later.")
                else:
                    print("⚠️  No progress to save (interrupted during initialization)")
            except NameError:
                print("⚠️  No progress to save (interrupted early)")
            except Exception as save_error:
                print(f"⚠️  Failed to save progress: {save_error}")
            return False

        except Exception as e:
            print(f"\n❌ Pipeline failed with unexpected error: {e}")
            try:
                print(
                    f"📊 Progress at failure: {total_profiles_processed} completed, {total_profiles_failed} failed"
                )
            except NameError:
                print("📊 Pipeline failed during initialization")
            return False

    def run_test_pipeline(self, test_file: str = "men_100.md", max_profiles: int = 10):
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
                test_csv = "output/test_profiles.csv"
                test_json = "output/test_characters.json"

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
                print(f"📁 Test files: {test_csv}, {test_json}")
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
    print("1. Run test pipeline (10 profiles, minimal cost)")
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
                print("\n🚀 Running full pipeline with retry logic...")
                success = pipeline.run_full_pipeline_with_retry()
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
                success = pipeline.run_full_pipeline_with_retry(
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
