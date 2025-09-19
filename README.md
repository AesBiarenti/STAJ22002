# STAJ22002

Bu depo, iki ayrı uygulama ve toplamda 3 projeyi bir arada barındırır;

-   argenova-mobile-app klasörü: Flutter mobil uygulaması (chat_llm_app) ve ilgili Flask API (flask_api) olmak üzere iki proje içerir ve mobil uygulama için hazırlanmıştır.
-   chat_llm_web_app projesi: Nuxt 3 tabanlı web uygulaması, Qdrant ve Ollama ile entegrasyon

Aşağıda her bir uygulamanın amacı, teknoloji yığını, kurulum/geliştirme talimatları ve önemli notlar özetlenmiştir.

## 1) argenova-mobile-app
<img width="1132" height="648" alt="Frame 6" src="https://github.com/user-attachments/assets/e9d8c4e2-1e3f-4e73-93cf-5343980dc460" />
### Amaç

-   Mobil cihazlardan sohbet arayüzü ile mesai verilerine ilişkin sorular sormak ve kısa, Türkçe yanıtlar almak
-   Excel dosyası ile çalışan verilerini backend’e yüklemek ve Qdrant’ta vektör olarak saklamak
-   Sohbet geçmişini cihazda (Hive) kalıcı olarak tutmak

### Bileşenler

-   chat_llm_app: Flutter istemci
-   flask_api: Python/Flask backend (Qdrant ve Ollama entegrasyonu)

### Teknolojiler

-   Flutter, Riverpod, Hive, http
-   Flask, Qdrant, Ollama, Pandas

### Hızlı Başlangıç

#### Flask API (Geliştirme)

1. Gerekli servislerin çalışır olduğundan emin olun:
    - Qdrant (örn. http://<sunucu-ip>:6333)
    - Ollama (örn. http://<sunucu-ip>:11434)
2. `argenova-mobile-app/flask_api` dizininde `.env` (opsiyonel) veya `config/settings.py` değerlerini kontrol edin:
    - QDRANT_URL, AI_SERVICE_URL, PORT varsayılanları
3. Uygulama:
    - Python ortamı kurun ve bağımlılıkları yükleyin: `pip install -r requirements.txt`
    - Çalıştırın: `python app.py`
    - Sağlık kontrolü: `GET http://<host>:5000/health`

Uç noktalar proje içerisinde ilgili controller/route dosyalarında tanımlıdır.

#### Flutter Mobil (Geliştirme)

-   Android emülatör için backend tabanı: `http://10.0.2.2:5000/api`
-   Komutlar:
    -   `flutter pub get`
    -   `flutter run`

### Dizin Yapısı (özet)

-   chat_llm_app/lib: Modeller (`Chat`, `ChatMessage`), provider’lar (`ChatNotifier`), sayfalar (chat, excel, ayarlar), servis (`AIService`)
-   flask_api: `controllers/` (chat, employee), `services/` (ai_service, qdrant_service), `config/settings.py`, `scripts/`

### Notlar

-   `AIService` yanıtları kısa ve Türkçe olacak şekilde optimize edilmiştir
-   Excel yüklemede veri temizliği ve gruplayarak tekilleştirme uygulanır
-   Sohbet geçmişi Hive’da saklanır, ilk kullanıcı mesajından sohbet başlığı üretilir

---

## 2) chat_llm_web_app
<img width="1125" height="1126" alt="Group 6" src="https://github.com/user-attachments/assets/584b9a96-60c7-4aa6-94b9-5c0509727d37" />
### Amaç

-   Web arayüzü üzerinden mesai verilerini yüklemek (Excel/CSV), Qdrant’a vektör olarak basmak
-   Qdrant’tan özet bağlam çıkarıp Ollama ile kısa, Türkçe sohbet yanıtları üretmek
-   Sohbet geçmişini MongoDB’de oturum bazlı tutmak

### Teknolojiler

-   Nuxt 3, Nitro server routes, Tailwind, Pinia
-   Qdrant HTTP API, Ollama HTTP API, MongoDB (Mongoose)

### Hızlı Başlangıç (Geliştirme - Docker Compose)

-   Başlat: `docker compose -f docker-compose.dev.yml up -d`
-   Durdur: `docker compose -f docker-compose.dev.yml stop`
-   Kaldır: `docker compose -f docker-compose.dev.yml down`


### Sunucu Uçları

Uç noktalar proje içerisinde ilgili controller/route dosyalarında tanımlıdır.

### Dizin Yapısı (özet)

-   server/utils: `ai.ts` (Ollama), `qdrant.ts` (Qdrant)
-   server/api: `chat.post.ts`, `vectors/upload-excel.post.ts`, `health.get.ts`, `history/*`
-   app/components: Chat arayüzü, sistem durumu ve vektör yönetimi bileşenleri
-   nuxt.config.ts: runtime config (qdrantUrl, ollamaUrl, mongodbUri vb.)

### Notlar

-   Koleksiyon adı: `ai_vectors` (web). Flutter/Flask tarafındaki `mesai` koleksiyonundan bağımsızdır.
-   Embedding boyutu 384, Cosine uzaklık kullanılır.
