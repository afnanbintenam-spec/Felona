# FeloNa ♻️

**AI-powered circular economy platform** — connecting users, buyers, and collectors in a sustainable ecosystem.

## Features

- 🤖 **AI Waste Scanner** — Take a photo, AI identifies waste category & disposal method
- 💬 **AI Recycling Assistant** — Chat with AI about recycling questions
- 🛒 **Marketplace** — List and sell reusable items
- 🚛 **Pickup Scheduling** — Request waste collection with timeline tracking
- 🌱 **Eco Score** — Gamified sustainability with levels (Seed → Earth)
- 📊 **Impact Tracking** — CO₂ saved, weight recycled, streaks

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter (Dart) |
| State Management | flutter_bloc |
| Backend | Node.js + Express |
| Database | PostgreSQL + Sequelize |
| AI | Google Gemini API |
| Auth | JWT |
| Architecture | Clean Architecture |

## Project Structure

```
felo_na/
├── lib/                    # Flutter app
│   ├── core/              # Shared: colors, widgets, services, errors
│   ├── features/          # Feature modules
│   │   ├── auth/          # Authentication
│   │   ├── ai/            # AI scanner + chatbot
│   │   ├── marketplace/   # Listings + offers
│   │   ├── pickup/        # Waste pickup
│   │   ├── eco_score/     # Gamification
│   │   └── notifications/ # Push notifications
│   └── main.dart
├── backend/               # Node.js API
│   ├── src/
│   │   ├── models/        # Sequelize models
│   │   ├── routes/        # Express routes
│   │   ├── middleware/    # Auth, upload
│   │   └── server.js
│   └── package.json
├── Assets/                # Images + SVG illustrations
└── test/                  # Unit tests
```

## Getting Started

### Flutter App
```bash
flutter pub get
flutter run -d chrome    # Web
flutter run              # Mobile
```

### Backend
```bash
cd backend
npm install
# Set up PostgreSQL and create 'felona' database
npm run db:seed          # Seed demo data
npm run dev              # Start server at localhost:3000
```

## User Roles

- **Normal User** — List items, request pickups, earn eco points
- **Buyer** — Browse marketplace, make offers
- **Collector** — Accept pickup jobs, complete collections

## License

MIT
