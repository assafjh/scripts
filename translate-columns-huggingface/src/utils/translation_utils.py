import time
from transformers import MarianMTModel, MarianTokenizer
import logging
from tenacity import retry, wait_exponential, stop_after_attempt, retry_if_exception_type, RetryError
import torch

def initialize_model_and_tokenizer(model_name):
    tokenizer = MarianTokenizer.from_pretrained(model_name)
    model = MarianMTModel.from_pretrained(model_name)
    device = "cuda" if torch.cuda.is_available() else "cpu"
    model.to(device)
    return model, tokenizer, device

@retry(wait=wait_exponential(multiplier=1, min=4, max=10), stop=stop_after_attempt(5), retry=(retry_if_exception_type(RetryError)))
def translate_texts(texts, model, tokenizer, device, translation_cache):
    translated_texts = []
    batch_size = 10  # Adjust batch size to avoid hitting rate limits quickly
    for i in range(0, len(texts), batch_size):
        batch = texts[i:i + batch_size]
        try:
            inputs = tokenizer(batch, return_tensors="pt", padding=True, truncation=True).to(device)
            translated = model.generate(**inputs)
            translations = tokenizer.batch_decode(translated, skip_special_tokens=True)
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
