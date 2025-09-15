// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'ตัวติดตามสุขภาพส่วนบุคคล';

  @override
  String get dashboard => 'แดชบอร์ด';

  @override
  String get settings => 'การตั้งค่า';

  @override
  String get account => 'บัญชี';

  @override
  String get language => 'ภาษา';

  @override
  String get notifications => 'การแจ้งเตือน';

  @override
  String get darkMode => 'โหมดมืด';

  @override
  String get signOut => 'ออกจากระบบ';

  @override
  String get light => 'สว่าง';

  @override
  String get dark => 'มืด';

  @override
  String get english => 'อังกฤษ';

  @override
  String get thai => 'ไทย';

  @override
  String get profile => 'โปรไฟล์';

  @override
  String stepOf(num current, num total) {
    return 'ขั้นตอน $current จาก $total';
  }

  @override
  String get addProfilePhoto => 'เพิ่มรูปโปรไฟล์';

  @override
  String get name => 'ชื่อ';

  @override
  String get nameHint => 'ชื่อของคุณ';

  @override
  String get dob => 'วันเดือนปีเกิด';

  @override
  String get dobHint => 'วว/ดด/ปปปป';

  @override
  String get gender => 'เพศ';

  @override
  String get male => 'ชาย';

  @override
  String get female => 'หญิง';

  @override
  String get other => 'อื่น ๆ';

  @override
  String get next => 'ถัดไป';

  @override
  String get openProfileSetup => 'เปิดหน้าตั้งค่าโปรไฟล์';

  @override
  String get physicalInfo => 'ข้อมูลร่างกาย';

  @override
  String get weight => 'น้ำหนัก';

  @override
  String get weightHint => 'กก.';

  @override
  String get height => 'ส่วนสูง';

  @override
  String get heightHint => 'ซม.';

  @override
  String get activityLevel => 'ระดับกิจกรรม';

  @override
  String get sedentary => 'นั่งทำงาน: ออกกำลังกายน้อยหรือไม่เลย';

  @override
  String get lightlyActive => 'กิจกรรมเบา: ออกกำลังกายเบา 1-3 วัน/สัปดาห์';

  @override
  String get moderatelyActive =>
      'กิจกรรมปานกลาง: ออกกำลังกายปานกลาง 3-5 วัน/สัปดาห์';

  @override
  String get veryActive => 'กิจกรรมหนัก: ออกกำลังกายหนัก 6-7 วัน/สัปดาห์';

  @override
  String get openProfileSetupStep2 => 'เปิดหน้าตั้งค่าโปรไฟล์ขั้นตอนที่ 2';
}
