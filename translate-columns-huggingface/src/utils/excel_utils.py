import pandas as pd
import string
import logging

def read_excel(file_path, header):
    logging.info(f"Reading Excel file from {file_path}")
    return pd.read_excel(file_path, header=header)

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
