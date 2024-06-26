# Translation Script

This script translates specified columns in an Excel file from one language to another using the Google Translate API. It supports concurrency, caching, rate limiting, and progress tracking.

## Features

- Translate specified columns in an Excel file.
- Supports multiple threads for concurrent processing.
- Caching to avoid redundant translations.
- Rate limiting to respect API quotas.
- Progress bar to track translation progress.

## Requirements

- Python 3.x
- pandas
- deep-translator
- nltk
- tqdm
- requests
- tenacity
- ratelimit
