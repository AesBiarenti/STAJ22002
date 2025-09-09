# 🏗️ Mimari Dokümantasyonu

## 📋 İçindekiler

1. [Genel Mimari](#genel-mimari)
2. [Katman Yapısı](#katman-yapısı)
3. [State Management](#state-management)
4. [Veri Modelleri](#veri-modelleri)
5. [Widget Yapısı](#widget-yapısı)
6. [Tema Sistemi](#tema-sistemi)
7. [Routing](#routing)
8. [Dependency Injection](#dependency-injection)

## 🎯 Genel Mimari

Bu proje **Clean Architecture** prensiplerine dayalı olarak geliştirilmiştir. Üç ana katmandan oluşur:

```
┌─────────────────────────────────────┐
│        Presentation Layer           │
│     (UI, Pages, Widgets)           │
├─────────────────────────────────────┤
│         Domain Layer                │
│    (Models, Providers)              │
├─────────────────────────────────────┤
│          Data Layer                 │
│    (Hive, Local Storage)            │
└─────────────────────────────────────┘
```

### Mimari Prensipleri

-   **Separation of Concerns**: Her katmanın belirli sorumlulukları var
-   **Dependency Inversion**: Yüksek seviye modüller düşük seviye detaylara bağımlı değil
-   **Single Responsibility**: Her sınıf tek bir sorumluluğa sahip
-   **Open/Closed Principle**: Genişletmeye açık, değişikliğe kapalı

## 🏢 Katman Yapısı

### 1. Presentation Layer (`lib/features/`)

UI bileşenleri ve kullanıcı etkileşimlerini içerir.

#### Chat Feature

```
features/chat/
├── presentation/
│   ├── pages/
│   │   ├── chat_list_page.dart      # Ana sohbet listesi
│   │   ├── chat_page.dart           # Sohbet detay sayfası
│   │   └── archive_page.dart        # Arşiv sayfası
│   └── widgets/
│       ├── chat_list_item.dart      # Sohbet listesi öğesi
│       ├── message_bubble.dart      # Mesaj balonu
│       └── chat_input.dart          # Mesaj girişi
```

#### Settings Feature

```
features/settings/
├── presentation/
│   └── pages/
│       └── settings_page.dart       # Ayarlar sayfası
```

### 2. Domain Layer (`lib/shared/`)

İş mantığı ve veri modellerini içerir.

#### Models

```
shared/models/
├── chat.dart                        # Sohbet modeli
├── chat_message.dart                # Mesaj modeli
└── *.g.dart                         # Hive adaptörleri
```

#### Providers (State Management)

```
shared/providers/
├── chat_provider.dart               # Sohbet state yönetimi
└── theme_provider.dart              # Tema state yönetimi
```

### 3. Data Layer

Veri saklama ve erişim işlemlerini içerir.

#### Hive Database

-   **Chat Box**: Sohbet verilerini saklar
-   **Settings Box**: Uygulama ayarlarını saklar
-   **Type Safety**: Güçlü tip güvenliği

## 🔄 State Management

### Riverpod Kullanımı

#### Provider Tipleri

1. **StateNotifierProvider**: Karmaşık state yönetimi

```dart
final chatsProvider = StateNotifierProvider<ChatNotifier, List<Chat>>((ref) {
  return ChatNotifier();
});
```

2. **StateProvider**: Basit state yönetimi

```dart
final selectedChatProvider = StateProvider<Chat?>((ref) => null);
```

#### Provider Hiyerarşisi

```
App
├── themeProvider (StateNotifierProvider)
├── chatsProvider (StateNotifierProvider)
│   └── selectedChatProvider (StateProvider)
└── UI Components
```

### State Güncelleme Akışı

```
User Action → Provider → State Update → UI Rebuild
     ↓              ↓           ↓           ↓
  Button Tap → ChatNotifier → addChat() → ListView
```

## 📊 Veri Modelleri

### Chat Model

```dart
@HiveType(typeId: 2)
class Chat extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String title;
  @HiveField(2) final List<ChatMessage> messages;
  @HiveField(3) final DateTime createdAt;
  @HiveField(4) final DateTime lastMessageTime;
  @HiveField(5) final String? avatarUrl;
  @HiveField(6) final bool isGroupChat;
  @HiveField(7) final bool isArchived;
}
```

### ChatMessage Model

```dart
@HiveType(typeId: 0)
class ChatMessage extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String content;
  @HiveField(2) final DateTime timestamp;
  @HiveField(3) final bool isFromUser;
  @HiveField(4) final String? senderName;
  @HiveField(5) final MessageStatus status;
}
```

## 🧩 Widget Yapısı

### Custom Widgets (`lib/shared/widgets/`)

#### AnimatedCard

-   Hover ve tap animasyonları
-   Shadow ve border efektleri
-   Responsive tasarım

#### GradientButton

-   Gradient arka plan
-   Loading state desteği
-   Custom icon desteği

#### AnimatedSearchBar

-   Expand/collapse animasyonu
-   Real-time arama
-   Smooth geçişler

#### CustomPopupMenu

-   Overlay tabanlı popup
-   Custom positioning
-   Auto-dismiss özelliği

### Widget Hiyerarşisi

```
Scaffold
├── SliverAppBar
│   ├── AnimatedSearchBar
│   └── CustomPopupMenu
├── SliverList
│   └── AnimatedCard
│       └── ChatListItem
└── FloatingActionButton
```

## 🎨 Tema Sistemi

### AppTheme (`lib/core/theme/app_theme.dart`)

#### Renk Paleti

```dart
// Gradient Renkler
static const Color primaryGradientStart = Color(0xFF667eea);
static const Color primaryGradientEnd = Color(0xFF764ba2);

// Nötr Renkler
static const Color backgroundLight = Color(0xFFf8fafc);
static const Color surfaceLight = Color(0xFFffffff);

// Accent Renkler
static const Color accentBlue = Color(0xFF4299e1);
static const Color accentGreen = Color(0xFF48bb78);
```

#### Tema Özellikleri

-   **Light/Dark Theme**: Sistem temasına uyum
-   **Custom Colors**: Material Design'dan bağımsız
-   **Gradient Support**: Modern gradient tasarımı
-   **Border Radius**: Tutarlı köşe yuvarlaklığı
-   **Shadows**: Katmanlı gölge sistemi

### Tema Kullanımı

```dart
// Gradient kullanımı
decoration: BoxDecoration(
  gradient: AppTheme.primaryGradient,
)

// Renk kullanımı
color: AppTheme.accentBlue

// Border radius kullanımı
borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium)
```

## 🛣️ Routing

### Route Yapısı

```dart
routes: {
  '/': (context) => const ChatListPage(),
  '/settings': (context) => const SettingsPage(),
  '/archive': (context) => const ArchivePage(),
},
onGenerateRoute: (settings) {
  if (settings.name == '/chat') {
    final chat = settings.arguments as Chat;
    return MaterialPageRoute(
      builder: (context) => ChatPage(chat: chat),
    );
  }
  return null;
},
```

### Navigation Patterns

-   **Named Routes**: Statik sayfalar için
-   **Dynamic Routes**: Parametreli sayfalar için
-   **Deep Linking**: Gelecek özellik

## 💉 Dependency Injection

### Provider Scope

```dart
void main() async {
  runApp(const ProviderScope(child: MyApp()));
}
```

### Provider Kullanımı

```dart
// Provider'a erişim
final chats = ref.watch(chatsProvider);

// Provider'ı güncelleme
ref.read(chatsProvider.notifier).addChat(newChat);
```

## 🔧 Geliştirme Prensipleri

### Kod Organizasyonu

1. **Feature-based**: Her özellik kendi klasöründe
2. **Separation**: UI, logic ve data ayrı
3. **Reusability**: Widget'lar yeniden kullanılabilir
4. **Testability**: Test edilebilir yapı

### Best Practices

-   **Consistent Naming**: Tutarlı isimlendirme
-   **Documentation**: Kapsamlı dokümantasyon
-   **Error Handling**: Hata yönetimi
-   **Performance**: Performans optimizasyonu

## 🚀 Gelecek Geliştirmeler

### Mimari İyileştirmeler

-   [ ] Repository Pattern implementasyonu
-   [ ] Use Case katmanı ekleme
-   [ ] Dependency injection framework
-   [ ] Error handling middleware

### Teknik İyileştirmeler

-   [ ] Unit test coverage
-   [ ] Integration tests
-   [ ] Performance monitoring
-   [ ] Code generation

---

Bu dokümantasyon projenin mimari yapısını anlamak için referans olarak kullanılabilir.
