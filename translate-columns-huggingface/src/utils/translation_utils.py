import time
from transformers import MarianMTModel, MarianTokenizer
import logging
import torch

def initialize_model_and_tokenizer(model_name):
    tokenizer = MarianTokenizer.from_pretrained(model_name)
    model = MarianMTModel.from_pretrained(model_name)
    device = "cuda" if torch.cuda.is_available() else "cpu"
    model.to(device)
    return model, tokenizer, device

def translate_texts(texts, model, tokenizer, device, translation_cache, batch_size=10):
    translated_texts = []
    for i in range(0, len(texts), batch_size):
        batch = texts[i:i + batch_size]
        inputs = tokenizer(batch, return_tensors="pt", padding=True, truncation=True).to(device)
        translated = model.generate(**inputs)
        translations = tokenizer.batch_decode(translated, skip_special_tokens=True)
        for original, translated in zip(batch, translations):
            if translated is None:
                translated = original
            translation_cache[original] = translated
            translated_texts.append(translated)
    return translated_texts

