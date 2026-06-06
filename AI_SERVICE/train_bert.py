import pandas as pd
import pickle
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification, Trainer, TrainingArguments
from sklearn.preprocessing import LabelEncoder
from datasets import Dataset

print("=== Menginisialisasi Pelatihan: IndoBERT ===")

# 1. Load Dataset
df = pd.read_csv('dataset_rodago_2000.csv')

# 2. Encode Label
label_encoder = LabelEncoder()
df['label'] = label_encoder.fit_transform(df['intent'])

# 3. Load Tokenizer & Model IndoBERT Asli
model_name = "indobenchmark/indobert-base-p1"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForSequenceClassification.from_pretrained(model_name, num_labels=len(label_encoder.classes_))

# 4. Ubah format data pandas ke format Hugging Face Dataset
hf_dataset = Dataset.from_pandas(df[['text', 'label']])

def tokenize_function(examples):
    # Padding & Truncation otomatis
    return tokenizer(examples["text"], padding="max_length", truncation=True, max_length=64)

print("Sedang memproses kata ke dalam bentuk Token Transformer...")
tokenized_datasets = hf_dataset.map(tokenize_function, batched=True)

# 5. Konfigurasi Training (Hanya butuh 4 Epoch untuk jadi sangat pintar)
training_args = TrainingArguments(
    output_dir="./rodago_bert_model",
    num_train_epochs=4,              # Transformer tidak butuh ratusan epoch
    per_device_train_batch_size=16,  # RTX 4060 lo kuat ngangkat batch ini
    logging_steps=10,
    save_strategy="epoch",
    use_cpu=False                    # Otomatis deteksi GPU jika tersedia
)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_datasets,
)

# 6. Eksekusi Training
print("Mulai melatih jaringan saraf Transformer...")
trainer.train()

# 7. Simpan Model dan Encoder ke folder lokal
print("Menyimpan model ke folder ./rodago_bert_model_final")
trainer.save_model("./rodago_bert_model_final")
tokenizer.save_pretrained("./rodago_bert_model_final")

with open('label_encoder_bert.pkl', 'wb') as f:
    pickle.dump(label_encoder, f)

print("=== Training Selesai! Model AI Dewa Siap Digunakan ===")