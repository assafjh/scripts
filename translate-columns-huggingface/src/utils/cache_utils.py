import os
import pickle
import threading
import logging
from collections import defaultdict

cache_lock = threading.Lock()

def load_cache(cache_file):
    if os.path.exists(cache_file):
        with open(cache_file, 'rb') as f:
            translation_cache = pickle.load(f)
        logging.info(f"Loaded translation cache from {cache_file}")
        return translation_cache
    return defaultdict(str)

def save_cache(translation_cache, cache_file):
    try:
        with cache_lock:
            with open(cache_file, 'wb') as f:
                pickle.dump(translation_cache, f)
        logging.info(f"Translation cache saved to {cache_file}")
    except Exception as e:
        logging.error(f"Error saving the cache file: {e}")
