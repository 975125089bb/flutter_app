from pathlib import Path
import re
from dataclasses import asdict, dataclass
from typing import List, Optional, Dict, Any
import re
from datetime import datetime  # Correct import for datetime

@dataclass
class Person:
    # Core identification
    id: str
    raw_text: str = None
    gender: Optional[str] = None
    
    # Personal details
    birth_year: Optional[str] = None
    zodiac: Optional[str] = None
    mbti: Optional[str] = None
    height: Optional[str] = None  # Original string value
    weight: Optional[str] = None  # Original string value
    bmi: Optional[float] = None
    
    # Derived/Calculated fields
    age: Optional[int] = None
    height_cm: Optional[int] = None
    weight_kg: Optional[int] = None
    
    # Background information
    hometown: Optional[str] = None
    current_residence: Optional[str] = None
    years_in_japan: Optional[str] = None
    japanese_level: Optional[str] = None
    
    # Education and career
    education: Optional[str] = None
    education_level: Optional[str] = None
    occupation: Optional[str] = None
    annual_income: Optional[str] = None
    income_min: Optional[int] = None
    income_max: Optional[int] = None
    
    # Legal status
    visa_status: Optional[str] = None
    
    # Lifestyle
    hobbies: Optional[str] = None
    smoking: Optional[str] = None
    drinking: Optional[str] = None
    has_pets: Optional[str] = None
    
    # Family information
    marital_status: Optional[str] = None
    has_children: Optional[str] = None
    family_info: Optional[str] = None
    
    # Assets
    has_property: Optional[str] = None
    has_car: Optional[str] = None
    
    # Personality and additional info
    personality: Optional[str] = None
    other_info: Optional[str] = None
    
    # Partner preferences
    partner_preferences: Optional[str] = None
    

    def __post_init__(self):
        """Post-initialization processing"""
        # Convert height to integer if possible
        if self.height:
            try:
                # Remove non-digit characters and convert
                clean_height = re.sub(r'\D', '', self.height)
                if clean_height:
                    self.height_cm = int(clean_height)
            except (ValueError, TypeError):
                pass
        
        # Convert weight to integer if possible
        if self.weight:
            try:
                # Remove non-digit characters and convert
                clean_weight = re.sub(r'\D', '', self.weight)
                if clean_weight:
                    self.weight_kg = int(clean_weight)
            except (ValueError, TypeError):
                pass
        
        if self.birth_year:
            try:
                # Case 1: Direct year format ("94年", "1994年")
                if re.search(r'\d{2,4}年', self.birth_year):
                    year_str = re.search(r'(\d{2,4})年', self.birth_year).group(1)
                    birth_year = int(year_str)
                    if birth_year < 100:  # Handle 2-digit years
                        birth_year += 1900 if birth_year > 30 else 2000
                        
                # Case 2: Plain number ("1994", "94")
                elif self.birth_year.isdigit():
                    birth_year = int(self.birth_year)
                    if birth_year < 100:  # Handle 2-digit years
                        birth_year += 1900 if birth_year > 30 else 2000
                
                # Case 3: Other formats ("1994.05", "1994年5月")
                else:
                    year_str = re.search(r'\d{4}', self.birth_year)
                    birth_year = int(year_str.group()) if year_str else None
                
                # Calculate age if we got a valid year
                if birth_year:
                    current_year = datetime.now().year
                    self.age = current_year - birth_year
                    
            except (ValueError, TypeError, AttributeError):
                pass
        
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for easy serialization"""
        return asdict(self)
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]):
        """Create from dictionary"""
        return cls(**data)

def extract_person_info(text: str) -> Dict[str, Any]:
    """Extract person information from a text block with enhanced pattern matching"""
    info = {}
    
    # Extract ID - improved pattern to handle different formats
    id_match = re.search(r'编号\s*(\d+)|（编号(\d+)）', text)
    if id_match:
        info['id'] = id_match.group(1) or id_match.group(2)  # Handle different formats
    
    # Enhanced patterns with better coverage and multilingual support
    patterns = {
        # Basic info
        'gender': r'性别[：:]?\s*([男女])',
        'birth_year': r'(?:出生[年月日]?|生年|年龄|出生年份|出生年|年[齢令]|ご?年齢|出厂日|(\d{1,2})岁|岁数|^|\s)(\d{2,4})年?[^\d]?',
        'zodiac': r'星座[：:]?\s*([^\n]+)',
        'mbti': r'MBTI[：:]?\s*([A-Za-z]{4})',
        
        # Physical attributes
        'height': r'身高[：:]?\s*(\d{2,3}\s*cm|\d{2,3})',
        'weight': r'体重[：:]?\s*(\d{2,3}\s*kg|\d{2,3})',
        'bmi': r'BMI[：:]?\s*([\d\.]+)',
        
        # Background
        'hometown': r'(?:出生地|籍贯|戸籍地|户籍地|老家|祖籍|家乡|◇籍贯|◇戸籍地)[：:]?\s*([^\n]+)',
        'current_residence': r'(?:现居住地|現住所|现住|居住地|◇現住所)[：:]?\s*([^\n]+)',
        'education': r'(?:学历|最終学歴|毕业院校|学校|学历|毕业学校)[：:]?\s*([^\n]+)',
        'occupation': r'(?:工作|ご職業|职业|行业|工作方面|职业)[：:]?\s*([^\n]+)',
        'annual_income': r'(?:年收|ご年収|年收|收入|年収|年收)[：:]?\s*([\d\-〜～\+]+[万wW]?)',
        'visa_status': r'(?:签证类型|在就资格|签证种类|在留|◇签证类型)[：:]?\s*([^\n]+)',
        'years_in_japan': r'(?:来日|赴日)[：:]?\s*([^\n]+)',
        'japanese_level': r'(?:日本語程度|日语)[：:]?\s*([^\n]+)',
        
        # Lifestyle
        'hobbies': r'(?:兴趣爱好|趣味|爱好|兴趣)[：:]?\s*([\s\S]+?)(?:\n\n|$)',
        'smoking': r'(?:抽烟|吸烟)[：:]?\s*([^\n]+)',
        'drinking': r'(?:喝酒|饮酒)[：:]?\s*([^\n]+)',
        'has_pets': r'(?:养宠物|有猫|有狗|养猫|养狗)[：:]?\s*([^\n]+)',
        
        # Family
        'marital_status': r'(?:婚史|感情状态|婚歴|婚姻状况)[：:]?\s*([^\n]+)',
        'has_children': r'(?:有孩子|有女儿|有儿子|有小孩|孩子情况)[：:]?\s*([^\n]+)',
        'family_info': r'(?:家庭状况|家庭情况|原生家庭|家族との同居)[：:]?\s*([^\n]+)',
        
        # Assets
        'has_property': r'(?:有房|已购房|有2套房|有自己的房子|◇是否已买房)[：:]?\s*([^\n]+)',
        'has_car': r'(?:有车|有自己的车子|◇是否已买车)[：:]?\s*([^\n]+)',
        
        # Personality
        'personality': r'(?:性格|性格特点|自我性格特征)[：:]?\s*([\s\S]+?)(?:\n\n|$)',
        
        # Partner preferences
        'partner_preferences': r'(?:对女?方的要求|希望对方|择偶要求|期待女生|择偶标准|择偶条件|要求男方|对伴侣的期望)[：:]?\s*([\s\S]+?)(?:\n\n|\Z)',
    }
    
    # First pass: Extract all fields using patterns
    for field, pattern in patterns.items():
        match = re.search(pattern, text, re.IGNORECASE | re.DOTALL)
        if match:
            # Handle fields with multiple capturing groups
            value = None
            if field in ['has_property', 'has_car', 'has_children']:
                value = True if "有" in match.group(0) else False  # Better boolean handling
            else:
                value = next((g for g in match.groups() if g is not None), match.group(0))
            
            if value:  # Only add non-empty values
                info[field] = value
    
    # Special handling for combined height/weight format (e.g., "163/50")
    hw_match = re.search(r'(\d{3})\s*[/／]\s*(\d{2,3})', text)
    if hw_match:
        if 'height' not in info:
            info['height'] = hw_match.group(1)
        if 'weight' not in info:
            info['weight'] = hw_match.group(2)
    
    # Special handling for income ranges
    if 'annual_income' in info:
        range_match = re.search(r'(\d+)\s*[〜～\-]\s*(\d+)\s*[万wW]', info['annual_income'])
        if range_match:
            info['income_min'] = range_match.group(1)
            info['income_max'] = range_match.group(2)
    
    # Normalize extracted values
    for field in ['height', 'weight']:
        if field in info:
            # Remove units and extra spaces
            info[field] = re.sub(r'[^\d]', '', info[field])
    
    # Extract other info sections with multiline support
    other_info_sections = []
    other_patterns = [
        r'其他[：:]\s*([\s\S]+?)(?=\n\n|$)',
        r'补充介绍[：:]\s*([\s\S]+?)(?=\n\n|$)',
        r'自我介绍[：:]\s*([\s\S]+?)(?=\n\n|$)',
        r'简介[：:]\s*([\s\S]+?)(?=\n\n|$)',
        r'其他介绍[：:]\s*([\s\S]+?)(?=\n\n|$)'
    ]
    
    for pattern in other_patterns:
        matches = re.findall(pattern, text)
        other_info_sections.extend(matches)
    
    if other_info_sections:
        info['other_info'] = "\n\n".join([sec.strip() for sec in other_info_sections])
    
    # Extract and clean visa status
    if 'visa_status' in info:
        visa_clean = re.search(r'(永住|高度人才|工作签证|経営・管理|特定活動)', info['visa_status'])
        if visa_clean:
            info['visa_status'] = visa_clean.group(1)
    
    # Extract education level
    if 'education' in info:
        edu_level = re.search(r'(专科|本科|修士|硕士|博士|大学院|研究生|高校)', info['education'])
        if edu_level:
            info['education_level'] = edu_level.group(1)
    
    # Extract language proficiency
    if 'japanese_level' in info:
        lang_level = re.search(r'(N1|N2|N3|N4|N5|JLPT)', info['japanese_level'])
        if lang_level:
            info['japanese_level'] = lang_level.group(1)
    
    return info

def process_data_file(file_path: str) -> List[Person]:
    """Process the data file and extract all person information"""
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # Split content into individual person blocks
    person_blocks = re.split(r'编号\d+', content)
    person_blocks = [block.strip() for block in person_blocks if block.strip()]
    
    people = []
    for i, block in enumerate(person_blocks, 1):
        print(block)
        info = extract_person_info(block)
        info["raw_text"] = block
        if not info.get('id'):
            # If no ID found, use the index
            id_match = re.search(r'编号(\d+)', block)
            if id_match:
                info['id'] = id_match.group(1)
            else:
                info['id'] = str(i)
        
        people.append(Person(**info))
    
    return people

def save_to_csv(people: List[Person], output_file: str):
    """Save the extracted data to a CSV file"""
    import csv
    
    fieldnames = [field.name for field in Person.__dataclass_fields__.values()]
    
    with open(output_file, 'w', newline='', encoding='utf-8-sig') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for person in people:
            writer.writerow(person.__dict__)

def main():
    # Assuming the data is saved in a file called 'personal_data.txt'
    folder_path = Path("lib", "data_generate_python", "raw_data")
    input_file = Path(folder_path, "men_100.md")
    output_file = 'extracted_personal_info.csv'
    
    people = process_data_file(input_file)
    save_to_csv(people, output_file)
    print(f"Successfully extracted data for {len(people)} people to {output_file}")

if __name__ == "__main__":
    main()