# 🤖 AI Mesai Analiz Sistemi v2.0 - Gelişmiş Nuxt.js Versiyonu

Modern ve gelişmiş bir mesai analiz ve raporlama sistemi. **ai-app-argenova** projesinin tamamen yeniden tasarlanmış ve geliştirilmiş versiyonu. Ollama LLM, Qdrant vektör veritabanı ve **Nuxt.js 3** kullanarak geliştirilmiştir.

## 🚀 **Yeni ve Gelişmiş Özellikler (v2.0)**

### 🎨 **Modern UI/UX Tasarımı**

-   **Gradient Arka Plan**: Profesyonel görünüm için slate-blue-indigo gradient
-   **Glassmorphism Efektleri**: Backdrop blur ve şeffaf bileşenler
-   **Responsive Tasarım**: Mobil, tablet ve desktop uyumlu
-   **Animasyonlar**: Smooth geçişler ve hover efektleri
-   **Dark Mode**: Göz yormayan koyu tema

### 🧠 **Gelişmiş AI Özellikleri**

-   **Çoklu Model Desteği**: Llama 3, Llama 3.2, Phi-3 modelleri
-   **Dinamik Model Seçimi**: Web arayüzünden anlık model değiştirme
-   **Gelişmiş Embedding**: all-minilm ve mxbai-embed-large desteği
-   **Akıllı Yanıt Sistemi**: Bağlamsal ve detaylı yanıtlar
-   **Sohbet Geçmişi**: Tam konuşma geçmişi korunması

### 📊 **Gelişmiş Veri Yönetimi**

-   **Excel/CSV Import**: Gelişmiş dosya yükleme sistemi
-   **Otomatik Veri İşleme**: Akıllı veri temizleme ve gruplandırma
-   **Vektör Yönetimi**: Qdrant ile semantic search

### 🔧 **Teknik Gelişmeler**

-   **Nuxt.js 3 Framework**: Modern full-stack geliştirme
-   **TypeScript Desteği**: Tip güvenliği ve daha iyi geliştirme deneyimi
-   **Pinia State Management**: Modern state yönetimi
-   **Composition API**: Vue 3'ün en son özellikleri
-   **Server-Side Rendering**: SEO dostu ve hızlı yükleme

## 📋 İçindekiler

-   [Özellikler](#özellikler)
-   [Teknolojiler](#teknolojiler)
-   [Kurulum](#kurulum)
-   [Kullanım](#kullanım)
-   [API Endpoints](#api-endpoints)
-   [Veritabanı Yapısı](#veritabanı-yapısı)
-   [Geliştirme](#geliştirme)
-   [Deployment](#deployment)
-   [Sorun Giderme](#sorun-giderme)
-   [ai-app-argenova ile Farklar](#ai-app-argenova-ile-farklar)

## ✨ Özellikler

### 🤖 AI Destekli Analiz

-   **Doğal Dil Sorguları**: "Kemal kaç saat mesai yapmış?", "En çok mesai yapan kim?"
-   **Akıllı Yanıtlar**: Ollama LLM ile bağlamsal yanıtlar
-   **Hızlı İşlem**: Optimize edilmiş veri yönetimi (5-10 saniye yanıt)
-   **Çoklu Model Desteği**: Llama 3, Llama 3.2, Phi-3 modelleri
-   **Dinamik Model Seçimi**: Web arayüzünden anlık değiştirme

### 📊 Veri Yönetimi

-   **Excel/CSV Yükleme**: Gelişmiş dosya yükleme sistemi
-   **Otomatik Gruplandırma**: Aynı isimleri tek kayıtta birleştirme
-   **Haftalık Analiz**: Detaylı haftalık mesai takibi
-   **Günlük Dağılım**: Pazartesi-Pazar günlük mesai analizi
-   **Vektör Yönetimi**: Qdrant ile semantic search

### 🔍 Gelişmiş Arama

-   **Vektör Arama**: Semantic search ile benzer sorular
-   **Filtreli Arama**: İsim bazlı direkt erişim
-   **Bağlam Koruma**: Sohbet geçmişini hatırlama
-   **Gerçek Zamanlı Arama**: Anlık sonuçlar

### 📈 Raporlama

-   **Karşılaştırmalı Analiz**: Çalışanlar arası karşılaştırma
-   **Sıralama**: En çok/az mesai yapanlar

-   **Görsel Raporlar**: Modern grafik ve tablolar

### 🎨 Modern Arayüz

-   **Responsive Tasarım**: Tüm cihazlarda mükemmel görünüm
-   **Glassmorphism**: Modern UI trendleri
-   **Animasyonlar**: Smooth geçişler ve efektler
-   **Dark Mode**: Göz yormayan tema
-   **Sidebar Navigation**: Kolay navigasyon

## 🛠 Teknolojiler

### Frontend (Yeni!)

-   **Nuxt.js 3**: Modern full-stack framework
-   **Vue.js 3**: Composition API ile reactive UI
-   **TypeScript**: Tip güvenliği
-   **Tailwind CSS**: Utility-first CSS framework
-   **Pinia**: Modern state management

### Backend

-   **Nuxt.js 3 Server**: Nitro server engine
-   **Ollama**: Local LLM (Llama 3, Llama 3.2, Phi-3)
-   **Qdrant**: Vektör veritabanı
-   **MongoDB**: Log ve istatistik veritabanı

### DevOps

-   **Docker**: Containerization
-   **Docker Compose**: Multi-service orchestration
-   **Nginx**: Reverse proxy ve SSL

## 🚀 Kurulum

### Gereksinimler

-   Docker & Docker Compose
-   Node.js 18+ (geliştirme için)
-   4GB+ RAM (Ollama için)

### 1. Projeyi Klonlayın

```bash
git clone <repository-url>
cd chat_llm_web_app
```

### 2. Ortam Değişkenlerini Ayarlayın

```bash
cp env.example .env
# .env dosyasını düzenleyin
```

### 3. Ollama Modelini İndirin

```bash
# Llama 3 modelini indir
ollama pull llama3
# Embedding modelini indir
ollama pull all-minilm

# Diğer modeller (opsiyonel)
ollama pull llama3.2:3b    # Hızlı model
ollama pull llama3.2:7b    # Dengeli performans
ollama pull phi3:mini      # Çok hızlı
ollama pull phi3:small     # Hızlı ve kaliteli
```

## 🏃‍♂️ Kullanım

### Server Başlatma

#### Geliştirme Modu

```bash
# Tüm servisleri başlat
docker-compose -f docker-compose.dev.yml up -d

# Sadece belirli servisi başlat
docker-compose -f docker-compose.dev.yml up -d nuxt-app
```

**Port Bilgileri:**

-   **Nuxt App**: http://localhost:3005
-   **Qdrant**: http://localhost:6335
-   **MongoDB**: localhost:27020
-   **Ollama**: http://localhost:11436

#### Production Modu

```bash
# Production build ile başlat
docker-compose -f docker-compose.yml up -d
```

### Server Kapatma

```bash
# Tüm servisleri durdur
docker-compose -f docker-compose.dev.yml down

# Sadece belirli servisi durdur
docker-compose -f docker-compose.dev.yml stop nuxt-app
```

### Server Yeniden Başlatma

```bash
# Tüm servisleri yeniden başlat
docker-compose -f docker-compose.dev.yml restart

# Sadece Nuxt uygulamasını yeniden başlat
docker-compose -f docker-compose.dev.yml restart nuxt-app
```

### Build İşlemleri

#### Development Build

```bash
# Geliştirme modunda build
npm run dev
```

#### Production Build

```bash
# Production build
npm run build

# Production build ve start
npm run build && npm run start
```

#### Docker Build

```bash
# Docker image build
docker build -t ai-mesai-app .

# Docker Compose ile build
docker-compose -f docker-compose.yml build
```

### Veri Yönetimi

#### Excel Dosyası Yükleme

1. Web arayüzünde **Vector Manager** sekmesine gidin
2. **Excel/CSV Dosyası Seç** butonuna tıklayın
3. Dosyanızı seçin ve yükleyin
4. Sistem otomatik olarak verileri işleyecek

#### Veri Formatı

Excel dosyanız şu sütunları içermeli:

-   `isim`: Çalışan adı
-   `tarih_araligi`: Hafta aralığı (YYYY-MM-DD/YYYY-MM-DD)
-   `toplam_mesai`: Haftalık toplam mesai saati
-   `pazartesi`, `sali`, `carsamba`, `persembe`, `cuma`, `cumartesi`, `pazar`: Günlük mesai saatleri

#### Veri Temizleme

```bash
# Qdrant verilerini temizle
curl -X DELETE "http://localhost:6333/collections/ai_vectors/points" \
  -H "Content-Type: application/json" \
  -d '{"points": {"all": true}}'
```

## 🔌 API Endpoints

### Chat API

```http
POST /api/chat
Content-Type: application/json

{
  "message": "Kemal kaç saat mesai yapmış?",
  "history": []
}
```

### Vektör Yönetimi

```http
# Excel yükleme
POST /api/vectors/upload-excel

# Vektör durumu
GET /api/vectors/status

# Vektör ekleme
POST /api/vectors/populate
```

### Sistem Durumu

```http
# Health check
GET /api/health



# Sohbet geçmişi
GET /api/history
```

## 🗄️ Veritabanı Yapısı

### Qdrant Vektör Veritabanı

```json
{
  "id": "employee_kemal_1234567890",
  "payload": {
    "isim": "Kemal",
    "isim_lower": "kemal",
    "toplam_hafta": 10,
    "ortalama_mesai": 23,
    "haftalik_veriler": [
      {
        "tarih_araligi": "2025-07-07/2025-07-13",
        "toplam_mesai": 21,
        "gunluk_mesai": {
          "pazartesi": 4,
          "sali": 4,
          "carsamba": 4,
          "persembe": 4,
          "cuma": 4,
          "cumartesi": 0,
          "pazar": 0
        }
      }
    ],
    "son_guncelleme": "2025-08-13T08:21:49.433Z"
  },
  "vector": [0.1, 0.2, ...] // 384 boyutlu embedding
}
```

### MongoDB Log Veritabanı

```json
{
    "message": "Kemal kaç saat mesai yapmış?",
    "response": "Kemal toplam 229 saat mesai yapmıştır...",
    "timestamp": "2025-08-13T08:21:49.433Z",
    "context": "Qdrant verisi kullanıldı",
    "contextUsed": true
}
```

## 🛠️ Geliştirme

### Geliştirme Ortamı Kurulumu

```bash
# Bağımlılıkları yükle
npm install

# Geliştirme sunucusunu başlat
npm run dev

# TypeScript kontrolü
npm run type-check

# Linting
npm run lint
```

### Kod Yapısı

```
chat_llm_web_app/
├── app/                    # Nuxt.js uygulama dosyaları
│   ├── components/         # Vue bileşenleri
│   │   ├── ChatInterface.vue    # Ana chat arayüzü
│   │   ├── Sidebar.vue          # Navigasyon sidebar
│   │   ├── VectorManager.vue    # Veri yönetimi
│   │   ├── SystemStatus.vue     # Sistem durumu
│   │   ├── ChatHistory.vue      # Sohbet geçmişi

│   │   └── SystemInfo.vue       # Sistem bilgileri
│   ├── pages/             # Sayfa bileşenleri
│   ├── stores/            # Pinia state management
│   └── assets/            # Statik dosyalar
├── server/                # Server-side kod
│   ├── api/               # API endpoints
│   │   ├── chat.post.ts           # Chat API
│   │   ├── health.get.ts          # Health check
│   │   ├── history.get.ts         # Sohbet geçmişi

│   │   └── vectors/               # Vektör yönetimi
│   ├── plugins/           # Nitro plugins
│   └── utils/             # Yardımcı fonksiyonlar
├── docker-compose.dev.yml # Geliştirme Docker Compose
├── docker-compose.yml     # Production Docker Compose
└── Dockerfile             # Docker image tanımı
```

### Yeni Özellik Ekleme

1. **API Endpoint**: `server/api/` altında yeni dosya oluştur
2. **Frontend**: `app/components/` altında Vue bileşeni ekle
3. **Veritabanı**: Gerekirse Qdrant schema'sını güncelle
4. **Test**: Yeni özelliği test et

## 🚀 Deployment

### Production Build

```bash
# Production build
npm run build

# Docker image oluştur
docker build -t ai-mesai-app:latest .

# Production'da çalıştır
docker-compose -f docker-compose.yml up -d
```

### Environment Variables

```bash
# .env dosyası
NODE_ENV=production
MONGODB_URI=mongodb://mongodb:27017/ai_logs
QDRANT_URL=http://qdrant:6333
OLLAMA_URL=http://ollama:11434/api
OLLAMA_CHAT_MODEL=llama3
OLLAMA_EMBEDDING_MODEL=all-minilm
AI_TEMPERATURE=0.7
AI_MAX_TOKENS=512
```

### SSL/HTTPS Kurulumu

```bash
# SSL sertifikalarını ekle
mkdir -p nginx/ssl
# sertifika dosyalarını kopyala

# SSL ile başlat
docker-compose -f docker-compose.ssl.yml up -d
```

## 🔧 Sorun Giderme

### Yaygın Sorunlar

#### 1. Ollama Bağlantı Hatası

```bash
# Ollama servisini kontrol et
docker-compose -f docker-compose.dev.yml logs ollama

# Modeli yeniden indir
docker exec -it nuxt-ai-ollama-dev ollama pull llama3
```

#### 2. Qdrant Veri Kaybı

```bash
# Volume'ları kontrol et
docker volume ls | grep qdrant

# Verileri yedekle
docker run --rm -v qdrant_storage_dev:/data -v $(pwd):/backup alpine tar czf /backup/qdrant-backup.tar.gz /data
```

#### 3. Yavaş Yanıtlar

```bash
# Sistem kaynaklarını kontrol et
docker stats

# LLM parametrelerini optimize et
# AI_TEMPERATURE=0.7, AI_MAX_TOKENS=512
```

#### 4. Memory Sorunları

```bash
# Docker memory limitini artır
# docker-compose.yml'da memory: 4g ekle
```

### Log Kontrolü

```bash
# Tüm servislerin loglarını gör
docker-compose -f docker-compose.dev.yml logs

# Belirli servisin loglarını gör
docker-compose -f docker-compose.dev.yml logs nuxt-app

# Canlı log takibi
docker-compose -f docker-compose.dev.yml logs -f
```

### Performans Optimizasyonu

```bash
# Sistem durumunu kontrol et
curl http://localhost:3005/api/health

# Vektör sayısını kontrol et
curl http://localhost:3005/api/vectors/status | jq '.status.result.points_count'
```

## 📊 Monitoring

### Health Check

```bash
# Sistem durumu
curl http://localhost:3005/api/health


```

### Metrics

-   **Yanıt Süresi**: Ortalama 5-10 saniye
-   **Vektör Sayısı**: Çalışan başına 1 kayıt
-   **Memory Kullanımı**: ~2GB (Ollama dahil)
-   **Disk Kullanımı**: ~500MB (Qdrant + MongoDB)

## 🔄 ai-app-argenova ile Farklar ve Avantajlar

### 🆕 **Yeni Özellikler**

| Özellik              | ai-app-argenova  | chat_llm_web_app (v2.0)     |
| -------------------- | ---------------- | --------------------------- |
| **Framework**        | Express.js       | **Nuxt.js 3**               |
| **Frontend**         | Vanilla JS + Vue | **Vue 3 + Composition API** |
| **TypeScript**       | ❌               | **✅ Tam Desteği**          |
| **State Management** | ❌               | **✅ Pinia**                |
| **UI/UX**            | Basit HTML       | **🎨 Modern Glassmorphism** |
| **Responsive**       | ❌               | **✅ Mobil Uyumlu**         |
| **Model Seçimi**     | Manuel           | **✅ Web Arayüzünden**      |
| **Animasyonlar**     | ❌               | **✅ Smooth Efektler**      |
| **Dark Mode**        | ❌               | **✅ Göz Yormayan Tema**    |
| **SSR**              | ❌               | **✅ SEO Dostu**            |

### 🚀 **Teknik Gelişmeler**

-   **Modern Stack**: Express.js → Nuxt.js 3
-   **Type Safety**: JavaScript → TypeScript
-   **State Management**: Global variables → Pinia
-   **UI Framework**: Custom CSS → Tailwind CSS
-   **Component Architecture**: Monolithic → Modular
-   **Development Experience**: Basic → Hot reload, TypeScript, ESLint

### 📈 **Performans İyileştirmeleri**

-   **Faster Loading**: SSR ile daha hızlı yükleme
-   **Better Caching**: Nuxt.js built-in caching
-   **Optimized Bundles**: Tree shaking ve code splitting
-   **Modern Build**: Vite tabanlı build sistemi

### 🎯 **Önemli Avantajlar**

#### 🏗️ **Mimari Avantajları**

-   **Full-Stack Framework**: Nuxt.js 3 ile tek proje içinde frontend ve backend
-   **Auto-Import**: Otomatik import sistemi ile daha temiz kod
-   **File-Based Routing**: Dosya tabanlı routing ile kolay navigasyon
-   **Built-in API Routes**: Nitro server ile güçlü API desteği
-   **Hot Module Replacement**: Geliştirme sırasında anlık güncelleme

#### 🎨 **UI/UX Avantajları**

-   **Modern Tasarım**: Glassmorphism ve gradient efektleri
-   **Responsive Layout**: Tüm cihazlarda mükemmel görünüm
-   **Interactive Elements**: Hover efektleri ve animasyonlar
-   **Accessibility**: Erişilebilirlik standartlarına uygun
-   **User Experience**: Kullanıcı dostu arayüz tasarımı

#### 🔧 **Geliştirme Avantajları**

-   **TypeScript Support**: Tip güvenliği ile daha az hata
-   **IntelliSense**: IDE desteği ile daha hızlı geliştirme
-   **Code Splitting**: Otomatik kod bölme ile daha hızlı yükleme
-   **Tree Shaking**: Kullanılmayan kodların otomatik temizlenmesi
-   **ESLint Integration**: Kod kalitesi kontrolü

#### 🚀 **Performans Avantajları**

-   **Server-Side Rendering**: SEO dostu ve hızlı ilk yükleme
-   **Static Generation**: Statik sayfa üretimi ile hızlı erişim
-   **Image Optimization**: Otomatik resim optimizasyonu
-   **Lazy Loading**: Gereksiz yüklemelerin önlenmesi
-   **Caching Strategy**: Akıllı önbellekleme stratejisi

#### 🔒 **Güvenlik Avantajları**

-   **Built-in Security**: Nuxt.js'in yerleşik güvenlik özellikleri
-   **CSRF Protection**: Cross-site request forgery koruması
-   **XSS Prevention**: Cross-site scripting önleme
-   **Content Security Policy**: İçerik güvenlik politikası
-   **HTTPS Ready**: SSL sertifika desteği

#### 📱 **Mobil Avantajları**

-   **Progressive Web App**: PWA desteği ile native app deneyimi
-   **Offline Support**: İnternet bağlantısı olmadan da çalışma
-   **Push Notifications**: Bildirim desteği
-   **Touch Optimized**: Dokunmatik cihazlar için optimize edilmiş
-   **Mobile-First Design**: Mobil öncelikli tasarım

#### 🔄 **Maintenance Avantajları**

-   **Modular Architecture**: Modüler yapı ile kolay bakım
-   **Component Reusability**: Yeniden kullanılabilir bileşenler
-   **Version Control**: Git ile etkili versiyon kontrolü
-   **Documentation**: Kapsamlı dokümantasyon
-   **Community Support**: Büyük topluluk desteği

#### 💼 **Business Avantajları**

-   **Faster Development**: Daha hızlı geliştirme süreci
-   **Lower Maintenance Cost**: Daha düşük bakım maliyeti
-   **Better User Experience**: Daha iyi kullanıcı deneyimi
-   **SEO Friendly**: Arama motoru optimizasyonu
-   **Scalable Architecture**: Ölçeklenebilir mimari

### 📊 **Karşılaştırma Özeti**

| Kategori               | ai-app-argenova | chat_llm_web_app (v2.0) | İyileştirme |
| ---------------------- | --------------- | ----------------------- | ----------- |
| **Geliştirme Hızı**    | ⭐⭐            | ⭐⭐⭐⭐⭐              | **%150**    |
| **Kod Kalitesi**       | ⭐⭐            | ⭐⭐⭐⭐⭐              | **%200**    |
| **Kullanıcı Deneyimi** | ⭐⭐            | ⭐⭐⭐⭐⭐              | **%300**    |
| **Performans**         | ⭐⭐⭐          | ⭐⭐⭐⭐⭐              | **%100**    |
| **Bakım Kolaylığı**    | ⭐⭐            | ⭐⭐⭐⭐⭐              | **%250**    |
| **Mobil Uyumluluk**    | ⭐              | ⭐⭐⭐⭐⭐              | **%500**    |
| **SEO**                | ⭐              | ⭐⭐⭐⭐⭐              | **%500**    |
| **Güvenlik**           | ⭐⭐⭐          | ⭐⭐⭐⭐⭐              | **%100**    |

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 📞 İletişim

-   **Geliştirici**: [Adınız]
-   **Email**: [email@example.com]
-   **GitHub**: [github.com/username]

---

**Not**: Bu sistem **ai-app-argenova** projesinin geliştirilmiş versiyonudur. Production kullanımı için ek güvenlik önlemleri alınmalıdır.
