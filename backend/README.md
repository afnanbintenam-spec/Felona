# FeloNa Backend API

Node.js + Express + PostgreSQL backend for the FeloNa Smart Waste Management platform.

## Features

- **Authentication**: JWT with access/refresh tokens, email OTP verification, password reset
- **Marketplace**: CRUD listings, offers, image uploads
- **Pickup Scheduling**: Calendar-based scheduling, recurring pickups, QR verification
- **Live Tracking**: WebSocket-based realtime collector location updates
- **Eco Score**: Points, streaks, leaderboard, activity history
- **AI**: Gemini-powered waste scanning and recycling chat
- **Notifications**: In-app notifications for all status changes
- **Admin Panel API**: Dashboard stats, user management, pickup assignment, analytics
- **Security**: Rate limiting, helmet, CORS, bcrypt, JWT rotation

## Tech Stack

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: PostgreSQL + Sequelize ORM
- **Auth**: JWT (access + refresh tokens)
- **Realtime**: WebSocket (ws)
- **AI**: Google Generative AI (Gemini)
- **Email**: Nodemailer (Gmail SMTP)
- **File Upload**: Multer

## Setup

```bash
# 1. Install dependencies
npm install

# 2. Create PostgreSQL database
createdb felona

# 3. Configure environment
cp .env.example .env
# Edit .env with your values

# 4. Start development server
npm run dev

# 5. (Optional) Seed database
npm run db:seed
```

## API Endpoints

### Auth (`/auth`)
- `POST /auth/register` — Register new user
- `POST /auth/verify-email` — Verify email with OTP
- `POST /auth/login` — Login
- `POST /auth/refresh` — Refresh token
- `POST /auth/forgot-password` — Request reset OTP
- `POST /auth/reset-password` — Reset password
- `POST /auth/change-password` — Change password (authenticated)
- `GET /auth/me` — Get current user
- `PUT /auth/profile/:userId` — Update profile

### Pickups (`/pickups`)
- `GET /pickups` — User's pickups
- `GET /pickups/available` — Available for collectors
- `GET /pickups/active` — Collector's active job
- `GET /pickups/history` — Paginated history
- `GET /pickups/collector/stats` — Collector dashboard stats
- `GET /pickups/:id` — Single pickup detail
- `GET /pickups/:id/tracking` — Live tracking data
- `POST /pickups` — Create pickup (with scheduling)
- `POST /pickups/:id/accept` — Collector accepts
- `PATCH /pickups/:id/status` — Update status
- `POST /pickups/:id/complete` — Mark completed
- `POST /pickups/:id/verify-qr` — QR verification
- `POST /pickups/:id/rate` — Rate pickup
- `POST /pickups/:id/location` — Update collector location
- `DELETE /pickups/recurring/:scheduleId` — Cancel recurring

### Listings (`/listings`)
- `GET /listings` — All active listings (paginated, searchable)
- `GET /listings/:id` — Single listing
- `POST /listings` — Create listing
- `DELETE /listings/:id` — Delete listing

### Eco Score (`/eco`)
- `GET /eco/stats` — User's eco stats
- `GET /eco/history` — Point history
- `GET /eco/leaderboard` — Top users

### Notifications (`/notifications`)
- `GET /notifications` — User's notifications
- `POST /notifications/read` — Mark as read
- `DELETE /notifications/:id` — Delete notification

### Admin (`/admin`)
- `GET /admin/dashboard` — Overview stats
- `GET /admin/users` — List users
- `PATCH /admin/users/:id` — Update user (ban/role)
- `GET /admin/pickups` — All pickups
- `POST /admin/pickups/:id/assign` — Assign collector
- `GET /admin/listings` — All listings
- `DELETE /admin/listings/:id` — Remove listing
- `GET /admin/analytics` — Detailed analytics

### AI (`/ai`)
- `POST /ai/scan` — Scan waste image
- `POST /ai/chat` — Recycling chat

### WebSocket (`ws://host:port/ws`)
- Send `{ type: "auth", token: "..." }` to authenticate
- Collectors send `{ type: "location_update", pickup_id, latitude, longitude, eta_minutes }`
- Requesters receive `{ type: "tracking_update", pickup_id, latitude, longitude, eta_minutes }`

## Environment Variables

See `.env.example` for all required configuration.
