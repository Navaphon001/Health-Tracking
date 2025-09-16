import 'package:flutter/foundation.dart';

class DateProvider with ChangeNotifier {
  DateTime _date = DateTime.now();
  String _formattedMonthYear = '';

  DateProvider() {
    _updateFormattedMonthYear(); // เรียกตอนสร้าง
  }

  DateTime get date => _date;
  String get formattedMonthYear => _formattedMonthYear;

  void setDate(DateTime newDate) {
    _date = newDate;
    _updateFormattedMonthYear(); // อัปเดต string เมื่อเปลี่ยนวันที่
    notifyListeners();
  }

  void _updateFormattedMonthYear() {
    const months = [
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม',
    ];
    _formattedMonthYear = '${months[_date.month - 1]} ${_date.year}';
  }
}
