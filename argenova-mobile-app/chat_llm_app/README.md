# 🤖 Chat LLM App

Modern, özelleştirilmiş arayüze sahip AI destekli sohbet uygulaması. WhatsApp benzeri arayüz ile kullanıcı dostu deneyim sunar.

## 🆕 Son Güncellemeler

-   **UI/UX**: Ana ekrana "Yeni Sohbet Ekle" butonu eklendi. İlk mesaj artık otomatik başlık olarak kullanılıyor. Mobilde drawer açıkken sohbete tıklayınca otomatik kapanıyor. Boş başlık/boş durumlar için daha iyi geri bildirimler eklendi.
-   **Performans**: Başlık güncelleme akışı sadeleştirildi (tek geçişte güncelleniyor), gereksiz state güncellemeleri azaltıldı. Sohbet listesi ve mesaj ekleme akışı optimize edildi.

## ✨ Özellikler

### 💬 Sohbet Özellikleri

-   **Metin Mesajlaşma**: Temiz ve hızlı metin mesajlaşma
-   **AI Yanıtları**: Simüle edilmiş AI yanıtları (LLM entegrasyonu için hazır)
-   **Grup Sohbetleri**: Yeni grup oluşturma ve yönetimi
-   **Sohbet Arama**: Gerçek zamanlı sohbet arama
-   **Arşivleme**: Sohbetleri arşivleme ve arşivden çıkarma
-   **Sohbet Düzenleme**: Sohbet adlarını değiştirme

### 🎨 Tasarım Özellikleri

-   **Özel Tasarım**: Material Design ve iOS tasarımından bağımsız
-   **Gradient Tema**: Modern gradient renk paleti
-   **Karanlık/Aydınlık Tema**: Sistem temasına uyum
-   **Animasyonlar**: Smooth geçişler ve hover efektleri
-   **Responsive**: Tüm ekran boyutlarına uyumlu

### 🔧 Teknik Özellikler

-   **Cross-Platform**: Android, iOS, Web desteği
-   **State Management**: Riverpod ile modern state yönetimi
-   **Local Storage**: Hive ile hızlı veri saklama
-   **Clean Architecture**: Temiz ve sürdürülebilir kod yapısı

## 🚀 Kurulum

### Backend (Flask API + Qdrant + Ollama)

Geliştirme ortamı için Docker Compose dosyası hazır gelir.

```bash
# Flask API klasörüne geçin
cd flask_api

# Geliştirme ortamını çalıştırın (port çakışması varsa 6336 / 11435 kullanılır)
docker compose -f docker-compose.dev.yml up -d --build

# Servisler:
# - Flask API: http://localhost:5000
# - Qdrant:    http://localhost:6336
# - Ollama:    http://localhost:11435
```

Mobil emulator için Flutter tarafında backend URL'i `10.0.2.2` olarak ayarlıdır (`lib/shared/services/ai_service.dart`).

### Gereksinimler

-   Flutter SDK (3.0.0+)
-   Dart SDK (3.0.0+)
-   Android Studio / VS Code

### Adımlar

```bash
# Projeyi klonla
git clone https://github.com/username/chat_llm_app.git
cd chat_llm_app

# Bağımlılıkları yükle
flutter pub get

# Hive adaptörlerini oluştur
flutter pub run build_runner build --delete-conflicting-outputs

# Uygulamayı çalıştır
flutter run
```

## 📱 Ekran Görüntüleri

> Not: UI/UX tarafında önemli iyileştirmeler yapıldı. Yeni sohbet başlatma akışı basitleştirildi ve mobil drawer etkileşimi iyileştirildi.

### Ana Sayfa

-   Sohbet listesi
-   Arama bar'ı
-   Hızlı eylemler
-   Yeni sohbet oluşturma

### Sohbet Sayfası

-   Mesaj geçmişi
-   Mesaj gönderme
-   AI yanıtları
-   Sohbet seçenekleri

### Arşiv Sayfası

-   Arşivlenmiş sohbetler
-   Arşivden çıkarma
-   Arama özelliği

## 🏗️ Proje Yapısı

```
lib/
├── core/                    # Çekirdek bileşenler
│   ├── constants/          # Sabitler
│   ├── theme/             # Tema tanımları
│   └── utils/             # Yardımcı fonksiyonlar
├── features/              # Özellik modülleri
│   ├── chat/             # Sohbet özellikleri
│   ├── contacts/         # Kişiler (gelecek)
│   └── settings/         # Ayarlar
├── shared/               # Paylaşılan bileşenler
│   ├── models/          # Veri modelleri
│   ├── providers/       # State yönetimi
│   └── widgets/         # Özel widget'lar
└── main.dart            # Uygulama girişi
```

## 🎯 Mimari

### Clean Architecture

-   **Presentation Layer**: UI bileşenleri ve sayfalar
-   **Domain Layer**: İş mantığı ve modeller
-   **Data Layer**: Veri yönetimi ve depolama

### State Management

-   **Riverpod**: Modern state yönetimi
-   **Provider Pattern**: Veri paylaşımı
-   **Reactive Programming**: Otomatik UI güncellemeleri

### Data Persistence

-   **Hive**: Hızlı NoSQL veritabanı
-   **Local Storage**: Offline çalışma
-   **Type Safety**: Güçlü tip güvenliği

## 🔧 Teknolojiler

-   **Flutter**: Cross-platform UI framework
-   **Dart**: Programlama dili
-   **Riverpod**: State management
-   **Hive**: Local database
-   **Custom UI**: Özel tasarım sistemi

## 📋 Geliştirme

### Kod Standartları

-   **Dart Style Guide**: Resmi Dart stil rehberi
-   **Clean Code**: Temiz ve okunabilir kod
-   **Documentation**: Kapsamlı dokümantasyon

### Test Stratejisi

-   **Unit Tests**: Fonksiyon testleri
-   **Widget Tests**: UI bileşen testleri
-   **Integration Tests**: Uçtan uca testler

## 🚧 Gelecek Özellikler

### LLM Entegrasyonu

-   [ ] Local LLM desteği
-   [ ] WhatsApp sohbet import
-   [ ] AI model eğitimi
-   [ ] Çoklu dil desteği

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 📞 İletişim

-   **Proje Linki**: [https://github.com/username/chat_llm_app](https://github.com/username/chat_llm_app)
-   **Issues**: [https://github.com/username/chat_llm_app/issues](https://github.com/username/username/chat_llm_app/issues)

---

⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!
