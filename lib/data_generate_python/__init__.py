"""
Dating App Data Processing Pipeline
A comprehensive Python pipeline to process dating profile data using DeepSeek API
"""

__version__ = "1.0.0"
__author__ = "Dating App Data Team"

# Main components
from .deepseek_data_processor import DeepSeekProcessor, ProcessedPerson
from .csv_to_flutter_converter import FlutterDataConverter
from .data_pipeline import DataPipeline
from .batch_processor import BatchProcessor

__all__ = [
    "DeepSeekProcessor",
    "ProcessedPerson",
    "FlutterDataConverter",
    "DataPipeline",
    "BatchProcessor",
]
