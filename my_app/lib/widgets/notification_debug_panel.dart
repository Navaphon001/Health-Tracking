// lib/widgets/notification_debug_panel.dart
import 'package:flutter/material.dart';
import '../services/local_notification_service.dart';

class NotificationDebugPanel extends StatelessWidget {
  const NotificationDebugPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔧 Notification Debug', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () async {
                    await LocalNotificationService.instance.debugDoctor();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('เปิด Logcat ดูผลตรวจสุขภาพ NotifDoctor')),
                    );
                  },
                  child: const Text('ตรวจสุขภาพ'),
                ),
                OutlinedButton(
                  onPressed: () => LocalNotificationService.instance.debugPing(),
                  child: const Text('เด้งทันที'),
                ),
                OutlinedButton(
                  onPressed: () => LocalNotificationService.instance.scheduleTestIn10s(),
                  child: const Text('เด้งใน 10 วิ'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'ถ้าไม่เด้ง: 1) อนุญาต Notifications, 2) อนุญาต Alarms & reminders, 3) ปิด DND ชั่วคราว',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
