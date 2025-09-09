import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ChatAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text(
        'Sohbetler',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO: Arama özelliği eklenecek
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'new_group':
                // TODO: Yeni grup oluşturma
                break;
              case 'new_broadcast':
                // TODO: Yeni yayın oluşturma
                break;
              case 'settings':
                Navigator.pushNamed(context, '/settings');
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'new_group',
              child: Row(
                children: [
                  Icon(Icons.group_add),
                  SizedBox(width: 8),
                  Text('Yeni Grup'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'new_broadcast',
              child: Row(
                children: [
                  Icon(Icons.broadcast_on_personal),
                  SizedBox(width: 8),
                  Text('Yeni Yayın'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Ayarlar'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
