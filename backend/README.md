# FeloNa Backend

Node.js + Express + PostgreSQL API for the FeloNa circular economy platform.

## Setup

### 1. Install PostgreSQL
Download from https://www.postgresql.org/download/

### 2. Create Database
```bash
createdb felona
```
Or via psql:
```sql
CREATE DATABASE felona;
```

### 3. Configure Environment
```bash
cp .env.example .env
# Edit .env with your PostgreSQL credentials
```

### 4. Install Dependencies
```bash
npm install
```

### 5. Seed Database (optional — creates demo data)
```bash
npm run db:seed
```

### 6. Start Server
```bash
npm run dev
```

Server runs at `http://localhost:3000`

## API Endpoints

### Auth
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /auth/register | Register new user |
| POST | /auth/login | Login |
| GET | /auth/me | Get current user |
| PUT | /auth/profile/:id | Update profile |
| POST | /auth/profile/:id/picture | Upload profile picture |

### Listings (Marketplace)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /listings | Get all listings (paginated) |
| GET | /listings/:id | Get single listing |
| POST | /listings | Create listing (auth required) |
| DELETE | /listings/:id | Delete listing (owner only) |

### Pickups
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /pickups | Get user's pickups |
| GET | /pickups/available | Available pickups (collectors) |
| POST | /pickups | Create pickup request |
| PUT | /pickups/:id/accept | Collector accepts pickup |
| PUT | /pickups/:id/status | Update pickup status |

### Eco Score
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /eco/stats | Get user's eco stats |
| GET | /eco/history | Get point history |
| GET | /eco/leaderboard | Global leaderboard |

## Test Accounts (after seeding)
- **Normal User:** afnan@felona.app / password123
- **Buyer:** sara@example.com / password123
- **Collector:** rahim@example.com / password123
