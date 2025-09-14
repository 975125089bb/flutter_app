#!/usr/bin/env python3
"""
Test script to demonstrate hobby normalization functionality
"""

import re
from typing import List

import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from csv_to_flutter_converter import FlutterDataConverter
from deepseek_data_processor import normalize_hobbies


def test_normalization():
    """Test the hobby normalization with real examples"""

    print("🧪 Testing Hobby Normalization\n")

    test_cases = [
        # Case 1: Simple comma-separated hobbies
        {"input": "游泳，读书，摄影", "description": "Simple comma-separated hobbies"},
        # Case 2: Redundant combined hobbies
        {
            "input": "游泳，读书，游泳读书，摄影",
            "description": "Contains redundant combined hobby '游泳读书'",
        },
        # Case 3: Multiple separators
        {"input": "游泳、读书；摄影，音乐", "description": "Mixed separators (、；，)"},
        # Case 4: Complex redundancy
        {
            "input": "跑步，游泳，跑步游泳，健身，跑步健身，游泳健身",
            "description": "Complex redundancy patterns",
        },
        # Case 5: Real dating profile example
        {
            "input": "书法，摄影，书法摄影，旅游，读书",
            "description": "Real-world dating profile example",
        },
    ]

    for i, case in enumerate(test_cases, 1):
        input_str = case["input"]
        description = case["description"]

        print(f"Test Case {i}: {description}")
        print(f"Input:  '{input_str}'")

        # Step 1: Split and basic normalization
        basic_split = normalize_hobbies(input_str)
        print(f"Split:  {basic_split}")

        # Step 2: Remove redundant combinations
        final_result = FlutterDataConverter._normalize_interests(basic_split)
        print(f"Final:  {final_result}")

        # Show what was removed
        removed = set(basic_split) - set(final_result)
        if removed:
            print(f"Removed: {sorted(removed)} (redundant combinations)")

        print(f"Reduction: {len(basic_split)} → {len(final_result)} interests")
        print("-" * 60)


if __name__ == "__main__":
    test_normalization()
