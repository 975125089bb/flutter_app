#!/usr/bin/env python3
"""
Pre-build script to generate fresh test_characters.json data before Flutter runs
"""

import sys
import os
import subprocess

# Add the data_generate_python directory to the path
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)
data_generate_dir = os.path.join(parent_dir, 'lib', 'data_generate_python')
sys.path.append(data_generate_dir)

def main():
    print("Ì¥Ñ Generating fresh test data before Flutter build...")
    
    try:
        # Change to the data generation directory
        os.chdir(data_generate_dir)
        
        # Import and run the data pipeline
        from data_pipeline import DataPipeline
        
        pipeline = DataPipeline()
        
        # Generate fresh test data
        print("Ì≥ä Running test data pipeline...")
        pipeline.run_test_pipeline()
        
        print("‚úÖ Fresh test data generated successfully!")
        print("Ì≥Å Updated: assets/test_characters.json")
        
    except Exception as e:
        print(f"‚ùå Error generating test data: {e}")
        print("‚ö†Ô∏è  Continuing with existing data...")
        return 1
    
    return 0

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)
