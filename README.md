# Local Community App

Mobilizing Communities for Economic Development
================================================

A mobile-first, cross-platform open-source application that democratizes access to funding and employment opportunities within local communities worldwide.


Vision
------

Transform economic empowerment globally through a Flutter-based platform connecting fundraising campaigns, job opportunities, marketplace services, and community impact analytics—starting with a single-city pilot, scaling to worldwide adoption.


Core Value Proposition
-----------------------

- **For Entrepreneurs/Initiators:** Access to localized funding and talent pools
- **For Job Seekers:** Discover employment opportunities and contribute skills locally  
- **For Communities:** Stimulate economic growth through transparent, accessible resource mobilization
- **For the World:** A replicable, adaptable framework for any community, region, or nation

This project is 100% open-source and designed to remain community-owned. No single person or entity should financially benefit from the core platform: the recommended rollout is zero commissions and zero fees (0% commission, 0 fees) to prioritize fast, broad, and inclusive economic stimulation and mobilization.


Key Features
------------

### Phase 1: MVP
- **Campaign System:** Create and fund business startups, community projects, and social initiatives
- **Job Board:** Post jobs and apply for local employment opportunities
- **Wallet System:** Secure payment processing with Stripe Connect integration
- **Location-Based Discovery:** Find relevant campaigns and jobs within customizable radius
- **Community Impact Statistics:** Calculate per-capita contribution impact with population data
- **Real-Time Updates:** Live campaign progress tracking and notifications

### Phase 2: Enhanced Features
- Social features (share, comment, follow)
- Advanced search with AI-powered recommendations
- Multi-language support (5+ languages)
- Business directory and marketplace
- Analytics dashboards for creators and administrators

### Phase 3: Full Ecosystem
- Accommodation & rentals module
- Transport services integration
- Cryptocurrency payment support
- Custom deployment options for organizations (core platform remains 100% open-source and the default deployment is non-profit; the recommended model is 0% commission, 0 fees)
- API for third-party integrations


Technology Stack
----------------

- **Frontend:** Flutter 3.24+ (iOS, Android, Web, Desktop)
- **Backend:** Firebase/Supabase (Authentication, Firestore, Cloud Functions)
- **Payments:** Stripe Connect (primary), PayPal, Flutterwave, Razorpay
- **Search:** Algolia or Meilisearch
- **Maps:** Google Maps Platform or Mapbox
- **Analytics:** Firebase Analytics, Mixpanel


Development System
------------------

This project uses an **Agent-Based Development Model** with specialized AI agents:

- **Navigator Agent:** Strategic planning & product management
- **Architect Agent:** System design & infrastructure  
- **Builder Agent:** Implementation (frontend & backend)
- **Security & Compliance Agent:** Authentication, payments, fraud prevention
- **Quality & Reliability Agent:** Testing, performance, monitoring
- **Documentation & Advocacy Agent:** Technical docs & community engagement

See [AGENTS.md](AGENTS.md) for detailed agent responsibilities and workflows.


Getting Started
---------------

### Prerequisites

To run this project, you need to install Dart and Flutter. Firebase and Stripe are optional for demo purposes.

#### Installing Flutter (includes Dart)

1. Download the Flutter SDK from the official website: https://flutter.dev/docs/get-started/install/linux

2. Extract the downloaded file to a desired location, e.g., `~/flutter`:

   ```bash
   tar xf ~/Downloads/flutter_linux_*.tar.xz -C ~/
   ```

3. Add Flutter to your PATH by adding the following line to your `~/.bashrc` or `~/.zshrc`:

   ```bash
   export PATH="$PATH:~/flutter/bin"
   ```

4. Reload your shell or run `source ~/.bashrc` (or equivalent).

5. Verify the installation:

   ```bash
   flutter doctor
   ```

This will install both Flutter and Dart, as Dart is bundled with Flutter.

For more information on Dart, visit: https://dart.dev/get-dart

### Installation

```bash
# Clone the repository
git clone https://github.com/aequchain/Local-Community-App.git
cd Local-Community-App/local_community_app

# Install Flutter dependencies
flutter pub get

# Run the app
# For any connected device (mobile/web/desktop)
flutter run

# For Chrome browser in release mode with WASM
flutter run -d chrome --release --wasm

# For Linux desktop
flutter run -d linux

# For Android mobile
flutter run --release # Connected Android device with USB debugging/debug mode ENABLED in you Android device Settings > Developer Options


# Other platform options:
# Android emulator: 
flutter run -d emulator
# iOS simulator (macOS only): 
flutter run -d simulator
# Specific device: flutter run -d <device_id> (use `flutter devices` to list available devices)
```

### Development Setup

See the [comprehensive development plan](Local%20Community%20App.md) for detailed architecture, database schemas, and implementation guidance.

### Current build snapshot (October 2025)
- ✅ Flutter 3.35 project scaffolded under `local_community_app/`
- ✅ Riverpod + GoRouter + Aequus design tokens wired into a responsive landing screen prototype
- ✅ Firebase CLI installed and authenticated (next step: `firebase init firestore functions hosting storage emulators` inside `local_community_app/` to generate config files)
- ✅ Free-tier friendly dependency set (Firebase Spark, Flutter web builds, no paid APIs wired yet)
- 🔜 Implement authentication onboarding flow followed by campaign/job domain models backed by Firestore


Contributing
------------

We welcome contributions from the global community! This open-source project aims to empower local communities worldwide.

### How to Contribute
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Standards
- Follow official Dart style guide with `effective_dart` lints
- Maintain 80%+ test coverage (unit, widget, integration tests)
- Use Fibonacci/prime number spacing for design consistency
- Include dartdoc comments for public APIs
- Ensure accessibility compliance (WCAG 2.1 AA)


Project Structure
-----------------

```
local_community_app/lib/
└── src/
	├── app.dart                # Root MaterialApp with routing & themes
	├── bootstrap.dart          # ProviderScope + guarded bootstrapper
	├── core/                   # (WIP) shared constants, utilities
	├── features/
	│   └── landing/            # First responsive screen + widgets
	├── routing/                # GoRouter configuration
	└── theme/                  # Aequus design tokens & theme builder

docs/
├── architecture/   # Architecture Decision Records (ADRs)
├── guides/         # User and developer guides
└── runbooks/       # Operational procedures
```


Roadmap
-------

MVP launch (single city pilot)  
Feature expansion and multi-city rollout  
International expansion (10+ countries)  
Full ecosystem with marketplace and AI features

See [Local Community App.md](Local%20Community%20App.md) for detailed phase breakdowns.


License
-------

MIT License - see LICENSE file for details


Community & Support
-------------------

- **Documentation:** [Local Community App.md](Local%20Community%20App.md)
- **Development System:** [AGENTS.md](AGENTS.md)
- **Issues:** GitHub Issues for bug reports and feature requests
- **Discussions:** GitHub Discussions for Q&A and ideas

---

**Built with fellowship by the global community for local communities everywhere**
