# 👨‍💻 Geliştirici Rehberi

## 📋 İçindekiler

1. [Kurulum](#kurulum)
2. [Geliştirme Ortamı](#geliştirme-ortamı)
3. [Kod Standartları](#kod-standartları)
4. [Git Workflow](#git-workflow)
5. [Testing](#testing)
6. [Debugging](#debugging)
7. [Performance](#performance)
8. [Deployment](#deployment)

## 🚀 Kurulum

### Gereksinimler

-   **Flutter SDK**: 3.0.0 veya üzeri
-   **Dart SDK**: 3.0.0 veya üzeri
-   **IDE**: Android Studio / VS Code
-   **Git**: Versiyon kontrolü için

### Kurulum Adımları

#### 1. Flutter Kurulumu

```bash
# Flutter SDK'yı indir
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"

# Flutter doctor ile kontrol et
flutter doctor
```

#### 2. Proje Kurulumu

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

### IDE Kurulumu

#### VS Code

```json
// settings.json
{
    "dart.flutterSdkPath": "/path/to/flutter",
    "dart.lineLength": 80,
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.fixAll": true
    }
}
```

#### Android Studio

-   Flutter ve Dart plugin'lerini yükle
-   Flutter SDK path'ini ayarla
-   Code formatting ayarlarını yapılandır

## 🛠️ Geliştirme Ortamı

### Proje Yapısı

```
chat_llm_app/
├── lib/                    # Ana kod klasörü
│   ├── core/              # Çekirdek bileşenler
│   ├── features/          # Özellik modülleri
│   ├── shared/            # Paylaşılan bileşenler
│   └── main.dart          # Uygulama girişi
├── test/                  # Test dosyaları
├── docs/                  # Dokümantasyon
├── assets/                # Statik dosyalar
└── pubspec.yaml           # Bağımlılıklar
```

### Hot Reload

```bash
# Development modunda çalıştır
flutter run

# Hot reload için 'r' tuşuna bas
# Hot restart için 'R' tuşuna bas
```

### Debug Mode

```bash
# Debug modunda çalıştır
flutter run --debug

# Profile modunda çalıştır
flutter run --profile

# Release modunda çalıştır
flutter run --release
```

## 📝 Kod Standartları

### Dart Style Guide

-   **Line Length**: 80 karakter
-   **Indentation**: 2 space
-   **Naming**: camelCase (değişkenler), PascalCase (sınıflar)
-   **Documentation**: Kapsamlı dokümantasyon

### Kod Örnekleri

#### Sınıf Tanımı

```dart
/// Kullanıcı bilgilerini temsil eden sınıf
class User {
  /// Kullanıcının benzersiz kimliği
  final String id;

  /// Kullanıcının adı
  final String name;

  /// Kullanıcının e-posta adresi
  final String email;

  /// Kullanıcı oluşturucu
  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  /// Kullanıcı kopyalama metodu
  User copyWith({
    String? id,
    String? name,
    String? email,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}
```

#### Widget Tanımı

```dart
/// Özel buton widget'ı
class CustomButton extends StatefulWidget {
  /// Buton metni
  final String text;

  /// Tıklama callback'i
  final VoidCallback? onPressed;

  /// Loading durumu
  final bool isLoading;

  /// Buton oluşturucu
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}
```

### Import Organizasyonu

```dart
// Dart imports
import 'dart:async';
import 'dart:io';

// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Third-party imports
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Local imports
import '../../core/theme/app_theme.dart';
import '../../shared/models/chat.dart';
```

## 🔄 Git Workflow

### Branch Stratejisi

```
main
├── develop
│   ├── feature/chat-archive
│   ├── feature/search-bar
│   └── bugfix/overflow-issue
└── hotfix/critical-bug
```

### Commit Mesajları

```
feat: add chat archive functionality
fix: resolve search bar overflow issue
docs: update widget documentation
refactor: improve state management
test: add unit tests for chat provider
style: format code according to style guide
```

### Pull Request Süreci

1. **Feature Branch Oluştur**

    ```bash
    git checkout -b feature/new-feature
    ```

2. **Değişiklikleri Commit Et**

    ```bash
    git add .
    git commit -m "feat: add new feature"
    ```

3. **Push Et**

    ```bash
    git push origin feature/new-feature
    ```

4. **Pull Request Oluştur**
    - Title: Açıklayıcı başlık
    - Description: Detaylı açıklama
    - Checklist: Tamamlanan görevler

### Code Review

-   **Functionality**: Kod doğru çalışıyor mu?
-   **Performance**: Performans etkisi var mı?
-   **Security**: Güvenlik açığı var mı?
-   **Maintainability**: Kod sürdürülebilir mi?

## 🧪 Testing

### Test Türleri

#### Unit Tests

```dart
// test/unit/chat_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('ChatProvider Tests', () {
    test('should add new chat', () {
      final container = ProviderContainer();
      final notifier = container.read(chatsProvider.notifier);

      final chat = Chat(
        id: '1',
        title: 'Test Chat',
        messages: [],
        createdAt: DateTime.now(),
        lastMessageTime: DateTime.now(),
      );

      notifier.addChat(chat);

      expect(container.read(chatsProvider).length, 1);
      expect(container.read(chatsProvider).first.title, 'Test Chat');
    });
  });
}
```

#### Widget Tests

```dart
// test/widget/chat_list_item_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChatListItem displays chat information', (tester) async {
    final chat = Chat(
      id: '1',
      title: 'Test Chat',
      messages: [],
      createdAt: DateTime.now(),
      lastMessageTime: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChatListItem(
          chat: chat,
          onTap: () {},
          onLongPress: () {},
        ),
      ),
    );

    expect(find.text('Test Chat'), findsOneWidget);
  });
}
```

#### Integration Tests

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete chat flow test', (tester) async {
    await tester.pumpWidget(MyApp());

    // Yeni sohbet oluştur
    await tester.tap(find.text('İlk Sohbeti Başlat'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Test Chat');
    await tester.tap(find.text('Oluştur'));
    await tester.pumpAndSettle();

    // Sohbet sayfasında mesaj gönder
    await tester.enterText(find.byType(TextField), 'Hello World');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(find.text('Hello World'), findsOneWidget);
  });
}
```

### Test Çalıştırma

```bash
# Tüm testleri çalıştır
flutter test

# Belirli test dosyasını çalıştır
flutter test test/unit/chat_provider_test.dart

# Coverage ile çalıştır
flutter test --coverage
```

## 🐛 Debugging

### Debug Araçları

#### Flutter Inspector

```bash
# Inspector'ı aç
flutter run --debug
# DevTools'u aç ve Inspector sekmesine git
```

#### Logging

```dart
import 'package:flutter/foundation.dart';

class ChatNotifier extends StateNotifier<List<Chat>> {
  void addChat(Chat chat) {
    if (kDebugMode) {
      print('Adding chat: ${chat.title}');
    }
    // Implementation
  }
}
```

#### Error Handling

```dart
try {
  await ref.read(chatsProvider.notifier).addChat(chat);
} catch (e, stackTrace) {
  if (kDebugMode) {
    print('Error adding chat: $e');
    print('Stack trace: $stackTrace');
  }
  // Error handling
}
```

### Performance Debugging

```bash
# Performance overlay'i aç
flutter run --profile --enable-software-rendering

# Timeline'i incele
flutter run --trace-startup
```

## ⚡ Performance

### Best Practices

#### Widget Optimization

```dart
// const constructor kullan
const CustomWidget({super.key});

// AnimatedBuilder ile gereksiz rebuild'leri önle
AnimatedBuilder(
  animation: _animationController,
  builder: (context, child) {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: child, // child parametresi kullan
    );
  },
  child: const ExpensiveWidget(), // const child
)
```

#### List Optimization

```dart
// ListView.builder kullan
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(items[index].title),
    );
  },
)

// SliverList kullan
SliverList(
  delegate: SliverChildBuilderDelegate(
    (context, index) => ListTile(
      title: Text(items[index].title),
    ),
    childCount: items.length,
  ),
)
```

#### Image Optimization

```dart
// Cached network image kullan
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### Memory Management

```dart
// Dispose metodlarını implement et
@override
void dispose() {
  _animationController.dispose();
  _textController.dispose();
  _focusNode.dispose();
  super.dispose();
}

// Stream subscription'ları iptal et
StreamSubscription? _subscription;

@override
void dispose() {
  _subscription?.cancel();
  super.dispose();
}
```

## 🚀 Deployment

### Android Build

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle
flutter build appbundle --release
```

### iOS Build

```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

### Web Build

```bash
# Web build
flutter build web --release

# Host et
flutter run -d chrome --web-port 8080
```

### Build Konfigürasyonu

#### Android (android/app/build.gradle)

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.example.chat_llm_app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

#### iOS (ios/Runner/Info.plist)

```xml
<key>CFBundleDisplayName</key>
<string>Chat LLM App</string>
<key>CFBundleVersion</key>
<string>1.0.0</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
```

## 📚 Faydalı Kaynaklar

### Flutter Dokümantasyonu

-   [Flutter Docs](https://docs.flutter.dev/)
-   [Dart Language Tour](https://dart.dev/guides/language/language-tour)
-   [Flutter Widget Catalog](https://docs.flutter.dev/development/ui/widgets)

### Paketler

-   [Riverpod](https://riverpod.dev/)
-   [Hive](https://docs.hivedb.dev/)
-   [Flutter Hooks](https://pub.dev/packages/flutter_hooks)

### Araçlar

-   [Flutter Inspector](https://docs.flutter.dev/development/tools/devtools/inspector)
-   [Flutter Performance](https://docs.flutter.dev/development/tools/devtools/performance)
-   [Flutter DevTools](https://docs.flutter.dev/development/tools/devtools)

---

Bu rehber, projeye katkıda bulunmak isteyen geliştiriciler için kapsamlı bir kaynak sağlar.
