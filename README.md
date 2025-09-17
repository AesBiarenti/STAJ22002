# STAJ22002 Monorepo

Bu depo, iki ayrı uygulamayı bir arada barındırır:

-   argenova-mobile-app: Flutter mobil uygulaması (chat_llm_app) ve ilgili Flask API (flask_api)
-   chat_llm_web_app: Nuxt 3 tabanlı web uygulaması, Qdrant ve Ollama ile entegrasyon

Aşağıda her bir uygulamanın amacı, teknoloji yığını, kurulum/geliştirme talimatları ve önemli notlar özetlenmiştir.

## 1) argenova-mobile-app

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

### Amaç

-   Web arayüzü üzerinden mesai verilerini yüklemek (Excel/CSV), Qdrant’a vektör olarak basmak
-   Qdrant’tan özet bağlam çıkarıp Ollama ile kısa, Türkçe sohbet yanıtları üretmek
-   Sohbet geçmişini MongoDB’de oturum bazlı tutmak

### Teknolojiler

-   Nuxt 3, Nitro server routes, Tailwind, Pinia
-   Qdrant HTTP API, Ollama HTTP API, MongoDB (Mongoose)

### Hızlı Başlangıç (Geliştirme - Docker Compose)

-   Dizine geçin: `chat_llm_web_app`
-   Başlat: `docker compose -f docker-compose.dev.yml up -d`
-   Durdur: `docker compose -f docker-compose.dev.yml stop`
-   Kaldır: `docker compose -f docker-compose.dev.yml down`

Varsayılan servisler ve portlar:

-   Nuxt Web: 3000
-   Qdrant: 6333
-   Ollama: 11434 (çakışma olursa dev compose’da host portunu değiştirin ve `OLLAMA_URL`’i güncelleyin)
-   MongoDB: 27017

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
-   Gerekirse `searchVector` ile semantik arama eklenebilir (şu an scroll + özet yaklaşımı kullanılıyor).

---

## Ortak Notlar

-   Üretimde kimlik doğrulama ve yetkilendirme eklenmesi önerilir
-   Büyük dosyalar ve raporlar `.gitignore` kapsamına alınmıştır
-   Port çakışmalarında ilgili servisi durdurun veya compose dosyasında host portunu değiştirin
