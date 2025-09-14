"""
CSV to Flutter Data Converter
Converts processed dating profile CSV data to Dart format for Flutter app integration
"""

import os
import sys
import pandas as pd
import json
from pathlib import Path
from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional

# Add current directory and parent directory to Python path
current_dir = Path(__file__).parent
sys.path.append(str(current_dir))
sys.path.append(str(current_dir.parent.parent.parent))  # Add root folder

# Change working directory to script location if running from elsewhere
if Path.cwd() != current_dir:
    print(f"Changing working directory to: {current_dir}")
    os.chdir(current_dir)


class FlutterDataConverter:
    """Convert processed CSV data to Flutter-compatible format"""

    def __init__(self):
        pass

    def csv_to_character_data(
        self, csv_file: str, output_file: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """Convert CSV data to Flutter Character format"""

        # Read CSV
        df = pd.read_csv(csv_file)

        characters = []

        for i in range(len(df)):
            row = df.iloc[i]
            character = self._convert_row_to_character(row, i)
            characters.append(character)

        # Save to JSON if output file specified
        if output_file:
            with open(output_file, "w", encoding="utf-8") as f:
                json.dump(
                    characters,
                    f,
                    ensure_ascii=False,
                    indent=2,
                    default=str,
                    allow_nan=False,
                )

        return characters

    def _convert_row_to_character(self, row: pd.Series, index: int) -> Dict[str, Any]:
        """Convert a single CSV row to Character format with only required fields"""

        # Generate unique ID
        char_id = f"profile_{row.get('id', index)}"

        # Extract raw text and clean it
        raw_text = self._safe_str(row.get("raw_text"))

        # Extract image first, then clean the text
        image_url = self._extract_image_from_text(raw_text)
        cleaned_raw_text = self._remove_images_from_text(raw_text)

        # Your required fields only
        character = {
            "id": char_id,
            "gender": self._safe_str(row.get("gender")),
            "age": self._safe_int(
                row.get("age")
            ),  # No random fallback - keep actual data or null
            "height": self._safe_int(row.get("height_cm")),  # height in cm
            "zodiac": self._safe_str(row.get("zodiac")),
            "mbti": self._safe_str(row.get("mbti")),
            "raw_text": cleaned_raw_text,  # cleaned profile text (images removed)
            "image": image_url,  # extracted image URL
            "bmi": self._safe_float(row.get("bmi")),
            "hometown": self._safe_str(row.get("hometown")),
            "current_location": self._safe_str(row.get("current_location")),
            "occupation": self._safe_str(row.get("occupation")),
            "interests": self._extract_interests(
                row.get("hobbies")
            ),  # converted from hobbies
            "has_house": self._safe_bool(row.get("has_house")),
            "has_car": self._safe_bool(row.get("has_car")),
            "marital_status": self._safe_str(row.get("marital_status")),
        }

        return character

    def _build_description(self, row: pd.Series) -> str:
        """Build character description from available data"""
        description_parts = []

        # Self introduction
        if pd.notna(row.get("self_introduction")):
            description_parts.append(str(row["self_introduction"])[:150])

        # Partner preferences
        if pd.notna(row.get("partner_preferences")):
            description_parts.append(
                "理想の相手：" + str(row["partner_preferences"])[:100]
            )

        # Personality
        if pd.notna(row.get("personality")):
            description_parts.append("性格：" + str(row["personality"])[:100])

        # Default description if nothing available
        if not description_parts:
            description_parts.append("よろしくお願いします！")

        return "\\n".join(description_parts)

    def _extract_interests(self, hobbies_str: Optional[str]) -> List[str]:
        """Extract and normalize interests from hobbies string - no random defaults"""
        if pd.isna(hobbies_str):
            return []  # Return empty array instead of random defaults

        # Split by common delimiters
        hobbies = str(hobbies_str).replace("、", ",").replace("，", ",")
        interests = [h.strip() for h in hobbies.split(",") if h.strip()]

        # Limit to 6 interests and clean up
        interests = [interest for interest in interests[:6] if len(interest) < 10]

        # Normalize interests to avoid redundancy
        interests = type(self)._normalize_interests(interests)

        return interests  # Return normalized interests or empty array

    @classmethod
    def _normalize_interests(cls, interests: List[str]) -> List[str]:
        """Normalize interests to avoid redundancy like '游泳', '读书', '游泳读书'"""
        if not interests:
            return []

        # Sort interests by length (shortest first)
        sorted_interests = sorted(interests, key=len)

        normalized_interests = []

        for interest in sorted_interests:
            # Check if this interest is a combination of already processed interests
            is_composite = any(
                existing in interest and existing != interest
                for existing in normalized_interests
            )

            if not is_composite:
                normalized_interests.append(interest)

        return normalized_interests

    def _extract_image_from_text(self, raw_text: Optional[str]) -> Optional[str]:
        """Extract image URL from markdown text"""
        if pd.isna(raw_text) or not raw_text:
            return None

        import re

        # Look for markdown image syntax: ![alt](url)
        markdown_img = re.search(r"!\[.*?\]\((https?://[^\s\)]+)\)", str(raw_text))
        if markdown_img:
            return markdown_img.group(1)

        # Look for direct GitHub asset URLs (common in the profiles)
        github_asset = re.search(
            r"(https://github\.com/[^\s\)]+\.(?:jpg|jpeg|png|gif|webp))",
            str(raw_text),
            re.IGNORECASE,
        )
        if github_asset:
            return github_asset.group(1)

        # Look for other image URLs
        img_url = re.search(
            r"(https?://[^\s\)]+\.(?:jpg|jpeg|png|gif|webp))",
            str(raw_text),
            re.IGNORECASE,
        )
        if img_url:
            return img_url.group(1)

        # No image found
        return None

    def _remove_images_from_text(self, raw_text: Optional[str]) -> Optional[str]:
        """Remove image markdown and URLs from raw text with improved formatting"""
        if pd.isna(raw_text) or not raw_text:
            return raw_text

        import re

        cleaned_text = str(raw_text)

        # Remove markdown image syntax: ![alt](url) - with surrounding whitespace
        cleaned_text = re.sub(r"\s*!\[.*?\]\([^\)]+\)\s*", " ", cleaned_text)

        # Remove markdown code block markers
        cleaned_text = re.sub(r"^\s*```\s*$", "", cleaned_text, flags=re.MULTILINE)
        cleaned_text = re.sub(
            r"\s*```\s*", "\n", cleaned_text
        )  # Replace ``` with newline

        # Remove standalone GitHub asset URLs with surrounding whitespace
        cleaned_text = re.sub(
            r"\s*https://github\.com/[^\s\)]+\.(?:jpg|jpeg|png|gif|webp)\s*",
            " ",
            cleaned_text,
            flags=re.IGNORECASE,
        )

        # Remove other standalone image URLs with surrounding whitespace
        cleaned_text = re.sub(
            r"\s*https?://[^\s\)]+\.(?:jpg|jpeg|png|gif|webp)\s*",
            " ",
            cleaned_text,
            flags=re.IGNORECASE,
        )

        # Clean up formatting issues:
        # 1. Remove empty lines that only contain whitespace
        cleaned_text = re.sub(r"\n\s*\n", "\n\n", cleaned_text)

        # 2. Remove triple or more consecutive newlines
        cleaned_text = re.sub(r"\n\n\n+", "\n\n", cleaned_text)

        # 3. Fix lines that start with just whitespace after image removal
        cleaned_text = re.sub(r"\n\s+\n", "\n\n", cleaned_text)

        # 4. Remove extra spaces within lines
        cleaned_text = re.sub(r" {2,}", " ", cleaned_text)

        # 5. Fix lines that end up empty after image removal
        lines = cleaned_text.split("\n")
        cleaned_lines = []
        for line in lines:
            line = line.strip()
            # Remove common markdown artifacts and empty lines
            if line and line not in ["```", "- (", "- ", "-", "```"]:
                cleaned_lines.append(line)
            elif (
                not line and cleaned_lines and cleaned_lines[-1]
            ):  # Preserve meaningful empty lines
                cleaned_lines.append("")

        # Rejoin and final cleanup
        cleaned_text = "\n".join(cleaned_lines)
        cleaned_text = cleaned_text.strip()

        # Remove any remaining artifacts
        cleaned_text = re.sub(r"^\s*-\s*$", "", cleaned_text, flags=re.MULTILINE)
        cleaned_text = re.sub(
            r"^\s*```\s*$", "", cleaned_text, flags=re.MULTILINE
        )  # Remove standalone code block markers
        cleaned_text = re.sub(r"\n\n\n+", "\n\n", cleaned_text)

        # Final cleanup - remove empty lines at start/end caused by removal
        cleaned_text = cleaned_text.strip()

        return cleaned_text if cleaned_text else None

    def _safe_str(self, value) -> Optional[str]:
        """Safely convert value to string, handling NaN"""
        if pd.isna(value):
            return None
        try:
            return str(value)
        except (ValueError, TypeError):
            return None

    def _safe_int(self, value) -> Optional[int]:
        """Safely convert value to int"""
        if pd.isna(value):
            return None
        try:
            return int(float(str(value)))
        except (ValueError, TypeError):
            return None

    def _safe_float(self, value) -> Optional[float]:
        """Safely convert value to float"""
        if pd.isna(value):
            return None
        try:
            return float(str(value))
        except (ValueError, TypeError):
            return None

    def _safe_bool(self, value) -> Optional[bool]:
        """Safely convert value to bool"""
        if pd.isna(value):
            return None
        if isinstance(value, bool):
            return value
        if isinstance(value, str):
            return value.lower() in ["true", "1", "yes", "y"]
        try:
            return bool(int(float(str(value))))
        except (ValueError, TypeError):
            return None


def main():
    """Main function to convert CSV to Flutter format"""

    # File paths
    csv_file = "test_profiles.csv"
    json_output = "flutter_characters.json"

    if not Path(csv_file).exists():
        print(f"CSV file {csv_file} not found!")
        print("Please run the data processor first to generate the CSV file.")
        return

    print("Converting CSV data to Flutter format...")

    # Create converter
    converter = FlutterDataConverter()

    try:
        # Convert CSV to character format
        characters = converter.csv_to_character_data(csv_file, json_output)

        print(f"✓ Converted {len(characters)} profiles to JSON format")
        print(f"✓ Saved JSON data to {json_output}")

        print(f"\nConversion complete!")
        print(f"Total profiles: {len(characters)}")
        print(f"\nTo use in your Flutter app:")
        print(f"1. Import: import 'data/generated_characters_data.dart';")
        print(f"2. Use: GeneratedCharactersData.getCharacters()")

    except Exception as e:
        print(f"Error during conversion: {e}")


if __name__ == "__main__":
    main()
