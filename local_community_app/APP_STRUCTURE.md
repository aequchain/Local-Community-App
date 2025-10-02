# App Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      Landing Page (/)                        │
│  • Hero section with gradient background                    │
│  • Impact metrics (3 cards)                                 │
│  • CTA: "Get started" → Sign In                            │
│  • Bottom sheet: Roadmap with dismissible UI               │
└───────────────────┬─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────┐
│                    Sign In Screen                            │
│  • Email/password form with validation                      │
│  • Google OAuth button (mock)                              │
│  • Password visibility toggle                              │
│  • Animated fade-in + slide-up (F15 timing)               │
└───────────────────┬─────────────────────────────────────────┘
                    │
                    ▼
         ┌──────────────────────┐
         │  Authentication OK    │
         └──────────┬────────────┘
                    │
    ┌───────────────┴───────────────┐
    │                               │
    ▼                               ▼
┌────────────────────┐      ┌──────────────────┐
│  Campaign Feed     │◄────►│  Profile Screen  │
│                    │      │                  │
│  • Responsive grid │ Nav  │  • User stats    │
│  • 1/2/3 columns   │ Bar  │  • Settings      │
│  • Hover effects   │      │  • Sign out      │
│  • Pull-refresh    │      │                  │
└─────────┬──────────┘      └──────────────────┘
          │
          │ Tap card
          ▼
┌─────────────────────────────────────────────────────────────┐
│                  Campaign Detail Screen                      │
│  • Collapsing SliverAppBar with hero image                 │
│  • Funding progress section                                │
│  • Full description                                        │
│  • Creator profile card                                    │
│  • Location map placeholder                                │
│  • FAB: "Contribute" → Bottom Sheet                       │
└─────────────────────────────────────────────────────────────┘
                    │
                    │ Tap FAB
                    ▼
         ┌──────────────────────┐
         │  Contribution Sheet   │
         │  • Quick amounts      │
         │  • Custom input       │
         │  • Confirm button     │
         └──────────────────────┘
```

---

## Screen Hierarchy

```
app/
├── Landing (unauthenticated)
│   └── Sign In
│       └── Campaign Feed (authenticated)
│           ├── Campaign Detail
│           │   └── Contribution Sheet
│           └── Profile
│               └── Settings (future)
```

---

## Navigation Structure

### Routes
| Path | Name | Screen | Transition |
|------|------|--------|------------|
| `/` | `landing` | LandingScreen | None |
| `/sign-in` | `sign-in` | SignInScreen | Fade (233ms) |
| `/campaigns` | `campaign-feed` | CampaignFeedScreen | Fade + Slide (377ms) |
| `/campaigns/:id` | `campaign-detail` | CampaignDetailScreen | Fade (233ms) |
| `/profile` | `profile` | ProfileScreen | Fade (233ms) |

### Bottom Navigation (authenticated screens only)
```
┌─────────────┬─────────────┐
│  Discover   │   Profile   │
│   (icon)    │   (icon)    │
└─────────────┴─────────────┘
```

---

## State Management

### Auth State
```
AuthStateChangesProvider (Stream<AuthUser?>)
    ├── null → Show Landing/Sign-in
    └── AuthUser → Show Campaign Feed
```

### Campaign State
```
ActiveCampaignsProvider (Stream<List<Campaign>>)
    ├── Loading → CircularProgressIndicator
    ├── Error → Error UI with retry
    └── Data → Grid of CampaignCards

CampaignByIdProvider(id) (Future<Campaign>)
    ├── Loading → CircularProgressIndicator
    ├── Error → "Campaign not found"
    └── Data → Campaign detail content
```

---

## Component Tree (Campaign Feed)

```
CampaignFeedScreen (StatefulWidget)
├── Scaffold
│   ├── AppBar
│   │   └── Text: "Discover campaigns"
│   ├── Body
│   │   └── RefreshIndicator
│   │       └── CustomScrollView
│   │           └── SliverPadding
│   │               └── SliverGrid (responsive)
│   │                   └── TweenAnimationBuilder (staggered)
│   │                       └── CampaignCard (×N)
│   │                           ├── MouseRegion (hover)
│   │                           ├── AnimatedBuilder (scale/elevation)
│   │                           └── InkWell (tap → detail)
│   │                               ├── AspectRatio (golden ratio image)
│   │                               ├── Category Badge
│   │                               ├── Title + Location
│   │                               ├── Progress Bar
│   │                               └── Funding Metrics
│   └── BottomNavigationBar
│       ├── Destination: Discover (selected)
│       └── Destination: Profile
```

---

## Data Flow

```
User Action → Provider → Repository → Mock/Firebase → Provider → UI Update
    ↓             ↓           ↓              ↓            ↓          ↓
  Tap card    Watch       Interface    Implementation  Notifier  Rebuild
             Provider                   (Mock/Real)    Listeners  Widget
```

### Example: Sign In Flow
```
1. User enters email/password
2. User taps "Sign in" button
3. SignInScreen calls authService.signInWithEmail()
4. AuthService → AuthRepository.signInWithEmailAndPassword()
5. MockAuthRepository delays 233-610ms (Fibonacci timing)
6. MockAuthRepository emits AuthUser to stream
7. authStateChangesProvider notifies listeners
8. Router rebuilds, navigates to /campaigns
9. CampaignFeedScreen watches activeCampaignsProvider
10. MockCampaignRepository emits 5 campaigns
11. Grid renders campaign cards with staggered animations
```

---

## Responsive Grid Logic

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final width = constraints.maxWidth;
    final crossAxisCount = switch (width) {
      < 610 => 1,           // Mobile (Aequus P4)
      < 987 => 2,           // Tablet (Aequus P5)
      _ => 3,               // Desktop
    };
    return GridView(...);
  },
)
```

### Breakpoint Examples
- **iPhone SE** (375px): 1 column
- **iPad Mini** (768px): 2 columns
- **MacBook Pro** (1440px): 3 columns

---

## Animation Timeline (Campaign Card)

```
Hover Enter:
  0ms ──────────────────────► 89ms
  Scale:     1.0 → 1.02
  Elevation: 2.0 → 8.0
  Curve: easeOut

Hover Exit:
  0ms ──────────────────────► 89ms
  Scale:     1.02 → 1.0
  Elevation: 8.0 → 2.0
  Curve: easeIn

Page Enter (staggered):
  Card 1: 233ms delay
  Card 2: 267ms delay (233 + 34)
  Card 3: 301ms delay (233 + 68)
  Card N: (233 + index*34)ms delay
```

---

## Color Scheme (Category-Specific)

| Category       | Hex Code  | Usage |
|----------------|-----------|-------|
| Agriculture    | #4CAF50   | Badge background, icon tint |
| Education      | #2196F3   | Badge background, icon tint |
| Healthcare     | #E91E63   | Badge background, icon tint |
| Infrastructure | #9C27B0   | Badge background, icon tint |
| Environment    | #009688   | Badge background, icon tint |
| Business       | #FF9800   | Badge background, icon tint |
| Arts           | #FF5722   | Badge background, icon tint |
| Community      | #607D8B   | Badge background, icon tint |

Colors applied at 13% opacity for badge backgrounds, full opacity for text.

---

## Mock Data Structure

### Campaign Example
```json
{
  "id": "camp_001",
  "title": "Farm Irrigation Project",
  "description": "Install modern irrigation system...",
  "imageUrl": "https://images.unsplash.com/...",
  "type": "agriculture",
  "status": "active",
  "fundingGoal": {
    "targetAmount": 10000.0,
    "currentAmount": 7500.0,
    "currency": "USD"
  },
  "location": {
    "city": "Nairobi",
    "country": "Kenya",
    "latitude": -1.2921,
    "longitude": 36.8219
  },
  "creatorName": "Sarah Mwangi",
  "supportersCount": 89,
  "startDate": "2024-01-15T00:00:00Z",
  "endDate": "2024-03-15T00:00:00Z",
  "tags": ["farming", "water", "sustainability"]
}
```

### Computed Properties
```dart
campaign.percentageFunded    // 75.0
campaign.daysRemaining       // 30
campaign.isUrgent           // true (if < 7 days left)
```

---

## File Structure

```
lib/src/
├── app.dart                          # Root MaterialApp widget
├── routing/
│   └── app_router.dart               # GoRouter configuration
├── theme/
│   ├── app_theme.dart                # Material 3 theme
│   └── design_tokens.dart            # Aequus tokens (spacing, durations, radii)
└── features/
    ├── landing/
    │   └── presentation/
    │       └── landing_screen.dart   # Landing page with hero
    ├── auth/
    │   ├── domain/
    │   │   ├── auth_user.dart        # User model
    │   │   └── auth_repository.dart  # Repository interface
    │   ├── data/
    │   │   └── mock_auth_repository.dart
    │   ├── application/
    │   │   └── auth_service.dart     # Riverpod providers
    │   └── presentation/
    │       └── sign_in_screen.dart   # Sign-in form
    ├── campaigns/
    │   ├── domain/
    │   │   ├── campaign.dart         # Campaign models
    │   │   └── campaign_repository.dart
    │   ├── data/
    │   │   └── mock_campaign_repository.dart
    │   ├── application/
    │   │   └── campaign_service.dart # Riverpod providers
    │   └── presentation/
    │       ├── campaign_feed_screen.dart
    │       ├── campaign_detail_screen.dart
    │       └── widgets/
    │           └── campaign_card.dart
    └── profile/
        └── presentation/
            └── profile_screen.dart   # Profile management
```

---

**Generated**: 2024 | **Framework**: Flutter 3.35 | **State**: Riverpod 2.6
