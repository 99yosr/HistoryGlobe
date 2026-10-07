# 🌍 HistoryGlobe

> Explore world history on an interactive 3D globe, with AI-powered summaries and quizzes.

**HistoryVerse** (`history_globe`) is a cross-platform **Flutter** app that turns history into something you explore. Spin a 3D globe, tap a country, and travel through its historical **periods**, key **events** and important **figures**. An AI backend summarizes events and generates quizzes from them, and your quiz scores are saved so you can follow your progress.

---

## ✨ Features

### 🗺️ Interactive 3D globe
- 3D globe map powered by **MapLibre GL**
- Country markers loaded from Firestore, with a coordinate and color for each country
- Tap a country to open its historical timeline

### 📜 Historical timeline
- **Periods**: each country's history split into eras
- **Events**: every period lists its events with dates, descriptions and sources
- **Historical figures**: profile pages with role, lifespan, significance and portrait (e.g. Hannibal, Ibn Khaldoun, Bourguiba)

### 🤖 AI-powered learning
- **Event summaries**: get a short AI summary of a long historical text
- **Quiz generation**: multiple-choice quizzes generated automatically from an event's content
- Runs on a local **Flask + Ollama** server (a local LLM, so no paid API is needed)

### 🧠 Quizzes and progress
- Answer the questions, get your score and a feedback message at the end
- Scores are saved per user in Firestore
- **Quiz history** page with score, percentage and date for each attempt

### 📅 "On This Day"
- Historical facts for today's date, fetched from an external "day in history" API

### 👤 Accounts and personalization
- Email/password sign-up and login with **Firebase Authentication**
- Animated landing page (Lottie globe animation)
- **Light / dark / system theme**, saved with SharedPreferences

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter (Dart SDK ^3.9) |
| State management | Provider |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| Map / globe | MapLibre GL |
| AI backend | Flask + Ollama (local LLM) via HTTP |
| Animations | Lottie |
| Other | http, intl, carousel_slider, shared_preferences, webview_flutter |

---

## 🏗️ Architecture

The project follows a layered structure: **data → state → presentation**.

```
lib/
├── main.dart                 # Entry point, Firebase initialization
├── app.dart                  # MaterialApp, themes, providers
├── firebase_options.dart
├── config/
│   ├── router.dart           # Named routes
│   └── themes.dart           # Light & dark themes
├── data/
│   ├── models/               # Country, Period, Event, Character, Quiz, HistoricalFact
│   ├── repositories/         # User repository
│   └── services/
│       ├── ai_service.dart           # Summary & quiz generation (Flask API)
│       ├── firebase_auth_service.dart
│       └── firestore_service.dart
└── presentation/
    ├── state/                # AuthProvider, CountryProvider, TimelineProvider, ThemeProvider
    └── pages/
        ├── landing/          # Landing page
        ├── auth/             # Login & Register
        ├── home/             # 3D globe map
        ├── timeline/         # Periods, events, event details, character details
        └── quiz/             # Quiz & quiz history
```

### 🔥 Firestore structure

```
countries/{countryId}
 ├── periods/{periodId}
 │     └── events/{eventId}
 └── figures/{figureId}

users/{userId}
 └── quiz_scores/{scoreId}
```

---

## 🧭 App Flow

```
Landing ─► Login / Register ─► 3D Globe
                                  │ tap a country
                                  ▼
                           Period Timeline
                                  │
                   ┌──────────────┴──────────────┐
                   ▼                             ▼
             Event Details                 Character Details
        (AI summary + quiz) ─► Quiz ─► Score saved ─► Quiz History
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart ^3.9)
- A Firebase project with **Authentication (Email/Password)** and **Cloud Firestore** enabled
- Python 3 + Flask and [Ollama](https://ollama.com/) for the AI features

### 1. Clone and install
```bash
git clone https://github.com/<your-username>/history_globe.git
cd history_globe
flutter pub get
```

### 2. Set up Firebase
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
This generates `lib/firebase_options.dart` and `android/app/google-services.json`.
Then fill Firestore with `countries`, using the structure above.

### 3. Start the AI server
The app expects a Flask server on port **5000** with these endpoints:

| Endpoint | Body | Response |
|----------|------|----------|
| `POST /summarize` | `{ "text": "..." }` | `{ "summary": "..." }` |
| `POST /quiz` | `{ "text": "..." }` | `{ "quiz": [ { "question", "options", "answer" } ] }` |

```bash
ollama serve
python app.py   # your Flask server
```

> The base URL is set in `lib/data/services/ai_service.dart`:
> - Android emulator → `http://10.0.2.2:5000`
> - iOS simulator → `http://localhost:5000`
> - Physical device → your computer's local IP

### 4. Run the app
```bash
flutter run
```

---

## 📦 Generate the app icon
```bash
dart run flutter_launcher_icons
```

---

## 🔮 Possible Improvements
- Deploy the AI backend so it works without a local server
- Search for countries and events
- More countries and historical content
- Offline caching of timelines
- Leaderboards and achievements for quizzes
- Multi-language support

---

## 📄 License

This project was built for educational purposes.
