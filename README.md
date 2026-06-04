# FeloNa — Smart Waste Management Platform

> **"FeloNa"** means *"Don't Throw Away"* in Bengali. Built for Bangladesh, it turns waste into value by connecting people who have recyclable items with buyers and collectors — all while rewarding eco-friendly behavior.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![Node.js](https://img.shields.io/badge/Node.js-Express-339933?logo=node.js)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Sequelize-4169E1?logo=postgresql)
![Firebase](https://img.shields.io/badge/Firebase-FCM-FFCA28?logo=firebase)
![Gemini AI](https://img.shields.io/badge/Google-Gemini_AI-4285F4?logo=google)

---

## What I Built

FeloNa is a **full-stack circular economy platform** with a Flutter mobile app and a Node.js/Express REST API backed by PostgreSQL. It serves three user types — **sellers, buyers, and collectors** — each with their own role-specific dashboard and feature set.

The core idea: instead of throwing recyclables away, users can schedule a pickup, sell items on the marketplace, or scan waste with AI to learn what to do with it. Collectors earn money by completing pickups. Buyers find scrap and second-hand items. Everyone earns eco points.

---

## Features

### Authentication
- Register with email → OTP verification via email (Nodemailer + Gmail SMTP)
- Login with JWT access + refresh token rotation
- Forgot password → OTP → reset password flow
- Change password (authenticated)
- Brute-force protection on OTP (5 attempt lockout)
- Email enumeration protection on forgot password

### Marketplace (Sellers & Buyers)
- Create listings with up to 5 image uploads (Multer)
- Browse with pagination, search, and category filters
- Buyer makes offers with optional message
- Seller accepts/rejects offers — accepted offer auto-rejects all others and marks listing as reserved
- Seller profile page with their listings and eco stats
- 15 eco points awarded per item listed

### Pickup System
- Schedule a waste pickup with date, 2-hour time slot, and address
- Support for **recurring pickups** (weekly or biweekly) with a shared schedule ID
- Collectors browse available jobs and accept them
- Full status lifecycle: `pending → accepted → on_the_way → arrived → completed`
- **Real-time collector location tracking** via WebSocket — collector sends GPS coordinates, requester receives live updates
- **QR code verification** — unique token per pickup, scanned by collector to confirm completion
- Rate and review collector after completion (30-day window)
- Cancel recurring schedules
- Eco points awarded on completion (weight × 10 points)

### Eco Score & Gamification
- Points earned for: signing up, listing items, completing pickups, scanning waste
- 5 nature-themed levels: Seed 🌱 → Sprout 🌿 → Tree 🌳 → Forest 🌲 → Earth 🌍
- Point history log with activity type and description
- Community leaderboard (top 20 users by eco points)
- CO₂ and landfill diversion stats per user

### AI Features (Gemini Vision)
- **Waste Scanner** — upload or photograph any item, Gemini identifies:
  - Item name, material, category, recyclability
  - Estimated weight, CO₂ saved, landfill diversion
  - Danger level, recommended action (recycle / reuse / sell / request pickup)
  - Resale value estimate in BDT
  - Eco tip + eco points earned
  - Full scan history saved per user
- **Recycling Chat** — Gemini-powered conversational assistant for recycling questions
- **AI Price Suggestion** — suggests resale price range for a listing based on item + condition

### Notifications
- In-app notifications for all key events (pickup accepted, offer received, status updates, eco milestones)
- Firebase Cloud Messaging for push notifications
- Mark individual or all notifications as read
- Unread badge count

### In-App Messaging
- Conversations list between buyers and sellers
- Real-time chat screen with message status (sent/delivered/read)

### Admin API
- Dashboard stats: total users, pickups, listings, CO₂ saved, eco points distributed
- User management: search, filter by role, ban/unban, change role
- Pickup management: view all, filter by status, manually assign a collector
- Listing moderation: view all (including soft-deleted), force delete
- Analytics: pickups per day (last 30 days), waste category breakdown, top 10 collectors by jobs/weight/rating

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile Frontend | Flutter 3, Dart |
| State Management | flutter_bloc (BLoC pattern) |
| Dependency Injection | get_it (lazy singletons + factories) |
| HTTP Client | Dio with JWT auth interceptor |
| Secure Storage | flutter_secure_storage (encrypted prefs) |
| Backend Runtime | Node.js |
| Backend Framework | Express.js |
| Database | PostgreSQL |
| ORM | Sequelize |
| Authentication | JWT (access + refresh tokens), bcryptjs |
| Realtime | WebSocket (ws library) |
| AI | Google Gemini 2.0 Flash (Vision + Chat) |
| Push Notifications | Firebase Cloud Messaging |
| Email | Nodemailer (Gmail SMTP) |
| File Uploads | Multer |
| Security | Helmet, CORS, custom in-memory rate limiter, express-validator |

---

## Architecture

### Frontend (Flutter)
Follows **Clean Architecture** — strictly separated into data, domain, and presentation layers per feature.

```
lib/
  core/
    constants/    # Colors, theme, spacing, enums, eco levels
    di/           # GetIt injection container
    errors/       # Failures, exceptions, error handler
    network/      # Dio ApiClient + auth interceptor
    services/     # Gemini, image upload, push notifications
    widgets/      # Shared: buttons, cards, chips, inputs, loaders
  features/
    auth/
    marketplace/
    pickup/
    eco_score/
    messaging/
    notifications/
    ai/
```

Each feature: `data/` (models, remote datasources, repo impl) → `domain/` (entities, repo interfaces) → `presentation/` (BLoC + pages + widgets)

### Backend (Node.js)
MVC-style Express app with Sequelize ORM.

```
backend/src/
  config/       # Database connection (Sequelize)
  middleware/   # JWT auth, Multer upload
  models/       # User, Listing, Offer, Pickup, EcoActivity, Notification, Otp, WasteScan
  routes/       # auth, listings, pickups, eco, ai, notifications, admin
  services/     # aiVisionService (Gemini), ecoImpactEngine, emailService
  server.js     # Express app + WebSocket server
```

---

## Database Models

| Model | Key Fields |
|---|---|
| `User` | id, full_name, email, password (bcrypt), role, eco_points, eco_level, streaks, fcm_token |
| `Listing` | id, user_id, title, description, price, category, condition, images[], status, views |
| `Offer` | id, listing_id, buyer_id, amount, message, status |
| `Pickup` | id, user_id, collector_id, waste_category, estimated_weight, address, lat/lng, status, qr_token, scheduled_date, time_slot, is_recurring, collector_lat/lng, eta_minutes, rating |
| `EcoActivity` | id, user_id, type, points, description, metadata |
| `Notification` | id, user_id, type, title, message, is_read, data |
| `Otp` | id, email, code, purpose, expires_at, is_used, attempts |
| `WasteScan` | id, user_id, image_url, item_name, material, category, is_recyclable, confidence, co2_saved_kg, points_earned, raw_response |

---

## API Overview

```
POST   /auth/register              Register + send OTP
POST   /auth/verify-email          Verify OTP → receive JWT
POST   /auth/login                 Login
POST   /auth/refresh               Refresh access token
POST   /auth/forgot-password       Send reset OTP
POST   /auth/reset-password        Reset with token
GET    /auth/me                    Current user

GET    /listings                   All active listings (paginated, searchable)
POST   /listings                   Create listing (multipart, up to 5 images)
POST   /listings/:id/offer         Make an offer
PATCH  /listings/offers/:id        Accept or reject offer

GET    /pickups/available          Open jobs for collectors
POST   /pickups                    Create pickup request
POST   /pickups/:id/accept         Collector accepts job
PATCH  /pickups/:id/status         Update status (on_the_way, arrived, etc.)
POST   /pickups/:id/verify-qr      QR code verification → completes pickup
POST   /pickups/:id/rate           Rate collector

GET    /eco/stats                  Eco score + impact stats
GET    /eco/leaderboard            Top 20 users

POST   /ai/scan                    Gemini vision scan
POST   /ai/chat                    Gemini recycling chat
POST   /ai/suggest-price           AI price suggestion

GET    /notifications              User notifications (paginated)
POST   /notifications/read         Mark as read

GET    /admin/dashboard            Platform overview stats
GET    /admin/analytics            Daily pickups, category breakdown, top collectors

WS     /ws                        Realtime collector location updates
```

---

## Setup

### Backend

```bash
cd backend
npm install

# Create PostgreSQL database
createdb felona

# Configure environment
cp .env.example .env
# Fill in: DB_HOST, DB_NAME, DB_USER, DB_PASSWORD, JWT_SECRET, GEMINI_API_KEY, EMAIL_USER, EMAIL_PASS

# Start dev server
npm run dev

# (Optional) Seed with sample data
npm run db:seed
```

### Flutter App

```bash
flutter pub get

# Run with Gemini key
flutter run --dart-define=GEMINI_API_KEY=your_key_here
```

### Environment Variables

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=felona
DB_USER=postgres
DB_PASSWORD=your_password
JWT_SECRET=your_jwt_secret
JWT_REFRESH_SECRET=your_refresh_secret
GEMINI_API_KEY=your_gemini_key
EMAIL_USER=your_gmail@gmail.com
EMAIL_PASS=your_app_password
PORT=3000
NODE_ENV=development
```

---

## Role-Based Navigation

| Role | Tab 1 | Tab 2 | Tab 3 | Tab 4 | Tab 5 |
|---|---|---|---|---|---|
| Normal User | Home Dashboard | Marketplace | My Pickups | Eco Score | Profile |
| Buyer | Buyer Dashboard | Browse | My Offers | Messages | Profile |
| Collector | Collector Dashboard | Available Jobs | Job History | Earnings | Profile |
