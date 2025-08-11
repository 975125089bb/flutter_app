import os
import json
import time
import re
import csv
from pathlib import Path
from typing import List, Dict, Any, Optional
from dataclasses import dataclass, asdict
import requests
from datetime import datetime


@dataclass
class ProcessedPerson:
    """Data structure for processed person information"""

    id: str
    raw_text: Optional[str] = None

    # Basic info
    gender: Optional[str] = None
    birth_year: Optional[str] = None
    age: Optional[int] = None
    zodiac: Optional[str] = None
    mbti: Optional[str] = None

    # Physical attributes
    height_cm: Optional[int] = None
    weight_kg: Optional[int] = None
    bmi: Optional[float] = None

    # Location info
    hometown: Optional[str] = None
    current_location: Optional[str] = None

    # Education & Career
    education: Optional[str] = None
    occupation: Optional[str] = None
    annual_income: Optional[str] = None

    # Lifestyle
    hobbies: Optional[str] = None
    personality: Optional[str] = None

    # Assets & Status
    has_house: Optional[bool] = None
    has_car: Optional[bool] = None
    marital_status: Optional[str] = None

    # Preferences
    partner_preferences: Optional[str] = None
    self_introduction: Optional[str] = None

    def __post_init__(self):
        """Calculate derived fields"""
        if self.height_cm and self.weight_kg:
            height_m = self.height_cm / 100
            self.bmi = round(self.weight_kg / (height_m**2), 1)

        if self.birth_year and self.birth_year.isdigit():
            current_year = datetime.now().year
            birth_year_int = int(self.birth_year)
            if birth_year_int < 100:  # Handle 2-digit years
                birth_year_int += 1900 if birth_year_int > 30 else 2000
            self.age = current_year - birth_year_int


class DeepSeekProcessor:
    """Process personal data using DeepSeek API with cost control"""

    def __init__(
        self,
        api_key: str,
        max_requests_per_minute: int = 20,
        delay_between_requests: float = 3.5,
    ):
        self.api_key = api_key
        self.base_url = "https://api.deepseek.com/v1/chat/completions"
        self.max_requests_per_minute = max_requests_per_minute
        self.delay_between_requests = delay_between_requests
        self.request_count = 0
        self.start_time = time.time()

        self.system_prompt = """
你是一个专业的个人信息提取助手。用户将提供包含个人档案信息的中文文本。

请严格按以下JSON格式返回提取到的所有信息，未提及的字段返回null。
注意：性别将由系统根据文件名自动确定，无需从文本中提取。

{
    "birth_year": "出生年份（4位数字字符串，如'1990'）或null",
    "zodiac": "星座或null", 
    "mbti": "MBTI性格类型（4字母，如'ENTJ'）或null",
    "height_cm": "身高厘米数（整数）或null",
    "weight_kg": "体重千克数（整数）或null",
    "hometown": "家乡/出生地或null",
    "current_location": "现居住地/地区或null", 
    "education": "学历或null",
    "occupation": "职业或null",
    "annual_income": "年收入描述或null",
    "hobbies": "爱好兴趣（合并为一个字符串）或null",
    "personality": "性格描述或null",
    "has_house": "是否有房（true/false/null）",
    "has_car": "是否有车（true/false/null）",
    "marital_status": "婚姻状况或null",
    "partner_preferences": "择偶要求或null",
    "self_introduction": "自我介绍或null"
}

提取规则：
1. 年份转换：81年->1981年，04年->2004年，2位数年份：>30加1900，<=30加2000
2. 单位转换：自动转换身高体重到厘米和千克
3. 房车状态：从"有房无车"、"无房有车"等文本中提取布尔值
4. 合并相似字段：将所有爱好合并为一个字符串
5. 只返回JSON，不要其他文字说明
6. 不要提取性别信息（系统会自动处理）

示例输入："81年生，身高180，体重85，松户，沈阳，大学，软件，天蝎，有房无车，离婚，爱好：书法，摄影"
示例输出：{"birth_year":"1981","zodiac":"天蝎","height_cm":180,"weight_kg":85,"hometown":"沈阳","current_location":"松户","education":"大学","occupation":"软件","hobbies":"书法，摄影","has_house":true,"has_car":false,"marital_status":"离婚"}
"""

    def rate_limit_control(self):
        """Control API request rate to avoid costs"""
        self.request_count += 1

        # Check if we've exceeded the rate limit
        elapsed_time = time.time() - self.start_time
        if elapsed_time < 60 and self.request_count >= self.max_requests_per_minute:
            sleep_time = 60 - elapsed_time
            print(f"Rate limit reached. Sleeping for {sleep_time:.1f} seconds...")
            time.sleep(sleep_time)
            self.request_count = 0
            self.start_time = time.time()

        # Delay between requests
        time.sleep(self.delay_between_requests)

    def call_api(self, text: str) -> Dict[str, Any]:
        """Make API call to DeepSeek"""
        self.rate_limit_control()

        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
        }

        payload = {
            "model": "deepseek-chat",
            "messages": [
                {"role": "system", "content": self.system_prompt},
                {"role": "user", "content": text},
            ],
            "temperature": 0.1,  # Low temperature for consistent extraction
            "max_tokens": 1000,
            "stream": False,
        }

        try:
            response = requests.post(
                self.base_url, headers=headers, json=payload, timeout=30
            )
            response.raise_for_status()

            result = response.json()
            content = result["choices"][0]["message"]["content"].strip()

            # Extract JSON from response
            json_match = re.search(r"\{.*\}", content, re.DOTALL)
            if json_match:
                return json.loads(json_match.group())
            else:
                print(f"No JSON found in response: {content}")
                return {}

        except requests.exceptions.RequestException as e:
            print(f"API request failed: {e}")
            return {}
        except json.JSONDecodeError as e:
            print(f"JSON decode error: {e}")
            return {}
        except Exception as e:
            print(f"Unexpected error: {e}")
            return {}

    def extract_person_blocks(self, content: str) -> List[Dict[str, str]]:
        """Extract individual person blocks from markdown content"""
        person_blocks = []

        # Split by person entries (编号XX pattern)
        pattern = r"编号"
        splits = re.split(pattern, content)

        # Process splits in pairs (id, content)
        for i in range(1, len(splits)):
            person_id = i
            person_content = splits[i]

            if "\n" in person_content:

                # extract the number ID
                first_line = person_content[: person_content.find("\n")]
                match = re.search(r"(\d+)", first_line)
                person_number = match.group(1) if match else "None"

                person_content = (
                    "编号"
                    + person_number
                    + "\n"
                    + person_content[person_content.find("\n") + 1 :]
                )

            if person_content:
                person_blocks.append({"id": person_id, "content": person_content})

        return person_blocks

    def determine_gender_from_filename(self, file_path: Path) -> Optional[str]:
        """Determine gender from filename pattern"""
        filename = file_path.name.lower()
        if filename.startswith("men_"):
            return "男"
        elif filename.startswith("women_"):
            return "女"
        return None

    def process_file(self, file_path: Path) -> List[ProcessedPerson]:
        """Process a single data file"""
        print(f"Processing file: {file_path.name}")

        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()

        person_blocks = self.extract_person_blocks(content)
        processed_people = []

        # Determine gender from filename
        gender_from_filename = self.determine_gender_from_filename(file_path)
        if gender_from_filename:
            print(f"📋 Determined gender from filename: {gender_from_filename}")

        for block in person_blocks:
            person_id = block["id"]
            text = block["content"]

            print(f"Processing person {person_id}...")

            # Call API to extract information
            extracted_info = self.call_api(text)

            if extracted_info:
                # Override gender with filename-based determination
                if gender_from_filename:
                    extracted_info["gender"] = gender_from_filename
                    print(f"✓ Set gender from filename: {gender_from_filename}")

                # Create ProcessedPerson object
                extracted_info["id"] = person_id
                extracted_info["raw_text"] = text

                try:
                    person = ProcessedPerson(**extracted_info)
                    processed_people.append(person)
                    print(f"✓ Successfully processed person {person_id}")
                except TypeError as e:
                    print(f"✗ Error creating person object for {person_id}: {e}")
                    # Create with minimal data
                    person = ProcessedPerson(
                        id=person_id, raw_text=text, gender=gender_from_filename
                    )
                    processed_people.append(person)
            else:
                print(f"✗ Failed to extract info for person {person_id}")
                # Create with minimal data, but include gender from filename
                person = ProcessedPerson(
                    id=person_id, raw_text=text, gender=gender_from_filename
                )
                processed_people.append(person)

        return processed_people

    def process_all_files(
        self,
        input_folder: Path,
        output_file: Path,
        file_patterns: Optional[List[str]] = None,
    ) -> List[ProcessedPerson]:
        """Process all matching files in the input folder"""

        if file_patterns is None:
            file_patterns = ["*.md"]

        all_people = []
        processed_files = []

        for pattern in file_patterns:
            files = list(input_folder.glob(pattern))
            for file_path in sorted(files):
                if file_path.name in [
                    "__init__.py",
                    "tinder.md",
                ]:  # Skip non-data files
                    continue

                try:
                    people = self.process_file(file_path)
                    all_people.extend(people)
                    processed_files.append(file_path.name)

                    print(f"Processed {len(people)} people from {file_path.name}")

                    # Save progress after each file
                    self.save_to_csv(all_people, output_file)

                except Exception as e:
                    print(f"Error processing file {file_path}: {e}")
                    continue

        print(f"\nProcessing complete!")
        print(f"Files processed: {processed_files}")
        print(f"Total people processed: {len(all_people)}")
        print(f"Total API requests made: {self.request_count}")

        return all_people

    def save_to_csv(self, people: List[ProcessedPerson], output_file: Path):
        """Save processed data to CSV"""
        if not people:
            return

        fieldnames = list(ProcessedPerson.__dataclass_fields__.keys())

        with open(output_file, "w", newline="", encoding="utf-8-sig") as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()
            for person in people:
                writer.writerow(asdict(person))

        print(f"Data saved to {output_file}")


def main():
    """Main processing function"""
    # Configuration
    API_KEY = "sk-d17e63eeef2d46f4bb404b2a05f125ce"  # Your API key

    # Paths
    input_folder = Path("lib/data_generate_python/raw_data")
    output_file = Path("processed_dating_profiles.csv")

    # Create processor
    processor = DeepSeekProcessor(
        api_key=API_KEY,
        max_requests_per_minute=15,  # Conservative rate limiting
        delay_between_requests=4.0,  # 4 second delay between requests
    )

    # Process files (you can specify which files to process)
    file_patterns = ["men_*.md", "women_*.md"]  # Process all men and women files

    print("Starting data processing with DeepSeek API...")
    print(f"Input folder: {input_folder}")
    print(f"Output file: {output_file}")
    print("=" * 50)

    try:
        all_people = processor.process_all_files(
            input_folder=input_folder,
            output_file=output_file,
            file_patterns=file_patterns,
        )

        print(f"\nFinal results:")
        print(f"Total profiles processed: {len(all_people)}")
        print(f"Output saved to: {output_file}")

    except KeyboardInterrupt:
        print("\nProcessing interrupted by user.")
    except Exception as e:
        print(f"\nUnexpected error: {e}")


if __name__ == "__main__":
    main()
