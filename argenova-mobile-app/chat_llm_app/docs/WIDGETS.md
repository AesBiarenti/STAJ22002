# 🧩 Widget Dokümantasyonu

## 📋 İçindekiler

1. [Custom Widgets](#custom-widgets)


2. [AnimatedCard](#animatedcard)
3. [GradientButton](#gradientbutton)
4. [AnimatedSearchBar](#animatedsearchbar)
5. [CustomPopupMenu](#custompopupmenu)
6. [CustomBottomSheet](#custombottomsheet)
7. [ChatListItem](#chatlistitem)
8. [MessageBubble](#messagebubble)
9. [ChatInput](#chatinput)

## 🎨 Custom Widgets

Bu proje, Material Design ve iOS tasarımından bağımsız özel widget'lar kullanır. Tüm widget'lar modern, animasyonlu ve kullanıcı dostu tasarıma sahiptir.

### Widget Kategorileri

-   **Layout Widgets**: AnimatedCard, CustomBottomSheet
-   **Interactive Widgets**: GradientButton, AnimatedSearchBar
-   **UI Components**: CustomPopupMenu, ChatListItem
-   **Chat Widgets**: MessageBubble, ChatInput

## 🃏 AnimatedCard

### Açıklama

Hover ve tap animasyonları ile gelişmiş kart widget'ı. Modern tasarım ve smooth geçişler sunar.

### Özellikler

-   ✅ Hover animasyonu
-   ✅ Tap animasyonu
-   ✅ Shadow efektleri
-   ✅ Border radius
-   ✅ Responsive tasarım

### Kullanım

```dart
AnimatedCard(
  onTap: () => print('Card tapped'),
  child: Text('Card Content'),
  margin: EdgeInsets.all(8),
  enableHover: true,
  enableShadow: true,
)
```

### Parametreler

| Parametre         | Tip                 | Varsayılan         | Açıklama          |
| ----------------- | ------------------- | ------------------ | ----------------- |
| `child`           | Widget              | -                  | Kart içeriği      |
| `onTap`           | VoidCallback?       | null               | Tap callback      |
| `padding`         | EdgeInsetsGeometry? | EdgeInsets.all(16) | İç boşluk         |
| `margin`          | EdgeInsetsGeometry? | EdgeInsets.all(8)  | Dış boşluk        |
| `enableHover`     | bool                | true               | Hover animasyonu  |
| `enableShadow`    | bool                | true               | Gölge efekti      |
| `backgroundColor` | Color?              | null               | Arka plan rengi   |
| `borderRadius`    | BorderRadius?       | null               | Köşe yuvarlaklığı |

### Animasyon Detayları

-   **Scale Animation**: 1.0 → 1.02 (hover)
-   **Shadow Animation**: Soft → Medium (hover)
-   **Duration**: 200ms
-   **Curve**: Curves.easeInOut

## 🎨 GradientButton

### Açıklama

Gradient arka planlı, animasyonlu buton widget'ı. Loading state ve icon desteği sunar.

### Özellikler

-   ✅ Gradient arka plan
-   ✅ Loading state
-   ✅ Icon desteği
-   ✅ Outlined variant
-   ✅ Press animation

### Kullanım

```dart
GradientButton(
  text: 'Click Me',
  icon: Icons.send,
  onPressed: () => print('Button pressed'),
  isLoading: false,
  gradient: AppTheme.primaryGradient,
)
```

### Parametreler

| Parametre    | Tip             | Varsayılan               | Açıklama         |
| ------------ | --------------- | ------------------------ | ---------------- |
| `text`       | String          | -                        | Buton metni      |
| `onPressed`  | VoidCallback?   | null                     | Press callback   |
| `isLoading`  | bool            | false                    | Loading durumu   |
| `width`      | double?         | null                     | Genişlik         |
| `height`     | double          | 50                       | Yükseklik        |
| `gradient`   | LinearGradient? | AppTheme.primaryGradient | Gradient         |
| `icon`       | IconData?       | null                     | İkon             |
| `isOutlined` | bool            | false                    | Outlined variant |

### Animasyon Detayları

-   **Scale Animation**: 1.0 → 0.95 (press)
-   **Duration**: 150ms
-   **Curve**: Curves.easeInOut

## 🔍 AnimatedSearchBar

### Açıklama

Expand/collapse animasyonlu arama bar'ı. Real-time arama ve smooth geçişler sunar.

### Özellikler

-   ✅ Expand/collapse animasyonu
-   ✅ Real-time arama
-   ✅ Clear button
-   ✅ Focus management
-   ✅ Custom styling

### Kullanım

```dart
AnimatedSearchBar(
  hintText: 'Search...',
  onSearch: (query) => print('Search: $query'),
  initiallyExpanded: false,
)
```

### Parametreler

| Parametre           | Tip              | Varsayılan | Açıklama          |
| ------------------- | ---------------- | ---------- | ----------------- |
| `onSearch`          | Function(String) | -          | Arama callback    |
| `hintText`          | String?          | 'Ara...'   | Placeholder metni |
| `initiallyExpanded` | bool             | false      | Başlangıç durumu  |

### Animasyon Detayları

-   **Width Animation**: 40px → 140px
-   **Opacity Animation**: 0.0 → 1.0
-   **Scale Animation**: 0.9 → 1.0
-   **Duration**: 250ms

## 🍔 CustomPopupMenu

### Açıklama

Overlay tabanlı özel popup menü. Custom positioning ve auto-dismiss özelliği sunar.

### Özellikler

-   ✅ Overlay tabanlı
-   ✅ Custom positioning
-   ✅ Auto-dismiss
-   ✅ Smooth animations
-   ✅ Custom styling

### Kullanım

```dart
CustomPopupMenu(
  items: [
    CustomPopupMenuItem(
      title: 'Option 1',
      icon: Icons.edit,
      onTap: () => print('Option 1'),
    ),
  ],
  child: Icon(Icons.more_vert),
)
```

### Parametreler

| Parametre | Tip                       | Varsayılan         | Açıklama       |
| --------- | ------------------------- | ------------------ | -------------- |
| `items`   | List<CustomPopupMenuItem> | -                  | Menü öğeleri   |
| `child`   | Widget                    | -                  | Trigger widget |
| `width`   | double                    | 200                | Menü genişliği |
| `padding` | EdgeInsets                | EdgeInsets.all(16) | İç boşluk      |

### CustomPopupMenuItem

```dart
CustomPopupMenuItem({
  required String title,
  required IconData icon,
  Color? iconColor,
  VoidCallback? onTap,
  bool isDestructive = false,
})
```

## 📋 CustomBottomSheet

### Açıklama

Özel tasarımlı bottom sheet. Handle bar ve custom content desteği sunar.

### Özellikler

-   ✅ Handle bar
-   ✅ Custom title
-   ✅ Scrollable content
-   ✅ Custom styling
-   ✅ Responsive height

### Kullanım

```dart
CustomBottomSheet(
  title: 'Options',
  children: [
    CustomBottomSheetItem(
      title: 'Option 1',
      icon: Icons.edit,
      onTap: () => print('Option 1'),
    ),
  ],
)
```

### Parametreler

| Parametre    | Tip          | Varsayılan | Açıklama             |
| ------------ | ------------ | ---------- | -------------------- |
| `title`      | String       | -          | Başlık               |
| `children`   | List<Widget> | -          | İçerik widget'ları   |
| `maxHeight`  | double?      | null       | Maksimum yükseklik   |
| `showHandle` | bool         | true       | Handle bar gösterimi |

### CustomBottomSheetItem

```dart
CustomBottomSheetItem({
  required String title,
  required IconData icon,
  Color? iconColor,
  VoidCallback? onTap,
  bool isDestructive = false,
  String? subtitle,
})
```

## 💬 ChatListItem

### Açıklama

Sohbet listesinde kullanılan öğe widget'ı. Avatar, başlık ve son mesaj bilgilerini gösterir.

### Özellikler

-   ✅ Avatar (gradient fallback)
-   ✅ Sohbet başlığı
-   ✅ Son mesaj
-   ✅ Zaman bilgisi
-   ✅ Okunmamış mesaj sayısı

### Kullanım

```dart
ChatListItem(
  chat: chat,
  onTap: () => Navigator.pushNamed(context, '/chat', arguments: chat),
  onLongPress: () => showChatOptions(context, chat),
)
```

### Parametreler

| Parametre     | Tip          | Varsayılan | Açıklama            |
| ------------- | ------------ | ---------- | ------------------- |
| `chat`        | Chat         | -          | Sohbet verisi       |
| `onTap`       | VoidCallback | -          | Tap callback        |
| `onLongPress` | VoidCallback | -          | Long press callback |

### Avatar Sistemi

-   **Network Image**: Eğer `avatarUrl` varsa
-   **Gradient Fallback**: İlk harf ile gradient
-   **Error Handling**: Hata durumunda fallback

## 💭 MessageBubble

### Açıklama

Sohbet sayfasında mesajları gösteren balon widget'ı. Kullanıcı ve AI mesajları için farklı stiller.

### Özellikler

-   ✅ Kullanıcı/AI mesaj ayrımı
-   ✅ Gradient arka plan (kullanıcı)
-   ✅ Border arka plan (AI)
-   ✅ Zaman gösterimi
-   ✅ Durum ikonları

### Kullanım

```dart
MessageBubble(
  message: message,
  showTime: true,
)
```

### Parametreler

| Parametre  | Tip         | Varsayılan | Açıklama        |
| ---------- | ----------- | ---------- | --------------- |
| `message`  | ChatMessage | -          | Mesaj verisi    |
| `showTime` | bool        | false      | Zaman gösterimi |

### Mesaj Tipleri

-   **User Message**: Sağda, gradient arka plan
-   **AI Message**: Solda, border arka plan
-   **Status Icons**: Gönderim durumu

## ⌨️ ChatInput

### Açıklama

Sohbet sayfasında mesaj girişi için kullanılan widget. Send button ve animasyonlar içerir.

### Özellikler

-   ✅ Text input
-   ✅ Send button
-   ✅ Animasyonlu button
-   ✅ Custom styling
-   ✅ Focus management

### Kullanım

```dart
ChatInput(
  controller: textController,
  onSend: () => sendMessage(),
)
```

### Parametreler

| Parametre    | Tip                   | Varsayılan | Açıklama        |
| ------------ | --------------------- | ---------- | --------------- |
| `controller` | TextEditingController | -          | Text controller |
| `onSend`     | VoidCallback          | -          | Send callback   |

### Button Animasyonu

-   **Icon Change**: Mic → Send (text varsa)
-   **Gradient Change**: Secondary → Primary
-   **Scale Animation**: Press effect

## 🎯 Widget Best Practices

### 1. Responsive Design

```dart
// MediaQuery kullanımı
final screenWidth = MediaQuery.of(context).size.width;
final isTablet = screenWidth > 600;
```

### 2. Theme Integration

```dart
// AppTheme kullanımı
decoration: BoxDecoration(
  gradient: AppTheme.primaryGradient,
  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
)
```

### 3. Animation Performance

```dart
// AnimatedBuilder kullanımı
AnimatedBuilder(
  animation: _animationController,
  builder: (context, child) {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: child,
    );
  },
)
```

### 4. Error Handling

```dart
// Error widget'ları
errorBuilder: (context, error, stackTrace) {
  return _buildFallbackWidget();
}
```

## 🔧 Custom Widget Geliştirme

### Yeni Widget Oluşturma

1. **Widget Sınıfı**: StatefulWidget veya StatelessWidget
2. **Animasyonlar**: AnimationController kullanımı
3. **Theme Integration**: AppTheme kullanımı
4. **Documentation**: Kapsamlı dokümantasyon
5. **Testing**: Widget testleri

### Widget Template

```dart
class CustomWidget extends StatefulWidget {
  const CustomWidget({
    super.key,
    required this.parameter,
  });

  final String parameter;

  @override
  State<CustomWidget> createState() => _CustomWidgetState();
}

class _CustomWidgetState extends State<CustomWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          // Widget implementation
        );
      },
    );
  }
}
```

---

Bu dokümantasyon projedeki tüm custom widget'ların kullanımını ve geliştirilmesini kapsar.
