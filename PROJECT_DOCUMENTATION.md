# Health Tracking App - Project Documentation

## 📋 Project Overview

**Project Name:** Health Tracking App  
**Type:** Flutter Mobile Application with FastAPI Backend  
**Author:** Punyaphat Kaewkao (punyaphat0010@gmail.com)  
**Course:** 240-331 Mobile App Development  
**Institution:** PSU (Prince of Songkla University)  
**Academic Year:** 2025 (4/1)

## 🎯 Project Description

Health Tracking App เป็นแอปพลิเคชันมือถือสำหรับติดตามสุขภาพประจำวัน พัฒนาด้วย Flutter framework เพื่อรองรับการใช้งานข้าม platform (iOS/Android) โดยมีระบบ backend API พัฒนาด้วย FastAPI

### Key Features
- 💧 **Water Intake Tracking** - ติดตามการดื่มน้ำประจำวัน
- 🏃‍♂️ **Exercise Logging** - บันทึกกิจกรรมการออกกำลังกาย
- 😴 **Sleep Monitoring** - ติดตามคุณภาพและระยะเวลาการนอน
- 📊 **Daily Summary** - สรุปข้อมูลสุขภาพรายวัน
- 🌐 **Multi-language Support** - รองรับหลายภาษา (Thai/English)
- 🎨 **Theme Customization** - ปรับแต่งธีมแสงและมืด
- 👤 **Profile Management** - จัดการข้อมูลส่วนตัว
- 📅 **Calendar Integration** - ปฏิทินสำหรับติดตามข้อมูล

## 🏗️ Project Architecture

### Directory Structure

```
Health-Tracking/
├── Backend/                    # FastAPI Backend Service
│   └── fastapi_backend/
│       ├── src/fastapi_backend/
│       │   ├── main.py        # FastAPI application entry point
│       │   └── __init__.py
│       ├── tests/             # Backend unit tests
│       ├── pyproject.toml     # Python dependencies & project config
│       ├── poetry.lock        # Locked dependencies
│       └── README.md
│
└── my_app/                     # Flutter Mobile Application
    ├── lib/                    # Main source code
    │   ├── main.dart          # Flutter app entry point
    │   ├── models/            # Data models
    │   ├── providers/         # State management (Provider pattern)
    │   ├── screens/           # UI screens/pages
    │   ├── services/          # Business logic & data services
    │   ├── shared/            # Shared utilities
    │   ├── theme/             # App theming
    │   └── l10n/              # Internationalization
    ├── android/               # Android-specific code
    ├── ios/                   # iOS-specific code
    ├── web/                   # Web support files
    ├── windows/               # Windows desktop support
    ├── linux/                 # Linux desktop support
    ├── macos/                 # macOS desktop support
    ├── test/                  # Flutter unit tests
    ├── pubspec.yaml          # Flutter dependencies & project config
    └── README.md
```

## 🛠️ Technology Stack

### Backend (FastAPI)
- **Framework:** FastAPI 0.116.1
- **Web Server:** Uvicorn (ASGI server)
- **Database:** PostgreSQL with SQLAlchemy ORM
- **Database Driver:** psycopg2-binary
- **Package Manager:** Poetry
- **Python Version:** ≥3.13

### Frontend (Flutter)
- **Framework:** Flutter (Dart SDK ^3.8.1)
- **State Management:** Provider Pattern
- **Local Database:** SQLite (sqflite)
- **Local Storage:** SharedPreferences
- **UI Calendar:** table_calendar
- **Internationalization:** flutter_localizations + intl
- **File System:** path_provider

### Key Dependencies

#### Flutter Dependencies
```yaml
dependencies:
  flutter: sdk
  flutter_localizations: sdk
  cupertino_icons: ^1.0.8
  provider: ^6.1.5+1          # State management
  shared_preferences: ^2.3.2   # Local key-value storage
  sqflite: ^2.3.0             # SQLite database
  path_provider: ^2.1.3        # File system paths
  path: ^1.9.0                 # Path manipulation
  intl: ^0.20.2                # Internationalization
  table_calendar: ^3.2.0       # Calendar widget
```

#### Backend Dependencies
```toml
[project.dependencies]
fastapi = ">=0.116.1,<0.117.0"
uvicorn[standard] = ">=0.35.0,<0.36.0"
psycopg2-binary = ">=2.9.10,<3.0.0"
sqlalchemy = ">=2.0.43,<3.0.0"
```

## 📱 Application Features & Implementation

### 1. State Management Architecture
แอปใช้ **Provider Pattern** สำหรับจัดการ state โดยมี providers หลักดังนี้:

- **AuthNotifier** - จัดการ authentication state
- **HabitNotifier** - จัดการข้อมูลนิสัยสุขภาพ
- **WaterProvider** - จัดการข้อมูลการดื่มน้ำ
- **ExerciseProvider** - จัดการข้อมูลการออกกำลังกาย  
- **MoodProvider** - จัดการข้อมูลอารมณ์
- **ThemeProvider** - จัดการธีมแอป
- **LanguageProvider** - จัดการการเปลี่ยนภาษา
- **DateProvider** - จัดการวันที่สำหรับติดตาม

### 2. Data Models
```dart
// Water tracking model
class WaterDay {
  final String date;  // yyyy-MM-dd format
  int count;          // Number of glasses consumed
  int goal;           // Daily goal (default: 8 glasses)
}

// Exercise tracking model  
class ExerciseActivity {
  String name;        // Exercise name
  int duration;       // Duration in minutes
  double? caloriesBurned;
}

// Sleep tracking model
class SleepLog {
  DateTime date;
  int hours;          // Sleep hours
  int minutes;        // Sleep minutes
  int? quality;       // Sleep quality rating
  String? note;       // Optional notes
}
```

### 3. Local Database Schema (SQLite)

#### Sleep Daily Table
```sql
CREATE TABLE sleep_daily (
  date_key   TEXT PRIMARY KEY,      -- yyyy-MM-dd
  hours      INTEGER NOT NULL DEFAULT 0 CHECK(hours BETWEEN 0 AND 24),
  minutes    INTEGER NOT NULL DEFAULT 0 CHECK(minutes BETWEEN 0 AND 59), 
  quality    INTEGER,               -- Sleep quality rating
  note       TEXT,                  -- Optional notes
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
```

#### Water Intake Logs Table
```sql
CREATE TABLE water_intake_logs (
  date_key   TEXT PRIMARY KEY,      -- yyyy-MM-dd
  count      INTEGER NOT NULL DEFAULT 0,  -- Number of glasses
  ml         INTEGER NOT NULL DEFAULT 0,  -- Total milliliters
  goal_count INTEGER,               -- Daily goal (glasses)
  goal_ml    INTEGER,               -- Daily goal (ml)
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
```

#### Exercise Daily Table
```sql
CREATE TABLE exercise_daily (
  date_key        TEXT PRIMARY KEY,  -- yyyy-MM-dd
  duration_min    INTEGER NOT NULL DEFAULT 0,
  calories_burned REAL,
  notes           TEXT,
  created_at      INTEGER NOT NULL,
  updated_at      INTEGER NOT NULL
);
```

### 4. Navigation & Routing
แอปใช้ Named Routes สำหรับการนำทาง:

```dart
routes: {
  '/login': (_) => const LoginScreen(),
  '/register': (_) => const RegisterScreen(),
  '/main': (_) => const MainNavigationScreen(),
  '/water': (_) => const WaterScreen(),
  '/exercise': (_) => const ExerciseScreen(),
  '/sleep': (_) => const SleepScreen(),
  '/onboarding': (_) => const OnboardingMain(),
  '/dashboard': (_) => const DashboardPage(),
  '/settings': (_) => const SettingsPage(),
  '/profile-setup': (_) => const ProfileSetupStep1(),
  '/profile-setup-step2': (_) => const ProfileSetupStep2(),
  '/profile-setup-step3': (_) => const ProfileSetupStep3(),
}
```

### 5. Internationalization (i18n)
- รองรับภาษาไทยและอังกฤษ
- ใช้ `flutter_localizations` และ `intl` package
- ไฟล์ localization อยู่ใน `lib/l10n/`
- การตั้งค่า: `generate: true` ใน `pubspec.yaml`

### 6. Database Service Layer

#### HabitLocalRepository
เป็น main repository class ที่จัดการการเชื่อมต่อกับฐานข้อมูลทั้ง SQLite และ SharedPreferences:

**Key Methods:**
- `getWaterDaily(DateTime day)` - ดึงข้อมูลการดื่มน้ำรายวัน
- `upsertWater()` - เพิ่ม/อัปเดตข้อมูลการดื่มน้ำ
- `getSleepDaily(DateTime day)` - ดึงข้อมูลการนอนรายวัน
- `setSleepHM()` - บันทึกข้อมูลการนอน
- `addExerciseMinutes()` - เพิ่มนาทีการออกกำลังกาย
- `dailySummary()` - สรุปข้อมูลสุขภาพรายวัน

## 🔧 Development Setup

### Prerequisites
- Flutter SDK (≥3.8.1)
- Dart SDK
- Python (≥3.13)
- Poetry (Python package manager)
- PostgreSQL (for backend)
- Android Studio / VS Code
- Android SDK / Xcode (for mobile development)

### Backend Setup
```bash
cd Backend/fastapi_backend

# Install dependencies using Poetry
poetry install

# Activate virtual environment
poetry shell

# Run FastAPI server
poetry run uvicorn src.fastapi_backend.main:app --reload
```

### Frontend Setup
```bash
cd my_app

# Get Flutter dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# Run on emulator/device
flutter run

# Run on specific platform
flutter run -d chrome    # Web
flutter run -d windows   # Windows desktop
```

### Database Setup
The SQLite database is automatically initialized on first app launch. The database file `habit_daily.db` is created in the app's documents directory.

## 🧪 Testing Strategy

### Backend Testing
- Unit tests location: `Backend/fastapi_backend/tests/`
- Run tests: `poetry run pytest`

### Frontend Testing  
- Widget tests location: `my_app/test/`
- Run tests: `flutter test`

### Debug Features
แอปมี debug mode ที่รัน smoke test เมื่อเริ่มแอป:
```dart
Future<void> _devSmokeTest() async {
  // Test water logging
  await repo.upsertWater(day: today, deltaCount: 1, deltaMl: 250);
  
  // Test sleep logging  
  await repo.setSleepHM(day: today, hours: 7, minutes: 30);
  
  // Test exercise logging
  await repo.addExerciseMinutes(day: today, deltaMinutes: 2);
  
  // Test daily summary
  final sum = await repo.dailySummary(today);
}
```

## 📈 Performance Considerations

### Database Optimization
- ใช้ Primary Key เป็น `date_key` รูปแบบ yyyy-MM-dd
- PRAGMA foreign_keys = ON สำหรับ referential integrity
- Database migration support ผ่าน `onUpgrade`

### State Management
- ใช้ `ChangeNotifier` เพื่อ efficient UI updates
- Lazy loading ของ providers
- Local caching ด้วย SharedPreferences

### UI Performance
- Material Design 3 theming
- Support สำหรับ Dark/Light themes
- Responsive design สำหรับหลาย screen sizes

## 🚀 Deployment

### Mobile App Deployment
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

### Backend Deployment
```bash
# Using Docker (recommended)
docker build -t health-tracking-api .
docker run -p 8000:8000 health-tracking-api

# Or direct deployment
poetry run uvicorn src.fastapi_backend.main:app --host 0.0.0.0 --port 8000
```

## 🤝 Contributing Guidelines

### Code Style
- Flutter: Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Python: Follow PEP 8 standards
- Use meaningful variable and function names
- Add comments for complex business logic

### Git Workflow
- Main branch: `main`
- Feature branches: `feature/feature-name`
- Bug fixes: `bugfix/issue-description`

### Pull Request Process
1. Create feature branch from main
2. Implement changes with tests
3. Update documentation if needed
4. Submit PR with clear description

## 📞 Support & Contact

**Developer:** Punyaphat Kaewkao  
**Email:** punyaphat0010@gmail.com  
**Course:** 240-331 Mobile App Development  
**Institution:** Prince of Songkla University

## 📄 License

This project is developed for educational purposes as part of PSU Mobile App Development course.

## 🔄 Version History

- **v1.0.0** - Initial release with core health tracking features
- **Database v2** - Enhanced schema with exercise daily tracking

---

*Last Updated: September 18, 2025*
*Document Version: 1.0*