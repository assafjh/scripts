#!/usr/bin/env python

import os
import argparse
import logging
from nltk.tokenize import sent_tokenize
from tqdm import tqdm
from concurrent.futures import ThreadPoolExecutor
import pandas as pd

from utils.cache_utils import load_cache, save_cache
from utils.excel_utils import read_excel, column_letter_to_index, index_to_column_letter
from utils.translation_utils import initialize_model_and_tokenizer, translate_texts
from utils.logging_utils import configure_logging

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
parser.add_argument('--threads', type=int, default=8, help='Number of concurrent threads. (default: 4)')

args = parser.parse_args()

# Set the log level based on command-line argument
log_level = getattr(logging, args.log.upper(), logging.INFO)

# Configure logging to file and console with different levels
log_file = "logs/translation.log"
configure_logging(log_file, log_level)

# Initialize Hugging Face model and tokenizer
model_name = f'Helsinki-NLP/opus-mt-{args.source_lang}-{args.target_lang}'
model, tokenizer, device = initialize_model_and_tokenizer(model_name)

# Load or initialize cache for translations
translation_cache = load_cache(args.cache_file)

def process_chunk(chunk, source_columns, target_columns, df, progress_bar):
    chunk_index, rows = chunk
    for index, row in rows.iterrows():
        process_row(index, row, source_columns, target_columns, df)
        progress_bar.update(1)
    return rows

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
                    translated_sentences = translate_texts(sentences, model, tokenizer, device, translation_cache)
                    translated_text = '. '.join(translated_sentences)
                    df.iloc[index, target_index] = translated_text
                    logging.debug(f"Row {index} | {source_column}: {text} -> {target_column_letter}: {translated_text}")
            else:
                logging.error(f"Target column letter {target_column_letter} is out of range for DataFrame columns.")
        else:
            logging.error(f"Source column index {source_index} is out of range for DataFrame columns.")

def main():
    # Read the Excel file
    df = read_excel(args.input, args.header)

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
    for target_column in target_columns:
        target_index = column_letter_to_index(target_column)
        if target_index >= len(df.columns):
            logging.info(f"Creating target column: {target_column}")
            while len(df.columns) <= target_index:
                df.loc[:, index_to_column_letter(len(df.columns))] = ""

    # Divide DataFrame into chunks
    chunk_size = len(df) // args.threads
    chunks = [(i, df.iloc[i * chunk_size:(i + 1) * chunk_size]) for i in range(args.threads)]
    
    # Process each chunk concurrently
    with ThreadPoolExecutor(max_workers=args.threads) as executor:
        futures = []
        with tqdm(total=len(df), desc="Translating rows") as pbar:
            for chunk in chunks:
                futures.append(executor.submit(process_chunk, chunk, source_columns, target_columns, df, pbar))
            for future in futures:
                future.result()

    # Save the translated DataFrame to an Excel file
    try:
        if os.path.exists(args.output):
            os.remove(args.output)
        df.to_excel(args.output, index=False)
        logging.info(f"Translation process completed. Combined Excel file created at {args.output}")
    except Exception as e:
        logging.error(f"Error saving the Excel file: {e}")

    # Save the cache to disk
    save_cache(translation_cache, args.cache_file)

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        logging.error(f"An error occurred: {e}")
        save_cache(translation_cache, args.cache_file)  # Save cache on exit due to error
