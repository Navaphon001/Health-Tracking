# Personal Wellness Tracker (Flutter)

ภาพรวมโปรเจค: แอปพลิเคชันติดตามสุขภาพและความเป็นอยู่ที่ดีแบบองค์รวม ช่วยให้ผู้ใช้จัดการและติดตามนิสัยเพื่อสุขภาพในชีวิตประจำวัน (ออกกำลังกาย น้ำ การนอน อารมณ์ อาหาร ฯลฯ) พร้อมระบบเป้าหมาย สถิติ และการแจ้งเตือนอัจฉริยะ

## คุณสมบัติหลัก (Core Features)
- การลงทะเบียนและโปรไฟล์สุขภาพ: Firebase Auth, ตั้งค่าโปรไฟล์เริ่มต้น (อายุ เพศ น้ำหนัก ส่วนสูง เป้าหมาย), การประเมินสุขภาพเบื้องต้น, การตั้งค่าการแจ้งเตือนส่วนบุคคล
- การติดตามนิสัยประจำวัน: ออกกำลังกาย (ประเภท ระยะเวลา แคลอรี่), ดื่มน้ำ, การนอน (เวลานอน-ตื่น คุณภาพการนอน), อารมณ์, กิจกรรมส่วนตัว (อ่านหนังสือ ทำสมาธิ)
- บันทึกอาหาร (Meal Logging): บันทึกมื้ออาหาร (เช้า กลางวัน เย็น ของว่าง), ถ่ายรูปอาหาร/คำอธิบาย, ค้นหาข้อมูลโภชนาการจาก API, คำนวณแคลอรี่และสารอาหาร
- การแสดงผลความก้าวหน้า: กราฟ/ชาร์ตแนวโน้ม (รายวัน รายสัปดาห์ รายเดือน), สถิติการบรรลุเป้าหมาย, รายงานสุขภาพ
- ระบบเป้าหมายและความสำเร็จ: เป้าหมายระยะสั้น/ยาว, badges/achievements, streak, การให้รางวัลตัวเอง
- การแจ้งเตือนอัจฉริยะ: เตือนดื่มน้ำ ออกกำลังกาย เวลานอน สรุปกิจกรรมประจำวัน
- การแชร์และส่งออกข้อมูล: ส่งออก PDF/CSV, แชร์สังคมออนไลน์, รายงานเพื่อแพทย์
- ออฟไลน์และซิงค์: ใช้งานออฟไลน์ + ซิงค์กับ Cloud เมื่อออนไลน์

## สถาปัตยกรรมและเทคโนโลยีที่ใช้
- Frontend: Flutter/Dart
- State Management: `provider` (เริ่มต้น) หรือ Riverpod/Bloc ในอนาคต
- Offline Local Database: `sqflite` (SQLite)
- Cloud Backend/API: FastAPI + PostgreSQL (ซิงค์ข้อมูลออนไลน์)
  - Data Validation & Schemas: Pydantic
  - API Document: Swagger (OpenAPI)
  - CSV Export: Pandas
  - PDF Export: WeasyPrint + Jinja2
- Firebase: Auth, Firestore (ผู้ใช้และเมตาดาต้า), Storage (รูปภาพ), Cloud Messaging (FCM) สำหรับ Notifications
- Notifications: `flutter_local_notifications` + FCM
- Charts: `fl_chart`
- Camera: `camera`
- Nutrition API: mock API/Edamam/FoodData Central (เริ่มด้วย mockapi เพื่อพัฒนา UI)

หมายเหตุสั้น ๆ ของแอปเวอร์ชันเริ่มต้นใน repo นี้:
- มี Splash + Onboarding (3 หน้า) พร้อมบันทึกสถานะการจบ onboarding ด้วย `shared_preferences` และโครงสร้าง routes พื้นฐาน (Login/Register/Dashboard placeholder)
- มีโมเดลตัวอย่าง `UserProfile`, `Habit`, `MealEntry` เพื่อใช้ต่อยอด

## แผนการส่งงาน (12 Sessions)
1) Project Setup & Dart Basics
	- โครงสร้างโปรเจค Flutter, Splash/Onboarding (3–4 หน้า), โค้ด Dart พื้นฐาน, Wireframe/UI mockups
2–3) Authentication & Basic Widgets
	- Login/Register (Firebase Auth), โปรไฟล์สุขภาพเริ่มต้น, หน้าหลัก Dashboard, Basic Widgets
4–5) Layout & Advanced Widgets
	- หน้าบันทึกกิจกรรม (habit tracking), หน้าบันทึกอาหารพร้อมถ่ายรูป, Responsive, Advanced Widgets (DatePicker/TimePicker/Slider)
6–7) State Management
	- Provider/Riverpod/Bloc, เพิ่ม/แก้ไข/ลบกิจกรรม, จัดการข้อมูลผู้ใช้/ตั้งค่า, Form validation & error handling
8–9) API Integration & Navigation
	- เชื่อม Firestore, Nutrition API, Navigation (Named Routes/Drawer), จัดการ API calls & loading states
10–11) Storage, Firebase & Notifications
	- Local Storage (SQLite), FCM reminders, Firebase Storage รูปภาพ, Sync online/offline
12) Best Practices & Final Delivery
	- Charts/สถิติ, Goals/Achievements, Export PDF/CSV, Refactor/Optimization, Docs/Comments, Presentation & Demo

## การติดตั้งและรัน (Windows PowerShell)
รันคำสั่งต่อไปนี้จากโฟลเดอร์โปรเจค `my_app`:

```powershell
flutter pub get
flutter run
```

ถ้าเจอปัญหา dependency ของแพ็กเกจที่เพิ่มไว้ (เช่น `shared_preferences`) ให้ตรวจสอบว่าได้รัน `flutter pub get` แล้ว และอุปกรณ์ทดสอบ (emulator/โทรศัพท์จริง) หรือ Chrome พร้อมใช้งาน

## โครงสร้างโค้ด (บางส่วน)
- `lib/main.dart` – กำหนดธีม/เส้นทาง (routes), Splash, Onboarding, Login/Register/Dashboard (placeholder)
- `lib/models.dart` – โมเดลเบื้องต้น (UserProfile, Habit, MealEntry)

## งานถัดไป (Next Steps)
- ผูก Firebase Auth จริง, หน้าตั้งค่าโปรไฟล์สุขภาพ
- วางโครงสร้าง SQLite + FastAPI sync (schema/Pydantic, endpoints, Swagger)
- เตรียม mock data โภชนาการ/กิจกรรม เพื่อทดสอบ UI
- วางระบบ Provider สำหรับ state ทั้งแอป
