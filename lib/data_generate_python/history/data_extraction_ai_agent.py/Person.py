from dataclasses import dataclass
from typing import Optional


@dataclass
class Person:
    # Identification
    id: str
    raw_text: str = None
    # Personal details
    birth_year: Optional[str] = None
    zodiac: Optional[str] = None
    mbti: Optional[str] = None
    
    # Calculated fields
    age: Optional[int] = None
    height_cm: Optional[int] = None
    weight_kg: Optional[int] = None
    bmi: Optional[float] = None
