# Health Tracking App - Developer Guide

## 🛠️ Development Environment Setup

### Prerequisites Installation

#### 1. Flutter Development Environment
```bash
# Install Flutter SDK
# Download from: https://flutter.dev/docs/get-started/install

# Verify installation
flutter doctor

# Expected output should show:
# ✓ Flutter (Channel stable, 3.8.1+)
# ✓ Android toolchain - develop for Android devices
# ✓ Chrome - develop for the web
# ✓ Visual Studio - develop for Windows
# ✓ Android Studio
# ✓ VS Code
```

#### 2. Python Backend Environment
```bash
# Install Python 3.13+
# Download from: https://python.org/downloads/

# Install Poetry (Package Manager)
curl -sSL https://install.python-poetry.org | python3 -
# Or on Windows:
# (Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | python -

# Verify Poetry installation
poetry --version
```

#### 3. Database Setup
```bash
# PostgreSQL (for production backend)
# Download from: https://postgresql.org/download/

# SQLite (automatically included with Flutter)
# No additional installation required
```

### Project Setup

#### 1. Clone Repository
```bash
git clone https://github.com/Navaphon001/Health-Tracking.git
cd Health-Tracking
```

#### 2. Backend Setup
```bash
cd Backend/fastapi_backend

# Install dependencies
poetry install

# Activate virtual environment
poetry shell

# Create environment file
cp .env.example .env

# Edit .env file with your database credentials
nano .env
```

#### 3. Frontend Setup
```bash
cd my_app

# Install Flutter dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# Check for any issues
flutter doctor
```

## 🔧 Development Workflow

### Daily Development Process

#### 1. Start Development Session
```bash
# Terminal 1: Start Backend Server
cd Backend/fastapi_backend
poetry shell
uvicorn src.fastapi_backend.main:app --reload --port 8000

# Terminal 2: Start Flutter App
cd my_app
flutter run
```

#### 2. Development Tools
```bash
# Flutter Inspector (for UI debugging)
flutter run --dart-define=flutter.inspector.structuredErrors=true

# Hot Reload (automatically enabled in debug mode)
# Press 'r' in terminal to hot reload
# Press 'R' in terminal to hot restart

# Flutter DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Code Organization Best Practices

#### 1. File Naming Conventions
```
lib/
├── screens/           # UI screens (snake_case)
│   ├── login_screen.dart
│   ├── dashboard_page.dart
│   └── settings_page.dart
├── models/            # Data models (snake_case)
│   ├── water_day.dart
│   ├── exercise_activity.dart
│   └── sleep_log.dart
├── providers/         # State management (snake_case + _provider suffix)
│   ├── water_provider.dart
│   ├── auth_notifier.dart
│   └── theme_provider.dart
├── services/          # Business logic (snake_case + _service suffix)
│   ├── app_db.dart
│   └── habit_local_repository.dart
└── shared/            # Utilities and constants
    ├── app_keys.dart
    └── date_key.dart
```

#### 2. Class Naming Conventions
```dart
// Screens: [Name]Screen or [Name]Page
class LoginScreen extends StatefulWidget {}
class DashboardPage extends StatelessWidget {}

// Models: Descriptive nouns
class WaterDay {}
class ExerciseActivity {}

// Providers: [Name]Provider or [Name]Notifier
class WaterProvider extends ChangeNotifier {}
class AuthNotifier extends ChangeNotifier {}

// Services: [Name]Service or [Name]Repository
class HabitLocalRepository {}
class ApiService {}
```

#### 3. Code Structure Template

**Screen Template:**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  // 1. Controllers and variables
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _controller;

  // 2. Lifecycle methods
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 3. Event handlers
  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Handle form submission
    }
  }

  // 4. Helper methods
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Form fields
        ],
      ),
    );
  }

  // 5. Build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example Screen'),
      ),
      body: Consumer<ExampleProvider>(
        builder: (context, provider, child) {
          return _buildForm();
        },
      ),
    );
  }
}
```

**Provider Template:**
```dart
import 'package:flutter/foundation.dart';

class ExampleProvider with ChangeNotifier {
  // Private variables
  bool _isLoading = false;
  String? _error;
  List<ExampleModel> _items = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ExampleModel> get items => List.unmodifiable(_items);

  // Methods
  Future<void> loadData() async {
    _setLoading(true);
    _clearError();

    try {
      final data = await _repository.fetchData();
      _items = data;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
```

## 🗄️ Database Development

### Local Database (SQLite) Development

#### 1. Database Schema Changes
```dart
// Update database version in app_db.dart
class AppDb {
  Future<Database> _open() async {
    return openDatabase(
      dbPath,
      version: 3, // Increment version number
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // Add migration logic
          await db.execute('''
            ALTER TABLE water_intake_logs 
            ADD COLUMN new_column TEXT DEFAULT '';
          ''');
        }
      },
    );
  }
}
```

#### 2. Testing Database Changes
```bash
# Clear app data to test fresh installation
flutter run
# Then stop app and clear data:
flutter clean
flutter pub get
flutter run
```

#### 3. Database Debugging
```dart
// Add debug queries in development
if (kDebugMode) {
  final db = await AppDb.instance.database;
  
  // List all tables
  final tables = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table'"
  );
  debugPrint('Tables: $tables');
  
  // Check table schema
  final schema = await db.rawQuery('PRAGMA table_info(water_intake_logs)');
  debugPrint('Schema: $schema');
  
  // Sample data check
  final data = await db.query('water_intake_logs', limit: 5);
  debugPrint('Sample data: $data');
}
```

### Backend Database (PostgreSQL) Development

#### 1. Database Connection Setup
```python
# In fastapi_backend/src/database.py
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os

DATABASE_URL = os.getenv(
    "DATABASE_URL", 
    "postgresql://user:password@localhost/healthtracking"
)

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
```

#### 2. Database Models
```python
# In fastapi_backend/src/models.py
from sqlalchemy import Column, Integer, String, DateTime, Float
from .database import Base

class WaterIntake(Base):
    __tablename__ = "water_intake"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    date = Column(String, index=True)
    count = Column(Integer, default=0)
    ml = Column(Integer, default=0)
    created_at = Column(DateTime)
    updated_at = Column(DateTime)
```

## 🧪 Testing Development

### Unit Testing Setup

#### 1. Flutter Unit Tests
```dart
// test/unit/providers/water_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/providers/water_provider.dart';

void main() {
  group('WaterProvider Tests', () {
    late WaterProvider provider;

    setUp(() {
      provider = WaterProvider();
    });

    test('initial water amount should be 0', () {
      expect(provider.water, 0);
    });

    test('setWater should update water amount', () {
      provider.setWater(5);
      expect(provider.water, 5);
    });
  });
}
```

#### 2. Widget Testing
```dart
// test/widget/screens/water_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_app/screens/water_screen.dart';
import 'package:my_app/providers/water_provider.dart';

void main() {
  testWidgets('WaterScreen displays current water amount', (tester) async {
    final provider = WaterProvider();
    provider.setWater(3);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<WaterProvider>.value(
          value: provider,
          child: const WaterScreen(),
        ),
      ),
    );

    expect(find.text('3'), findsOneWidget);
  });
}
```

#### 3. Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/providers/water_provider_test.dart

# Run tests with coverage
flutter test --coverage
```

### Backend Testing

#### 1. FastAPI Test Setup
```python
# tests/test_main.py
from fastapi.testclient import TestClient
from src.fastapi_backend.main import app

client = TestClient(app)

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello FastAPI + PostgreSQL + Poetry!"}
```

#### 2. Running Backend Tests
```bash
cd Backend/fastapi_backend
poetry run pytest tests/ -v
```

## 🚀 Build and Deployment

### Development Builds

#### 1. Debug Builds
```bash
# Android Debug APK
flutter build apk --debug

# iOS Debug Build
flutter build ios --debug --no-codesign
```

#### 2. Profile Builds (Performance Testing)
```bash
# Android Profile APK
flutter build apk --profile

# Run in profile mode
flutter run --profile
```

### Production Builds

#### 1. Android Release
```bash
# Generate keystore (first time only)
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Build App Bundle (recommended)
flutter build appbundle --release

# Build APK
flutter build apk --release --split-per-abi
```

#### 2. iOS Release
```bash
# Build for iOS
flutter build ios --release

# Archive in Xcode
open ios/Runner.xcworkspace
# Product -> Archive in Xcode
```

#### 3. Web Release
```bash
flutter build web --release
```

### Backend Deployment

#### 1. Docker Deployment
```dockerfile
# Dockerfile
FROM python:3.13-slim

WORKDIR /app
COPY poetry.lock pyproject.toml ./
RUN pip install poetry && poetry install --no-dev

COPY src/ ./src/
EXPOSE 8000

CMD ["poetry", "run", "uvicorn", "src.fastapi_backend.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

```bash
# Build and run Docker container
docker build -t health-tracking-api .
docker run -p 8000:8000 -e DATABASE_URL="postgresql://..." health-tracking-api
```

## 🐛 Debugging Guide

### Common Flutter Issues

#### 1. Hot Reload Not Working
```bash
# Try hot restart instead
flutter run
# Press 'R' in terminal

# If still not working, clean and rebuild
flutter clean
flutter pub get
flutter run
```

#### 2. Package Version Conflicts
```bash
# Update dependencies
flutter pub upgrade

# If conflicts persist, delete pubspec.lock and reinstall
rm pubspec.lock
flutter pub get
```

#### 3. SQLite Database Issues
```dart
// Clear database for testing
final db = await AppDb.instance.database;
await db.execute('DROP TABLE IF EXISTS water_intake_logs');
// Restart app to recreate tables
```

### Debugging Tools

#### 1. Flutter Inspector
```bash
# Run with inspector enabled
flutter run --debug
# Then open DevTools in browser
```

#### 2. Performance Profiling
```bash
# Run in profile mode
flutter run --profile

# Use Flutter DevTools for performance analysis
flutter pub global run devtools
```

#### 3. Network Debugging
```dart
// Add logging interceptor for HTTP requests
import 'package:http/http.dart' as http;

class LoggingClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    print('Request: ${request.method} ${request.url}');
    final response = await _inner.send(request);
    print('Response: ${response.statusCode}');
    return response;
  }
}
```

## 📚 Resources and Documentation

### Official Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [SQLite Documentation](https://sqlite.org/docs.html)

### Useful Packages
- [Provider Package](https://pub.dev/packages/provider) - State Management
- [SQLite Package](https://pub.dev/packages/sqflite) - Local Database
- [SharedPreferences](https://pub.dev/packages/shared_preferences) - Key-Value Storage
- [Table Calendar](https://pub.dev/packages/table_calendar) - Calendar Widget

### Development Tools
- [Flutter DevTools](https://flutter.dev/docs/development/tools/devtools/overview)
- [Android Studio](https://developer.android.com/studio) - IDE
- [VS Code](https://code.visualstudio.com/) - Editor
- [Postman](https://postman.com) - API Testing

---

*Developer Guide v1.0*  
*Last Updated: September 18, 2025*