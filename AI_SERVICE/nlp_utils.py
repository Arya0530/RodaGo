import re
from Sastrawi.Stemmer.StemmerFactory import StemmerFactory

# 1. Inisialisasi Stemmer Sastrawi
factory = StemmerFactory()
stemmer = factory.create_stemmer()

# 2. Kamus Anti-Alay / Singkatan (Bisa lo tambahin sendiri nanti)
kamus_slang = {
    "bs": "bisa", "bsa": "bisa", "bisaa": "bisa",
    "syrt": "syarat", "sarat": "syarat",
    "hargany": "harga", "hrg": "harga",
    "bgmn": "bagaimana", "gmn": "bagaimana", "gimana": "bagaimana",
    "min": "admin", "p": "halo", "ping": "halo",
    "yg": "yang", "d": "di",
    "klo": "kalau", "kalo": "kalau",
    "ntar": "nanti", "brp": "berapa"
}

def preprocess_text(text):
    # A. Ubah ke huruf kecil
    text = text.lower()
    
    # B. Hapus tanda baca (sisakan huruf dan angka saja)
    text = re.sub(r'[^a-zA-Z0-9\s]', ' ', text)
    
    # C. Ganti kata singkatan dari kamus_slang
    words = text.split()
    normalized_words = [kamus_slang.get(word, word) for word in words]
    text = ' '.join(normalized_words)
    
    # D. Potong imbuhan pakai Sastrawi (Stemming)
    text = stemmer.stem(text)
    
    return text