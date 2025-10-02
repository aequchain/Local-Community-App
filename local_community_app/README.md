# Local Community App

A Flutter-based crowdfunding platform enabling community-driven campaigns with per-capita contribution insights, responsive design, and Material 3 theming.

---

## Project Status Timeline

### **October 2, 2025 - Current State**

**Completed Features:**
- **Authentication Flow**: Login/Register with form validation and Riverpod state management
- **Campaign Discovery**: Responsive grid feed with hover animations and empty states
- **Campaign Details**: Full-screen view with hero image, funding progress, and contribution modal
- **Per-Capita Insights**: Shared widget showing region/city/country contribution breakdowns with adaptive 2-4 decimal formatting, color-coded by scope, and bold inline styling
- **Filter & Search**: Bottom sheet filters (type + location) and full-text search delegate with active filter indicators
- **Design System**: Aequus tokens (Fibonacci spacing: 3,5,8,13,21,34,55,89; durations: 34ms-610ms; radii: 8,13,21)
- **Navigation**: GoRouter with type-safe routing, auth guards, and custom page transitions
- **Testing**: 3/3 unit tests passing (auth flow, widget rendering, campaign detail)
- **Code Quality**: 0 analyzer issues, DRY principle applied with shared widgets

**In Progress / Pending:**
- Create Campaign flow (multi-step form with image upload)
- Contribution processing (payment integration placeholder)
- Profile screen (user info, my campaigns, contribution history)
- Firebase integration (replacing mock repositories)
- Backend API connections

**Next Sprint Priority:**
1. Implement Create Campaign multi-step wizard (~8 hours)
2. Firebase Authentication + Firestore integration
3. Profile screen CRUD operations
4. Payment gateway integration prep

---

## Getting Started

### Prerequisites

1. **Dart SDK** (stable)
   ```bash
   # Option A: Install Dart via snap (Linux)
   sudo snap install dart --classic

   # Option B: Install via apt (Ubuntu/Debian) - follow official instructions
   # See: https://dart.dev/get-dart
   ```

2. **Flutter SDK** (3.0.0 or higher)
   ```bash
   # Install Flutter via snap (Linux)
   sudo snap install flutter --classic
   
   # Or download from: https://docs.flutter.dev/get-started/install
   ```

3. **Chrome** (for web deployment)
   ```bash
   # Ubuntu/Debian
   sudo apt install google-chrome-stable
   ```


4. **Git** (for version control)
   ```bash
   sudo apt install git
   ```

5. **Backend / CLI accounts (optional for demo)**

- **Firebase CLI or Supabase account**: If you intend to use Firebase for Authentication/Firestore/Storage, install the Firebase CLI and configure a Firebase project. Alternatively, you can create a Supabase project if you prefer Postgres + Auth. (Not required to run the demo with mock repositories.)

  ```bash
  # Firebase CLI
  npm install -g firebase-tools

  # or Supabase CLI
  npm install -g supabase
  ```

- **Stripe account (optional)**: Required only if you want to wire payments in production. For local demos you can leave payment processing mocked.


### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/aequchain/Local-Community-App.git
   cd Local-Community-App/local_community_app
   ```

2. **Verify Flutter installation:**
   ```bash
   flutter doctor -v
   ```
   Ensure Chrome is detected for web support.

3. **Enable web support:**
   ```bash
   flutter config --enable-web
   ```

4. **Install dependencies:**
   ```bash
   flutter pub get
   ```

5. **Run code generation (for Riverpod/Freezed):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Running the App

#### Development Mode (Chrome)
```bash
flutter run -d chrome
```

#### Production Build (Wasm - Optimized)
```bash
flutter run -d chrome --release --wasm
```

#### Build for Deployment
```bash
# Web build with Wasm renderer
flutter build web --release --wasm

# Output will be in: build/web/
```

### Project Structure

```
lib/
├── src/
│   ├── common/
│   │   ├── design_tokens/        # Aequus design system (spacing, durations, radii)
│   │   ├── widgets/               # Shared components (gradient_scaffold, etc.)
│   │   └── routing/               # GoRouter configuration with auth guards
│   ├── features/
│   │   ├── auth/                  # Login/Register with Riverpod providers
│   │   │   ├── data/              # Mock repository (to be replaced with Firebase)
│   │   │   ├── domain/            # User entity and auth contracts
│   │   │   └── presentation/      # Login/Register screens
│   │   ├── campaigns/             # Campaign discovery and details
│   │   │   ├── data/              # Mock campaign repository
│   │   │   ├── domain/            # Campaign, FundingGoal entities
│   │   │   └── presentation/      # Feed, detail, filter, search, per-capita widgets
│   │   ├── profile/               # User profile (placeholder)
│   │   └── landing/               # Landing page
│   └── app.dart                   # Root app widget with Material 3 theme
└── main.dart                      # Entry point
```

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run analyzer
flutter analyze
```

**Current Test Results:**
- 3/3 tests passing
- 0 analyzer issues

### Development Notes

- **State Management**: Riverpod 2.x with `AsyncNotifierProvider` for async operations
- **Theming**: Material 3 with custom `ColorScheme.fromSeed` (seed: `Color(0xFF6750A4)`)
- **Responsive Design**: `LayoutBuilder` with breakpoints (mobile: <600, tablet: 600-1200, desktop: >1200)
- **Animations**: Fibonacci-based durations (34ms, 55ms, 89ms, 144ms, 233ms, 377ms, 610ms)
- **Routing**: Named routes with type-safe navigation and smooth custom transitions

### Mock Data

The app currently uses mock repositories with sample data:
- 5 sample campaigns (varied types, locations, funding goals)
- Per-capita calculations based on real population data
- Mock authentication (any email/password accepted)

**To integrate real backend:**
1. Replace `MockCampaignRepository` in `lib/src/features/campaigns/data/`
2. Replace `MockAuthRepository` in `lib/src/features/auth/data/`
3. Configure Firebase (see Firebase Integration section below)

### Firebase Integration (Planned)

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login and initialize
firebase login
firebase init

# Add FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for Flutter
flutterfire configure
```

Required Firebase services:
- Authentication (Email/Password provider)
- Firestore Database (campaigns, users collections)
- Storage (campaign images)

---

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Material 3 Design](https://m3.material.io/)
- [GoRouter Package](https://pub.dev/packages/go_router)

---

## Contributing

This project follows the Aequus design manifesto with emphasis on:
- Fibonacci-based spacing and timing
- Accessible color contrasts
- Responsive layouts for all screen sizes
- Clean architecture with feature-first organization

---

## License

[Add your license here]

---

**Last Updated:** October 2, 2025  
**Flutter Version:** 3.x  
**Status:** Active Development
