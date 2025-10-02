# Local Community App - Development Progress

## 🎨 Aequus Design System Implementation

This Flutter application implements the **Aequus Design Protocol** - a comprehensive design system based on mathematical harmony using Fibonacci spacing and prime-number animation durations.

### Design Tokens

#### Spacing (Fibonacci Sequence)
```dart
s3: 3px    s5: 5px    s8: 8px    s13: 13px
s21: 21px  s34: 34px  s55: 55px  s89: 89px
s144: 144px
```

#### Animation Durations (Prime Numbers)
```dart
p89: 89ms (fast)        // Instant feedback
p233: 233ms (moderate)  // Quick transitions
p377: 377ms (relaxed)   // Smooth animations
p610: 610ms (slow)      // Deliberate effects
```

#### Border Radii (Fibonacci)
```dart
s3, s5, s8, s13, s21, s34
```

#### Responsive Breakpoints
- **Mobile**: < 610px (P4)
- **Tablet**: 610px - 987px (P5)
- **Desktop**: > 987px

#### Golden Ratio
- Image aspect ratios: 1.618:1
- Line height for body text: 1.618

---

## 📦 Feature Modules Implemented

### 1. **Landing Page** ✅
- **Location**: `lib/src/features/landing/`
- **Components**:
  - Animated hero section with fade-in and slide-up effects
  - Impact metrics cards (campaigns, raised, supported)
  - Call-to-action buttons with navigation
  - Roadmap bottom sheet with dismissible gesture
- **Design**: Full-screen gradient background, staggered animations using Fibonacci timing

### 2. **Authentication** ✅
- **Location**: `lib/src/features/auth/`
- **Architecture**:
  - Domain layer: `AuthUser` model, `AuthRepository` interface
  - Data layer: `MockAuthRepository` (simulates Firebase with 233-610ms delays)
  - Application layer: `AuthService` with Riverpod providers
  - Presentation layer: `SignInScreen` with form validation
- **Features**:
  - Email/password sign-in with validation
  - Google OAuth simulation
  - Password visibility toggle
  - Error handling with user-friendly messages
  - Automatic navigation to campaign feed on success

### 3. **Campaign Discovery** ✅
- **Location**: `lib/src/features/campaigns/`
- **Architecture**:
  - Domain layer: `Campaign`, `CampaignLocation`, `FundingGoal` models
  - Data layer: `MockCampaignRepository` with 5 realistic African campaigns
  - Application layer: `CampaignService` with stream/future providers
  - Presentation layer: Feed screen with responsive grid
- **Components**:
  - **Campaign Feed Screen**:
    - Responsive grid (1/2/3 columns based on screen width)
    - Pull-to-refresh functionality
    - Staggered card animations (233ms + index × 34ms)
    - Loading, error, and empty states
  - **Campaign Card**:
    - MouseRegion hover detection
    - AnimatedBuilder for scale (1.0 → 1.02) and elevation (2.0 → 8.0)
    - Golden ratio image aspect ratio (1.618:1)
    - Progress bar showing funding percentage
    - Category badges with type-specific colors
    - Tap navigation to detail screen
  - **Campaign Detail Screen**:
    - Collapsing SliverAppBar with hero image
    - Scroll-aware app bar background
    - Funding progress section with metrics
    - Campaign description with golden ratio line height
    - Creator profile card
    - Location section with coordinates
    - Floating action button for contributions
    - Contribution bottom sheet with quick amounts

### 4. **Profile Management** ✅
- **Location**: `lib/src/features/profile/`
- **Components**:
  - Profile header with avatar (photo or initials)
  - Statistics cards (campaigns supported, total contributed)
  - Account settings section (Edit Profile, Notifications, Privacy)
  - Sign-out functionality with confirmation dialog
  - State-aware UI (shows sign-in prompt when logged out)

### 5. **Navigation** ✅
- **Location**: `lib/src/routing/app_router.dart`
- **Implementation**: GoRouter with Riverpod integration
- **Routes**:
  - `/` - Landing page (no transition)
  - `/sign-in` - Sign-in screen (fade transition)
  - `/campaigns` - Campaign feed (fade + slide transition)
  - `/campaigns/:id` - Campaign detail (fade transition)
  - `/profile` - Profile screen (fade transition)
- **Features**:
  - Auth state watching for conditional navigation
  - Custom transition animations using Fibonacci timing
  - Path parameters for campaign details
  - Bottom navigation bar (Discover ↔ Profile)

---

## 🏗️ Architecture

### Clean Architecture Layers

```
lib/src/features/<feature>/
├── domain/           # Business entities and repository interfaces
├── data/            # Repository implementations (mock/real)
├── application/     # Use cases and Riverpod providers
└── presentation/    # UI screens and widgets
```

### State Management
- **Riverpod 2.x** for dependency injection and state management
- Providers for:
  - `authStateChangesProvider` (Stream) - Authentication state
  - `activeCampaignsProvider` (Stream) - Real-time campaign updates
  - `fetchCampaignsProvider` (Future) - One-time campaign fetch
  - `campaignByIdProvider(id)` (Future) - Individual campaign details

### Mock Implementations
All repositories have mock implementations for development without Firebase:
- **MockAuthRepository**: Simulates sign-in with 233-610ms delays
- **MockCampaignRepository**: Provides 5 sample campaigns with realistic data
- Mock data includes campaigns from Nairobi, Accra, Lagos, Cape Town, Cairo

---

## 🎯 Responsive Design

### Breakpoint Logic
```dart
final width = MediaQuery.of(context).size.width;
final crossAxisCount = width < 610 ? 1 : (width < 987 ? 2 : 3);
```

### Mobile (< 610px)
- Single column grid
- Full-width cards
- Compact spacing (F1-F8)

### Tablet (610-987px)
- Two-column grid
- Medium spacing (F8-F13)
- Touch-optimized buttons

### Desktop (> 987px)
- Three-column grid
- Generous spacing (F13-F21)
- Hover interactions

---

## 🎭 Animation Specifications

### Timing Functions
```dart
// Fast feedback (hover, button press)
AequusDesignTokens.durations.fast // 89ms (P2)

// Moderate transitions (page navigation)
AequusDesignTokens.durations.moderate // 233ms (P3)

// Relaxed animations (list items, cards)
AequusDesignTokens.durations.relaxed // 377ms (P5)

// Slow, deliberate effects (hero animations)
AequusDesignTokens.durations.slow // 610ms (P4)
```

### Staggered Animations
```dart
// Campaign feed cards
final delay = Duration(
  milliseconds: 233 + (index * 34), // P3 + (index × F7)
);
```

### Hover Interactions
```dart
// Campaign card hover
Transform.scale(
  scale: 1.0 + (controller.value * 0.02), // 2% scale increase
  child: Card(
    elevation: 2.0 + (controller.value * 6), // 2 → 8 elevation
  ),
);
```

---

## 📊 Sample Data

### Campaign Types
1. **Agriculture** (Green) - Farm irrigation project in Nairobi
2. **Education** (Blue) - Computer lab in Accra
3. **Healthcare** (Pink) - Maternal clinic in Lagos
4. **Infrastructure** (Purple) - Solar-powered water pumps in Cape Town
5. **Business** (Orange) - Women's cooperative in Cairo

Each campaign includes:
- Title, description, and image URL
- Creator name and supporter count
- Funding goal (target + current + currency)
- Geographic location (city, country, lat/lng)
- Status (active/completed/cancelled)
- Dates (start, end)
- Category and tags

---

## 🚀 Getting Started

### Prerequisites
```bash
Flutter SDK: >=3.35.0
Dart SDK: >=3.9.0
```

### Dependencies
```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  go_router: ^14.7.2
  intl: ^0.20.1
```

### Run the App
```bash
cd local_community_app
flutter pub get
flutter run
```

### Development Workflow
1. **Sign in** with any email/password (mock auth always succeeds)
2. **Browse campaigns** on the feed screen
3. **Tap a campaign** to view details
4. **Contribute** via the bottom sheet
5. **Navigate to profile** using bottom nav bar
6. **Sign out** from profile screen

---

## 🔮 Future Enhancements

### Phase 1 (Backend Integration)
- [ ] Replace mock repositories with Firebase implementations
- [ ] Implement actual authentication (Email, Google, Phone)
- [ ] Real-time campaign sync with Firestore
- [ ] Cloud Storage for campaign images

### Phase 2 (Payment)
- [ ] Stripe/Paystack payment integration
- [ ] Wallet management
- [ ] Transaction history
- [ ] Receipt generation

### Phase 3 (Discovery)
- [ ] Search functionality with filters (type, location, status)
- [ ] Sort options (newest, trending, most funded, ending soon)
- [ ] Map view showing campaign locations
- [ ] Bookmarking/favoriting campaigns

### Phase 4 (Engagement)
- [ ] Campaign creation flow for creators
- [ ] Comment system on campaign details
- [ ] Social sharing (Twitter, WhatsApp, Email)
- [ ] Push notifications for updates

### Phase 5 (Trust & Safety)
- [ ] Campaign verification badges
- [ ] Withdrawal tracking for transparency
- [ ] Reporting system for suspicious campaigns
- [ ] KYC for campaign creators

---

## 📐 Design Principles

### 1. **Mathematical Harmony**
All spacing, timing, and proportions derive from Fibonacci sequence and prime numbers, creating a naturally balanced visual rhythm.

### 2. **Progressive Disclosure**
Information is revealed gradually (card → detail → contribution) to prevent overwhelming users.

### 3. **Responsive by Default**
Every component adapts to screen size using breakpoints at 610px and 987px.

### 4. **Accessibility**
- Semantic HTML structure
- ARIA labels for screen readers
- Keyboard navigation support
- Color contrast ratios meet WCAG AA standards

### 5. **Performance**
- Lazy loading for images
- Optimistic UI updates
- Efficient state management with Riverpod
- Mock data for fast development iteration

---

## 🧪 Testing Strategy

### Unit Tests (Planned)
- Repository mock implementations
- Campaign model computed properties
- Form validation logic

### Widget Tests (Planned)
- Campaign card rendering
- Profile screen states
- Authentication flow

### Integration Tests (Planned)
- End-to-end sign-in → browse → contribute flow
- Navigation between screens
- Pull-to-refresh functionality

---

## 📝 Code Conventions

### File Naming
- `snake_case` for file names
- `UpperCamelCase` for class names
- `lowerCamelCase` for variables/methods

### Architecture Patterns
- **Repository Pattern**: Separate data access from business logic
- **Provider Pattern**: Riverpod for dependency injection
- **BLoC-lite**: StateNotifiers for complex state (planned)

### Comments
- Use `//` for single-line explanations
- Document Aequus design token usage with `// Aequus: F13, P3` markers
- Add `TODO:` comments for future enhancements

---

## 📄 License

This project is a development prototype and not yet licensed for production use.

---

## 👥 Contributors

- **Aequus Design System**: Mathematical design framework
- **Flutter Team**: UI framework
- **Riverpod**: State management solution

---

**Last Updated**: 2024 (Milestone 1 - Core Features)
