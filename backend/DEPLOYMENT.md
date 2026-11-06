# Backend Deployment & Production Setup Guide

This guide explains how to deploy the **Smart Routine & Management** Next.js REST API backend to production and connect it with your Flutter mobile app and MongoDB Atlas database.

---

## 1. Architecture & Stack Overview

- **Backend Framework:** Next.js 14 (App Router) REST API
- **Runtime:** Node.js 18+ / 20+
- **Database:** MongoDB Atlas (Cloud Cluster `cluster0.u9jjnjy.mongodb.net`, database: `smart_routine_db`)
- **Authentication:** JSON Web Tokens (JWT) + bcryptjs password hashing
- **Client:** Flutter Android Mobile App

---

## 2. Step 1: Prepare MongoDB Atlas for Cloud Deployment (Mandatory)

Because cloud hosting platforms (like Vercel or Render) use dynamic outbound IP addresses, you must allow connection from any IP:

1. Log in to [MongoDB Atlas](https://cloud.mongodb.com/).
2. In the left navigation, click **Network Access** under **Security**.
3. Click **Add IP Address**.
4. Choose **Allow Access from Anywhere** (`0.0.0.0/0`).
5. Click **Confirm**.
6. Verify your Database User under **Database Access** has read/write privileges on `smart_routine_db`.

---

## 3. Step 2: Deploy to Hosting Platform

### Option A: Vercel (Recommended for Next.js)

Vercel provides native, optimized serverless deployment for Next.js with a generous free tier.

#### Method 1: Via GitHub (Zero-setup & Automatic Updates)
1. Push your latest code to your GitHub repository:
   ```bash
   git add .
   git commit -m "Configure production deployment"
   git push origin main
   ```
2. Go to [vercel.com](https://vercel.com) and log in with your GitHub account.
3. Click **Add New...** -> **Project**.
4. Select your repository `muhammadrohan3002-lgtm/online-class-routine`.
5. In **Project Settings**:
   - **Framework Preset:** `Next.js`
   - **Root Directory:** Click `Edit` and select `backend`.
6. Expand **Environment Variables** and add the following:

   | Variable Name | Value | Note |
   | :--- | :--- | :--- |
   | `MONGODB_URI` | `mongodb+srv://<user>:<password>@cluster0.u9jjnjy.mongodb.net/smart_routine_db?retryWrites=true&w=majority` | Your Atlas connection string |
   | `MONGODB_DB` | `smart_routine_db` | Database name |
   | `JWT_SECRET` | *(Random 32+ character string)* | e.g. `smart_routine_jwt_super_secret_production_key_2026` |
   | `JWT_EXPIRES_IN` | `30d` | Token expiry duration |
   | `NODE_ENV` | `production` | Production environment flag |

7. Click **Deploy**.
8. After 1-2 minutes, Vercel gives you your live production URL (e.g., `https://smart-routine-backend-xxxx.vercel.app`).

#### Method 2: Via Vercel CLI
```bash
cd backend
vercel login
vercel --prod
```

---

### Option B: Render.com (Alternative Persistent Web Service)

1. Log in to [render.com](https://render.com).
2. Click **New +** -> **Blueprint** or **Web Service**.
3. Connect your GitHub repository.
4. If using Web Service:
   - **Root Directory:** `backend`
   - **Build Command:** `npm install && npm run build`
   - **Start Command:** `npm run start`
   - **Environment Variables:** Add `MONGODB_URI`, `JWT_SECRET`, `MONGODB_DB`, `JWT_EXPIRES_IN`.
5. Click **Create Web Service**.

---

## 4. Step 3: Verify the Live Deployed Backend

Once deployed, verify that the health and auth endpoints work:

1. **Health Check:**
   ```bash
   curl https://<YOUR_DEPLOYED_URL>/api/health
   ```
   Expected response:
   ```json
   { "status": "healthy", "database": "connected", "timestamp": "..." }
   ```

2. **Login Test:**
   ```bash
   curl -X POST https://<YOUR_DEPLOYED_URL>/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email": "student@cse.edu", "password": "student123"}'
   ```

---

## 5. Step 4: Update the Flutter App to Use the Production URL

You can point the Flutter app to the live backend in two ways:

### Method A: Compile-time define (Recommended for release builds)
Build the APK passing your production API URL:
```bash
flutter build apk --release --dart-define=API_URL=https://<YOUR_DEPLOYED_URL>/api
```

### Method B: Update `api_endpoints.dart`
In `smart_routine_mobile/lib/core/constants/api_endpoints.dart`:
```dart
static const String productionUrl = 'https://<YOUR_DEPLOYED_URL>/api';
```

### Method C: In-App Dynamic Switching (No rebuild needed!)
Open the Smart Routine app on your phone:
1. Tap the **Server Connection Settings** icon in the AppBar on the Login or Register screen.
2. Select or enter your HTTPS cloud URL (e.g., `https://<YOUR_DEPLOYED_URL>/api`).
3. Tap **Test Server Connection** (it will verify connection to `/api/health`).
4. Tap **Save and Apply**.
