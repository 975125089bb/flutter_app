import os
from pathlib import Path


def divide_data_personwise():
    CURRENT_DIR = Path(__file__).parent.parent
    folder_path = Path(CURRENT_DIR, "raw_data").resolve()
    print(folder_path)
    for root, dirs, files in os.walk(folder_path):
        print(root, files)
        
divide_data_personwise()