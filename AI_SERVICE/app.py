import pickle
import random
import torch
from flask import Flask, request, jsonify
from transformers import AutoTokenizer, AutoModelForSequenceClassification

app = Flask(__name__)

# =================================================================
# LOAD MODEL INDOBERT (Dijalankan sekali pas Flask start)
# =================================================================
try:
    with open('label_encoder_bert.pkl', 'rb') as f:
        label_encoder = pickle.load(f)
    
    tokenizer = AutoTokenizer.from_pretrained("./rodago_bert_model_final")
    model = AutoModelForSequenceClassification.from_pretrained("./rodago_bert_model_final")
    
    # Gunakan GPU jika tersedia
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model.to(device)
    
    print("Model IndoBERT RodaGo berhasil di-load!")
except Exception as e:
    print(f"Waduh error load model: {e}. Udah jalanin 'python train_bert.py' belum?")

# =================================================================
# DICTIONARY RESPONSES (Total 60 Variasi Jawaban Utuh Tanpa Potongan)
# =================================================================
responses = {
    'salam': [
        "Halo Kak! Ada yang bisa aku bantu seputar penyewaan di RodaGo? 😊",
        "Hai Kak! Selamat datang di RodaGo. Mau jalan-jalan ke mana kita hari ini? Ada yang bisa dibantu?",
        "Halo! RodaGo AI Assistant di sini. Siap bantu lancarin urusan rental kendaraan Kakak!",
        "Hai Kak! Ada yang bisa aku bantu terkait sewa mobil atau motor di RodaGo?",
        "Halo Kak, senang bisa menyapa Anda! Butuh info seputar rental hari ini? Tanyain aja ya!",
        "Halo! Ada yang bisa RodaGo AI bantu untuk mempermudah sewa kendaraanmu hari ini? 👋"
    ],
    'booking_mobil': [
        "Untuk melakukan pemesanan kendaraan, langsung buka menu **Beranda** ya Kak! Pilih kendaraan idamanmu, tentukan tanggal, lalu gass pol!",
        "Mau booking? Gampang banget! Kakak tinggal meluncur ke halaman **Beranda**, pilih unit yang ready, ketuk sewa, dan selesaikan pesanan.",
        "Pemesanan bisa langsung Kakak lakukan lewat menu **Beranda** di aplikasi. Pilih mobil/motornya, atur tanggal sewa, beres deh!",
        "Yuk, langsung gas ke menu **Beranda** buat booking unit favorit Kakak sebelum kehabisan!",
        "Langkah bookingnya simpel: Masuk ke **Beranda** -> Pilih Kendaraan -> Pilih Tanggal & Durasi -> Klik Pesan sekarang!",
        "Langsung gass ke tab **Beranda** Kak! Pilih armada yang cocok, tentukan waktu sewa, dan amankan ketersediaannya di sana."
    ],
    'syarat_lepas_kunci': [
        "Tenang Kak, syarat lepas kunci di RodaGo gampang banget kok! Cukup siapin **E-KTP asli** dan **SIM aktif** pas verifikasi data (KYC) di halaman **Profil** Kakak.",
        "Persyaratan lepas kunci gak ribet! Kakak cuma butuh upload foto **E-KTP** dan **SIM** yang masih berlaku saat verifikasi KYC di menu **Profil**.",
        "Sewa lepas kunci di RodaGo wajib upload **E-KTP** dan **SIM** yang valid ya Kak. Proses verifikasinya bisa dilakukan di menu **Profil**.",
        "Cukup pastikan data diri seperti **E-KTP** dan **SIM** Kakak sudah terverifikasi (KYC) di halaman **Profil** sebelum mulai sewa lepas kunci.",
        "Syarat utamanya cuma dua dokumen: **E-KTP asli** & **SIM aktif**. Pastikan sudah di-upload di halaman **Profil** Kakak ya!",
        "Syaratnya super gampang Kak! Cukup upload foto **E-KTP** dan **SIM** Kakak yang masih aktif di halaman **Profil** untuk verifikasi akun."
    ],
    'pakai_supir': [
        "Koreksi sedikit ya Kak, demi kenyamanan dan kebebasan berkendara Kakak, RodaGo **HANYA melayani sewa lepas kunci (tanpa sopir/driver)**. Jadi Kakak bisa bebas jalan-jalan sendiri! 🚗",
        "Mohon maaf Kak, saat ini RodaGo **khusus menyediakan sewa lepas kunci saja** dan tidak menyediakan opsi dengan driver/sopir.",
        "Di RodaGo Kakak bisa menikmati perjalanan dengan bebas karena sistem kami **100% lepas kunci tanpa sopir**.",
        "Kami tidak menyediakan layanan driver ya Kak. Semua unit di RodaGo disewakan dengan sistem **lepas kunci** supaya privasi Kakak jaga.",
        "RodaGo dirancang khusus untuk sewa mandiri, jadi **tidak ada pilihan dengan sopir**. Hanya melayani sewa lepas kunci ya Kak!",
        "Sebagai informasi tambahan, seluruh layanan rental di RodaGo **murni lepas kunci (tanpa sopir)** ya Kak, agar perjalanan Kakak lebih privat."
    ],
    'tanya_mobil': [
        "Untuk melihat unit mobil yang ready beserta pilihan transmisinya (Matic/Manual), silakan langsung cek secara real-time di halaman **Beranda** aplikasi kita ya Kak!",
        "Ketersediaan armada mobil, tipe mobil, dan jenis transmisinya bisa Kakak pantau langsung secara live di halaman **Beranda**.",
        "Cek pilihan mobil yang siap pakai langsung di menu **Beranda** ya Kak. Lengkap dari city car sampai SUV!",
        "Semua unit mobil beserta status ready atau tidaknya bisa langsung Kakak lihat di menu **Beranda** aplikasi.",
        "Mau lihat-lihat koleksi mobil RodaGo? Langsung buka tab **Beranda** aja Kak, unitnya lengkap di sana!",
        "Kakak bisa langsung mengecek katalog kendaraan lengkap beserta pilihan transmisinya yang sedang ready di halaman **Beranda** secara real-time."
    ],
    'tanya_harga': [
        "Pricelist tarif sewa lengkap dan transparan bisa Kakak cek langsung di menu **Beranda** sesuai jenis kendaraan yang Kakak inginkan. Dijamin bersahabat kok!",
        "Mengenai harga sewa, Kakak bisa cek langsung secara detail dan transparan pada tiap unit kendaraan di halaman **Beranda**.",
        "Tarif sewa bervariasi tergantung jenis armada. Detail biayanya bisa langsung dilihat di menu **Beranda** aplikasi RodaGo.",
        "Gak perlu khawatir boncos, tarif sewa per hari sudah tertera jelas di menu **Beranda** untuk setiap kendaraan.",
        "Harga sewa terbaik dan promo yang tersedia bisa Kakak intip langsung di halaman **Beranda** ya!",
        "Info harga sewa per hari untuk setiap armada sudah dicantumkan secara transparan kok Kak, bisa langsung dicek di halaman **Beranda**."
    ],
    'pembayaran': [
        "Sistem pembayaran RodaGo fleksibel banget! Kakak bisa melakukan pembayaran aman melalui M-Banking (BCA, dll), E-Wallet (Dana, ShopeePay, OVO), maupun QRIS langsung di aplikasi.",
        "Untuk transaksi, RodaGo mendukung berbagai metode pembayaran: Transfer Bank (Virtual Account), QRIS, hingga E-Wallet pilihan Kakak.",
        "Pembayaran bisa diselesaikan langsung di aplikasi menggunakan QRIS, E-Wallet seperti Dana/OVO, atau M-Banking secara aman.",
        "Tenang Kak, metode pembayaran kita lengkap banget! Bisa pakai Virtual Account bank, QRIS, atau E-Wallet favorit Kakak.",
        "Setelah booking, Kakak bisa memilih opsi pembayaran lewat QRIS, transfer bank, atau dompet digital yang tersedia di aplikasi.",
        "Untuk metode pembayaran, aplikasi RodaGo sudah terintegrasi dengan QRIS, Virtual Account bank, dan E-Wallet (seperti Dana) biar makin praktis!"
    ],
    'pembatalan': [
        "Butuh melakukan pembatalan atau ubah jadwal? Kakak bisa mengaturnya langsung secara mandiri lewat halaman **Status Pesanan** atau **Dasbor** Kakak ya.",
        "Pembatalan sewa atau reschedule bisa Kakak kelola secara mandiri melalui menu **Dasbor** atau **Status Pesanan** Kakak.",
        "Jika ada rencana yang berubah, Kakak bisa mengajukan pembatalan pesanan langsung melalui halaman **Status Pesanan**.",
        "Fitur pembatalan transaksi sudah disediakan di aplikasi. Silakan cek di bagian **Dasbor** atau riwayat **Status Pesanan** Anda.",
        "Mau cancel atau ubah jadwal booking? Langsung cek ketentuannya di menu **Status Pesanan** Kakak ya.",
        "Jika rencana Kakak berubah, Kakak bisa membatalkan atau mengubah jadwal pesanan secara mandiri melalui menu **Status Pesanan** di **Dasbor** Kakak."
    ],
    'lokasi_pool': [
        "Untuk lokasi kantor/pool dan titik pengambilan unit terdekat, semuanya tertera detail dan sudah terintegrasi dengan Google Maps di aplikasi kita, Kak.",
        "Alamat lengkap pool pengambilan kendaraan bisa Kakak lihat langsung via Google Maps yang tertanam di detail pesanan aplikasi.",
        "Titik jemput atau lokasi pool armada RodaGo sudah terintegrasi otomatis dengan peta Google Maps di dalam aplikasi.",
        "Kakak bisa melihat rute menuju lokasi pool terdekat kami secara langsung melalui fitur maps di aplikasi.",
        "Lokasi fisik pool dan pengambilan unit akan muncul lengkap dengan koordinat Google Maps setelah pesanan Kakak diproses.",
        "Titik koordinat pool pengambilan unit sudah terintegrasi dengan Google Maps dan bisa Kakak lihat langsung di detail aplikasi RodaGo setelah pesanan sukses."
    ],
    'penutup': [
        "Siap Kak, sama-sama! Kalau ada yang membingungkan lagi, kabari aku ya. Selamat berkendara dengan RodaGo! 🚗💨",
        "Oke Kak, senang bisa membantu! Semoga perjalanan Anda menyenangkan bersama RodaGo!",
        "Sama-sama Kak! Tetap utamakan keselamatan di jalan ya. Hubungi aku lagi kalau butuh sesuatu!",
        "Siap! Jika ada pertanyaan lain di kemudian hari, jangan ragu buat chat aku lagi ya. Have a safe trip!",
        "Kembali kasih Kak! Selamat menikmati perjalanan seru dan bebas ribet bareng RodaGo!",
        "Sip, sama-sama Kak! Semoga urusan rentalnya lancar jaya dan selamat menikmati perjalanan bersama RodaGo! 🚗"
    ]
}

@app.route("/")
def home():
    return "Backend RodaGo IndoBERT Aktif!"

@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.get_json()
        user_message = data.get('message', '').strip()
        
        if not user_message:
            return jsonify({'reply': "Pesan tidak boleh kosong!"})
        
        # 1. Tokenisasi Input User
        inputs = tokenizer(user_message, return_tensors="pt", truncation=True, padding=True, max_length=64)
        inputs = {k: v.to(device) for k, v in inputs.items()}
        
        # 2. Prediksi dengan Transformer
        with torch.no_grad():
            outputs = model(**inputs)
            logits = outputs.logits
            probabilities = torch.nn.functional.softmax(logits, dim=-1)
            
        max_prob = torch.max(probabilities).item()
        pred_idx = torch.argmax(logits, dim=1).item()
        
        # 3. Kembalikan ke nama intent asli
        predicted_intent = label_encoder.inverse_transform([pred_idx])[0]
        
        print(f"User: '{user_message}' -> Intent: '{predicted_intent}' (Confidence: {max_prob*100:.2f}%)")
        
        # Threshold aman sedikit dinaikkan karena IndoBERT sangat yakin
        if max_prob < 0.30:
            bot_reply = f"🤖 [DEBUG - Fallback | Score: {max_prob*100:.2f}%]\n\nWah, maaf banget Kak, aku agak kurang yakin. Bisa tolong jelaskan kembali?"
        else:
            if predicted_intent in responses:
                jawaban_asli = random.choice(responses[predicted_intent])
                bot_reply = f"🤖 [INDOBERT - Intent: {predicted_intent} | Confidence: {max_prob*100:.2f}%]\n\n{jawaban_asli}"
            else:
                bot_reply = "Intent tidak ditemukan."
                
        return jsonify({'reply': bot_reply})
            
    except Exception as e:
        return jsonify({'reply': f"Backend Error: {str(e)}"})

if __name__ == '__main__':
    app.run(debug=True, port=5000)