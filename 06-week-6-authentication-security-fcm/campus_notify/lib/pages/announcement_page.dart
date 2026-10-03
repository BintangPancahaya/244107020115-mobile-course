import 'package:flutter/material.dart';
import '../data/announcements.dart';
import '../routes.dart';

/// Halaman tujuan deep link /pengumuman/:id (dibuka dari klik notifikasi).
class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final a = findAnnouncement(id);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Pengumuman #$id')),
      body: a == null
          ? const Center(child: Text('Pengumuman tidak ditemukan.'))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(a.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.event, size: 18),
                  const SizedBox(width: 6),
                  Text(a.date),
                ]),
                const Divider(height: 32),
                Text(a.body, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 24),
                Card(
                  color: theme.colorScheme.secondaryContainer,
                  child: ListTile(
                    leading: const Icon(Icons.link),
                    title: const Text('Dibuka dari deep link'),
                    subtitle: Text(
                        'Rute ${announcementRoute(id)} dari data.route payload FCM'),
                  ),
                ),
              ],
            ),
    );
  }
}
