# Smart Routine & Management Application

A complete, modern, production-grade mobile application and REST API backend built for Computer Science & Engineering (CSE) university students to organize class schedules, assignments, exams, attendance logs, and study sessions.

Built with **Flutter (Material 3, Riverpod, GoRouter)** for mobile and **Next.js (App Router, Route Handlers, MongoDB Atlas)** for the backend.

---

## 📑 Table of Contents
1. [Project Overview & Key Features](#-project-overview--key-features)
2. [Architecture & Technology Stack](#-architecture--technology-stack)
3. [Repository Structure](#-repository-structure)
4. [Prerequisites](#-prerequisites)
5. [Backend Setup (Next.js & MongoDB Atlas)](#-backend-setup-nextjs--mongodb-atlas)
6. [MongoDB Atlas Setup Guide](#-mongodb-atlas-setup-guide)
7. [Mobile App Setup (Flutter)](#-mobile-app-setup-flutter)
8. [Connecting Mobile App to Backend (Development & Production)](#-connecting-mobile-app-to-backend)
9. [Running on Android Emulator & Physical Devices](#-running-on-android-emulator--physical-devices)
10. [REST API Documentation](#-rest-api-documentation)
11. [Testing & Quality Verification](#-testing--quality-verification)
12. [CSE Student Guide: Key Implementation Decisions](#-cse-student-guide-key-implementation-decisions)

---

## 🌟 Project Overview & Key Features

### 1. Authentication & Security
- **JWT-based Authentication**: Secure password hashing with `bcryptjs` and stateless token management.
- **Password Reset Flow**: Request reset codes and update passwords securely.
- **Strict Data Isolation**: Every API endpoint verifies JWT ownership—users can never access or modify another student's courses, tasks, or routines.

### 2. Home Dashboard
- Real-time greeting with today's date and day of week.
- **Next Upcoming Class Card**: Live countdown, room number, teacher, and course code.
- **Today's Class Counter**: Shows total classes scheduled for today.
- **Attendance Gauge**: Overall percentage with visual warning badge if below 75%.
- **Quick Action Grid**: 1-tap shortcuts to add tasks, log attendance, start focus timer, or add an exam.
- **Upcoming Deadlines & Countdown**: Aggregated view of upcoming assignments and exams.

### 3. Weekly Routine Management (Saturday – Friday)
- Full 7-day academic timetable support (standard Saturday–Friday schedule).
- Day selector strip with quick day-by-day navigation.
- Color-coded course cards showing room, time, and instructor.
- **Real-Time Conflict Detection Algorithm**: Automatically flags overlapping class periods on both client and server before saving.
- Filter classes by course code or day.

### 4. Task & Assignment Management
- Priority levels: High (red), Medium (amber), Low (blue).
- Categories: `Study`, `Assignment`, `Personal`, `Other`.
- Status filtering: `All`, `Pending`, `Completed`, `Overdue`.
- Due date sorting with live countdown tags (e.g. "Due tomorrow", "Overdue").
- Optimistic UI updates when toggling task completion.

### 5. Exam & Academic Event Tracker
- Types: `Midterm Exam`, `Final Exam`, `Quiz`, `Lab Exam`, `Presentation`.
- Date, time, venue, and syllabus notes.
- Visual countdown timers (e.g. "In 3 days").
- Local notification scheduling for study reminders.

### 6. Course Attendance Management
- Session logging: `Present`, `Late`, `Absent`.
- Course-by-course attendance percentages.
- **Configurable Warning Threshold**: Alerts students when attendance drops below the threshold (default: 75%).
- **Duplicate Prevention**: Compound database index and backend validation guarantee that only one attendance record can exist for a specific course on a given date.

### 7. Study Planner & Focus Timer
- Daily study target goal tracking (e.g. 180 minutes/day).
- Interactive **Focus Timer / Pomodoro Stopwatch**: Start, pause, resume, and log study sessions directly linked to courses.
- Weekly progress bar chart visualizing minutes studied across the past 7 days.

### 8. Settings & Profile
- Toggle between Light and Dark Material 3 themes.
- Edit student name, university, and department.
- Adjust the Attendance Warning Threshold (50% – 90%).
- Built-in **Server Configuration Screen**: Test API latency and change the backend URL on the fly without recompiling the app.

---

## 🏗 Architecture & Technology Stack

```
┌─────────────────────────────────────────────────────────────┐
│                 Flutter Mobile Application                  │
│  ┌─────────────────┐ ┌─────────────────┐ ┌───────────────┐  │
│  │   UI (M3, Fonts)│ │ Riverpod State  │ │ GoRouter Nav  │  │
│  └────────┬────────┘ └────────┬────────┘ └───────┬───────┘  │
│           │                   │                  │          │
│           ▼                   ▼                  ▼          │
│  ┌───────────────────────────────────────────────────────┐  │
│  │     Repositories & Dio Client (Auth Interceptor)      │  │
│  └────────────────────────────┬──────────────────────────┘  │
└───────────────────────────────┼─────────────────────────────┘
                                │ HTTP / REST (Bearer JWT)
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                 Next.js App Router Backend                  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │            Route Handlers (/api/*) + CORS             │  │
│  └────────────────────────────┬──────────────────────────┘  │
│                               │                             │
│  ┌────────────────────────────▼──────────────────────────┐  │
│  │ JWT Auth Verification | Conflict & Validation Logic   │  │
│  └────────────────────────────┬──────────────────────────┘  │
│                               │                             │
│  ┌────────────────────────────▼──────────────────────────┐  │
│  │             Official MongoDB Node.js Driver           │  │
│  └────────────────────────────┬──────────────────────────┘  │
└───────────────────────────────┼─────────────────────────────┘
                                │
                                ▼
               ┌─────────────────────────────────┐
               │      MongoDB Atlas Database     │
               │ (users, courses, routines, etc.)│
               └─────────────────────────────────┘
```

---

## 📁 Repository Structure

```
Smart Routine & Management App/
├── .gitignore
├── README.md
│
├── backend/                              # Next.js App Router REST API
│   ├── .env.example                      # Sample configuration
│   ├── package.json
│   ├── tsconfig.json
│   ├── next.config.mjs                   # CORS configuration
│   ├── lib/
│   │   ├── mongodb.ts                    # MongoDB connection & index initialization
│   │   ├── models.ts                     # TypeScript document interfaces
│   │   ├── auth.ts                       # bcryptjs & jsonwebtoken helpers
│   │   ├── validation.ts                 # Time conflict & regex validators
│   │   └── api-response.ts               # Standardized JSON response helpers
│   ├── app/api/
│   │   ├── auth/                         # /register, /login, /me, /forgot-password, /reset-password
│   │   ├── courses/                      # /courses, /courses/[id]
│   │   ├── routines/                     # /routines, /routines/check-conflict, /routines/[id]
│   │   ├── tasks/                        # /tasks, /tasks/[id]
│   │   ├── exams/                        # /exams, /exams/[id]
│   │   ├── attendance/                   # /attendance, /attendance/summary, /attendance/[id]
│   │   ├── study-sessions/               # /study-sessions, /study-sessions/progress, /study-sessions/[id]
│   │   ├── dashboard/                    # /dashboard summary aggregation
│   │   └── health/                       # /health check
│   ├── scripts/
│   │   └── seed.mjs                      # Sample database seeder
│   └── tests/
│       └── business-logic.test.mjs       # Backend unit tests
│
└── smart_routine_mobile/                 # Flutter Mobile Application
    ├── pubspec.yaml
    ├── analysis_options.yaml
    ├── lib/
    │   ├── main.dart                     # App entry point
    │   ├── app/
    │   │   ├── app.dart                  # Root MaterialApp.router
    │   │   ├── router.dart               # GoRouter with 5-tab ShellRoute
    │   │   └── theme.dart                # Material 3 light/dark themes
    │   ├── core/
    │   │   ├── constants/                # Colors, strings, API endpoints
    │   │   ├── errors/                   # ApiException & error mapper
    │   │   ├── network/                  # Dio wrapper & Auth interceptor
    │   │   ├── services/                 # StorageService & NotificationService
    │   │   ├── utils/                    # DateTimeUtils & ConflictDetector
    │   │   ├── providers/                # Global Riverpod providers
    │   │   └── widgets/                  # Reusable buttons, badges, cards, inputs
    │   └── features/
    │       ├── auth/                     # Login, register, forgot/reset password
    │       ├── dashboard/                # Next class card, stats, quick actions
    │       ├── courses/                  # Course management & color picker
    │       ├── routine/                  # Weekly timetable, conflict detection
    │       ├── tasks/                    # Task CRUD, filters, priority badges
    │       ├── calendar/                 # Exams & academic events, countdowns
    │       ├── attendance/               # Session logging, summary, warning banner
    │       ├── study_planner/            # Goals, focus timer, weekly bar chart
    │       └── profile/                  # Profile edit, settings, server config
    └── test/
        ├── routine_conflict_test.dart    # Conflict algorithm unit tests
        ├── attendance_calculation_test.dart # Attendance % calculation tests
        └── widget_test.dart              # Core widget rendering tests
```

---

## ⚙️ Prerequisites

Ensure you have the following installed on your machine:
- **Node.js**: v18.17+ or v20+ (`node -v`)
- **npm**: v9+ (`npm -v`)
- **Flutter SDK**: v3.19+ or v3.27+ (`flutter --version`)
- **Dart SDK**: v3.3+ (bundled with Flutter)
- **Android Studio** or **VS Code** with Flutter & Dart extensions
- Free **MongoDB Atlas** account (or local MongoDB v6.0+)

---

## 🚀 Backend Setup (Next.js & MongoDB Atlas)

### 1. Install Dependencies
Open a terminal in the `backend/` folder:
```bash
cd backend
npm install
```

### 2. Configure Environment Variables
Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```
Open `.env` in a text editor and fill in your values:
```env
MONGODB_URI=mongodb+srv://<username>:<password>@cluster0.mongodb.net/smart_routine_db?retryWrites=true&w=majority
MONGODB_DB=smart_routine_db
JWT_SECRET=super_secret_jwt_key_at_least_32_characters_long
JWT_EXPIRES_IN=30d
NODE_ENV=development
PORT=5000
```

### 3. Seed Sample Data (Optional)
Once your MongoDB URI is set up, you can seed realistic CSE demo data (courses, routines, tasks, exams, attendance logs, and study sessions):
```bash
npm run seed
```
> **Default Demo Account created by seeder:**
> - Email: `student@cse.edu`
> - Password: `student123`

### 4. Start the Backend Server
```bash
npm run dev
```
The server will start on `http://localhost:5000`. Test the health check endpoint in your browser or curl:
```bash
curl http://localhost:5000/api/health
```
Response:
```json
{"success":true,"message":"Smart Routine & Management API is healthy","timestamp":"..."}
```

---

## 🍃 MongoDB Atlas Setup Guide

Follow these steps to set up a free cloud database on MongoDB Atlas:

1. **Sign Up / Log In**: Visit [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas) and create a free account.
2. **Create a Free Cluster**:
   - Choose **M0 Free** (Shared).
   - Select your preferred cloud provider and region (e.g. AWS / us-east-1 or ap-southeast-1).
   - Click **Create Deployment**.
3. **Set Up Database User**:
   - Go to **Security > Database Access > Add New Database User**.
   - Select **Password Authentication**.
   - Username: e.g. `cse_student`.
   - Password: generate a strong password and save it safely.
   - Built-in Role: **Read and write to any database**.
4. **Configure Network Access (IP Whitelist)**:
   - Go to **Security > Network Access > Add IP Address**.
   - Click **Allow Access from Anywhere** (`0.0.0.0/0`) for development, or add your current IP address.
5. **Get Connection String**:
   - Go to **Database > Clusters > Connect**.
   - Choose **Drivers** (Node.js).
   - Copy the connection URI:
     `mongodb+srv://cse_student:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority`
   - Paste it into your `backend/.env` file as `MONGODB_URI`, replacing `<password>` with your real password.

---

## 📱 Mobile App Setup (Flutter)

### 1. Install Dependencies
Open a terminal in the `smart_routine_mobile/` folder:
```bash
cd smart_routine_mobile
flutter pub get
```

### 2. Verify Flutter Environment
Run:
```bash
flutter doctor
```
Ensure Android toolchain and connected devices/emulators are recognized.

---

## 🌐 Connecting Mobile App to Backend

Depending on where you run the Flutter app, configure the API URL:

| Environment | Backend URL | Why? |
|---|---|---|
| **Android Emulator** | `http://10.0.2.2:5000/api` | `10.0.2.2` is the special Android loopback alias for your host machine's `localhost`. |
| **iOS Simulator** | `http://localhost:5000/api` | iOS simulator shares the network interface with your Mac. |
| **Physical Phone (USB / Wi-Fi)** | `http://192.168.x.x:5000/api` | Use your computer's local Wi-Fi IP address (run `ipconfig` on Windows or `ifconfig` on Mac/Linux). |
| **Cloud Production** | `https://your-domain.vercel.app/api` | Deployed backend on Vercel / Render / Railway. |

### Dynamic In-App Configuration
You do **not** need to recompile the app to switch URLs!
1. Open the app.
2. Go to **Profile > Server Configuration**.
3. Type in your host IP (or choose **Android Emulator 10.0.2.2** or **Localhost**).
4. Tap **Test Server Connection** to verify latency and connectivity.
5. Tap **Save & Apply URL**.

---

## 📲 Running on Android Emulator & Physical Devices

### Running on Android Emulator
1. Start an Android Virtual Device (AVD) from Android Studio Device Manager.
2. Ensure your backend is running (`cd backend && npm run dev`).
3. Run the Flutter app:
   ```bash
   cd smart_routine_mobile
   flutter run
   ```

### Running on a Physical Android Phone
1. Enable **Developer Options** and **USB Debugging** on your phone:
   - Go to **Settings > About Phone** and tap **Build Number** 7 times.
   - Go to **Settings > Developer Options** and enable **USB Debugging**.
2. Connect your phone via USB cable and allow USB debugging when prompted.
3. Make sure your computer and phone are connected to the **same Wi-Fi network**.
4. In Windows PowerShell, find your computer's local IP address:
   ```powershell
   ipconfig
   # Look for "IPv4 Address", e.g. 192.168.1.15
   ```
5. Ensure Windows Firewall permits incoming traffic on port 5000.
6. Launch the app:
   ```bash
   flutter run -d <device_id>
   ```
7. Open **Profile > Server Configuration** and set the URL to `http://192.168.1.15:5000/api`.

---

## 📡 REST API Documentation

All protected endpoints require the header:
`Authorization: Bearer <your_jwt_token>`

### Auth Endpoints
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `POST` | `/api/auth/register` | Register new student account (`name`, `email`, `password`, `university`, `department`) | No |
| `POST` | `/api/auth/login` | Log in and receive JWT token | No |
| `GET` | `/api/auth/me` | Fetch currently authenticated user profile | Yes |
| `PUT` | `/api/auth/me` | Update student profile and preferences | Yes |
| `POST` | `/api/auth/forgot-password`| Request password reset code | No |
| `POST` | `/api/auth/reset-password` | Reset password using reset code | No |

### Dashboard Endpoint
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/dashboard` | Aggregated dashboard: next class, today's count, pending tasks, upcoming exams, attendance overview | Yes |

### Courses Endpoints
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/courses` | List all student courses | Yes |
| `POST` | `/api/courses` | Create course (`code`, `name`, `teacher`, `credit`, `colorHex`) | Yes |
| `PUT` | `/api/courses/[id]` | Update course | Yes |
| `DELETE` | `/api/courses/[id]` | Delete course | Yes |

### Routine Endpoints
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/routines` | Get timetable (supports `?day=Monday` or `?courseId=...`) | Yes |
| `POST` | `/api/routines` | Add class schedule (validates time overlaps) | Yes |
| `POST` | `/api/routines/check-conflict` | Pre-flight test if a time slot overlaps an existing class | Yes |
| `PUT` | `/api/routines/[id]` | Update class schedule (validates overlaps) | Yes |
| `DELETE` | `/api/routines/[id]` | Delete class schedule | Yes |

### Task Endpoints
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/tasks` | List tasks (supports `?status=pending`, `?category=Study`, `?sort=dueDate`) | Yes |
| `POST` | `/api/tasks` | Create task (`title`, `description`, `dueDate`, `priority`, `category`) | Yes |
| `PUT` | `/api/tasks/[id]` | Update task or toggle status (`completed`, `pending`, `overdue`) | Yes |
| `DELETE` | `/api/tasks/[id]` | Delete task | Yes |

### Exam Endpoints
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/exams` | List exams & academic events | Yes |
| `POST` | `/api/exams` | Add exam (`courseId`, `title`, `type`, `date`, `time`, `location`, `notes`) | Yes |
| `PUT` | `/api/exams/[id]` | Update exam | Yes |
| `DELETE` | `/api/exams/[id]` | Delete exam | Yes |

### Attendance Endpoints
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/attendance` | List recent attendance logs (`?courseId=...`) | Yes |
| `GET` | `/api/attendance/summary` | Course-by-course attendance % and low attendance alerts | Yes |
| `POST` | `/api/attendance` | Record attendance (`courseId`, `date`, `status`). Rejects duplicate records | Yes |
| `DELETE` | `/api/attendance/[id]` | Delete attendance entry | Yes |

### Study Session Endpoints
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/study-sessions` | List recorded study sessions | Yes |
| `GET` | `/api/study-sessions/progress` | Daily target progress and 7-day bar chart minutes | Yes |
| `POST` | `/api/study-sessions` | Log study session (`courseId`, `durationMinutes`, `notes`) | Yes |
| `DELETE` | `/api/study-sessions/[id]` | Delete study session | Yes |

---

## 🧪 Testing & Quality Verification

### Run Flutter Unit & Widget Tests
```bash
cd smart_routine_mobile
flutter test
```
**Test suite coverage includes:**
1. `routine_conflict_test.dart`:
   - Overlapping interval detection (e.g. `09:00 - 10:30` vs `10:00 - 11:30`).
   - Back-to-back adjacent classes (e.g. `09:00 - 10:00` and `10:00 - 11:00` do NOT conflict).
   - Day isolation (same time on different days is allowed).
   - Edit exclusion (updating an existing class ignores self-collision).
2. `attendance_calculation_test.dart`:
   - Present/Late/Absent percentage mathematics.
   - Threshold warning triggers when attendance drops below 75%.
3. `widget_test.dart`:
   - `CustomButton` tap response and spinner state.
   - `StatusBadge` styling and colors for priorities.
   - `EmptyStateView` action button and text display.

### Run Flutter Static Code Analysis
```bash
cd smart_routine_mobile
flutter analyze
```
*(Verified with 0 issues).*

### Run Backend Unit Tests
```bash
cd backend
npm test
```
Tests routine interval mathematics, adjacent slot rules, and attendance calculation logic.

---

## 🎓 CSE Student Guide: Key Implementation Decisions

### 1. State Management with Riverpod
**Why Riverpod over Provider or setState?**
- Riverpod is compile-safe: no `ProviderNotFoundException` at runtime.
- It doesn't depend on the Flutter widget tree, allowing business logic and state to be tested without inflating UI widgets.
- `StateNotifierProvider` cleanly models async lifecycle states (`AsyncValue.loading`, `AsyncValue.data`, `AsyncValue.error`).

### 2. Navigation with GoRouter & StatefulShellRoute
**Why StatefulShellRoute?**
- Standard bottom navigation often rebuilds screens and loses scroll positions when switching tabs.
- `StatefulShellRoute.indexedStack` maintains the state of all 5 root tabs (Home, Routine, Tasks, Calendar, Profile) in memory while providing clean URL routes.

### 3. Timetable Overlap Algorithm
Two time intervals `[StartA, EndA)` and `[StartB, EndB)` overlap if and only if:
$$\text{StartA} < \text{EndB} \quad \text{AND} \quad \text{StartB} < \text{EndA}$$
This mathematical condition is implemented both client-side in `ConflictDetector.dart` for immediate UI feedback and server-side in `backend/lib/validation.ts` to enforce data integrity.

### 4. Preventing Duplicate Attendance Logs
To guarantee a student cannot log attendance twice for the same class on the same day:
1. **Database Level**: A unique compound index `{ userId: 1, courseId: 1, date: 1 }` is automatically created on the `attendance` collection.
2. **Application Level**: Pre-insert validation checks if a record already exists and returns HTTP `409 Conflict`.
3. **Client UI Level**: The attendance dialog informs the user if a record was already logged for that date.

### 5. Network Architecture & Interceptors
- All HTTP requests flow through a unified `ApiClient` powered by `Dio`.
- `AuthInterceptor` automatically retrieves the JWT from `SharedPreferences` and attaches `Authorization: Bearer <token>`.
- If an API returns HTTP `401 Unauthorized`, the interceptor triggers automatic session clearing and redirects to the login screen.

---

## 📄 License
This project is open-source and created for academic purposes. Feel free to use and extend it for your CSE Capstone or final year project!
