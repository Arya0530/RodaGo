import pandas as pd
import pickle
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import LabelEncoder
from nlp_utils import preprocess_text # <--- IMPORT FUNGSI YANG BARU DIBUAT

print("=== Memulai Proses Training Model RodaGo (Dengan Pre-Processing Sastrawi) ===")

# 1. Load dataset
df = pd.read_csv('dataset_rodago_2000.csv')

# 2. BERSIHKAN DATASET DULU (Ini memakan waktu sekitar 1-2 menit karena Sastrawi)
print("Sedang membersihkan teks dan memotong imbuhan... Tunggu bentar bro!")
df['clean_text'] = df['text'].astype(str).apply(preprocess_text)

X = df['clean_text']
y = df['intent']

# List kata basa-basi
id_stopwords = ['apakah', 'bisa', 'setelah', 'yang', 'di', 'ke', 'dari', 'ini', 'itu', 'untuk', 'ya', 'kak', 'admin', 'adalah', 'kalau', 'bagaimana']

# 3. Extract feature (Naik level n-gram jadi 1-3 biar bisa baca "tanpa lepas kunci")
vectorizer = TfidfVectorizer(ngram_range=(1, 3), sublinear_tf=True, stop_words=id_stopwords)
X_vec = vectorizer.fit_transform(X)

# 4. Encode label
label_encoder = LabelEncoder()
y_enc = label_encoder.fit_transform(y)

# 5. Training Model
model = LogisticRegression(max_iter=1000, class_weight='balanced', C=10.0)
model.fit(X_vec, y_enc)

# 6. Save file .pkl baru
with open('vectorizer.pkl', 'wb') as f: pickle.dump(vectorizer, f)
with open('label_encoder.pkl', 'wb') as f: pickle.dump(label_encoder, f)
with open('rodago_model.pkl', 'wb') as f: pickle.dump(model, f)

print("=== Training Selesai! Model Bersih Berhasil Disimpan ===")