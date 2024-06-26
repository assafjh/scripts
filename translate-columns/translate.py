#!/usr/bin/python3

import os
import pandas as pd
from deep_translator import GoogleTranslator
import argparse
import logging
import string
from nltk.tokenize import sent_tokenize
from collections import defaultdict
from tqdm import tqdm
from ratelimit import limits, sleep_and_retry
from tenacity import retry, wait_exponential, stop_after_attempt, retry_if_exception_type, RetryError
import pickle
import time

# Configure command-line arguments
parser = argparse.ArgumentParser(description='Translate columns in an Excel file.')
parser.add_argument('--input', type=str, required=True, help='Path to the input Excel file.')
parser.add_argument('--output', type=str, required=True, help='Path to the output Excel file.')
parser.add_argument('--source_columns', type=str, required=True, help='Comma-separated list of source columns (letters or zero-based indices).')
parser.add_argument('--target_columns', type=str, required=True, help='Comma-separated list of target columns.')
parser.add_argument('--source_lang', type=str, required=True, help='Source language code (e.g., "hu" for Hungarian).')
parser.add_argument('--target_lang', type=str, required=True, help='Target language code (e.g., "de" for German).')
parser.add_argument('--header', type=int, default=0, help='Row number to use as column names (default is 0). Use None if there is no header.')
parser.add_argument('--log', type=str, default='INFO', choices=['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'], help='Set the log level (default: INFO)')
parser.add_argument('--cache_file', type=str, default='translation_cache.pkl', help='Path to the cache file.')

args = parser.parse_args()

# Set the log level based on command-line argument
log_level = getattr(logging, args.log.upper(), logging.INFO)

# Configure logging to file and console with different levels
log_file = "translation.log"
file_handler = logging.FileHandler(log_file)
file_handler.setLevel(logging.DEBUG)
file_formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
file_handler.setFormatter(file_formatter)

console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)
console_formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
console_handler.setFormatter(console_formatter)

logging.basicConfig(level=log_level, format='%(asctime)s - %(levelname)s - %(message)s')

# Initialize translator
translator = GoogleTranslator(source=args.source_lang, target=args.target_lang)

# Rate limiter to ensure we do not exceed 5 requests per second
@sleep_and_retry
@limits(calls=5, period=1)
@retry(wait=wait_exponential(multiplier=1, min=2, max=60), stop=stop_after_attempt(5), retry=retry_if_exception_type(Exception))
def translate_batch_with_limit(batch):
    try:
        translations = translator.translate_batch(batch)
        return translations
    except requests.exceptions.HTTPError as e:
        if e.response.status_code == 429:  # Too Many Requests
            retry_after = int(e.response.headers.get("Retry-After", 60))  # Default to 60 seconds if not provided
            logging.warning(f"Rate limit exceeded. Retrying after {retry_after} seconds.")
            time.sleep(retry_after)
        raise

# Load or initialize cache for translations
if os.path.exists(args.cache_file):
    with open(args.cache_file, 'rb') as f:
        translation_cache = pickle.load(f)
    logging.info(f"Loaded translation cache from {args.cache_file}")
else:
    translation_cache = defaultdict(str)

def column_letter_to_index(letter):
    """Convert a column letter (e.g., 'A', 'B', 'AA') to a zero-based index."""
    index = 0
    for i, char in enumerate(reversed(letter)):
        index += (string.ascii_uppercase.index(char) + 1) * (26 ** i)
    return index - 1

def index_to_column_letter(index):
    """Convert a zero-based index to a column letter (e.g., 0 -> 'A', 1 -> 'B')."""
    letters = ""
    while index >= 0:
        letters = chr(index % 26 + ord('A')) + letters
        index = index // 26 - 1
    return letters

def translate_texts(texts):
    translated_texts = []
    batch_size = 100  # Adjust batch size to avoid hitting rate limits quickly
    for i in range(0, len(texts), batch_size):
        batch = texts[i:i + batch_size]
        try:
            translations = translate_batch_with_limit(batch)
            for original, translated in zip(batch, translations):
                if translated is None:
                    translated = original
                translation_cache[original] = translated
                translated_texts.append(translated)
        except RetryError as e:
            logging.error(f"Error during batch translation: {e}")
            translated_texts.extend([translation_cache.get(text, text) for text in batch])
        time.sleep(1)  # Add a delay to respect rate limits
    return translated_texts

def process_row(index, row, source_columns, target_columns, df):
    for source_index, target_column_letter in zip(source_columns, target_columns):
        if source_index < len(df.columns):
            source_column = df.columns[source_index]
            target_index = column_letter_to_index(target_column_letter)
            if target_index < len(df.columns):
                text = row[source_column]
                if pd.isna(text):
                    text = ''
                logging.debug(f"Row {index} | {source_column}: {text}")
                if text.strip():  # Only translate non-empty text
                    sentences = sent_tokenize(text)
                    translated_sentences = []
                    for sentence in sentences:
                        words = sentence.split()
                        translated_words = []
                        for word in words:
                            if word.startswith('$'):
                                translated_words.append(word)
                            else:
                                translated_word = translation_cache.get(word, None)
                                if translated_word is None:
                                    translated_word = translator.translate(word)
                                    translation_cache[word] = translated_word
                                translated_words.append(translated_word)
                        translated_sentence = ' '.join(word if word is not None else '' for word in translated_words)
                        translated_sentences.append(translated_sentence)
                    translated_text = '. '.join(translated_sentences)
                    # Update the DataFrame at the correct target column index
                    df.iloc[index, target_index] = translated_text
                    logging.debug(f"Row {index} | {source_column}: {text} -> {target_column_letter}: {translated_text}")
            else:
                logging.error(f"Target column letter {target_column_letter} is out of range for DataFrame columns.")
        else:
            logging.error(f"Source column index {source_index} is out of range for DataFrame columns.")

def save_cache():
    try:
        with open(args.cache_file, 'wb') as f:
            pickle.dump(translation_cache, f)
        logging.info(f"Translation cache saved to {args.cache_file}")
    except Exception as e:
        logging.error(f"Error saving the cache file: {e}")

def main():
    # Read the Excel file
    logging.info(f"Reading Excel file from {args.input}")
    df = pd.read_excel(args.input, header=args.header)

    # Parse columns
    source_columns = []
    for col in args.source_columns.split(','):
        if col.isdigit():
            source_columns.append(int(col))
        else:
            source_columns.append(column_letter_to_index(col.strip().upper()))

    target_columns = args.target_columns.split(',')

    if len(source_columns) != len(target_columns):
        logging.error("The number of source columns must match the number of target columns.")
        return

    # Ensure target columns exist
    for target_column_letter in target_columns:
        target_index = column_letter_to_index(target_column_letter)
        if target_index >= len(df.columns):
            logging.info(f"Creating target column: {target_column_letter}")
            while len(df.columns) <= target_index:
                df.loc[:, index_to_column_letter(len(df.columns))] = ""


    # Process each row and translate the specified columns
    logging.info(f"Starting translation of {len(df)} rows...")

    with tqdm(total=len(df), desc="Translating rows") as pbar:
        for index, row in df.iterrows():
            process_row(index, row, source_columns, target_columns, df)
            pbar.update(1)

    # Save the translated DataFrame to an Excel file
    try:
        if os.path.exists(args.output):
            os.remove(args.output)
        df.to_excel(args.output, index=False)
        logging.info(f"Translation process completed. Combined Excel file created at {args.output}")
    except Exception as e:
        logging.error(f"Error saving the Excel file: {e}")

    # Save the cache to disk
    save_cache()

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        logging.error(f"An error occurred: {e}")
        save_cache()  # Save cache on exit due to error
