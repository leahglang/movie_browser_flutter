![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Dart](https://img.shields.io/badge/Dart-3.x-blue)
![State Management](https://img.shields.io/badge/BLoC-Cubit-orange)
![Storage](https://img.shields.io/badge/Storage-Hive-yellow)
![Networking](https://img.shields.io/badge/HTTP-Dio-purple)

# 🎬 Movie Finder App

A Flutter application for searching movies using the OMDb API.

The app allows users to search for movies, view detailed information, and manage a list of favorite movies with local persistence.

---
📚 Table of Contents

Overview

App Screenshot

Getting Started

Technologies

Features

Project Structure

---

## 📱 App Screenshot

![Movie Finder Screenshot](assets/screenshots/screenshot.png)

---

## 🚀 Getting Started

### Clone the repository

```bash
git clone https://github.com/leahglang/movie_browser_flutter.git
cd movie_browser_flutter
```

### Create a `.env` file

```env
BASE_URL=https://www.omdbapi.com
OMDB_API_KEY=your_api_key_here
```

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

---

## 🛠 Technologies

* Flutter
* Dart
* BLoC / Cubit
* Dio
* Hive
* intl (localization)
* OMDb API

The project follows **Clean Architecture** principles with separated UI, state management, and data layers.

---

## ✨ Features

* 🔎 Search movies by title
* 📄 Paginated search results
* 🕘 Search history (stored locally)
* 🎞 View movie details
* 📡 Network fallback to cached movie details
* ⭐ Add / remove favorites
* 💾 Local persistence using Hive
* 🌍 Localization (English / Hebrew)
* ⚠️ Localized error handling
* ♿ Basic accessibility support

---

## 📂 Project Structure

```
 ├── assets/
 │    └── lang/          # localization files (JSON)
 ├── lib/
 │    ├── blocs/         # state management
 │    ├── models/        # data models
 │    ├── repositories/  # API & local data handling
 │    ├── screens/       # UI screens
 │    ├── widgets/       # reusable widgets
 │    └── core/          # utilities and localization
 |── .env
```

---

## 📄 License

This project is intended for **educational and demonstration purposes**.
