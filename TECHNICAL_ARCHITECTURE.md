# Health Tracking App - Technical Architecture Documentation

## 🏛️ System Architecture Overview

### Application Architecture Pattern
แอปพลิเคชันใช้ **Clean Architecture** ร่วมกับ **Provider Pattern** สำหรับ Flutter และ **Layered Architecture** สำหรับ FastAPI backend

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────────────────────────────────────────────────┤
│  │ Screens (UI) │ Providers (State Management)             │
│  └─────────────────────────────────────────────────────────┤
├─────────────────────────────────────────────────────────────┤
│                    Business Logic Layer                     │
│  ┌─────────────────────────────────────────────────────────┤
│  │ Services │ Repositories │ Models                        │
│  └─────────────────────────────────────────────────────────┤
├─────────────────────────────────────────────────────────────┤
│                      Data Layer                            │
│  ┌─────────────────────────────────────────────────────────┤
│  │ SQLite Database │ SharedPreferences │ FastAPI           │
│  └─────────────────────────────────────────────────────────┤
└─────────────────────────────────────────────────────────────┘
```

## 📊 Data Flow Architecture

### Frontend Data Flow (Flutter)
```
User Input → Screen → Provider → Repository → Database → Provider → Screen → UI Update
```

### State Management Flow
```
1. User Action (tap button)
2. Screen calls Provider method
3. Provider updates internal state
4. Provider calls Repository
5. Repository performs database operation
6. Repository returns result to Provider
7. Provider calls notifyListeners()
8. All watching widgets rebuild automatically
```

## 🗄️ Database Design

### Entity Relationship Diagram
```
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│   sleep_daily       │    │ water_intake_logs   │    │  exercise_daily     │
├─────────────────────┤    ├─────────────────────┤    ├─────────────────────┤
│ date_key (PK)       │    │ date_key (PK)       │    │ date_key (PK)       │
│ hours               │    │ count               │    │ duration_min        │
│ minutes             │    │ ml                  │    │ calories_burned     │
│ quality             │    │ goal_count          │    │ notes               │
│ note                │    │ goal_ml             │    │ created_at          │
│ created_at          │    │ created_at          │    │ updated_at          │
│ updated_at          │    │ updated_at          │    │                     │
└─────────────────────┘    └─────────────────────┘    └─────────────────────┘
```

### Database Normalization
- **First Normal Form (1NF):** แต่ละ column มีค่าเดียว atomic values
- **Second Normal Form (2NF):** ไม่มี partial dependencies
- **Third Normal Form (3NF):** ไม่มี transitive dependencies

### Indexing Strategy
```sql
-- Primary indexes (automatically created)
CREATE INDEX idx_sleep_daily_date ON sleep_daily(date_key);
CREATE INDEX idx_water_logs_date ON water_intake_logs(date_key);  
CREATE INDEX idx_exercise_daily_date ON exercise_daily(date_key);

-- Composite indexes for common queries
CREATE INDEX idx_water_date_count ON water_intake_logs(date_key, count);
CREATE INDEX idx_exercise_date_duration ON exercise_daily(date_key, duration_min);
```

## 🔄 API Design (Backend)

### RESTful API Endpoints
```
Health Tracking API v1
├── Authentication
│   ├── POST /auth/login
│   ├── POST /auth/register  
│   └── POST /auth/logout
├── Water Tracking
│   ├── GET /api/v1/water/{date}
│   ├── POST /api/v1/water
│   ├── PUT /api/v1/water/{date}
│   └── DELETE /api/v1/water/{date}
├── Exercise Tracking  
│   ├── GET /api/v1/exercise/{date}
│   ├── POST /api/v1/exercise
│   ├── PUT /api/v1/exercise/{date}
│   └── DELETE /api/v1/exercise/{date}
├── Sleep Tracking
│   ├── GET /api/v1/sleep/{date}
│   ├── POST /api/v1/sleep
│   ├── PUT /api/v1/sleep/{date}
│   └── DELETE /api/v1/sleep/{date}
└── Analytics
    ├── GET /api/v1/summary/{date}
    ├── GET /api/v1/trends/{start_date}/{end_date}
    └── GET /api/v1/statistics/{user_id}
```

### API Response Format
```json
{
  "success": true,
  "data": {
    "date": "2025-09-18",
    "water": {
      "count": 6,
      "ml": 1500,
      "goal_count": 8,
      "goal_ml": 2000
    }
  },
  "message": "Data retrieved successfully",
  "timestamp": "2025-09-18T10:30:00Z"
}
```

## 🎨 UI/UX Architecture

### Design System Components
```
Design System
├── Colors
│   ├── Primary Palette
│   ├── Secondary Palette
│   ├── Semantic Colors (Success, Warning, Error)
│   └── Neutral Grays
├── Typography
│   ├── Headers (H1-H6)
│   ├── Body Text (Large, Medium, Small)
│   └── Captions
├── Spacing System
│   ├── Margins (4px, 8px, 16px, 24px, 32px)
│   └── Padding (4px, 8px, 16px, 24px, 32px)
└── Components
    ├── Buttons (Primary, Secondary, Text)
    ├── Cards (Elevated, Outlined, Filled)
    ├── Forms (TextField, Dropdown, Checkbox)
    └── Navigation (AppBar, BottomNav, Drawer)
```

### Screen Architecture Pattern
```dart
class ScreenTemplate extends StatefulWidget {
  @override
  _ScreenTemplateState createState() => _ScreenTemplateState();
}

class _ScreenTemplateState extends State<ScreenTemplate> {
  // 1. State variables
  // 2. Lifecycle methods
  // 3. Event handlers  
  // 4. Helper methods
  // 5. Build method
}
```

## 🔒 Security Architecture

### Frontend Security
- **Local Data Encryption:** Sensitive data encrypted before storing in SQLite
- **Secure Storage:** Critical information stored using flutter_secure_storage
- **Input Validation:** All user inputs validated before processing
- **SQL Injection Prevention:** Parameterized queries only

### Backend Security  
- **Authentication:** JWT token-based authentication
- **Authorization:** Role-based access control (RBAC)
- **HTTPS Enforcement:** All API communication over HTTPS
- **CORS Configuration:** Proper CORS headers configured
- **Rate Limiting:** API rate limiting to prevent abuse
- **Input Sanitization:** All inputs sanitized and validated

### Data Privacy
- **GDPR Compliance:** User data handling follows GDPR guidelines
- **Data Minimization:** Only necessary data collected and stored
- **Right to Deletion:** Users can delete their account and all data
- **Data Portability:** Users can export their data

## 📱 Cross-Platform Strategy

### Flutter Platform Support
```
├── Mobile Platforms
│   ├── Android (API 21+)
│   └── iOS (11.0+)
├── Desktop Platforms  
│   ├── Windows (10+)
│   ├── macOS (10.14+)
│   └── Linux (64-bit)
└── Web Platform
    ├── Chrome (84+)
    ├── Firefox (72+)
    ├── Safari (14+)
    └── Edge (84+)
```

### Platform-Specific Implementations
```dart
// Platform-specific code organization
lib/
├── platform/
│   ├── android/
│   │   └── android_specific_service.dart
│   ├── ios/
│   │   └── ios_specific_service.dart
│   ├── web/
│   │   └── web_specific_service.dart
│   └── interface/
│       └── platform_interface.dart
```

## ⚡ Performance Architecture

### Frontend Performance
- **Lazy Loading:** Screens and data loaded on demand
- **Widget Optimization:** Const constructors and widget recycling
- **State Minimization:** Only necessary state stored in providers  
- **Image Optimization:** Cached network images and proper sizing
- **Memory Management:** Proper disposal of controllers and streams

### Database Performance
- **Connection Pooling:** SQLite connection reuse
- **Query Optimization:** Indexed columns for frequent queries
- **Batch Operations:** Bulk inserts/updates for better performance
- **Data Pagination:** Large datasets loaded in chunks
- **Cache Strategy:** Frequently accessed data cached in memory

### Backend Performance
- **Async Processing:** Non-blocking I/O operations
- **Database Connection Pooling:** PostgreSQL connection pooling
- **Response Caching:** API response caching for static data
- **Query Optimization:** Optimized SQL queries with proper indexes
- **Load Balancing:** Horizontal scaling support

## 🧪 Testing Architecture

### Testing Pyramid
```
                    ╔══════════════╗
                   ╔╝  E2E Tests   ╚╗ ← Few, Expensive
                  ╔╝  (Integration)  ╚╗
                 ╔╝                   ╚╗
                ╔╝   Integration Tests  ╚╗ ← Some, Moderate Cost
               ╔╝    (Widget Tests)      ╚╗
              ╔╝                          ╚╗
             ╔╝        Unit Tests           ╚╗ ← Many, Cheap
            ╚════════════════════════════════╝
```

### Test Organization
```
test/
├── unit/
│   ├── models_test.dart
│   ├── providers_test.dart
│   ├── services_test.dart
│   └── utils_test.dart
├── widget/
│   ├── screens_test.dart
│   ├── components_test.dart
│   └── widgets_test.dart
├── integration/
│   ├── app_flow_test.dart
│   ├── database_test.dart
│   └── api_integration_test.dart
└── mocks/
    ├── mock_repositories.dart
    ├── mock_services.dart
    └── test_data.dart
```

## 🚀 Deployment Architecture

### CI/CD Pipeline
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Source    │    │    Build    │    │    Test     │    │   Deploy    │
│   Control   │───▶│   Stage     │───▶│   Stage     │───▶│   Stage     │
│  (GitHub)   │    │             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
  - Git commits      - Flutter build     - Unit tests      - App Store
  - Pull requests    - Docker build      - Widget tests    - Play Store  
  - Branch merges    - Dependencies      - Integration     - Web hosting
  - Release tags     - Code analysis     - E2E tests       - API server
```

### Environment Configuration
```yaml
# Development Environment
environment: development
api_url: http://localhost:8000
debug_mode: true
database_url: sqlite://local.db

# Staging Environment  
environment: staging
api_url: https://staging-api.healthapp.com
debug_mode: false
database_url: postgresql://staging_db

# Production Environment
environment: production
api_url: https://api.healthapp.com  
debug_mode: false
database_url: postgresql://prod_db
```

## 📈 Scalability Considerations

### Frontend Scalability
- **Modular Architecture:** Feature-based code organization
- **State Management:** Scalable provider architecture
- **Code Splitting:** Dynamic imports for large features
- **Asset Optimization:** Efficient asset bundling and caching

### Backend Scalability
- **Microservices Ready:** Modular service architecture
- **Database Sharding:** Horizontal database scaling support
- **Load Balancing:** Multiple server instance support
- **Caching Layers:** Redis/Memcached integration ready
- **CDN Integration:** Static asset delivery optimization

### Monitoring & Analytics
- **Performance Monitoring:** Real-time app performance tracking
- **Error Tracking:** Comprehensive error logging and alerting
- **Usage Analytics:** User behavior and feature usage tracking
- **Health Checks:** Automated system health monitoring

---

*Technical Architecture Document v1.0*  
*Last Updated: September 18, 2025*