# Students System (نظام تسجيل الطلاب)

A production-grade Flutter application for student registration and administration built with clean feature-first architecture, Riverpod state management, Dio HTTP networking, GoRouter navigation, Arabic RTL UI design, and full integration with the hosted REST API.

---

## 🌟 Product Experiences

### 1. Student / Public Registration Experience (`/` & `/registration`)
- **Landing & Multi-Section Registration Form**:
  - **البيانات الشخصية** (First Name, Father's Name, Grandfather's Name, Family Name, Gender)
  - **البيانات الأكاديمية** (Governorate 1-12, Class Level 1-12, School Name, Grade/Average)
  - **بيانات التواصل** (Phone 1, Phone 2, Address)
  - **المستندات والشهادات** (Certificate Image Picker with live preview/remove, optional additional images)
- **Form Validation**: Strict client-side field validation and real-time upload progress.
- **Success Screen**: Displays assigned Student ID (`#ID`) in a popup upon successful API registration.

### 2. Admin Experience (`/admin/login` & `/admin`)
- **Authentication**:
  - Username & Password login with persistent Bearer token storage via `SharedPreferences`.
  - Auto-login on app launch if authenticated.
  - Automatic token invalidation and redirect to login on HTTP 401 response.
  - Credentials from API docs: `username: admin`, `password: admin`.
- **Dashboard & Analytics**:
  - Summary cards (Total Students count, Average Grade, Gender Ratio breakdown).
  - Quick action buttons (New Student Registration, Export CSV, Refresh).
- **Students Management & Data Table**:
  - **Desktop/Tablet**: High-density interactive Data Table.
  - **Mobile**: Touch-optimized Card List view.
  - **Backend Search**: Real-time search query parameter integration.
  - **Advanced Filtering & Sorting**: Filter by Class, Gender, Governorate, School, Grade range, and sort by Grade ascending/descending.
- **Student Profile Details (`/admin/students/:id`)**:
  - Comprehensive student details view.
  - Interactive Lightbox image viewer for student certificate images.
  - Edit Student Dialog (partial PUT update support).
  - Delete Student Confirmation Modal (destructive action safeguard with DELETE API call).
- **CSV Export**:
  - Calls `/api/admin/students/export/csv` preserving active query filters.
  - Triggers browser Blob file download on Web and native file saving on Android/iOS/Desktop.

---

## ⚙️ REST API Endpoints Integrated

Base URL: `https://studentshonoringsystem-o46s.onrender.com/api/`

| Feature | Method | Endpoint | Auth Required |
|---|---|---|---|
| Admin Login | `POST` | `/api/admin/login` | No |
| Public Student Registration | `POST` | `/api/students` | No |
| Get All Students (Paginated/Filtered) | `GET` | `/api/admin/students` | Bearer Token |
| Get Single Student Profile | `GET` | `/api/admin/students/{id}` | Bearer Token |
| Update Student | `PUT` | `/api/admin/students/{id}` | Bearer Token |
| Delete Student | `DELETE` | `/api/admin/students/{id}` | Bearer Token |
| Export Students to CSV | `GET` | `/api/admin/students/export/csv` | Bearer Token |
| Admin Logout | `POST` | `/api/logout` | Bearer Token |

### 📌 Known Backend Limitation
The API overview documentation mentions an "add student" Admin endpoint, but specific request details were omitted from the documentation. 
* **Design Decision**: The app uses the documented public student creation endpoint `POST /api/students` for registration. The data repository is structured modularly so a distinct Admin Add endpoint can be linked seamlessly when provided by backend documentation.

---

## 🏗️ Architecture & Project Structure

```
lib/
├── app/
│   ├── app.dart                        # MaterialApp.router with Arabic locale & RTL
│   └── config/
│       ├── api_config.dart             # API Base URL & endpoint routes
│       └── constants.dart              # Saudi Governorates (1-12) & Classes (1-12)
├── core/
│   ├── errors/                         # Custom ApiException & Arabic ErrorHandler
│   ├── network/                        # DioClient & Auth Interceptor
│   ├── routing/                        # GoRouter configuration & guards
│   ├── storage/                        # AuthStorage (SharedPreferences)
│   ├── theme/                          # Material 3 custom theme & Cairo GoogleFont
│   ├── utils/                          # Validators & Cross-Platform CSV Exporter
│   └── widgets/                        # AppButton, AppTextField, CustomCard, Lightbox
├── features/
│   ├── auth/                           # Admin Authentication module
│   ├── registration/                   # Public Student Registration module
│   └── students/                       # Admin Dashboard & Student CRUD module
└── main.dart                           # Entry point
```

---

## 🛠️ How to Change API Base URL

To point the application to a different server or local dev backend:
Open `lib/app/config/api_config.dart` and update the `baseUrl` constant:

```dart
class ApiConfig {
  static const String baseUrl = 'https://your-custom-api-domain.com/api/';
}
```

*Note for Android Emulator with local backend*: If running a local server on host machine, use `http://10.0.2.2:8000/api/` instead of `http://localhost:8000/api/`.

---

## 🚀 How to Build & Run

### Prerequisites
- Flutter SDK `^3.41.0` or stable
- Dart SDK `^3.11.0`

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run Tests
```bash
flutter test
```

### 3. Run Application

#### On Web:
```bash
flutter run -d chrome
```

#### On Desktop (Windows/macOS/Linux):
```bash
flutter run -d windows
```

#### On Mobile (Android/iOS):
```bash
flutter run
```

---

## 📦 Packages Used

- **`flutter_riverpod`**: State management
- **`dio`**: HTTP client & Interceptors
- **`go_router`**: Declarative routing & Auth guards
- **`shared_preferences`**: Local token persistence
- **`image_picker`**: Certificate image upload
- **`google_fonts`**: Cairo font for Arabic typography
- **`flutter_localizations`**: Arabic RTL localizations
- **`cross_file`**: Cross-platform image/file handling
