// lib/widgets/bedtime_setting_tile.dart
import 'package:flutter/material.dart';
import '../services/local_notification_service.dart';

class BedtimeSettingTile extends StatefulWidget {
  const BedtimeSettingTile({super.key});

  @override
  State<BedtimeSettingTile> createState() => _BedtimeSettingTileState();
}

class _BedtimeSettingTileState extends State<BedtimeSettingTile> {
  bool _enabled = true;
  TimeOfDay _tod = const TimeOfDay(hour: 22, minute: 0);
  int _windDown = 60; // เตือนล่วงหน้ากี่นาที
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await LocalNotificationService.instance.getBedtime();
    if (v != null) {
      _enabled = v.enabled;
      _tod = TimeOfDay(hour: v.hour, minute: v.minute);
      _windDown = v.windDown;
    }
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _save() async {
    if (_enabled) {
      await LocalNotificationService.instance.setBedtime(
        hour: _tod.hour,
        minute: _tod.minute,
        windDownMinutes: _windDown,
        enabled: true,
      );
    } else {
      await LocalNotificationService.instance.disableBedtimeReminder();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _tod,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _tod = picked);
      await _save();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกเวลาเข้านอนแล้ว')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const ListTile(
        title: Text('กำลังโหลด...'),
        trailing: SizedBox(
          width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final timeText =
        '${_tod.hour.toString().padLeft(2, '0')}:${_tod.minute.toString().padLeft(2, '0')} น.';

    return Column(
      children: [
        SwitchListTile(
          title: const Text('เตือนเตรียมเข้านอน'),
          subtitle: Text('เตือนล่วงหน้า $_windDown นาที'),
          value: _enabled,
          onChanged: (v) async {
            setState(() => _enabled = v);
            await _save();
          },
        ),
        ListTile(
          title: const Text('เวลาเข้านอนเป้าหมาย'),
          subtitle: Text(timeText),
          trailing: const Icon(Icons.chevron_right),
          onTap: _pickTime,
        ),
        ListTile(
          title: const Text('เตือนล่วงหน้า (นาที)'),
          subtitle: Text('$_windDown นาที'),
          trailing: DropdownButton<int>(
            value: _windDown,
            items: const [15, 30, 45, 60, 90, 120]
                .map((m) => DropdownMenuItem(value: m, child: Text('$m')))
                .toList(),
            onChanged: (m) async {
              if (m == null) return;
              setState(() => _windDown = m);
              await _save();
            },
          ),
        ),
      ],
    );
  }
}
