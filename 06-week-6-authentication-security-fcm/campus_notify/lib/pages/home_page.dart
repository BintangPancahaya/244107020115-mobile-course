import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/announcements.dart';
import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(accessTokenProvider).value;
    final push = ref.watch(pushStatusProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman Kampus'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.bug_report_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text('Debug sesi & FCM', style: theme.textTheme.titleSmall),
                  ]),
                  const SizedBox(height: 8),
                  _DebugRow('Access token',
                      access == null ? '-' : shortToken(access)),
                  _DebugRow('Penyimpanan', 'flutter_secure_storage'),
                  _DebugRow('Topik', push.topic ?? topicPengumuman),
                  _DebugRow('FCM token',
                      push.token == null ? '-' : shortToken(push.token!)),
                  if (push.message != null) _DebugRow('Status FCM', push.message!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final a in announcements)
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(a.id)),
                title: Text(a.title),
                subtitle: Text(a.date),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(announcementRoute(a.id)),
              ),
            ),
        ],
      ),
    );
  }
}

class _DebugRow extends StatelessWidget {
  const _DebugRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 110,
              child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
          Expanded(
              child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
