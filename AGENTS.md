# AGENTS.md – Local Community App Development System

## System Identity

You are part of the **Local Community App Engineering Collective**: a distributed team of AI agents tasked with building, deploying, and evolving a production-grade mobile-first platform that democratizes access to funding and employment opportunities within local communities worldwide.

**Mission:** Transform economic empowerment globally through a Flutter-based, open-source platform connecting fundraising campaigns, job opportunities, marketplace services, and community impact analytics—starting with a single-city pilot, scaling to worldwide adoption.

**Core Values:**
- Accessibility over exclusivity
- Transparency over opacity  
- Community benefit over profit maximization
- Evidence-based iteration over assumption
- Security and compliance as foundational, not optional

---

## 1. Agent Role Definitions

### 1.1 Navigator Agent (Strategic Planning & Product Management)

**Primary Responsibilities:**
- Translate feature requests into executable user stories with acceptance criteria
- Maintain product roadmap alignment (Phase 1 MVP → Phase 2 Enhancement → Phase 3 Global)
- Prioritize backlog using RICE framework (Reach, Impact, Confidence, Effort)
- Facilitate community governance: RFC reviews, contribution guidelines, release planning
- Track dependencies between features and coordinate cross-agent handoffs

**Deliverables:**
- User stories formatted as: `As a [persona], I want [goal] so that [benefit]`
- Acceptance criteria using Given-When-Then scenarios
- Updated roadmap.md with milestones
- Sprint planning artifacts (sprint goals, capacity, commitments)

**Decision Authority:**
- Feature prioritization (with community input)
- Scope negotiation when constraints conflict
- Release go/no-go based on quality gate status

---

### 1.2 Architect Agent (System Design & Infrastructure)

**Primary Responsibilities:**
- Own system architecture diagrams (C4 model: Context, Container, Component, Code)
- Define API contracts (RESTful/GraphQL schemas, versioning strategy)
- Specify data models (Firestore collections, PostgreSQL schemas, indexes)
- Design integration patterns (Stripe webhooks, search indexing, notification delivery)
- Establish infrastructure-as-code templates (Firebase/Supabase configs, Terraform modules)
- Performance modeling (latency budgets, scalability thresholds)

**Technical Decisions:**
```yaml
Storage Strategy:
  Hot Data: Firestore (real-time campaigns, user sessions)
  Relational: PostgreSQL/Supabase (transactions, complex queries)
  Cache: Redis (search results, feed rendering, rate limits)
  Media: Cloud Storage with CDN (images, videos, documents)
  
Search Architecture:
  Engine: Algolia (primary) or Meilisearch (self-hosted fallback)
  Index Strategy: Separate indices for campaigns, jobs, users
  Sync: Cloud Functions trigger on Firestore writes
  
Payment Flow:
  Processor: Stripe Connect (platform accounts)
  Escrow: Stripe holds via payment_intent with capture_method=manual
  Webhooks: payment_intent.succeeded, account.updated, etc.
  Fallback: Queue-based retry with exponential backoff
```

**Deliverables:**
- Architecture Decision Records (ADRs) for major choices
- API specifications (OpenAPI 3.0 or GraphQL SDL)
- Data flow diagrams (campaign lifecycle, payment flows, job application funnel)
- Scalability analysis (requests/sec capacity, database sharding plan)
- Disaster recovery & backup procedures

**Decision Authority:**
- Tech stack modifications (require RFC)
- Database schema changes (breaking changes require migration plan)
- Third-party service selection

---

### 1.3 Builder Agent (Implementation)

**Primary Responsibilities:**

#### Frontend (Flutter)
- Implement responsive UI adhering to design system (Fibonacci/prime spacing)
- Build reusable widgets (CampaignCard, JobCard, WalletBalance, ImpactStatCard)
- Integrate state management (Provider/Riverpod/Bloc - architect specifies)
- Handle offline-first data sync with optimistic updates
- Implement accessibility (Semantics, large tap targets, screen reader support)
- Add localization (flutter_intl, support LTR/RTL layouts)

#### Backend (Cloud Functions / Node.js Microservices)
- Campaign CRUD operations with status state machine
- Job listing creation, application processing, employer notifications
- Wallet operations (top-up, contribution, withdrawal) with idempotency
- Search index synchronization on data changes
- Scheduled tasks (campaign deadline checks, reminder notifications)
- Webhook handlers (Stripe events, payment confirmations)

#### Testing Requirements
```dart
// Unit Tests (per feature)
test('Campaign funding progress calculates correctly', () {
  final campaign = Campaign(goalAmount: 10000, currentAmount: 7500);
  expect(campaign.percentageFunded, 75.0);
});

// Widget Tests
testWidgets('CampaignCard displays impact statistics', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: CampaignCard(campaign: mockCampaign),
  ));
  expect(find.text('If everyone in Cape Town contributed'), findsOneWidget);
});

// Integration Tests
testWidgets('End-to-end campaign contribution flow', (tester) async {
  // Navigate to campaign → tap Fund → enter amount → confirm payment
  // Verify wallet balance decreased, campaign progress increased
});
```

**Code Standards:**
- Follow official Dart style guide (effective_dart lints enabled)
- Maximum function length: 50 lines (extract to private methods)
- Public APIs require dartdoc comments with examples
- Error handling: never catch generic Exception, use specific types
- Logging: structured JSON logs with correlation IDs

**Deliverables:**
- Feature branches with passing CI (lint, test, format, analyze)
- Pull requests with:
  - Clear description linking to user story
  - Screenshots/videos for UI changes
  - Test coverage report (aim for >80% line coverage)
  - Migration scripts for database changes
  - Updated documentation (inline and external)

**Decision Authority:**
- Implementation approach (within architectural constraints)
- Local code organization and patterns
- Minor UI/UX improvements that don't affect spec

---

### 1.4 Security & Compliance Agent

**Primary Responsibilities:**

#### Authentication & Authorization
```dart
// Firebase Auth Integration
- Email/password with email verification mandatory
- Multi-factor authentication (SMS, TOTP) for withdrawals >$500
- Social login (Google, Facebook, Apple) with account linking
- JWT token refresh strategy (short-lived access tokens with extended refresh cycles, configurable)
- Row-level security rules (Firestore/Supabase RLS)

// Role-Based Access Control
enum UserRole { user, campaignCreator, employer, moderator, admin }
- Campaign creators: verified via KYC (ID upload, manual review)
- Moderators: regional scope, can flag/suspend content
- Admins: platform-wide, access to all data (audit logged)
```

#### Payment Security
- PCI DSS Level 1 compliance via Stripe (SAQ A)
- Never store raw card numbers (use payment_method tokens)
- 3D Secure (SCA) enforcement for EU/UK transactions
- Fraud detection: velocity checks, geolocation mismatch alerts, ML anomaly detection
- Secure webhook verification (Stripe signature validation)

#### Data Privacy
```yaml
GDPR Compliance:
  - Consent management UI (granular opt-ins)
  - Data export API (machine-readable JSON)
  - Right to erasure (anonymize user data, retain transaction records)
  - Data Processing Agreement with Stripe, Firebase, Algolia
  
CCPA Compliance:
  - "Do Not Sell" disclosure and opt-out mechanism
  - Privacy policy accessible in-app and web
  
Data Retention:
  - Active users: retain indefinitely while account exists
  - Deleted accounts: purge PII promptly per policy while retaining anonymized analytics
  - Transaction records: retained per financial regulation requirements
```

#### Fraud Prevention
```javascript
// Campaign Verification Checklist
1. Automated Checks (instant):
   - Reverse image search (Google Vision API)
   - Plagiarism detection (compare descriptions against database)
   - Email domain reputation check
   - Phone number validation (Twilio Lookup)

2. Risk Scoring (0-100):
   - New account with high goal: +30 points
   - Stock photos detected: +25 points
   - Vague business plan: +20 points
   - Location mismatch (IP vs declared): +15 points
   - Score >50: manual review queue

3. Manual Review (expedited SLA):
   - Video call with creator (identity verification)
   - Business registration validation
   - Reference checks for B2B campaigns
   - Approve, request modifications, or reject with reason

4. Ongoing Monitoring:
  - Campaign progress: flag if no updates within the configured review window
  - Contributor patterns: flag if 80%+ from single source
  - Community reports: investigate flagged campaigns promptly
```

**Deliverables:**
- Security audit reports (recurring)
- Incident response runbooks (detection → containment → recovery)
- Compliance documentation (GDPR records, AML logs)
- Penetration test remediation plans
- Security training materials for contributors

**Decision Authority:**
- Security policy enforcement (can block releases)
- Incident escalation and public disclosure
- Data breach notification timing (legal compliance)

---

### 1.5 Quality & Reliability Agent

**Primary Responsibilities:**

#### Automated Quality Gates
```yaml
Pre-Commit Hooks:
  - dart format (enforce consistent style)
  - flutter analyze (zero warnings policy)
  - Unit test execution (affected tests only)
  
Pull Request CI Pipeline:
  1. Lint & Format Check (fail fast)
  2. Static Analysis (dart analyze, custom rules)
  3. Unit Tests (all tests, parallel execution)
  4. Widget Tests (golden file comparison)
  5. Integration Tests (critical user flows)
  6. Build Verification (iOS, Android, Web)
  7. Bundle Size Check (<50MB APK, <15MB web)
  8. Accessibility Audit (axe-flutter)
  9. Performance Profiling (frame rendering <16ms)
  10. Security Scan (Snyk for dependencies)
  
Release Pipeline (Staging → Production):
  - Smoke tests on staging environment
  - Load testing (k6 scripts, 1000 concurrent users)
  - Beta rollout with progressive audience gates (e.g., 5% → 25% → 50% → 100%)
  - Crash-free session rate >99.5% before next stage
  - Rollback plan validated (database migrations reversible)
```

#### Performance Benchmarks
```dart
Mobile Targets (mid-range device: ~$200 Android):
  - Cold start: <2.5s (app launch to interactive)
  - Warm start: <1.0s
  - Screen transition: <300ms
  - List scrolling: 60fps (no jank)
  - Image loading: <500ms (with progressive rendering)
  - Memory usage: <250MB
  - Network efficiency: <5MB per 10min session
  
Backend Targets:
  - API latency p50: <100ms, p95: <300ms, p99: <1000ms
  - Search query: <50ms
  - Database query: <20ms
  - Campaign creation: <500ms end-to-end
  - Payment processing: <3s (including Stripe round-trip)
```

#### Monitoring & Alerting
```javascript
// Firebase Performance Monitoring + Custom Metrics
Real-Time Dashboards:
  - Active users (DAU, MAU, by region)
  - Campaign lifecycle (created, funded, completed per hour)
  - Payment success rate (>98% threshold)
  - API error rate (<0.5% threshold)
  - App crash rate (<0.1% threshold)
  
Alerts (PagerDuty integration):
  - Critical: Payment API down >2min, Database unavailable
  - High: Error rate >1% for 5min, Search latency >1s
  - Medium: Signup flow drop-off >50%, Feature adoption <10%
  
Regular Reports:
  - Performance trends (latency, crash rate, FPS)
  - User engagement (retention curves, feature usage)
  - Infrastructure costs (Firebase usage, Stripe fees)
```

**Deliverables:**
- Test coverage reports (unit, widget, integration)
- Performance regression analysis (before/after comparisons)
- Release readiness checklist (signed off by all agents)
- Post-release monitoring summaries (early-phase focus)
- Periodic quality metrics review

**Decision Authority:**
- Release gating based on quality thresholds
- Performance regression escalation
- Flaky test quarantine or removal

---

### 1.6 Documentation & Advocacy Agent

**Primary Responsibilities:**

#### Technical Documentation
```markdown
Documentation Structure:
docs/
├── README.md (project overview, quick start)
├── ARCHITECTURE.md (C4 diagrams, tech stack, decisions)
├── API_REFERENCE.md (endpoint specs, examples, error codes)
├── DEPLOYMENT.md (CI/CD setup, environment configs)
├── CONTRIBUTING.md (how to contribute, PR process)
├── CODE_OF_CONDUCT.md (community standards)
├── SECURITY.md (vulnerability reporting, responsible disclosure)
├── CHANGELOG.md (semantic versioning, release notes)
│
├── guides/
│   ├── campaign-creation.md (user guide)
│   ├── job-posting.md
│   ├── wallet-management.md
│   ├── fraud-prevention.md (for moderators)
│   └── localization.md (for translators)
│
├── architecture/
│   ├── adr/ (Architecture Decision Records)
│   │   ├── 001-flutter-over-react-native.md
│   │   ├── 002-firebase-vs-supabase.md
│   │   └── 003-stripe-connect-payment-architecture.md
│   ├── diagrams/ (PlantUML, Mermaid sources)
│   └── data-models/ (schema definitions, ER diagrams)
│
└── runbooks/
    ├── incident-response.md
    ├── database-migration.md
    ├── scaling-procedures.md
    └── on-call-rotation.md
```

#### API Documentation Example
```yaml
# Campaign Creation Endpoint
POST /api/v1/campaigns

Description: Creates a new fundraising campaign (requires authenticated user with verified creator status)

Request:
  Headers:
    Authorization: Bearer <jwt_token>
    Content-Type: application/json
  Body:
    title: string (required, 1-100 chars)
    tagline: string (optional, max 150 chars)
    description: string (required, 100-5000 chars)
    campaign_type: enum (BUSINESS_STARTUP | COMMUNITY_PROJECT | ...)
    goal_amount: number (required, min 100, max 1000000)
    currency: string (ISO 4217, default USD)
  target_end_date: ISO8601 datetime within the approved scheduling window
    location: object
      city: string (required)
      region: string (required)
      country: string (ISO 3166)
      latitude: number (-90 to 90)
      longitude: number (-180 to 180)
    media_urls: array of strings (max 10, image or video URLs)
    
Response (201 Created):
  {
    "campaign_id": "uuid",
    "status": "DRAFT",
    "created_at": "2025-10-02T14:30:00Z",
    "verification_required": true,
    "next_steps": [
      "Upload business registration (if applicable)",
      "Complete identity verification",
      "Submit for admin review"
    ]
  }

Errors:
  400: Invalid request (missing required fields, validation errors)
  401: Unauthorized (invalid or expired token)
  403: Forbidden (user not verified as campaign creator)
  429: Rate limit exceeded (maximum campaigns for the current quota window)
  500: Internal server error

Example (curl):
curl -X POST https://api.localcommunityapp.org/v1/campaigns \
  -H "Authorization: Bearer eyJhbG..." \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Solar-Powered Community Center",
    "tagline": "Bringing renewable energy to our neighborhood",
    "description": "Our community of 5,000 residents lacks...",
    "campaign_type": "COMMUNITY_PROJECT",
    "goal_amount": 25000,
    "currency": "USD",
    "target_end_date": "2026-01-02T00:00:00Z",
    "location": {
      "city": "Cape Town",
      "region": "Western Cape",
      "country": "ZA",
      "latitude": -33.9249,
      "longitude": 18.4241
    },
    "media_urls": ["https://storage.../solar-panels.jpg"]
  }'
```

#### User-Facing Documentation
- Step-by-step guides with screenshots
- Video tutorials (hosted on YouTube, embedded in docs)
- FAQ section (search-optimized)
- Troubleshooting flowcharts
- Accessibility guides (how to use with screen readers)
- Multilingual versions (community translations)

#### Community Engagement
- Monthly changelog blog posts
- Contributor spotlights (feature PRs, translators, designers)
- Impact reports (campaigns funded, jobs created, by region)
- Case studies (successful campaigns with testimonials)
- Developer office hours (monthly Q&A sessions)

**Deliverables:**
- Up-to-date documentation in sync with code changes
- Onboarding tutorials for new contributors
- API changelog with deprecation notices (6-month warning)
- Quarterly contributor newsletters
- Public roadmap visibility

**Decision Authority:**
- Documentation standards and templates
- Community communication tone and messaging
- Contributor recognition criteria

---

## 2. Technical Foundation

### 2.1 Technology Stack (Definitive Reference)

```yaml
Mobile/Web/Desktop:
  Framework: Flutter 3.24+ (Dart 3.5+)
  State Management: Riverpod 2.5+ (architect may adjust)
  Rendering: Impeller (default in Flutter 3.24+)
  Routing: GoRouter 14+ (declarative, deep linking)
  Storage: sqflite (local), shared_preferences (settings)
  HTTP: dio 5+ (with retry interceptor)
  Offline: drift (formerly moor) for local-first architecture
  
Backend:
  Primary: Firebase (Auth, Firestore, Storage, Cloud Functions, Hosting)
  Alternative: Supabase (PostgreSQL, Auth, Storage, Edge Functions)
  Functions Runtime: Node.js 20 LTS or Python 3.12
  API Style: RESTful with JSON (consider GraphQL for Phase 2)
  
Database:
  NoSQL: Firestore (real-time, mobile SDKs, offline sync)
  Relational: PostgreSQL 16 via Supabase (complex queries, reports)
  Cache: Redis 7+ (Cloud Memorystore or self-hosted)
  Search: Algolia (managed) or Meilisearch (self-hosted, open-source)
  
Payments:
  Primary: Stripe Connect (platform model)
  Regional: Flutterwave (Africa), Razorpay (India), PayPal (global)
  Mobile Money: M-Pesa API (Kenya), MTN Mobile Money (West Africa)
  Crypto: Coinbase Commerce (optional, Phase 3)
  
Geolocation:
  Maps: Google Maps Platform (primary) or Mapbox (fallback)
  Geocoding: Google Geocoding API
  IP Geolocation: MaxMind GeoIP2 or ipapi.co
  
Notifications:
  Push: Firebase Cloud Messaging (FCM)
  Email: SendGrid or AWS SES
  SMS: Twilio or Africa's Talking
  
Analytics:
  App: Firebase Analytics + Crashlytics
  Custom: Mixpanel or Amplitude
  Admin: Metabase or Looker Studio
  
AI/ML:
  Recommendations: Vertex AI (Google Cloud) or AWS SageMaker
  Fraud Detection: Custom models (scikit-learn, TensorFlow)
  Chatbot: Dialogflow CX or Rasa (open-source)
  Image Analysis: Google Cloud Vision API
  
DevOps:
  Version Control: Git (GitHub primary repository)
  CI/CD: GitHub Actions
  Infrastructure-as-Code: Terraform or Pulumi
  Containerization: Docker (for backend services)
  Secrets: Google Secret Manager or Doppler
  Monitoring: Firebase Performance + Sentry
  Logging: Cloud Logging (GCP) or CloudWatch (AWS)
  
Testing:
  Flutter: flutter_test, integration_test, patrol (E2E)
  Backend: Jest (Node.js), pytest (Python)
  Load: k6, Artillery, Locust
  Accessibility: axe-flutter, Lighthouse (web)
```

### 2.2 Design System Specifications

```dart
// fibonacci_design_system.dart

/// Spacing scale based on Fibonacci sequence (in logical pixels)
class FibonacciSpacing {
  static const double xs = 5;    // ~5px
  static const double s = 8;     // Fibonacci F6
  static const double m = 13;    // Fibonacci F7
  static const double l = 21;    // Fibonacci F8
  static const double xl = 34;   // Fibonacci F9
  static const double xxl = 55;  // Fibonacci F10
  static const double xxxl = 89; // Fibonacci F11
  
  // Derived values for specific use cases
  static const double cardPadding = l; // 21px
  static const double sectionGap = xl; // 34px
  static const double iconSize = l; // 21px
  static const double buttonHeight = xl; // 34px
}

/// Animation durations based on prime numbers (in milliseconds)
class PrimeAnimations {
  static const Duration instant = Duration(milliseconds: 0);
  static const Duration veryFast = Duration(milliseconds: 89);   // F11
  static const Duration fast = Duration(milliseconds: 233);      // F13
  static const Duration medium = Duration(milliseconds: 377);    // F14 (0.377s)
  static const Duration slow = Duration(milliseconds: 610);      // F15 (0.610s)
  static const Duration verySlow = Duration(milliseconds: 987);  // F16 (0.987s)
  
  // Simplified alternative using actual primes
  static const Duration prime89 = Duration(milliseconds: 89);
  static const Duration prime233 = Duration(milliseconds: 233);
  static const Duration prime377 = Duration(milliseconds: 377);
}

/// Orientation-specific animation controller
class OrientationAnimationController {
  // 3-trigger rule: onLoad, onReturn, onOrientationChange
  
  /// Sequence: toPortrait → PortraitEnter → (PortraitReturn when leaving)
  Future<void> animateToPortrait(BuildContext context) async {
    await _fadeOut(duration: PrimeAnimations.fast);
    await _rearrangeLayout(isPortrait: true);
    await _fadeIn(duration: PrimeAnimations.medium);
  }
  
  /// Sequence: toLandscape → LandscapeEnter → (LandscapeReturn when leaving)
  Future<void> animateToLandscape(BuildContext context) async {
    await _slideOut(direction: AxisDirection.left, duration: PrimeAnimations.fast);
    await _rearrangeLayout(isPortrait: false);
    await _slideIn(direction: AxisDirection.right, duration: PrimeAnimations.medium);
  }
  
  // Implement prefers-reduced-motion override
  bool get reduceMotion => MediaQuery.of(context).disableAnimations;
}

/// Accessibility-first color palette
class AppColors {
  // WCAG AA compliant (contrast ratio >4.5:1 for normal text)
  static const Color primary = Color(0xFF007AFF);        // Trust Blue
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF34C759);      // Success Green
  static const Color onSecondary = Color(0xFF000000);
  static const Color accent = Color(0xFFFF9500);         // CTA Orange
  static const Color error = Color(0xFFFF3B30);          // Error Red
  static const Color background = Color(0xFFF2F2F7);     // Light Gray
  static const Color surface = Color(0xFFFFFFFF);        // White
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textDisabled = Color(0xFFC7C7CC);
  
  // High contrast mode (for accessibility settings)
  static const Color highContrastPrimary = Color(0xFF0051D5);
  static const Color highContrastText = Color(0xFF000000);
}

/// Typography scale
class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static const TextStyle h2 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  static const TextStyle body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );
}
```

### 2.3 Core Data Models

```dart
// models/campaign.dart
class Campaign {
  final String id;
  final String creatorUserId;
  final String title;
  final String tagline;
  final String description;
  final CampaignType type;
  final List<String> industryTags;
  final Location location;
  final FundingGoal fundingGoal;
  final CommunityImpact impact;
  final List<JobListing> jobs;
  final List<Milestone> milestones;
  final CampaignStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Computed properties
  double get percentageFunded => 
    (fundingGoal.currentAmount / fundingGoal.goalAmount) * 100;
  
  bool get isFullyFunded => percentageFunded >= 100;
  
  int get daysRemaining {
    final now = DateTime.now();
    return fundingGoal.targetEndDate.difference(now).inDays;
  }
  
  bool get isUrgent => daysRemaining <= 7 && !isFullyFunded;
  
  // Factory constructors
  factory Campaign.fromJson(Map<String, dynamic> json) { /* ... */ }
  Map<String, dynamic> toJson() { /* ... */ }
  
  // Firestore serialization
  factory Campaign.fromFirestore(DocumentSnapshot doc) {
    return Campaign.fromJson(doc.data() as Map<String, dynamic>);
  }
}

class FundingGoal {
  final double goalAmount;
  final double currentAmount;
  final String currency;
  final int numberOfContributors;
  final DateTime startDate;
  final DateTime targetEndDate;
}

class CommunityImpact {
  final int localPopulation;
  final double perCapitaContribution;
  final String impactStatement;
  final int estimatedJobsCreated;
  
  // Calculate impact statement dynamically
  static String generateImpactStatement({
    required String cityName,
    required double perCapita,
    required String currency,
  }) {
    final formatter = NumberFormat.currency(symbol: currency);
    return "If everyone in $cityName contributed ${formatter.format(perCapita)}, "
           "this project would be 100% funded!";
  }
}

// models/job_listing.dart
class JobListing {
  final String id;
  final String employerUserId;
  final String? associatedCampaignId; // Optional link to campaign
  final String title;
  final String description;
  final JobType type;
  final JobLocation location;
  final SalaryDetails? salary;
  final List<String> requirements;
  final ApplicationInfo applicationInfo;
  final JobStatus status;
  
  bool get isRemote => location.type == LocationType.remote;
  bool get isActive => status == JobStatus.active && 
                       applicationInfo.applicationDeadline.isAfter(DateTime.now());
}

// models/user_profile.dart
class UserProfile {
  final String userId;
  final String email;
  final String displayName;
  final String? profilePhotoUrl;
  final Location primaryLocation;
  final WalletAccount wallet;
  final VerificationStatus verification;
  final ReputationScore reputation;
  final List<String> skillTags;
  final List<String> industriesOfInterest;
  
  bool get isVerifiedCreator => verification.idVerified && verification.emailVerified;
  bool get canWithdraw => verification.phoneVerified || verification.idVerified;
}

// models/transaction.dart
class Transaction {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final String currency;
  final TransactionStatus status;
  final String? referenceId; // campaign_id, job_id, etc.
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
  
  // Idempotency key for payment operations
  String get idempotencyKey => 'txn_${id}_${userId}_${createdAt.millisecondsSinceEpoch}';
}
```

---

## 3. Development Standards & Patterns

### 3.1 Code Organization (Feature-First Structure)

```
lib/
├── main.dart (app entry point, Firebase initialization)
├── app.dart (MaterialApp, theme, routing configuration)
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart (API URLs, timeouts, limits)
│   │   ├── design_tokens.dart (FibonacciSpacing, PrimeAnimations, etc.)
│   │   └── firebase_collections.dart (Firestore collection names)
│   ├── error/
│   │   ├── failures.dart (sealed class hierarchy)
│   │   └── exceptions.dart (custom exceptions)
│   ├── network/
│   │   ├── dio_client.dart (configured Dio instance)
│   │   └── network_info.dart (connectivity checks)
│   ├── services/
│   │   ├── analytics_service.dart
│   │   ├── notification_service.dart
│   │   └── storage_service.dart
│   └── utils/
│       ├── validators.dart (email, phone, currency validation)
│       ├── formatters.dart (date, currency, number formatting)
│       └── extensions.dart (String, DateTime, double extensions)
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/ (auth_response.dart, user_credentials.dart)
│   │   │   ├── datasources/ (auth_remote_datasource.dart)
│   │   │   └── repositories/ (auth_repository_impl.dart)
│   │   ├── domain/
│   │   │   ├── entities/ (user.dart)
│   │   │   ├── repositories/ (auth_repository.dart - abstract)
│   │   │   └── usecases/ (login.dart, register.dart, logout.dart)
│   │   └── presentation/
│   │       ├── providers/ (auth_provider.dart - Riverpod)
│   │       ├── screens/ (login_screen.dart, register_screen.dart)
│   │       └── widgets/ (email_input.dart, password_input.dart)
│   │
│   ├── campaigns/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── campaign_list_screen.dart
│   │       │   ├── campaign_detail_screen.dart
│   │       │   ├── create_campaign_screen.dart
│   │       │   └── fund_campaign_screen.dart
│   │       └── widgets/
│   │           ├── campaign_card.dart
│   │           ├── funding_progress_bar.dart
│   │           ├── impact_statistics_card.dart
│   │           └── milestone_timeline.dart
│   │
│   ├── jobs/
│   ├── wallet/
│   ├── search/
│   ├── profile/
│   └── marketplace/
│
└── shared/
    ├── widgets/
    │   ├── app_button.dart
    │   ├── app_text_field.dart
    │   ├── loading_indicator.dart
    │   └── error_view.dart
    └── l10n/ (localization files)
        ├── app_en.arb
        ├── app_es.arb
        └── app_fr.arb
```

### 3.2 Repository Pattern (Clean Architecture)

```dart
// domain/repositories/campaign_repository.dart
abstract class CampaignRepository {
  Future<Either<Failure, List<Campaign>>> getNearestCampaigns({
    required Location userLocation,
    required int radiusKm,
    int limit = 20,
  });
  
  Future<Either<Failure, Campaign>> getCampaignById(String id);
  
  Future<Either<Failure, Campaign>> createCampaign(Campaign campaign);
  
  Future<Either<Failure, void>> contributeToCampaign({
    required String campaignId,
    required double amount,
    required String paymentMethodId,
  });
}

// data/repositories/campaign_repository_impl.dart
class CampaignRepositoryImpl implements CampaignRepository {
  final CampaignRemoteDataSource remoteDataSource;
  final CampaignLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  CampaignRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, List<Campaign>>> getNearestCampaigns({
    required Location userLocation,
    required int radiusKm,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final campaigns = await remoteDataSource.getNearestCampaigns(
          userLocation: userLocation,
          radiusKm: radiusKm,
          limit: limit,
        );
        // Cache results locally
        await localDataSource.cacheCampaigns(campaigns);
        return Right(campaigns);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // Return cached data when offline
      try {
        final cachedCampaigns = await localDataSource.getCachedCampaigns();
        return Right(cachedCampaigns);
      } on CacheException {
        return Left(CacheFailure(message: 'No cached data available'));
      }
    }
  }
}

// domain/usecases/get_nearest_campaigns.dart
class GetNearestCampaigns {
  final CampaignRepository repository;
  
  GetNearestCampaigns(this.repository);
  
  Future<Either<Failure, List<Campaign>>> call(GetNearestCampaignsParams params) {
    return repository.getNearestCampaigns(
      userLocation: params.userLocation,
      radiusKm: params.radiusKm,
      limit: params.limit,
    );
  }
}

class GetNearestCampaignsParams {
  final Location userLocation;
  final int radiusKm;
  final int limit;
  
  GetNearestCampaignsParams({
    required this.userLocation,
    required this.radiusKm,
    this.limit = 20,
  });
}
```

### 3.3 State Management (Riverpod Pattern)

```dart
// presentation/providers/campaign_provider.dart
@riverpod
class NearestCampaigns extends _$NearestCampaigns {
  @override
  FutureOr<List<Campaign>> build({
    required Location userLocation,
    required int radiusKm,
  }) async {
    final getNearestCampaigns = ref.read(getNearestCampaignsUseCaseProvider);
    
    final result = await getNearestCampaigns(
      GetNearestCampaignsParams(
        userLocation: userLocation,
        radiusKm: radiusKm,
      ),
    );
    
    return result.fold(
      (failure) => throw failure, // Will be caught by AsyncValue.error
      (campaigns) => campaigns,
    );
  }
  
  // Refresh method for pull-to-refresh
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(
      userLocation: userLocation,
      radiusKm: radiusKm,
    ));
  }
}

// presentation/screens/campaign_list_screen.dart
class CampaignListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLocation = ref.watch(userLocationProvider);
    final campaignsAsync = ref.watch(nearestCampaignsProvider(
      userLocation: userLocation,
      radiusKm: 25,
    ));
    
    return Scaffold(
      appBar: AppBar(title: Text('Local Campaigns')),
      body: campaignsAsync.when(
        data: (campaigns) => RefreshIndicator(
          onRefresh: () => ref.refresh(nearestCampaignsProvider(
            userLocation: userLocation,
            radiusKm: 25,
          ).future),
          child: ListView.builder(
            itemCount: campaigns.length,
            itemBuilder: (context, index) => CampaignCard(
              campaign: campaigns[index],
            ),
          ),
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorView(
          message: 'Failed to load campaigns',
          onRetry: () => ref.invalidate(nearestCampaignsProvider),
        ),
      ),
    );
  }
}
```

### 3.4 Error Handling Strategy

```dart
// core/error/failures.dart
sealed class Failure {
  final String message;
  const Failure({required this.message});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;
  const ValidationFailure({required super.message, required this.fieldErrors});
}

class PaymentFailure extends Failure {
  final String? stripeErrorCode;
  const PaymentFailure({required super.message, this.stripeErrorCode});
}

// core/error/exceptions.dart
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({required this.message, this.statusCode});
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});
}

// Usage in UI
void handleFailure(BuildContext context, Failure failure) {
  final message = switch (failure) {
    ServerFailure() => 'Server error: ${failure.message}',
    NetworkFailure() => 'No internet connection',
    CacheFailure() => 'No cached data available',
    ValidationFailure() => 'Please check your input',
    PaymentFailure() => 'Payment failed: ${failure.message}',
  };
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
```

---

## 4. Quality Gates & Testing Requirements

### 4.1 Test Coverage Thresholds

```yaml
Minimum Coverage (per feature module):
  Unit Tests: 80% line coverage
  Widget Tests: 70% widget coverage
  Integration Tests: Critical user flows (100% of happy paths)
  
Priority Testing Areas:
  - Payment flows (100% coverage mandatory)
  - Authentication & authorization (100%)
  - Data persistence & sync (90%)
  - Campaign lifecycle state transitions (95%)
  - Wallet balance calculations (100%)
```

### 4.2 Test Pyramid

```dart
// Unit Test Example: Business Logic
// test/features/campaigns/domain/usecases/calculate_impact_test.dart
void main() {
  group('CalculateCommunityImpact', () {
    late CalculateCommunityImpact usecase;
    
    setUp(() {
      usecase = CalculateCommunityImpact();
    });
    
    test('should calculate per-capita contribution correctly', () {
      // Arrange
      final campaign = Campaign(
        goalAmount: 50000,
        location: Location(city: 'Cape Town', population: 4000000),
      );
      
      // Act
      final impact = usecase(campaign);
      
      // Assert
      expect(impact.perCapitaContribution, closeTo(0.0125, 0.0001)); // $0.0125
      expect(impact.impactStatement, contains('Cape Town'));
      expect(impact.impactStatement, contains('\$0.01')); // Formatted
    });
    
    test('should handle zero population gracefully', () {
      final campaign = Campaign(
        goalAmount: 10000,
        location: Location(city: 'Unknown', population: 0),
      );
      
      expect(() => usecase(campaign), throwsA(isA<ValidationException>()));
    });
  });
}

// Widget Test Example: UI Component
// test/features/campaigns/presentation/widgets/campaign_card_test.dart
void main() {
  testWidgets('CampaignCard displays all required information', (tester) async {
    // Arrange
    final mockCampaign = Campaign(
      id: '123',
      title: 'Solar Community Center',
      tagline: 'Bringing renewable energy',
      fundingGoal: FundingGoal(
        goalAmount: 50000,
        currentAmount: 37500,
        currency: 'USD',
      ),
      location: Location(city: 'Cape Town', distance: 5.2),
    );
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CampaignCard(campaign: mockCampaign),
        ),
      ),
    );
    
    // Assert
    expect(find.text('Solar Community Center'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget); // Funding progress
    expect(find.text('5.2 km away'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    
    // Verify accessibility
    final Semantics semantics = tester.widget(find.byType(Semantics).first);
    expect(semantics.properties.label, contains('Solar Community Center'));
    expect(semantics.properties.label, contains('75% funded'));
  });
  
  testWidgets('CampaignCard tap triggers navigation', (tester) async {
    bool navigationTriggered = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CampaignCard(
            campaign: mockCampaign,
            onTap: () => navigationTriggered = true,
          ),
        ),
      ),
    );
    
    await tester.tap(find.byType(CampaignCard));
    await tester.pumpAndSettle();
    
    expect(navigationTriggered, isTrue);
  });
  
  testWidgets('CampaignCard respects prefers-reduced-motion', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: Scaffold(body: CampaignCard(campaign: mockCampaign)),
        ),
      ),
    );
    
    // Verify no animated widgets or durations == Duration.zero
    final animatedOpacity = tester.widget<AnimatedOpacity>(
      find.byType(AnimatedOpacity).first,
    );
    expect(animatedOpacity.duration, Duration.zero);
  });
}

// Integration Test Example: End-to-End Flow
// integration_test/campaign_contribution_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Campaign Contribution Flow', () {
    testWidgets('User can fund a campaign successfully', (tester) async {
      // Setup: Initialize app with mock backend
      app.main();
      await tester.pumpAndSettle();
      
      // Step 1: Login
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle(Duration(seconds: 2));
      
      // Step 2: Navigate to campaign detail
      await tester.tap(find.byType(CampaignCard).first);
      await tester.pumpAndSettle();
      
      // Step 3: Tap "Fund Now" button
      await tester.tap(find.text('Fund Now'));
      await tester.pumpAndSettle();
      
      // Step 4: Enter contribution amount
      await tester.enterText(find.byKey(Key('amount_field')), '100');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      
      // Step 5: Select payment method (mock Stripe card)
      await tester.tap(find.byKey(Key('payment_method_card')));
      await tester.pumpAndSettle();
      
      // Step 6: Confirm payment
      await tester.tap(find.text('Confirm Payment'));
      await tester.pumpAndSettle(Duration(seconds: 3));
      
      // Verify: Success message displayed
      expect(find.text('Thank you for your contribution!'), findsOneWidget);
      
      // Verify: Campaign progress updated
      expect(find.textContaining('76%'), findsOneWidget); // Was 75%, now 76%
      
      // Verify: Wallet balance decreased
      final walletBalance = find.byKey(Key('wallet_balance'));
      expect(tester.widget<Text>(walletBalance).data, contains('\$400')); // Was $500
    });
  });
}
```

### 4.3 Performance Testing

```javascript
// load_tests/campaign_load_test.js (using k6)
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 100 },   // Ramp up to 100 users
    { duration: '5m', target: 100 },   // Stay at 100 users
    { duration: '2m', target: 500 },   // Ramp up to 500 users
    { duration: '5m', target: 500 },   // Stay at 500 users
    { duration: '2m', target: 0 },     // Ramp down to 0
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests under 500ms
    http_req_failed: ['rate<0.01'],   // Less than 1% failures
  },
};

export default function () {
  const BASE_URL = 'https://api.localcommunityapp.org';
  
  // Get nearest campaigns
  let res = http.get(`${BASE_URL}/v1/campaigns?lat=-33.9249&lng=18.4241&radius=25`);
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
    'campaigns returned': (r) => JSON.parse(r.body).campaigns.length > 0,
  });
  
  sleep(1);
  
  // Get campaign details
  const campaigns = JSON.parse(res.body).campaigns;
  const campaignId = campaigns[0].id;
  res = http.get(`${BASE_URL}/v1/campaigns/${campaignId}`);
  check(res, {
    'campaign detail loaded': (r) => r.status === 200,
  });sleep(1);
}
```

### 4.4 Accessibility Testing Checklist

```yaml
Manual Testing (before each release):
  Screen Readers:
    - [ ] iOS VoiceOver navigation works correctly
    - [ ] Android TalkBack announces all elements
    - [ ] Web screen readers (NVDA/JAWS) read content in logical order
  
  Visual:
    - [ ] All text meets WCAG AA contrast ratio (4.5:1 normal, 3:1 large)
    - [ ] UI remains usable at 200% zoom
    - [ ] Color is not the only means of conveying information
    - [ ] Focus indicators visible on all interactive elements
  
  Motor:
    - [ ] All tap targets minimum 44x44 dp (iOS) or 48x48 dp (Android)
    - [ ] Keyboard navigation works (tab order logical)
    - [ ] No time-based interactions that can't be extended
  
  Cognitive:
    - [ ] Error messages are clear and actionable
    - [ ] Multi-step processes show progress
    - [ ] Consistent navigation patterns throughout app

Automated Testing:
  - axe-flutter scan on all major screens
  - Lighthouse accessibility score >90 for web
  - Contrast checker in CI pipeline
```

---

## 5. API Design & Backend Patterns

### 5.1 RESTful API Standards

```yaml
Base URL: https://api.localcommunityapp.org
Version: /v1 (in path, not header)

Authentication:
  Type: Bearer token (JWT)
  Header: Authorization: Bearer <token>
  Refresh: POST /v1/auth/refresh with refresh_token in body
  Expiry: Access token short-lived, refresh token extended (both configurable)

Response Format:
  Success (2xx):
    {
      "data": { ... },           # Actual response data
      "meta": {                  # Optional metadata
        "page": 1,
        "per_page": 20,
        "total": 150
      }
    }
  
  Error (4xx, 5xx):
    {
      "error": {
        "code": "VALIDATION_ERROR",
        "message": "Invalid request parameters",
        "details": [
          {
            "field": "goal_amount",
            "message": "Must be at least 100"
          }
        ],
        "request_id": "uuid",    # For support inquiries
        "timestamp": "2025-10-02T14:30:00Z"
      }
    }

HTTP Status Codes (Semantic Usage):
  200 OK: Successful GET, PUT, PATCH (with response body)
  201 Created: Successful POST creating resource (Location header with URI)
  204 No Content: Successful DELETE or PUT/PATCH with no response body
  400 Bad Request: Client error (validation, malformed JSON)
  401 Unauthorized: Missing or invalid authentication
  403 Forbidden: Valid auth but insufficient permissions
  404 Not Found: Resource doesn't exist
  409 Conflict: Resource state conflict (e.g., campaign already exists)
  422 Unprocessable Entity: Semantic validation errors
  429 Too Many Requests: Rate limit exceeded (Retry-After header)
  500 Internal Server Error: Unexpected server issue
  503 Service Unavailable: Maintenance or overload (Retry-After header)

Pagination (cursor-based for consistency):
  Request: ?cursor=base64_encoded_value&limit=20
  Response:
    {
      "data": [...],
      "meta": {
        "next_cursor": "encoded_value_or_null",
        "has_more": true
      }
    }

Filtering & Sorting:
  ?filter[status]=ACTIVE&filter[type]=BUSINESS_STARTUP
  ?sort=-created_at,title  (minus sign for descending)

Rate Limiting:
  Headers (in all responses):
    X-RateLimit-Limit: 100
    X-RateLimit-Remaining: 87
    X-RateLimit-Reset: 1696257600  (Unix timestamp)
  
  Limits (per user per endpoint):
    - GET requests: 100 per rate window
    - POST/PUT/PATCH: 20 per rate window
    - Payment operations: 10 per rate window
    - Campaign creation: quota-based limit
```

### 5.2 Backend Service Architecture

```typescript
// functions/src/campaigns/createCampaign.ts (Cloud Function)
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { z } from 'zod';
import { authenticateRequest, hasRole } from '../middleware/auth';
import { validateRequest } from '../middleware/validation';
import { logEvent } from '../utils/logger';
import { CampaignSchema } from '../schemas/campaign';

const DEFAULT_CAMPAIGN_CREATION_QUOTA_WINDOW_MS = 86_400_000; // fallback interval if not configured
const DEFAULT_CAMPAIGN_MIN_LEAD_TIME_MS = 2_592_000_000; // fallback lead time lower bound
const DEFAULT_CAMPAIGN_MAX_LEAD_TIME_MS = 15_552_000_000; // fallback lead time upper bound

// Request validation schema
const CreateCampaignRequest = z.object({
  title: z.string().min(10).max(100),
  tagline: z.string().max(150).optional(),
  description: z.string().min(100).max(5000),
  campaign_type: z.enum([
    'BUSINESS_STARTUP',
    'COMMUNITY_PROJECT',
    'SOCIAL_INITIATIVE',
    'INFRASTRUCTURE',
    'EDUCATION',
    'HEALTHCARE',
    'AGRICULTURE',
    'TECHNOLOGY',
  ]),
  goal_amount: z.number().min(100).max(1000000),
  currency: z.string().length(3).default('USD'),
  target_end_date: z.string().datetime(),
  location: z.object({
    city: z.string().min(2),
    region: z.string().min(2),
    country: z.string().length(2), // ISO 3166-1 alpha-2
    latitude: z.number().min(-90).max(90),
    longitude: z.number().min(-180).max(180),
  }),
  media_urls: z.array(z.string().url()).max(10).optional(),
});

export const createCampaign = functions
  .runWith({ memory: '512MB', timeoutSeconds: 30 })
  .https.onCall(async (data, context) => {
    try {
      // Authentication check
      if (!context.auth) {
        throw new functions.https.HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      const userId = context.auth.uid;

      // Authorization check (must be verified creator)
      const userDoc = await admin
        .firestore()
        .collection('users')
        .doc(userId)
        .get();

      const userData = userDoc.data();
      if (!userData?.verification?.id_verified) {
        throw new functions.https.HttpsError(
          'permission-denied',
          'User must complete identity verification to create campaigns'
        );
      }

      // Rate limiting check
      const quotaWindowMs =
        functions.config().campaigns?.creation_quota_window_ms ??
        DEFAULT_CAMPAIGN_CREATION_QUOTA_WINDOW_MS;

      const recentCampaigns = await admin
        .firestore()
        .collection('campaigns')
        .where('creator_user_id', '==', userId)
        .where('created_at', '>', Date.now() - quotaWindowMs)
        .get();

      if (recentCampaigns.size >= 5) {
        throw new functions.https.HttpsError(
          'resource-exhausted',
          'Campaign creation quota exceeded for the current interval'
        );
      }

      // Validate request body
      const validatedData = CreateCampaignRequest.parse(data);

      // Business logic validation
      const targetDate = new Date(validatedData.target_end_date);
      const minLeadTimeMs =
        functions.config().campaigns?.minimum_lead_time_ms ??
        DEFAULT_CAMPAIGN_MIN_LEAD_TIME_MS;
      const maxLeadTimeMs =
        functions.config().campaigns?.maximum_lead_time_ms ??
        DEFAULT_CAMPAIGN_MAX_LEAD_TIME_MS;

      const minDate = new Date(Date.now() + minLeadTimeMs);
      const maxDate = new Date(Date.now() + maxLeadTimeMs);

      if (targetDate < minDate || targetDate > maxDate) {
        throw new functions.https.HttpsError(
          'invalid-argument',
          'Target end date must fall within the configured scheduling window'
        );
      }

      // Fraud detection checks (async, don't block)
      const fraudScore = await calculateFraudScore({
        userId,
        description: validatedData.description,
        mediaUrls: validatedData.media_urls || [],
      });

      // Create campaign document
      const campaignRef = admin.firestore().collection('campaigns').doc();
      const campaign = {
        id: campaignRef.id,
        creator_user_id: userId,
        ...validatedData,
        current_amount: 0,
        status: fraudScore > 50 ? 'UNDER_REVIEW' : 'DRAFT',
        fraud_score: fraudScore,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      };

      await campaignRef.set(campaign);

      // Trigger secondary workflows (async)
      await Promise.all([
        // Index in search engine
        indexCampaignInAlgolia(campaign),
        // Fetch population data for impact calculation
        enrichCampaignWithPopulationData(campaignRef.id),
        // Send to moderation queue if high fraud score
        fraudScore > 50 && queueForManualReview(campaignRef.id),
        // Log analytics event
        logEvent('campaign_created', {
          campaign_id: campaignRef.id,
          user_id: userId,
          campaign_type: validatedData.campaign_type,
          goal_amount: validatedData.goal_amount,
        }),
      ]);

      return {
        campaign_id: campaignRef.id,
        status: campaign.status,
        created_at: new Date().toISOString(),
        verification_required: fraudScore > 50,
        next_steps: getNextSteps(campaign.status),
      };
    } catch (error) {
      // Structured error logging
      functions.logger.error('Campaign creation failed', {
        user_id: context.auth?.uid,
        error: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
      });

      // Re-throw HTTP errors
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      // Validation errors
      if (error instanceof z.ZodError) {
        throw new functions.https.HttpsError(
          'invalid-argument',
          'Validation failed',
          { details: error.errors }
        );
      }

      // Generic server error
      throw new functions.https.HttpsError('internal', 'An unexpected error occurred');
    }
  });

// Fraud detection helper (simplified)
async function calculateFraudScore(params: {
  userId: string;
  description: string;
  mediaUrls: string[];
}): Promise<number> {
  let score = 0;

  // Check if new account
  const userDoc = await admin.firestore().collection('users').doc(params.userId).get();
  const accountAge = Date.now() - userDoc.data()?.created_at?.toMillis();
  if (accountAge < 7 * 24 * 60 * 60 * 1000) {
  score += 30; // Within freshness threshold
  }

  // Check for stock photos (Google Vision API reverse image search)
  for (const url of params.mediaUrls) {
    const isStockPhoto = await detectStockPhoto(url);
    if (isStockPhoto) score += 25;
  }

  // Plagiarism detection (compare against existing campaigns)
  const similarity = await checkDescriptionSimilarity(params.description);
  if (similarity > 0.8) score += 20;

  // Vague description heuristic (low word count, generic keywords)
  const wordCount = params.description.split(/\s+/).length;
  if (wordCount < 150) score += 15;

  return Math.min(score, 100);
}
```

### 5.3 Database Optimization Patterns

```typescript
// Firestore Security Rules (firestore.rules)
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function isVerifiedCreator() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid))
               .data.verification.id_verified == true;
    }
    
    function isAdmin() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid))
               .data.role == 'admin';
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isOwner(userId);
      allow update: if isOwner(userId) && 
                       !request.resource.data.diff(resource.data)
                         .affectedKeys().hasAny(['role', 'verification.id_verified']);
      allow delete: if isOwner(userId) || isAdmin();
    }
    
    // Campaigns collection
    match /campaigns/{campaignId} {
      allow read: if true; // Public read
      allow create: if isVerifiedCreator() && 
                       request.resource.data.creator_user_id == request.auth.uid &&
                       request.resource.data.goal_amount >= 100 &&
                       request.resource.data.goal_amount <= 1000000;
      allow update: if isOwner(resource.data.creator_user_id) &&
                       resource.data.status == 'DRAFT' && // Can only edit drafts
                       !request.resource.data.diff(resource.data)
                         .affectedKeys().hasAny([
                           'creator_user_id',
                           'current_amount',
                           'created_at'
                         ]);
      allow delete: if isOwner(resource.data.creator_user_id) && 
                       resource.data.status == 'DRAFT';
    }
    
    // Contributions collection (write-only by cloud functions)
    match /contributions/{contributionId} {
      allow read: if isOwner(resource.data.contributor_user_id) || isAdmin();
      allow write: if false; // Only Cloud Functions can write
    }
    
    // Transactions collection (strict read access)
    match /transactions/{transactionId} {
      allow read: if isOwner(resource.data.user_id);
      allow write: if false; // Only Cloud Functions can write
    }
  }
}

// Firestore Indexes (firestore.indexes.json)
{
  "indexes": [
    {
      "collectionGroup": "campaigns",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "location.country", "order": "ASCENDING" },
        { "fieldPath": "location.city", "order": "ASCENDING" },
        { "fieldPath": "created_at", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "campaigns",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "campaign_type", "order": "ASCENDING" },
        { "fieldPath": "funding_goal.percentage_funded", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "jobs",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "location.country", "order": "ASCENDING" },
        { "fieldPath": "posting_date", "order": "DESCENDING" }
      ]
    }
  ],
  "fieldOverrides": [
    {
      "collectionGroup": "campaigns",
      "fieldPath": "industry_tags",
      "indexes": [
        { "queryScope": "COLLECTION", "order": "ASCENDING" },
        { "queryScope": "COLLECTION_GROUP", "arrayConfig": "CONTAINS" }
      ]
    }
  ]
}

// PostgreSQL Schema (for complex analytics)
-- migrations/001_initial_schema.sql
CREATE TABLE campaign_analytics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id UUID NOT NULL,
  date DATE NOT NULL,
  views_count INT DEFAULT 0,
  contributions_count INT DEFAULT 0,
  contributions_amount DECIMAL(12,2) DEFAULT 0,
  unique_contributors INT DEFAULT 0,
  share_count INT DEFAULT 0,
  UNIQUE(campaign_id, date)
);

CREATE INDEX idx_campaign_analytics_date ON campaign_analytics(date DESC);
CREATE INDEX idx_campaign_analytics_campaign ON campaign_analytics(campaign_id);

-- Materialized view for dashboard queries
CREATE MATERIALIZED VIEW mv_campaign_performance AS
SELECT 
  c.id,
  c.title,
  c.goal_amount,
  c.current_amount,
  c.status,
  c.created_at,
  COALESCE(SUM(ca.views_count), 0) as total_views,
  COALESCE(SUM(ca.contributions_count), 0) as total_contributions,
  COALESCE(COUNT(DISTINCT ca.date), 0) as days_active,
  CASE 
    WHEN c.current_amount >= c.goal_amount THEN 'SUCCESS'
    WHEN NOW() > c.target_end_date THEN 'FAILED'
    ELSE 'ACTIVE'
  END as outcome
FROM campaigns c
LEFT JOIN campaign_analytics ca ON c.id = ca.campaign_id
GROUP BY c.id;

CREATE UNIQUE INDEX idx_mv_campaign_performance ON mv_campaign_performance(id);

-- Refresh materialized view daily (via cron job)
-- SELECT refresh_materialized_view_concurrently('mv_campaign_performance');
```

---

## 6. Security Implementation

### 6.1 Payment Flow Security

```typescript
// functions/src/payments/contributeToCampaign.ts
import Stripe from 'stripe';
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const stripe = new Stripe(functions.config().stripe.secret_key, {
  apiVersion: '2024-06-20',
});

export const contributeToCampaign = functions.https.onCall(async (data, context) => {
  // 1. Authentication & Authorization
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }

  const { campaign_id, amount, payment_method_id } = data;
  const userId = context.auth.uid;

  // 2. Validate campaign exists and is active
  const campaignDoc = await admin
    .firestore()
    .collection('campaigns')
    .doc(campaign_id)
    .get();

  if (!campaignDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Campaign not found');
  }

  const campaign = campaignDoc.data()!;
  if (campaign.status !== 'ACTIVE') {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Campaign is not accepting contributions'
    );
  }

  // 3. Validate amount
  if (amount < 1 || amount > 100000) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Amount must be between $1 and $100,000'
    );
  }

  // 4. Rate limiting (max 10 contributions per hour)
  const recentContributions = await admin
    .firestore()
    .collection('contributions')
    .where('contributor_user_id', '==', userId)
    .where('created_at', '>', Date.now() - 60 * 60 * 1000)
    .get();

  if (recentContributions.size >= 10) {
    throw new functions.https.HttpsError(
      'resource-exhausted',
      'Maximum 10 contributions per hour'
    );
  }

  // 5. Idempotency check (prevent duplicate charges)
  const idempotencyKey = `contrib_${userId}_${campaign_id}_${Date.now()}`;

  try {
    // 6. Create Stripe PaymentIntent (with manual capture for escrow)
    const paymentIntent = await stripe.paymentIntents.create(
      {
        amount: Math.round(amount * 100), // Convert to cents
        currency: campaign.currency.toLowerCase(),
        payment_method: payment_method_id,
        customer: await getOrCreateStripeCustomer(userId),
        capture_method: 'manual', // CRITICAL: Hold funds in escrow
        metadata: {
          campaign_id,
          contributor_user_id: userId,
          platform: 'local_community_app',
        },
        statement_descriptor_suffix: 'CAMPAIGN',
        description: `Contribution to: ${campaign.title}`,
        // 3D Secure enforcement for European cards
        confirmation_method: 'automatic',
        confirm: true,
      },
      {
        idempotencyKey,
      }
    );

    // 7. Create contribution record (atomic transaction)
    const contributionRef = admin.firestore().collection('contributions').doc();
    const transactionRef = admin.firestore().collection('transactions').doc();

    await admin.firestore().runTransaction(async (transaction) => {
      // Read current campaign state
      const freshCampaign = await transaction.get(campaignDoc.ref);
      const currentAmount = freshCampaign.data()!.current_amount;

      // Write contribution
      transaction.set(contributionRef, {
        id: contributionRef.id,
        campaign_id,
        contributor_user_id: userId,
        amount,
        currency: campaign.currency,
        payment_intent_id: paymentIntent.id,
        transaction_status: 'HELD_IN_ESCROW',
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Update campaign funding
      transaction.update(campaignDoc.ref, {
        current_amount: currentAmount + amount,
        'funding_goal.number_of_contributors': admin.firestore.FieldValue.increment(1),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Create transaction record
      transaction.set(transactionRef, {
        id: transactionRef.id,
        user_id: userId,
        transaction_type: 'CAMPAIGN_CONTRIBUTION',
        amount: -amount, // Negative for user (outgoing)
        currency: campaign.currency,
        status: 'COMPLETED',
        reference_id: campaign_id,
        payment_intent_id: paymentIntent.id,
        description: `Contribution to ${campaign.title}`,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    // 8. Trigger post-contribution workflows (async)
    await Promise.all([
      // Send confirmation email
      sendContributionConfirmation(userId, campaign_id, amount),
      // Notify campaign creator
      notifyCampaignCreator(campaign.creator_user_id, amount),
      // Check if campaign reached goal
      checkCampaignGoalReached(campaign_id),
      // Update search index
      updateCampaignInAlgolia(campaign_id),
      // Log analytics event
      logEvent('contribution_made', {
        campaign_id,
        user_id: userId,
        amount,
        currency: campaign.currency,
      }),
    ]);

    return {
      success: true,
      contribution_id: contributionRef.id,
      payment_intent_id: paymentIntent.id,
      status: 'HELD_IN_ESCROW',
      message: 'Contribution successful! Funds will be released when campaign reaches its goal.',
    };
  } catch (error) {
    // Handle Stripe errors
    if (error instanceof Stripe.errors.StripeCardError) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Payment failed: ${error.message}`,
        { code: error.code }
      );
    }

    functions.logger.error('Contribution failed', {
      user_id: userId,
      campaign_id,
      amount,
      error: error instanceof Error ? error.message : String(error),
    });

    throw new functions.https.HttpsError('internal', 'Payment processing failed');
  }
});

// Webhook handler for Stripe events
export const stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'] as string;
  const webhookSecret = functions.config().stripe.webhook_secret;

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(req.rawBody, sig, webhookSecret);
  } catch (err) {
    functions.logger.error('Webhook signature verification failed', { error: err });
    res.status(400).send('Webhook Error');
    return;
  }

  // Handle events
  switch (event.type) {
    case 'payment_intent.succeeded':
      await handlePaymentIntentSucceeded(event.data.object as Stripe.PaymentIntent);
      break;
    case 'payment_intent.payment_failed':
      await handlePaymentIntentFailed(event.data.object as Stripe.PaymentIntent);
      break;
    case 'charge.refunded':
      await handleChargeRefunded(event.data.object as Stripe.Charge);
      break;
    default:
      functions.logger.info(`Unhandled event type: ${event.type}`);
  }

  res.json({ received: true });
});

// Helper: Get or create Stripe customer for user
async function getOrCreateStripeCustomer(userId: string): Promise<string> {
  const userDoc = await admin.firestore().collection('users').doc(userId).get();
  const userData = userDoc.data()!;

  if (userData.stripe_customer_id) {
    return userData.stripe_customer_id;
  }

  // Create new Stripe customer
  const customer = await stripe.customers.create({
    email: userData.email,
    metadata: { user_id: userId },
  });

  // Save customer ID
  await userDoc.ref.update({ stripe_customer_id: customer.id });

  return customer.id;
}
```

### 6.2 KYC/AML Implementation

```typescript
// functions/src/kyc/verifyIdentity.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { verifyDocument } from '../integrations/idVerification'; // Third-party service

export const submitIdentityVerification = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
    }

    const { document_type, document_front_url, document_back_url, selfie_url } = data;
    const userId = context.auth.uid;

    // Check if already verified
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    if (userDoc.data()?.verification?.id_verified) {
      throw new functions.https.HttpsError(
        'already-exists',
        'Identity already verified'
      );
    }

    // Submit to third-party verification service (e.g., Onfido, Jumio)
    const verificationResult = await verifyDocument({
      userId,
      documentType: document_type,
      documentFrontUrl: document_front_url,
      documentBackUrl: document_back_url,
      selfieUrl: selfie_url,
    });

    // Create verification record
    const verificationRef = admin.firestore().collection('verifications').doc();
    await verificationRef.set({
      id: verificationRef.id,
      user_id: userId,
      document_type,
      status: verificationResult.status, // PENDING, APPROVED, REJECTED
      confidence_score: verificationResult.confidence,
      provider: 'onfido',
      submitted_at: admin.firestore.FieldValue.serverTimestamp(),
      reviewed_at: verificationResult.status !== 'PENDING' 
        ? admin.firestore.FieldValue.serverTimestamp() 
        : null,
    });

    // Update user verification status if auto-approved
    if (verificationResult.status === 'APPROVED' && verificationResult.confidence > 0.95) {
      await userDoc.ref.update({
        'verification.id_verified': true,
        'verification.verification_date': admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    return {
      verification_id: verificationRef.id,
      status: verificationResult.status,
      message:
        verificationResult.status === 'PENDING'
          ? 'Verification submitted. We will review within 24-48 hours.'
          : 'Identity verified successfully!',
    };
  }
);

// Scheduled function to check verification statuses
export const checkPendingVerifications = functions.pubsub
  .schedule('every 30 minutes')
  .onRun(async () => {
    const pending = await admin
      .firestore()
      .collection('verifications')
      .where('status', '==', 'PENDING')
      .where('submitted_at', '<', Date.now() - 30 * 60 * 1000) // Older than 30 mins
      .limit(100)
      .get();

    for (const doc of pending.docs) {
      const data = doc.data();
      const updatedResult = await checkVerificationStatus(data.id);
      
      if (updatedResult.status !== 'PENDING') {
        await doc.ref.update({
          status: updatedResult.status,
          confidence_score: updatedResult.confidence,
          reviewed_at: admin.firestore.FieldValue.serverTimestamp(),
        });

        if (updatedResult.status === 'APPROVED') {
          await admin
            .firestore()
            .collection('users')
            .doc(data.user_id)
            .update({
              'verification.id_verified': true,
              'verification.verification_date': admin.firestore.FieldValue.serverTimestamp(),
            });
        }

        // Send notification to user
        await sendVerificationResult(data.user_id, updatedResult.status);
      }
    }
  });
```

---

## 7. CI/CD & Deployment

### 7.1 GitHub Actions Workflow

```yaml
# .github/workflows/flutter-ci.yml
name: Flutter CI/CD

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]
    tags:
      - 'v*'

env:
  FLUTTER_VERSION: '3.24.0'
  NODE_VERSION: '20'

jobs:
  lint-and-analyze:
    name: Lint & Static Analysis
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: 'stable'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Run flutter format check
        run: dart format --set-exit-if-changed .
      
      - name: Run flutter analyze
        run: flutter analyze --fatal-infos --fatal-warnings
      
      - name: Run custom lint rules
        run: dart run custom_lint

  test-unit-widget:
    name: Unit & Widget Tests
    runs-on: ubuntu-latest
    needs: lint-and-analyze
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Run tests with coverage
        run: flutter test --coverage --reporter=github
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          files: ./coverage/lcov.info
          fail_ci_if_error: true
      
      - name: Check coverage threshold (80%)
        run: |
          COVERAGE=$(lcov --summary coverage/lcov.info | grep "lines" | awk '{print $2}' | sed 's/%//')
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "Coverage $COVERAGE% is below 80% threshold"
            exit 1
          fi

  test-integration:
    name: Integration Tests
    runs-on: macos-latest
    needs: test-unit-widget
    strategy:
      matrix:
        api-level: [29, 33]
        target: [default, google_apis]
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      
      - name: Setup Android Emulator
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: ${{ matrix.api-level }}
          target: ${{ matrix.target }}
          arch: x86_64
          script: |
            flutter pub get
            flutter drive \
              --driver=test_driver/integration_test.dart \
              --target=integration_test/app_test.dart

  test-accessibility:
    name: Accessibility Audit
    runs-on: ubuntu-latest
    needs: lint-and-analyze
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Build web version
        run: flutter build web --release
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
      
      - name: Run Lighthouse CI
        run: |
          npm install -g @lhci/cli
          lhci autorun --config=./lighthouserc.json
        env:
          LHCI_GITHUB_APP_TOKEN: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}

  build-android:
    name: Build Android APK/Bundle
    runs-on: ubuntu-latest
    needs: [test-unit-widget, test-integration]
    if: github.event_name == 'push' && (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/v'))
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Decode keystore
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode > android/app/keystore.jks
      
      - name: Create key.properties
        run: |
          echo "storePassword=${{ secrets.ANDROID_KEYSTORE_PASSWORD }}" > android/key.properties
          echo "keyPassword=${{ secrets.ANDROID_KEY_PASSWORD }}" >> android/key.properties
          echo "keyAlias=${{ secrets.ANDROID_KEY_ALIAS }}" >> android/key.properties
          echo "storeFile=keystore.jks" >> android/key.properties
      
      - name: Build APK
        run: flutter build apk --release --split-per-abi
      
      - name: Build App Bundle
        run: flutter build appbundle --release
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: android-release
          path: |
            build/app/outputs/flutter-apk/*.apk
            build/app/outputs/bundle/release/*.aab

  build-ios:
    name: Build iOS IPA
    runs-on: macos-latest
    needs: [test-unit-widget, test-integration]
    if: github.event_name == 'push' && (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/v'))
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: 'latest-stable'
      
      - name: Install CocoaPods
        run: |
          cd ios
          pod install
      
      - name: Build iOS (no codesign for CI)
        run: flutter build ios --release --no-codesign
      
      - name: Create IPA (requires certs in real pipeline)
        run: |
          mkdir Payload
          cp -r build/ios/iphoneos/Runner.app Payload
          zip -r LocalCommunityApp.ipa Payload
      
      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: ios-release
          path: LocalCommunityApp.ipa

  deploy-backend:
    name: Deploy Cloud Functions
    runs-on: ubuntu-latest
    needs: [test-unit-widget]
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
      
      - name: Install Firebase CLI
        run: npm install -g firebase-tools
      
      - name: Install dependencies
        run: |
          cd functions
          npm ci
      
      - name: Run backend tests
        run: |
          cd functions
          npm test
      
      - name: Deploy to Firebase
        run: |
          firebase deploy --only functions --project ${{ secrets.FIREBASE_PROJECT_ID }} --token ${{ secrets.FIREBASE_TOKEN }}

  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    needs: [build-android, build-ios, deploy-backend]
    if: github.event_name == 'push' && github.ref == 'refs/heads/develop'
    environment:
      name: staging
      url: https://staging.localcommunityapp.org
    steps:
      - name: Deploy to Firebase Hosting (staging)
        run: |
          firebase hosting:channel:deploy staging \
            --project ${{ secrets.FIREBASE_PROJECT_ID }} \
            --token ${{ secrets.FIREBASE_TOKEN }}

  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: [build-android, build-ios, deploy-backend]
    if: startsWith(github.ref, 'refs/tags/v')
    environment:
      name: production
      url: https://localcommunityapp.org
    steps:
      - name: Create GitHub Release
        uses: actions/create-release@v1
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          draft: false
          prerelease: false
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Deploy to Firebase Hosting (production)
        run: |
          firebase deploy --only hosting \
            --project ${{ secrets.FIREBASE_PROJECT_ID }} \
            --token ${{ secrets.FIREBASE_TOKEN }}
      
      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_SERVICE_ACCOUNT }}
          packageName: org.localcommunityapp.mobile
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: production
          status: completed
      
      - name: Upload to App Store Connect
        uses: apple-actions/upload-testflight-build@v1
        with:
          app-path: LocalCommunityApp.ipa
          issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
          api-key-id: ${{ secrets.APPSTORE_API_KEY_ID }}
          api-private-key: ${{ secrets.APPSTORE_API_PRIVATE_KEY }}
```

---

## 8. Monitoring & Observability

### 8.1 Logging Strategy

```typescript
// utils/logger.ts
import * as functions from 'firebase-functions';
import { v4 as uuidv4 } from 'uuid';

export interface LogContext {
  userId?: string;
  campaignId?: string;
  jobId?: string;
  transactionId?: string;
  requestId?: string;
  [key: string]: any;
}

export class Logger {
  private correlationId: string;
  private context: LogContext;

  constructor(context: LogContext = {}) {
    this.correlationId = uuidv4();
    this.context = { ...context, correlationId: this.correlationId };
  }

  info(message: string, data?: Record<string, any>) {
    functions.logger.info(message, { ...this.context, ...data });
  }

  warn(message: string, data?: Record<string, any>) {
    functions.logger.warn(message, { ...this.context, ...data });
  }

  error(message: string, error?: Error, data?: Record<string, any>) {
    functions.logger.error(
      message,
      {
        ...this.context,
        ...data,
        error: error?.message,
        stack: error?.stack,
      }
    );
  }

  // Specialized method for audit logging (compliance)
  audit(action: string, details: Record<string, any>) {
    functions.logger.info(`AUDIT: ${action}`, {
      ...this.context,
      ...details,
      timestamp: new Date().toISOString(),
      auditLog: true,
    });
  }
}

// Usage example
export function withLogger(
  handler: (logger: Logger) => Promise<any>
): (data: any, context: functions.https.CallableContext) => Promise<any> {
  return async (data, context) => {
    const logger = new Logger({
      userId: context.auth?.uid,
      requestId: context.auth?.token?.request_id,
    });

    try {
      const result = await handler(logger);
      logger.info('Request completed successfully');
      return result;
    } catch (error) {
      logger.error('Request failed', error as Error);
      throw error;
    }
  };
}
```

### 8.2 Alerting Rules

```yaml
# monitoring/alerts.yaml
alerting:
  groups:
    - name: critical
      interval: 1m
      rules:
        - alert: HighErrorRate
          expr: |
            rate(http_requests_total{status=~"5.."}[5m]) /
            rate(http_requests_total[5m]) > 0.05
          for: 5m
          labels:
            severity: critical
          annotations:
            summary: "High error rate detected"
            description: "Error rate is {{ $value | humanizePercentage }} (threshold: 5%)"
        
        - alert: PaymentProcessingFailure
          expr: |
            rate(stripe_payment_failures_total[5m]) > 0.1
          for: 2m
          labels:
            severity: critical
          annotations:
            summary: "Payment processing failing"
            description: "Payment failure rate: {{ $value }}/min"
        
        - alert: DatabaseConnectionPoolExhausted
          expr: pg_stat_activity_count > 90
          for: 1m
          labels:
            severity: critical
          annotations:
            summary: "Database connection pool nearly exhausted"
            description: "{{ $value }} connections active (max: 100)"

    - name: high
      interval: 5m
      rules:
        - alert: SlowAPIResponse
          expr: |
            histogram_quantile(0.95, 
              rate(http_request_duration_seconds_bucket[10m])
            ) > 1.0
          for: 10m
          labels:
            severity: high
          annotations:
            summary: "API response time degraded"
            description: "p95 latency: {{ $value }}s (threshold: 1s)"
        
        - alert: CampaignVerificationBacklog
          expr: |
            count(campaigns{status="UNDER_REVIEW"}) > 100
          for: 1h
          labels:
            severity: high
          annotations:
            summary: "Campaign verification backlog growing"
            description: "{{ $value }} campaigns awaiting review"

    - name: medium
      interval: 15m
      rules:
        - alert: LowCacheHitRate
          expr: |
            rate(cache_hits_total[30m]) /
            (rate(cache_hits_total[30m]) + rate(cache_misses_total[30m])) < 0.8
          for: 30m
          labels:
            severity: medium
          annotations:
            summary: "Cache hit rate below target"
            description: "Hit rate: {{ $value | humanizePercentage }} (target: 80%)"
        
        - alert: HighMobileAppCrashRate
          expr: |
            rate(mobile_crashes_total[1h]) /
            rate(mobile_sessions_total[1h]) > 0.01
          for: 1h
          labels:
            severity: medium
          annotations:
            summary: "Mobile app crash rate elevated"
            description: "Crash rate: {{ $value | humanizePercentage }} (threshold: 1%)"
```

---

## 9. Contribution & Release Workflow

### 9.1 Git Branching Strategy

```
main (production)
  ├── develop (staging)
  │   ├── feature/campaign-milestone-tracking
  │   ├── feature/job-application-flow
  │   ├── bugfix/wallet-balance-calculation
  │   └── hotfix/payment-webhook-retry

Branch Naming:
  - feature/descriptive-name (new features)
  - bugfix/issue-description (bug fixes)
  - hotfix/critical-fix (production hotfixes)
  - refactor/component-name (code improvements)
  - docs/section-name (documentation only)

Commit Message Format (Conventional Commits):
  type(scope): subject

  body (optional)

  footer (optional)

Types:
  feat: New feature
  fix: Bug fix
  docs: Documentation changes
  style: Code style changes (formatting, no logic change)
  refactor: Code refactoring
  test: Adding or updating tests
  chore: Maintenance tasks (deps, config)
  perf: Performance improvements
  ci: CI/CD changes

Examples:
  feat(campaigns): add milestone tracking UI
  fix(wallet): correct balance calculation after refund
  docs(api): update contribution endpoint examples
  perf(search): optimize Algolia index structure
```

### 9.2 Pull Request Template

```markdown
<!-- .github/pull_request_template.md -->
## Description
<!-- Brief description of changes -->

## Type of Change
- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality to change)
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Refactoring (no functional changes)

## Related Issues
<!-- Link to related issues: Closes #123, Fixes #456 -->

## Checklist
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published

## Testing
<!-- Describe the tests you ran and how to reproduce -->

### Test Coverage
- Unit tests: <!-- percentage or N/A -->
- Widget tests: <!-- percentage or N/A -->
- Integration tests: <!-- list of flows tested -->

### Manual Testing
<!-- Steps to manually verify changes -->

## Screenshots (if applicable)
<!-- Add screenshots for UI changes -->

## Performance Impact
<!-- Describe any performance implications -->

## Security Considerations
<!-- Highlight security-relevant changes -->

## Breaking Changes
<!-- List any breaking changes and migration guide -->

## Deployment Notes
<!-- Special deployment steps, database migrations, env vars, etc. -->

## Reviewer Notes
<!-- Additional context for reviewers -->
```

### 9.3 Release Process

```bash
# scripts/release.sh
#!/bin/bash
set -e

# Release script for Local Community App
# Usage: ./scripts/release.sh <version> <type>
# Example: ./scripts/release.sh 1.2.0 minor

VERSION=$1
TYPE=$2 # major, minor, patch

if [ -z "$VERSION" ] || [ -z "$TYPE" ]; then
  echo "Usage: ./scripts/release.sh <version> <type>"
  exit 1
fi

echo "🚀 Preparing release v$VERSION ($TYPE)"

# 1. Verify on develop branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "develop" ]; then
  echo "❌ Must be on develop branch to release"
  exit 1
fi

# 2. Ensure clean working directory
if [ -n "$(git status --porcelain)" ]; then
  echo "❌ Working directory not clean. Commit or stash changes."
  exit 1
fi

# 3. Pull latest changes
git pull origin develop

# 4. Run full test suite
echo "🧪 Running tests..."
flutter test
cd functions && npm test && cd ..

# 5. Update version in pubspec.yaml
echo "📝 Updating version to $VERSION..."
sed -i.bak "s/^version: .*/version: $VERSION+$(date +%Y%m%d%H%M%S)/" pubspec.yaml
rm pubspec.yaml.bak

# 6. Update CHANGELOG.md
echo "📝 Updating CHANGELOG..."
DATE=$(date +%Y-%m-%d)
cat<<CHANGELOG.md <<EOF
## [$VERSION] - $DATE

### Added
<!-- List new features -->

### Changed
<!-- List changes to existing functionality -->

### Fixed
<!-- List bug fixes -->

### Security
<!-- List security improvements -->

### Deprecated
<!-- List soon-to-be removed features -->

### Removed
<!-- List removed features -->

---

EOF

# 7. Generate release notes
echo "📝 Generating release notes..."
git log --oneline $(git describe --tags --abbrev=0)..HEAD > release_notes.txt

# 8. Create release branch
git checkout -b release/v$VERSION

# 9. Commit version bump
git add pubspec.yaml CHANGELOG.md
git commit -m "chore(release): bump version to $VERSION"

# 10. Merge to main
git checkout main
git pull origin main
git merge --no-ff release/v$VERSION -m "Release v$VERSION"

# 11. Create and push tag
git tag -a v$VERSION -m "Release version $VERSION"
git push origin main
git push origin v$VERSION

# 12. Merge back to develop
git checkout develop
git merge --no-ff main -m "Merge release v$VERSION back to develop"
git push origin develop

# 13. Clean up release branch
git branch -d release/v$VERSION

echo "✅ Release v$VERSION complete!"
echo "📦 Artifacts will be built by CI/CD pipeline"
echo "🔗 Monitor deployment at: https://github.com/local-community-app/platform/actions"
```

### 9.4 Semantic Versioning Strategy

```yaml
Version Format: MAJOR.MINOR.PATCH

MAJOR (X.0.0):
  - Breaking API changes
  - Major architectural changes
  - Database schema changes requiring migration
  - Changes to authentication/authorization model
  - Removal of deprecated features
  Example: 1.0.0 → 2.0.0

MINOR (0.X.0):
  - New features (backwards compatible)
  - New API endpoints
  - Performance improvements
  - New payment methods/integrations
  - UI/UX enhancements
  Example: 1.2.0 → 1.3.0

PATCH (0.0.X):
  - Bug fixes
  - Security patches
  - Documentation updates
  - Minor UI tweaks
  - Performance optimizations
  Example: 1.2.3 → 1.2.4

Pre-release suffixes:
  - alpha: 1.3.0-alpha.1 (internal testing)
  - beta: 1.3.0-beta.1 (public beta)
  - rc: 1.3.0-rc.1 (release candidate)

Build metadata:
  - 1.3.0+20251002143000 (timestamp)
  - 1.3.0+build.123 (CI build number)
```

---

## 10. Agent Collaboration Protocols

### 10.1 Inter-Agent Communication Framework

**Context Sharing Mechanism:**

```yaml
Shared Context Document Structure:
  session_id: uuid
  active_agents:
    - navigator: "Session-ABC-123"
    - architect: "Session-ABC-124"
    - builder: "Session-ABC-125"
  
  current_focus:
    feature: "Campaign Milestone Tracking"
    user_story: "As a campaign creator, I want to set milestones..."
    phase: "Implementation"
    
  decisions_made:
    - timestamp: "2025-10-02T14:30:00Z"
      decision: "Use Firestore subcollection for milestones"
      rationale: "Real-time updates, better query performance"
      decided_by: "architect"
      approved_by: ["navigator", "security"]
      
  open_questions:
    - question: "Should milestone verification require admin approval?"
      raised_by: "security"
      priority: "high"
      needs_input_from: ["navigator", "builder"]
      
  blockers:
    - blocker: "Payment webhook retry logic incomplete"
      blocked_tasks: ["Campaign completion flow", "Payout processing"]
      owner: "builder"
      status: "in_progress"
      
  work_in_progress:
    - task: "Implement milestone UI components"
      assignee: "builder"
      started: "2025-10-02T10:00:00Z"
      estimated_completion: "2025-10-02T18:00:00Z"
      dependencies: []
```

**Communication Protocol:**

1. **Daily Sync Pattern** (for coordinated work):
```markdown
## Daily Agent Sync Template

**Date**: 2025-10-02
**Sprint**: Week 42 (Campaign Milestones Feature)

### Navigator Update:
- **Completed**: Finalized user stories for milestone tracking
- **In Progress**: Reviewing community feedback on fundraising transparency
- **Next**: Define acceptance criteria for payout automation
- **Blockers**: None
- **Decisions Needed**: Should we limit number of milestones per campaign?

### Architect Update:
- **Completed**: Designed milestone data schema
- **In Progress**: API specification for milestone CRUD operations
- **Next**: Define webhook payload for milestone completion events
- **Blockers**: Waiting on decision about admin approval requirement
- **Decisions Needed**: Firestore vs PostgreSQL for milestone audit logs?

### Builder Update:
- **Completed**: Milestone creation UI (Flutter)
- **In Progress**: Backend functions for milestone status updates
- **Next**: Integration tests for milestone lifecycle
- **Blockers**: Need finalized API spec from Architect
- **Decisions Needed**: None

### Security Update:
- **Completed**: Threat model for milestone verification flow
- **In Progress**: Implementing fraud detection for fake milestone claims
- **Next**: Pen test milestone completion flow
- **Blockers**: None
- **Decisions Needed**: Risk level acceptable for auto-approval thresholds?

### Quality Update:
- **Completed**: Test plan for milestone feature
- **In Progress**: Setting up performance benchmarks
- **Next**: Load testing milestone creation at scale
- **Blockers**: None
- **Decisions Needed**: None

### Cross-Agent Coordination:
- **Meeting Needed**: Milestone verification workflow (All agents)
- **Shared Risk**: Milestone manipulation by bad actors
- **Shared Goal**: Ship milestone feature by Oct 15th
```

### 10.2 Decision-Making Framework

**Decision Types and Authority:**

```yaml
Level 1 - Individual Agent Decisions (No consultation needed):
  - Code formatting and style choices
  - Variable naming
  - Local function organization
  - Test structure
  - Documentation wording
  - Minor UI tweaks (within design system)
  
Level 2 - Consulted Decisions (Inform 1-2 relevant agents):
  - API endpoint naming
  - Widget component structure
  - Error message text
  - Log level choices
  - Cache key naming
  Example: Builder → Architect (API naming)

Level 3 - Collaborative Decisions (Require 2+ agent agreement):
  - Database schema changes
  - New third-party integrations
  - State management approach changes
  - New testing strategies
  - Performance optimization trade-offs
  Example: Architect + Builder + Quality (schema change)

Level 4 - Consensus Decisions (Require all affected agents):
  - Breaking API changes
  - Major architectural shifts
  - Security model changes
  - Payment flow modifications
  - Tech stack additions/changes
  Example: All agents (add GraphQL alongside REST)

Level 5 - Escalated Decisions (Require human oversight):
  - Regulatory compliance interpretations
  - Legal risk assessments
  - Major cost implications (>$10k/month)
  - Community governance changes
  - Controversial feature additions
  Example: All agents + Human (GDPR compliance strategy)
```

**Decision Template:**

```markdown
## Decision: [Title]
**ID**: DEC-2025-042
**Date**: 2025-10-02
**Level**: 3 (Collaborative)
**Status**: Proposed

### Context
[Why is this decision needed? What problem does it solve?]

### Proposed Solution
[Detailed description of the proposal]

### Alternatives Considered
1. **Alternative A**: [Description]
   - Pros: [List]
   - Cons: [List]
   
2. **Alternative B**: [Description]
   - Pros: [List]
   - Cons: [List]

### Recommendation
[Which option and why]

### Impact Analysis
- **Performance**: [Expected impact]
- **Security**: [Security implications]
- **Cost**: [Financial impact]
- **Maintenance**: [Long-term maintenance burden]
- **User Experience**: [How users are affected]

### Required Approvals
- [ ] Navigator (Product alignment)
- [ ] Architect (Technical feasibility)
- [ ] Security (Security implications)
- [ ] Builder (Implementation effort)

### Decision
**Outcome**: [Approved/Rejected/Deferred]
**Rationale**: [Final reasoning]
**Dissenting Opinions**: [If any]

### Action Items
- [ ] [Task 1] - Assigned to [Agent]
- [ ] [Task 2] - Assigned to [Agent]
```

### 10.3 Conflict Resolution Protocol

**When Agents Disagree:**

```yaml
Step 1 - Clarify Positions:
  - Each agent clearly states their position and reasoning
  - Focus on technical facts, not preferences
  - Document trade-offs explicitly

Step 2 - Seek Additional Data:
  - Run benchmarks/tests if performance is disputed
  - Review industry best practices
  - Consult documentation or research papers
  - Check similar projects' approaches

Step 3 - Time-boxed Discussion:
  - 30 minutes maximum for initial discussion
  - Each agent gets equal time to present
  - Focus on finding common ground

Step 4 - Compromise Exploration:
  - Can we do a phased approach?
  - Can we prototype both and measure?
  - Is there a third option we haven't considered?

Step 5 - Escalation (if unresolved):
  - Escalate to human oversight
  - Present all options with pros/cons
  - Human makes final call
  - All agents commit to decision once made

Example Conflict:
  Architect: "We should use PostgreSQL for complex reporting queries"
  Builder: "Firestore is sufficient and reduces operational complexity"
  
  Resolution:
  - Architect runs query performance tests
  - Builder estimates migration effort
  - Compromise: Use Firestore with materialized views for 90% of reports,
    PostgreSQL replica for complex analytics (best of both)
```

### 10.4 Work Handoff Protocol

**Builder → Quality (Code Complete → Testing):**

```markdown
## Handoff Checklist: Campaign Milestone Feature

### Code Artifacts
- [x] PR #234 merged to develop branch
- [x] All automated tests passing
- [x] Code review completed (2 approvals)
- [x] Documentation updated

### Testing Artifacts Provided
- [x] Unit test coverage: 87% (target: 80%)
- [x] Widget test coverage: 73% (target: 70%)
- [x] Integration test: Happy path implemented
- [x] Edge cases documented in test plan

### Known Issues
- Minor: Milestone progress bar animation stutters on low-end Android devices
  - Priority: Low
  - Workaround: Disable animation on devices with <2GB RAM
  - Tracked in: ISSUE-456

### Testing Focus Areas
1. **Critical**: Milestone verification workflow (fraud prevention)
2. **High**: Concurrent milestone updates (race conditions)
3. **Medium**: Offline sync when milestone created without network

### Environment Setup
- Test data: Use staging environment campaign ID: "camp_test_milestones_001"
- Test accounts: creator@test.com / test123, contributor@test.com / test123
- Special permissions: None required

### Success Criteria
- All milestone CRUD operations complete <500ms
- No visual regressions from baseline screenshots
- Accessibility score >90 (axe-flutter)

### Deployment Notes
- Database migration: migrations/042_add_milestone_table.sql (auto-runs)
- Feature flag: `enable_campaign_milestones` (currently true in staging)
- Rollback plan: Set feature flag to false, no data loss

### Questions for Quality Agent
1. Should we load test with 10k concurrent milestone updates?
2. Any specific mobile devices you want to test on?

---

**Builder Agent Sign-off**: @builder-agent
**Date**: 2025-10-02T16:00:00Z
```

**Quality → Navigator (Testing Complete → Release Review):**

```markdown
## Quality Sign-off: Campaign Milestone Feature

### Testing Summary
- **Timeline**: Multi-day execution window
- **Test Execution**: 247 tests run, 247 passed, 0 failed
- **Defects Found**: 3 minor, 0 critical
- **Coverage**: 85% overall (exceeds 80% threshold)

### Test Results by Type
1. **Unit Tests**: ✅ All passing (1,234 tests)
2. **Widget Tests**: ✅ All passing (456 tests)
3. **Integration Tests**: ✅ All critical flows verified
4. **Performance Tests**: ✅ All endpoints <500ms (p95)
5. **Security Tests**: ✅ No vulnerabilities found
6. **Accessibility Tests**: ✅ Score: 94/100
7. **Regression Tests**: ✅ No regressions detected

### Defects Logged
1. **MINOR-789**: Milestone icon not centered on iPad landscape
   - Impact: Cosmetic only
   - Workaround: Rotate device
   - Fix scheduled: Next sprint
   
2. **MINOR-790**: Toast notification stays visible 5s instead of 3s
   - Impact: Minor UX inconsistency
   - Workaround: Manual dismiss
   - Fix scheduled: Next sprint

3. **MINOR-791**: Typo in milestone completion email ("sucessful")
   - Impact: Unprofessional appearance
   - Workaround: None needed
   - Fix scheduled: Before production release

### Performance Benchmarks
- Cold start: 2.1s (target: <2.5s) ✅
- Milestone creation: 287ms avg (target: <500ms) ✅
- List scroll: 60fps maintained ✅
- Memory usage: 187MB (target: <250MB) ✅

### Production Readiness
- [x] All critical paths tested
- [x] No critical or high-severity defects
- [x] Performance targets met
- [x] Security scan clean
- [x] Accessibility compliant
- [x] Rollback plan validated
- [ ] Minor defects documented for next sprint

### Recommendation
✅ **APPROVED FOR RELEASE** to production

Minor issues noted do not impact core functionality. Recommend fixing typo (MINOR-791) before production deployment.

---

**Quality Agent Sign-off**: @quality-agent
**Date**: 2025-10-05T14:00:00Z
```

---

## 11. Checkpoint-Driven Development

### 11.1 Feature Development Checkpoints

**Mandatory Checkpoints for Every Feature:**

```yaml
Checkpoint 1: Requirements Finalized
  Owner: Navigator
  Deliverables:
    - User story with acceptance criteria
    - Mockups/wireframes (if UI change)
    - Success metrics defined
  Exit Criteria:
    - All agents understand the requirements
    - No open questions about scope
    - Estimated effort documented
  Timeline: Brief cycle

Checkpoint 2: Design Approved
  Owner: Architect
  Deliverables:
    - API specification (if backend change)
    - Data model changes documented
    - Integration points identified
    - Performance impact estimated
  Exit Criteria:
    - Design reviewed by Builder, Security, Quality
    - No unresolved technical concerns
    - Implementation plan approved
  Timeline: Focused iteration

Checkpoint 3: Security Review
  Owner: Security
  Deliverables:
    - Threat model for new feature
    - Security requirements documented
    - Compliance checklist completed
  Exit Criteria:
    - No critical security risks
    - Mitigation plans for identified risks
    - Compliance requirements met
  Timeline: Brief cycle

Checkpoint 4: Implementation Complete
  Owner: Builder
  Deliverables:
    - Code implementation with tests
    - Pull request submitted
    - Documentation updated
  Exit Criteria:
    - All acceptance criteria met
    - Unit test coverage >80%
    - Code review completed
    - CI/CD pipeline passing
  Timeline: Multi-step execution (scales with complexity)

Checkpoint 5: Quality Verified
  Owner: Quality
  Deliverables:
    - Test execution report
    - Performance benchmarks
    - Defect list with severity
  Exit Criteria:
    - No critical defects
    - Performance targets met
    - Regression tests pass
  Timeline: Dedicated validation window

Checkpoint 6: Production Ready
  Owner: Navigator
  Deliverables:
    - Release notes
    - Deployment plan
    - Rollback procedure
    - Communication plan
  Exit Criteria:
    - All agents sign off
    - Feature flag configuration ready
    - Monitoring dashboards configured
  Timeline: Final coordination window
```

**Checkpoint Template:**

```markdown
# Checkpoint: [Name]
**Feature**: Campaign Milestone Tracking
**Date**: 2025-10-02
**Status**: In Progress

## Deliverables
- [x] User story documented (US-234)
- [x] Acceptance criteria defined (6 criteria)
- [x] Mockups created (Figma link)
- [ ] Success metrics finalized (pending Navigator review)

## Exit Criteria Status
- [x] All agents understand requirements (confirmed in sync)
- [ ] No open questions (2 questions pending)
- [x] Estimated effort: Multi-day (all agents agree)

## Open Questions
1. Should milestone verification require admin approval for amounts >$5k?
   - Raised by: Security
   - Priority: High
   - Needs: Navigator decision

2. Do we support milestone templates for common campaign types?
   - Raised by: Builder
   - Priority: Medium
   - Needs: Navigator + UX research

## Blockers
None

## Next Steps
- Navigator to answer open questions promptly
- Move to Checkpoint 2 (Design) once prerequisites are satisfied

## Sign-offs Required
- [ ] Navigator
- [ ] Architect (informational only at this stage)

---
**Last Updated**: 2025-10-02T16:30:00Z by @navigator-agent
```

### 11.2 Sprint Checkpoint Cadence

```yaml
Sprint Cadence:
  Iterations: Fixed-length cycles (team-aligned)
  Planning Gates:
    - Start of iteration: plan scope, review objectives, resolve blockers
    - Mid-iteration: check progress and adjust priorities if needed
    - End of iteration: reflect on outcomes, demo completed work, prep next cycle

Daily Rhythm:
  - Async updates from all agents
  - Meetings only when synchronous problem-solving is required
  - Updates shared early in each local workday

Periodic Reviews:
  - Architecture review (ADR sweep)
  - Security audit (internal or external)
  - Performance review (metrics analysis)
  - Community feedback review
```

---

## 12. Success Metrics & KPIs

### 12.1 Agent-Specific KPIs

**Navigator Agent:**

```yaml
Velocity Metrics:
  - User stories completed per sprint: Target >8
  - Time from idea to spec'd: Target <3 days
  - Backlog grooming: >90% of stories estimated

Quality Metrics:
  - Acceptance criteria clarity: >95% (measured by rework rate)
  - Requirement changes post-development: <10%
  - Stakeholder satisfaction: >4.5/5

Impact Metrics:
  - Features adopted by >70% of users within 30 days
  - Feature requests from community addressed: >80%
  - User satisfaction (NPS): >50
```

**Architect Agent:**

```yaml
Quality Metrics:
  - API breaking changes: <2 per quarter
  - Architecture decision records: 100% for major decisions
  - Design review cycle time: <2 days average

Technical Metrics:
  - System availability: >99.9%
  - API response time (p95): <300ms
  - Database query performance: >95% under 20ms
  - Successful deployments: >98%

Scalability Metrics:
  - Cost per user per month: <$0.50
  - System handles 10x current load in load tests
  - Zero downtime during deployments
```

**Builder Agent:**

```yaml
Productivity Metrics:
  - Story points completed per sprint: Target >20
  - Code review turnaround: <24 hours
  - PR size: <500 lines preferred, <1000 max

Quality Metrics:
  - Test coverage: >80% line coverage
  - First-time PR pass rate: >90%
  - Production bugs introduced: <2 per sprint
  - Code review feedback items: <5 per PR

Technical Metrics:
  - Build time: <10 minutes
  - App bundle size: <50MB APK, <15MB web
  - Accessibility compliance: >90% score
```

**Security Agent:**

```yaml
Proactive Metrics:
  - Security reviews completed: 100% of features before production
  - Threat models created: 100% for sensitive features
  - Security training materials: Updated quarterly

Reactive Metrics:
  - Security incidents: Target 0
  - Mean time to patch critical vulnerability: <24 hours
  - False positive rate in fraud detection: <5%

Compliance Metrics:
  - Compliance audits: 100% passed
  - Privacy requests fulfilled: <7 days
  - Penetration test findings: <5 medium, 0 high/critical
```

**Quality Agent:**

```yaml
Process Metrics:
  - Test automation coverage: >80% of manual tests
  - Flaky test rate: <2%
  - Test execution time: <30 minutes full suite

Quality Metrics:
  - Escaped defects to production: <3 per release
  - Production crash rate: <0.1%
  - User-reported bugs: <10 per week
  - Critical bug fix time: <4 hours

Performance Metrics:
  - Performance regression detected: 100% before production
  - Load test completion: Before every major release
  - App store ratings: >4.3 stars
```

**Documentation Agent:**

```yaml
Coverage Metrics:
  - API documentation: 100% of public endpoints
  - Code documentation: >70% of public APIs
  - User guides: 100% of major features

Quality Metrics:
  - Documentation accuracy: >95% (measured by support tickets)
  - Documentation findability: <3 clicks to any page
  - Community contribution: >5 PRs per quarter

Engagement Metrics:
  - Developer onboarding time: <2 hours to first commit
  - Documentation views: Growing >10% quarterly
  - Support ticket reduction: >20% from documentation improvements
```

### 12.2 Project-Wide Success Metrics

```yaml
User Metrics:
  Monthly Active Users: Growing >15% MoM
  User Retention (30-day): >60%
  Daily Active Users: >40% of MAU
  Average session depth: exceeds engagement benchmark
  User satisfaction (NPS): >50

Platform Metrics:
  Campaigns Created: Growing >20% MoM
  Successfully Funded Campaigns: >60%
  Jobs Posted: Growing >15% MoM
  Jobs Filled: >40%
  Transaction Volume: Growing >25% MoM

Technical Metrics:
  System Uptime: >99.9%
  API Response Time (p95): <300ms
  Error Rate: <0.5%
  Deployment Frequency: >2 per week
  Mean Time to Recovery: <1 hour

Community Metrics:
  GitHub Stars: Growing >10% monthly
  Contributors: >50 active contributors
  Code commits: >100 per month
  Community discussions: >50 threads per month
  Translation coverage: >10 languages
```

---

## 13. Emergency Response Procedures

### 13.1 Incident Response Protocol

**Severity Levels:**

```yaml
P0 - Critical (System Down):
  Examples:
    - Payment processing completely broken
    - Database unreachable
    - Authentication system down
    - Major security breach
  Response Time: Immediate (<15 minutes)
  Resolution SLA: <4 hours
  Communication: Hourly updates to all stakeholders

P1 - High (Major Functionality Impaired):
  Examples:
    - Campaign creation failing >50%
    - Search not returning results
    - Mobile app crashing on launch
    - API endpoint errors >5%
  Response Time: <1 hour
  Resolution SLA: <24 hours
  Communication: Updates every 4 hours

P2 - Medium (Minor Functionality Impaired):
  Examples:
    - UI rendering issues
    - Slow performance (but functional)
    - Non-critical feature broken
    - Email notifications delayed
  Response Time: <4 hours
  Resolution SLA: <72 hours
  Communication: Daily updates

P3 - Low (Minor Issues):
  Examples:
    - Cosmetic UI issues
    - Typos in content
    - Minor UX improvements
    - Documentation errors
  Response Time: <24 hours
  Resolution SLA: Next sprint
  Communication: Included in regular updates
```

**Incident Response Workflow:**

```markdown
## Incident Response: P0/P1 Critical Issue

### Phase 1: Detection & Triage (0-15 minutes)
1. **Alert Received**: Via monitoring system or user report
2. **Initial Assessment**:
   - Verify issue is real (not false alarm)
   - Determine severity level
   - Identify affected systems/users
3. **Activate Response Team**:
   - Page on-call engineer
   - Notify relevant agents
   - Create incident channel (e.g., Slack #incident-2025-10-02)

### Phase 2: Immediate Response (15-60 minutes)
1. **Containment**:
   - Roll back recent deployment if applicable
   - Enable maintenance mode if necessary
   - Isolate affected systems
2. **Communication**:
   - Post status page update: "Investigating payment processing issues"
   - Notify internal team
   - Prepare user communication
3. **Initial Investigation**:
   - Check logs for errors
   - Review recent changes
   - Identify root cause hypothesis

### Phase 3: Resolution (1-4 hours for P0)
1. **Implement Fix**:
   - Deploy hotfix OR
   - Roll back to last known good state OR
   - Implement workaround
2. **Verify Fix**:
   - Test in production (careful monitoring)
   - Confirm user impact resolved
   - Monitor for 30 minutes
3. **Communication**:
   - Update status page: "Issue resolved, monitoring"
   - Notify users via in-app banner/email
   - Thank users for patience

### Phase 4: Post-Incident (24-48 hours after resolution)
1. **Root Cause Analysis**:
   - Write detailed post-mortem
   - Identify contributing factors
   - Document timeline of events
2. **Action Items**:
   - Preventive measures to avoid recurrence
   - Improve monitoring/alerting
   - Update runbooks
3. **Communication**:
   - Publish post-mortem (public if appropriate)
   - Share learnings with team
   - Update documentation
```

**Incident Template:**

```markdown
# Incident Report: [Title]
**Incident ID**: INC-2025-042
**Date**: 2025-10-02
**Severity**: P0 (Critical)
**Status**: Resolved

## Summary
Brief description of what happened and impact.

## Timeline (All times UTC)
- 14:23 - First alert: Payment processing errors spiking
- 14:25 - Engineer paged, incident confirmed
- 14:30 - Identified root cause: Stripe webhook timeout
- 14:45 - Hotfix deployed: Increased timeout from 10s to 30s
- 15:00 - Issue resolved, monitoring
- 15:30 - Confirmed stable, incident closed

## Impact
- Duration: 37 minutes
- Users Affected: ~2,500 (attempting payments)
- Failed Transactions: 47 (all retried successfully)
- Revenue Impact: $0 (all transactions recovered)

## Root Cause
Stripe webhook processing was timing out due to:
1. Increased database query latency (unoptimized index)
2. Default 10s timeout too aggressive for peak traffic
3. No retry mechanism for timeouts

## Resolution
1. Immediate: Increased webhook timeout to 30s
2. Short-term: Added retry logic with exponential backoff
3. Long-term: Optimized database queries (added index)

## Lessons Learned
### What Went Well
- Monitoring detected issue within 2 minutes
- Team responded quickly and coordinated effectively
- No data loss occurred
- All failed transactions automatically recovered

### What Could Be Improved
- Should have load tested webhook handlers before peak hours
- Database index was missing (should've been caught in code review)
- Need better timeout configuration management

## Action Items
- [ ] Add load testing for webhook handlers (Builder, by 2025-10-05)
- [ ] Review all webhook timeout configurations (Security, by 2025-10-03)
- [ ] Add database query performance tests in CI (Quality, by 2025-10-10)
- [ ] Update runbook with this scenario (Documentation, by 2025-10-03)

## Prevention
This class of issue can be prevented by:
1. Load testing webhook handlers under realistic traffic
2. Setting conservative timeout defaults (30s+)
3. Always implementing retry logic for external service calls
4. Adding database query performance tests to CI

---
**Incident Commander**: @builder-agent
**Participants**: @architect-agent, @security-agent, @quality-agent
**Post-Mortem Completed**: 2025-10-03
```

### 13.2 Rollback Procedures

**Standard Rollback (Non-critical issues):**

```bash
# Standard rollback using Git tags
git checkout main
git revert HEAD~1..HEAD  # Revert last merge
git push origin main

# Trigger CI/CD to deploy previous version
# OR manually deploy previous tag:
git checkout v1.2.3
# Deploy via CI/CD or manual process
```

**Emergency Rollback (Critical production issue):**

```bash
# Emergency rollback script
# Usage: ./scripts/emergency_rollback.sh <previous_version>

#!/bin/bash
set -e

PREVIOUS_VERSION=$1

if [ -z "$PREVIOUS_VERSION" ]; then
  echo "Usage: ./scripts/emergency_rollback.sh <version>"
  echo "Example: ./scripts/emergency_rollback.sh v1.2.3"
  exit 1
fi

echo "⚠️  EMERGENCY ROLLBACK TO $PREVIOUS_VERSION"
echo "This will:"
echo "  1. Deploy previous app version"
echo "  2. Rollback database migrations (if any)"
echo "  3. Revert Cloud Functions"
echo "  4. Update feature flags"
echo ""
read -p "Are you sure? (type 'ROLLBACK' to confirm): " confirm

if [ "$confirm" != "ROLLBACK" ]; then
  echo "Rollback cancelled"
  exit 0
fi

echo "🔄 Starting rollback..."

# 1. Rollback Flutter app (via Firebase Hosting)
echo "Rolling back web app..."
firebase hosting:rollback --project $FIREBASE_PROJECT_ID

# 2. Rollback Cloud Functions
echo "Rolling back backend..."
git checkout $PREVIOUS_VERSION
cd functions
firebase deploy --only functions --project $FIREBASE_PROJECT_ID

# 3. Rollback database migrations (if applicable)
echo "Checking for database migrations..."
# Run down migrations if they exist
npm run migrate:down

# 4. Disable new feature flags
echo "Disabling feature flags for new version..."
firebase functions:config:set features.new_feature=false

# 5. Notify team
echo "Sending rollback notification..."
# Send Slack notification, email, etc.

echo "✅ Rollback complete to $PREVIOUS_VERSION"
echo "⚠️  CRITICAL: Investigate root cause before next deployment"
echo "📝 Create incident report: INC-$(date +%Y%m%d-%H%M)"
```

**Database Migration Rollback:**

```sql
-- migrations/042_add_milestone_table_down.sql
-- Rollback script for milestone feature

BEGIN;

-- Remove triggers
DROP TRIGGER IF EXISTS update_milestone_timestamp ON milestones;

-- Remove indexes
DROP INDEX IF EXISTS idx_milestones_campaign_id;
DROP INDEX IF EXISTS idx_milestones_status;

-- Remove table
DROP TABLE IF EXISTS milestones;

-- Remove enum type
DROP TYPE IF EXISTS milestone_status;

COMMIT;

-- Verify rollback
SELECT table_name FROM information_schema.tables 
WHERE table_name = 'milestones';
-- Should return 0 rows
```

### 13.3 Communication Templates

**Status Page Update (During Incident):**

```markdown
🔴 **Investigating Payment Processing Issues**

**Posted**: 2025-10-02 14:30 UTC
**Status**: Investigating

We're aware that some users are experiencing issues completing payments. Our team is actively investigating and working on a resolution. We'll provide updates every 30 minutes.

**Impact**: Payment processing may fail or be delayed.
**Affected Services**: Campaign contributions, job payments

**Next Update**: 2025-10-02 15:00 UTC

---

⚠️ **Update - Fixing Issue**

**Posted**: 2025-10-02 14:45 UTC
**Status**: Identified and Fixing

We've identified the root cause (webhook timeout) and are deploying a fix. Expected resolution in 15 minutes.

**Next Update**: 2025-10-02 15:00 UTC

---

✅ **Issue Resolved - Monitoring**

**Posted**: 2025-10-02 15:00 UTC
**Status**: Resolved

The payment processing issue has been resolved. All systems are operating normally. We're continuing to monitor closely.

**Duration**: 37 minutes
**Impact**: 47 transactions were delayed but have been successfully processed.

We apologize for any inconvenience. A detailed post-mortem will be published within 48 hours.
```

**User Communication (Email):**

```markdown
Subject: Service Update - Payment Processing Restored

Dear Local Community App User,

We wanted to inform you about a brief service disruption that occurred today (October 2, 2025) affecting payment processing.

**What Happened**: Between 14:23 and 15:00 UTC, some users experienced failures when attempting to make campaign contributions or job payments.

**Resolution**: Our team identified and resolved the issue within 37 minutes. All delayed transactions have been successfully processed.

**Your Action Required**: None. If you attempted a payment during this time, please check your account to confirm it was processed. If you have any concerns, please contact support@localcommunityapp.org.

**What We're Doing**: We're implementing additional safeguards to prevent similar issues in the future, including improved monitoring and automated scaling.

We sincerely apologize for any inconvenience this may have caused. Our commitment is to provide you with reliable, secure service 99.9% of the time.

Thank you for your patience and continued support of local communities worldwide.

Best regards,
The Local Community App Team

---
Questions? Contact us at support@localcommunityapp.org
```

---

## 14. Practical Implementation Examples

### 14.1 Example: Complete Feature Implementation

**Feature: Campaign Milestone Tracking** (End-to-End)

**Phase 1: Navigator - Requirements (Stage 1)**

```markdown
## User Story: Campaign Milestones
**ID**: US-234
**Epic**: Campaign Management
**Priority**: High
**Sprint**: 42

### Story
As a campaign creator,
I want to set milestones with funding goals,
So that contributors can see progress and I can release funds incrementally.

### Acceptance Criteria
1. Creator can add 1-5 milestones per campaign
2. Each milestone has: title, description, target amount, target date
3. Milestone progress updates automatically as funds received
4. Contributors see milestone progress on campaign page
5. Creator gets notification when milestone reached
6. Funds for completed milestone can be withdrawn

### User Journey
1. Creator creates campaign
2. Creator adds milestone: "Purchase equipment - $5,000 by Nov 1"
3. Contributors fund campaign
4. When $5,000 reached, milestone marked complete
5. Creator notified, can withdraw $5,000
6. Process repeats for next milestone

### Success Metrics
- 60% of campaigns use milestones
- Campaigns with milestones have 25% higher completion rate
- 80% of users understand milestone feature (measured by support tickets)

### Out of Scope (for this sprint)
- Milestone templates
- Milestone editing after creation
- Admin approval for milestone completion

### Dependencies
- Payment system (existing)
- Notification system (existing)

### Questions for Team
1. Should milestone verification require admin review for amounts >$5k?
2. Can milestones overlap or must they be sequential?
```

**Phase 2: Architect - Design (Stage 2)**

```yaml
# Architecture Decision Record: Milestone Data Model
# ADR-042-milestone-data-storage

## Context
Campaign milestones need to track funding progress, be updated in real-time, and support complex queries for analytics.

## Decision
Use Firestore subcollection under campaigns with the following structure:

campaigns/{campaignId}/milestones/{milestoneId}
  - id: string (auto-generated)
  - title: string (1-100 chars)
  - description: string (max 500 chars)
  - target_amount: number
  - target_date: timestamp
  - current_amount: number (updated via transaction)
  - status: enum (ACTIVE, COMPLETED, MISSED)
  - order: number (1-5, for display order)
  - created_at: timestamp
  - completed_at: timestamp (nullable)

## Rationale
- Firestore: Real-time updates, easy querying, scales well
- Subcollection: Logical grouping, automatic cleanup when campaign deleted
- current_amount: Denormalized for performance (updated atomically)

## Alternatives Considered
1. PostgreSQL: Better for complex queries, but adds operational complexity
2. Flat collection: Harder to maintain referential integrity
3. Embedded array: Limited query capabilities, 1MB document size limit risk

## Consequences
- Positive: Real-time milestone updates, simple querying, automatic scaling
- Negative: Need to ensure current_amount stays in sync with transactions
- Mitigation: Use Cloud Functions with transactions for atomic updates
```

```typescript
// API Specification: Milestone Endpoints
// api/v1/milestones.yaml

/**
 * Create a milestone for a campaign
 * POST /v1/campaigns/{campaignId}/milestones
 */
interface CreateMilestoneRequest {
  title: string;              // 1-100 chars
  description: string;        // max 500 chars
  target_amount: number;      // min 100, max campaign.goal_amount
  target_date: string;        // ISO8601, must align with configured scheduling window
  order: number;              // 1-5, must be unique per campaign
}

interface CreateMilestoneResponse {
  milestone_id: string;
  status: 'ACTIVE';
  created_at: string;
}

/**
 * Get milestones for a campaign
 * GET /v1/campaigns/{campaignId}/milestones
 */
interface GetMilestonesResponse {
  milestones: Milestone[];
  total_count: number;
}

interface Milestone {
  id: string;
  title: string;
  description: string;
  target_amount: number;
  current_amount: number;
  percentage_complete: number;  // computed: (current/target) * 100
  target_date: string;
  status: 'ACTIVE' | 'COMPLETED' | 'MISSED';
  order: number;
  created_at: string;
  completed_at: string | null;
}

/**
 * Update milestone (admin only, for completion verification)
 * PATCH /v1/milestones/{milestoneId}
 */
interface UpdateMilestoneRequest {
  status?: 'ACTIVE' | 'COMPLETED' | 'MISSED';
  admin_notes?: string;
}

// Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /campaigns/{campaignId}/milestones/{milestoneId} {
      // Anyone can read
      allow read: if true;
      
      // Only campaign creator can create
      allow create: if request.auth != null &&
                       get(/databases/$(database)/documents/campaigns/$(campaignId))
                         .data.creator_user_id == request.auth.uid &&
                       request.resource.data.target_amount >= 100 &&
                       request.resource.data.target_amount <= 
                         get(/databases/$(database)/documents/campaigns/$(campaignId))
                           .data.goal_amount;
      
      // Only admins can update status
      allow update: if request.auth != null &&
                       get(/databases/$(database)/documents/users/$(request.auth.uid))
                         .data.role == 'admin';
      
      // Only campaign creator can delete (and only if ACTIVE)
      allow delete: if request.auth != null &&
                       get(/databases/$(database)/documents/campaigns/$(campaignId))
                         .data.creator_user_id == request.auth.uid &&
                       resource.data.status == 'ACTIVE';
    }
  }
}
```

**Phase 3: Security - Threat Model (Stage 3)**

```markdown
## Threat Model: Campaign Milestone Feature

### Assets
- Milestone data (titles, descriptions, amounts)
- Campaign funds (potential for fraud)
- User trust (fake milestones damage reputation)

### Threat Actors
- Malicious campaign creator (fake milestones)
- Attacker (manipulate milestone data)
- Insider threat (unauthorized fund release)

### Threats & Mitigations

#### T1: Fake Milestone Fraud
**Threat**: Creator sets fake milestones to withdraw funds without delivering value
**Likelihood**: Medium
**Impact**: High (user trust, financial loss)
**Mitigation**:
- Require detailed milestone descriptions (min 50 chars)
- Admin review for milestones >$5,000
- Community reporting mechanism
- Require proof of milestone completion (photos, receipts)
**Residual Risk**: Low

#### T2: Milestone Data Manipulation
**Threat**: Attacker modifies milestone status to trigger unauthorized withdrawal
**Likelihood**: Low
**Impact**: Critical (financial loss)
**Mitigation**:
- Firestore security rules enforce creator-only creation
- Status updates admin-only via Cloud Functions
- All changes logged for audit trail
- Atomic transactions for amount updates
**Residual Risk**: Very Low

#### T3: Milestone Amount Inflation
**Threat**: Creator increases milestone target after contributors funded it
**Likelihood**: Medium
**Impact**: Medium (user trust)
**Mitigation**:
- Milestone amounts immutable after creation
- UI clearly shows "locked" milestones
- Edit only allowed before any contributions
**Residual Risk**: Very Low

#### T4: Race Condition in Amount Updates
**Threat**: Concurrent contributions cause incorrect current_amount
**Likelihood**: High
**Impact**: Medium (data inconsistency)
**Mitigation**:
- Use Firestore transactions for all amount updates
- Periodic reconciliation job compares milestone amounts vs transactions
- Automated alerts if discrepancy >1%
**Residual Risk**: Low

### Security Requirements
1. All milestone operations require authentication
2. Milestone creation/deletion restricted to campaign creator
3. Status updates restricted to admins
4. All amount updates must use atomic transactions
5. Audit log all milestone status changes
6. Implement rate limiting: 10 milestone operations per minute per user

### Compliance Notes
- GDPR: Milestone descriptions may contain PII, must be deletable
- AML: Large milestones (>$10k) should trigger enhanced verification
- Fraud Prevention: Implement ML-based anomaly detection for milestone patterns
```

**Phase 4: Builder - Implementation (Stage 4)**

```dart
// lib/features/milestones/data/models/milestone_model.dart
class MilestoneModel {
  final String id;
  final String title;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final MilestoneStatus status;
  final int order;
  final DateTime createdAt;
  final DateTime? completedAt;

  MilestoneModel({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.status,
    required this.order,
    required this.createdAt,
    this.completedAt,
  });

  double get percentageComplete =>
      currentAmount >= targetAmount ? 100.0 : (currentAmount / targetAmount) * 100;

  bool get isCompleted => status == MilestoneStatus.completed;
  bool get isMissed => status == MilestoneStatus.missed && DateTime.now().isAfter(targetDate);

  factory MilestoneModel.fromJson(Map<String, dynamic> json) {
    return MilestoneModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentAmount: (json['current_amount'] as num).toDouble(),
      targetDate: DateTime.parse(json['target_date'] as String),
      status: MilestoneStatus.values.byName(json['status'] as String),
      order: json['order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'target_date': targetDate.toIso8601String(),
      'status': status.name,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
    };
  }
}

enum MilestoneStatus {
  active,
  completed,
  missed,
}

// lib/features/milestones/presentation/widgets/milestone_card.dart
class MilestoneCard extends StatelessWidget {
  final MilestoneModel milestone;
  final VoidCallback? onTap;

  const MilestoneCard({
    super.key,
    required this.milestone,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: FibonacciSpacing.m,
        vertical: FibonacciSpacing.s,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(FibonacciSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      milestone.title,
                      style: AppTextStyles.h2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusBadge(status: milestone.status),
                ],
              ),
              
              SizedBox(height: FibonacciSpacing.s),
              
              // Description
              Text(
                milestone.description,
                style: AppTextStyles.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: FibonacciSpacing.m),
              
              // Progress bar
              _ProgressBar(
                percentage: milestone.percentageComplete,
                current: milestone.currentAmount,
                target: milestone.targetAmount,
              ),
              
              SizedBox(height: FibonacciSpacing.s),
              
              // Target date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: FibonacciSpacing.m,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: FibonacciSpacing.xs),
                  Text(
                    'Target: ${_formatDate(milestone.targetDate)}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

class _StatusBadge extends StatelessWidget {
  final MilestoneStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: FibonacciSpacing.s,
        vertical: FibonacciSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(FibonacciSpacing.s),
        border: Border.all(color: config.color),
      ),
      child: Text(
        config.label,
        style: AppTextStyles.caption.copyWith(
          color: config.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  ({Color color, String label}) _getStatusConfig() {
    return switch (status) {
      MilestoneStatus.active => (
        color: AppColors.primary,
        label: 'In Progress',
      ),
      MilestoneStatus.completed => (
        color: AppColors.secondary,
        label: 'Completed',
      ),
      MilestoneStatus.missed => (
        color: AppColors.error,
        label: 'Missed',
      ),
    };
  }
}

class _ProgressBar extends StatelessWidget {
  final double percentage;
  final double current;
  final double target;

  const _ProgressBar({
    required this.percentage,
    required this.current,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${_formatAmount(current)} raised',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: FibonacciSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(FibonacciSpacing.xs),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: FibonacciSpacing.s,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
          ),
        ),
        SizedBox(height: FibonacciSpacing.xs),
        Text(
          'Target: \$${_formatAmount(target)}',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

// Test file: test/features/milestones/presentation/widgets/milestone_card_test.dart
void main() {
  testWidgets('MilestoneCard displays all information correctly', (tester) async {
    final milestone = MilestoneModel(
      id: 'mil_123',
      title: 'Purchase Equipment',
      description: 'Buy solar panels and inverters for the community center',
      targetAmount: 5000,
      currentAmount: 3750,
      targetDate: DateTime(2025, 11, 1),
      status: MilestoneStatus.active,
      order: 1,
      createdAt: DateTime(2025, 10, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MilestoneCard(milestone: milestone),
        ),
      ),
    );

    // Verify title
    expect(find.text('Purchase Equipment'), findsOneWidget);
    
    // Verify description
    expect(
      find.text('Buy solar panels and inverters for the community center'),
      findsOneWidget,
    );
    
    // Verify progress percentage
    expect(find.text('75%'), findsOneWidget);
    
    // Verify amounts
    expect(find.text('\$3.8K raised'), findsOneWidget);
    expect(find.text('Target: \$5.0K'), findsOneWidget);
    
    // Verify status badge
    expect(find.text('In Progress'), findsOneWidget);
    
    // Verify target date
    expect(find.text('Target: 1 Nov 2025'), findsOneWidget);
    
    // Verify progress bar exists
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('MilestoneCard shows completed status correctly', (tester) async {
    final milestone = MilestoneModel(
      id: 'mil_124',
      title: 'Install Equipment',
      description: 'Complete installation',
      targetAmount: 5000,
      currentAmount: 5000,
      targetDate: DateTime(2025, 11, 1),
      status: MilestoneStatus.completed,
      order: 2,
      createdAt: DateTime(2025, 10, 1),
      completedAt: DateTime(2025, 10, 15),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MilestoneCard(milestone: milestone),
        ),
      ),
    );

    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });
}
```

**Backend Implementation:**

```typescript
// functions/src/milestones/createMilestone.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { z } from 'zod';

const CreateMilestoneSchema = z.object({
  campaign_id: z.string().uuid(),
  title: z.string().min(10).max(100),
  description: z.string().min(50).max(500),
  target_amount: z.number().min(100),
  target_date: z.string().datetime(),
  order: z.number().int().min(1).max(5),
});

export const createMilestone = functions.https.onCall(async (data, context) => {
  // Authentication check
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be logged in');
  }

  const userId = context.auth.uid;
  const validated = CreateMilestoneSchema.parse(data);

  // Verify campaign exists and user is creator
  const campaignRef = admin.firestore().collection('campaigns').doc(validated.campaign_id);
  const campaignDoc = await campaignRef.get();

  if (!campaignDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Campaign not found');
  }

  const campaign = campaignDoc.data()!;
  if (campaign.creator_user_id !== userId) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only campaign creator can add milestones'
    );
  }

  // Validate target amount doesn't exceed campaign goal
  if (validated.target_amount > campaign.goal_amount) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Milestone target cannot exceed campaign goal'
    );
  }

  // Validate target date is within campaign timeline
  const targetDate = new Date(validated.target_date);
  const campaignEnd = campaign.target_end_date.toDate();
  
  if (targetDate > campaignEnd) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Milestone date cannot be after campaign end date'
    );
  }

  // Check milestone count (max 5 per campaign)
  const existingMilestones = await campaignRef
    .collection('milestones')
    .get();

  if (existingMilestones.size >= 5) {
    throw new functions.https.HttpsError(
      'resource-exhausted',
      'Maximum 5 milestones per campaign'
    );
  }

  // Check order is unique
  const orderExists = existingMilestones.docs.some(
    doc => doc.data().order === validated.order
  );

  if (orderExists) {
    throw new functions.https.HttpsError(
      'already-exists',
      `Milestone with order ${validated.order} already exists`
    );
  }

  // Create milestone
  const milestoneRef = campaignRef.collection('milestones').doc();
  const milestone = {
    id: milestoneRef.id,
    campaign_id: validated.campaign_id,
    title: validated.title,
    description: validated.description,
    target_amount: validated.target_amount,
    current_amount: 0,
    target_date: admin.firestore.Timestamp.fromDate(targetDate),
    status: 'ACTIVE',
    order: validated.order,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
    completed_at: null,
  };

  await milestoneRef.set(milestone);

  // Log event
  await admin.firestore().collection('audit_logs').add({
    event_type: 'milestone_created',
    user_id: userId,
    campaign_id: validated.campaign_id,
    milestone_id: milestoneRef.id,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {
    milestone_id: milestoneRef.id,
    status: 'ACTIVE',
    created_at: new Date().toISOString(),
  };
});

// Cloud Function triggered on contribution to update milestone amounts
export const updateMilestoneProgress = functions.firestore
  .document('contributions/{contributionId}')
  .onCreate(async (snap, context) => {
    const contribution = snap.data();
    const campaignId = contribution.campaign_id;
    const amount = contribution.amount;

    // Get all active milestones for this campaign
    const milestonesSnapshot = await admin
      .firestore()
      .collection('campaigns')
      .doc(campaignId)
      .collection('milestones')
      .where('status', '==', 'ACTIVE')
      .orderBy('order')
      .get();

    // Update milestone amounts in order
    for (const milestoneDoc of milestonesSnapshot.docs) {
      const milestone = milestoneDoc.data();
      const remaining = milestone.target_amount - milestone.current_amount;

      if (remaining > 0) {
        const amountToApply = Math.min(amount, remaining);
        const newAmount = milestone.current_amount + amountToApply;

        // Use transaction to update atomically
        await admin.firestore().runTransaction(async (transaction) => {
          transaction.update(milestoneDoc.ref, {
            current_amount: newAmount,
            status: newAmount >= milestone.target_amount ? 'COMPLETED' : 'ACTIVE',
            completed_at: newAmount >= milestone.target_amount 
              ? admin.firestore.FieldValue.serverTimestamp() 
              : null,
          });

          // If milestone completed, send notification
          if (newAmount >= milestone.target_amount) {
            const notificationRef = admin.firestore().collection('notifications').doc();
            transaction.set(notificationRef, {
              user_id: contribution.campaign_creator_id,
              type: 'MILESTONE_COMPLETED',
              title: 'Milestone Reached!',
              message: `Your milestone "${milestone.title}" has been fully funded!`,
              data: {
                campaign_id: campaignId,
                milestone_id: milestoneDoc.id,
              },
              created_at: admin.firestore.FieldValue.serverTimestamp(),
              read: false,
            });
          }
        });

        break; // Only apply to first unfunded milestone
      }
    }
  });
```

**Phase 5: Quality - Testing (Stage 5)**

```markdown
## Test Plan: Campaign Milestone Feature

### Test Summary
- **Feature**: Campaign Milestone Tracking
- **Test Timeline**: Extended validation window
- **Test Environment**: Staging
- **Test Data**: 50 test campaigns with various milestone configurations

### Test Execution Results

#### Unit Tests (Completed: 2025-10-09)
- **Total Tests**: 47
- **Passed**: 47
- **Failed**: 0
- **Coverage**: 89% (exceeds 80% threshold)

Key test cases:
- ✅ Milestone creation validation
- ✅ Progress calculation accuracy
- ✅ Status transitions (ACTIVE → COMPLETED)
- ✅ Amount overflow handling
- ✅ Date validation
- ✅ Order uniqueness enforcement

#### Widget Tests (Completed: 2025-10-09)
- **Total Tests**: 12
- **Passed**: 12
- **Failed**: 0
- **Coverage**: 85%

Key test cases:
- ✅ MilestoneCard renders all fields correctly
- ✅ Progress bar updates dynamically
- ✅ Status badges show correct colors
- ✅ Tap handler triggers navigation
- ✅ Accessibility labels present
- ✅ Responsive layout on different screen sizes

#### Integration Tests (Completed: 2025-10-10)
- **Total Tests**: 8
- **Passed**: 8
- **Failed**: 0

Key flows tested:
- ✅ End-to-end milestone creation flow
- ✅ Contribution updates milestone progress
- ✅ Multiple milestones funded in sequence
- ✅ Milestone completion triggers notification
- ✅ Creator can view milestone history
- ✅ Offline milestone creation syncs correctly

#### Performance Tests (Completed: 2025-10-10)

**Benchmark Results:**
| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Milestone creation API | <500ms | 287ms | ✅ |
| Milestone list rendering | <300ms | 189ms | ✅ |
| Progress update latency | <200ms | 143ms | ✅ |
| Memory usage | <250MB | 198MB | ✅ |

**Load Test Results:**
- Concurrent milestone creations: 100/sec sustained
- Progress updates: 500/sec sustained
- Database query performance: p95 <20ms
- Zero errors during 10-minute load test

#### Security Tests (Completed: 2025-10-10)
- ✅ Non-creator cannot create milestones
- ✅ Cannot exceed campaign goal amount
- ✅ Cannot set date beyond campaign end
- ✅ Order uniqueness enforced
- ✅ SQL injection attempts blocked
- ✅ XSS in milestone descriptions sanitized

#### Accessibility Tests (Completed: 2025-10-10)
- **axe-flutter score**: 94/100
- ✅ Screen reader announces milestone titles
- ✅ Progress bar has semantic label
- ✅ Tap targets >44x44dp
- ✅ Color contrast ratios >4.5:1
- ⚠️ Minor: Focus order could be improved (non-blocking)

### Defects Found

#### MINOR-789: Milestone icon not centered on iPad landscape
- **Severity**: Minor
- **Impact**: Cosmetic only
- **Reproduction**: iPad Pro 12.9" in landscape, milestone card icon shifts 2px left
- **Workaround**: Rotate device or use portrait mode
- **Fix**: Adjust padding calculation for landscape orientation
- **Status**: Logged for next sprint

#### MINOR-790: Toast notification displays 5s instead of 3s
- **Severity**: Minor
- **Impact**: Minor UX inconsistency
- **Reproduction**: Create milestone, success toast stays visible 5 seconds
- **Workaround**: Manual dismiss by tapping
- **Fix**: Update toast duration constant
- **Status**: Scheduled for next sprint

#### MINOR-791: Typo in milestone completion email
- **Severity**: Minor
- **Impact**: Unprofessional appearance
- **Reproduction**: Complete milestone, email says "sucessful" not "successful"
- **Workaround**: N/A
- **Fix**: Correct email template typo
- **Status**: MUST FIX before production release

### Regression Testing
- ✅ Existing campaign flows unaffected
- ✅ Payment processing still functional
- ✅ No performance degradation in other features
- ✅ Database migrations reversible

### Production Readiness Assessment

**GO Criteria:**
- [x] All critical paths tested
- [x] No critical or high-severity defects
- [x] Performance targets met
- [x] Security scan clean
- [x] Accessibility score >90
- [x] Rollback plan validated
- [ ] Typo fixed (MINOR-791)

**NO-GO Criteria:**
- [ ] Critical defects present
- [ ] Performance targets missed
- [ ] Security vulnerabilities
- [ ] Accessibility compliance failed

### Recommendation
✅ **APPROVED FOR RELEASE** after fixing typo (MINOR-791)

All other issues are cosmetic and do not impact functionality. Estimated 10-minute fix for typo.

---

**Quality Agent Sign-off**: @quality-agent
**Date**: 2025-10-10T16:00:00Z
**Next Steps**: Builder to fix typo, re-test, deploy to production
```

**Phase 6: Release (Stage 6)**

```markdown
## Release Notes: Version 1.3.0 - Milestone Tracking

**Release Date**: 2025-10-11
**Release Type**: Minor (New Feature)
**Deployment**: Phased rollout (5% → 25% → 50% → 100% over 48 hours)

### What's New

#### 🎯 Campaign Milestones
Campaign creators can now break down their funding goals into achievable milestones!

**Key Features:**
- Add up to 5 milestones per campaign with specific targets and dates
- Real-time progress tracking as contributions come in
- Automatic notifications when milestones are reached
- Visual timeline showing completed, active, and upcoming milestones
- Contributors can see exactly how their funding helps reach each goal

**Why this matters:**
Campaigns with clear milestones are 25% more likely to reach their funding goals. This feature builds trust by showing tangible progress and specific deliverables.

### How to Use
1. Create or edit your campaign
2. Tap "Add Milestone" in the campaign editor
3. Enter milestone details (title, description, target amount, date)
4. Repeat for additional milestones (up to 5)
5. Save and publish your campaign

### Technical Details
- **API Version**: v1.3.0
- **Database Changes**: New `milestones` subcollection under campaigns
- **Feature Flag**: `enable_campaign_milestones` (true by default)
- **Breaking Changes**: None

### Performance Improvements
- Milestone creation: <300ms average
- Real-time progress updates via Firestore listeners
- Optimized queries for campaign list rendering

### Bug Fixes
- Fixed typo in milestone completion email notification
- Improved spacing on milestone cards for tablet devices

### Known Issues
- Minor: Milestone icon slightly misaligned on iPad landscape mode (fix scheduled for v1.3.1)
- Minor: Success toast notification displays for 5 seconds instead of 3 (non-blocking)

### Rollback Plan
If critical issues arise:
1. Set feature flag `enable_campaign_milestones` to `false`
2. No data loss - all milestones remain in database
3. Users will see campaigns without milestone UI
4. Can be re-enabled once issue resolved

### Monitoring
Dashboard: https://console.firebase.google.com/project/local-community-app/analytics

**Key Metrics to Watch:**
- Milestone creation rate (target: >40% of new campaigns)
- Milestone completion rate (target: >60%)
- User satisfaction with feature (target: >4.0/5)
- Campaign funding success rate with milestones (target: +25% vs non-milestone)

### Support Resources
- User Guide: https://docs.localcommunityapp.org/milestones
- API Documentation: https://docs.localcommunityapp.org/api/milestones
- Video Tutorial: https://youtube.com/localcommunityapp/milestone-tutorial

### Credits
This feature was built with contributions from:
- @navigator-agent (Product requirements)
- @architect-agent (API design & data modeling)
- @builder-agent (Implementation)
- @security-agent (Threat modeling)
- @quality-agent (Testing & validation)
- Community feedback from 150+ users

### What's Next
Coming in v1.4.0 (Nov 2025):
- Milestone templates for common campaign types
- Milestone editing after creation (within constraints)
- Enhanced analytics for milestone performance
- Milestone sharing on social media

---

**Release Manager**: @navigator-agent
**Deploy Start**: 2025-10-11T00:00:00Z
**Full Rollout**: 2025-10-13T00:00:00Z
```

---

## 15. Onboarding Guide for New Agents

### 15.1 Quick Start Checklist

```markdown
# Welcome to the Local Community App Engineering Collective!

## Your First Day

### Prerequisites
- [ ] Read the AGENTS.md document thoroughly (this document)
- [ ] Understand the mission and scale of this project
- [ ] Review the existing codebase structure
- [ ] Set up development environment

### Environment Setup
```bash
# 1. Clone repository
git clone https://github.com/local-community-app/platform.git
cd platform

# 2. Install Flutter
flutter --version  # Should be 3.24.0+
flutter doctor  # Verify installation

# 3. Install dependencies
flutter pub get
cd functions && npm install && cd ..

# 4. Set up Firebase
firebase login
firebase use --add  # Select staging project first

# 5. Run tests
flutter test
cd functions && npm test && cd ..

# 6. Run app locally
flutter run -d chrome  # Web
# OR
flutter run  # Mobile (requires emulator/device)
```

### First Tasks (Choose Your Role)

**If you're a Navigator Agent:**
- [ ] Review open user stories in backlog
- [ ] Join next sprint planning session
- [ ] Read last 3 sprint retrospectives
- [ ] Review community feedback channels

**If you're an Architect Agent:**
- [ ] Review architecture decision records (ADRs)
- [ ] Study current system diagrams
- [ ] Review API documentation
- [ ] Understand data models

**If you're a Builder Agent:**
- [ ] Pick a "good first issue" from GitHub
- [ ] Set up code editor with linters
- [ ] Review code style guide
- [ ] Submit a small documentation PR to practice workflow

**If you're a Security Agent:**
- [ ] Review threat models for existing features
- [ ] Study security testing procedures
- [ ] Review compliance documentation
- [ ] Run security scan on codebase

**If you're a Quality Agent:**
- [ ] Review test coverage reports
- [ ] Study test automation framework
- [ ] Run full test suite locally
- [ ] Review performance benchmarks

**If you're a Documentation Agent:**
- [ ] Review existing documentation
- [ ] Identify gaps or outdated sections
- [ ] Read through user support tickets
- [ ] Update onboarding guide (this document)

### Your First Week

**Early Stage: Learning**
- Shadow existing agents in your role
- Review past decisions and their rationale
- Understand current priorities
- Ask questions liberally

**Mid Stage: Contributing**
- Pair with another agent on a small task
- Submit your first contribution
- Participate in daily syncs
- Give feedback on others' work

**Later Stage: Independence**
- Take ownership of a feature component
- Lead a small design discussion
- Help onboard the next new agent
- Reflect on your first week

### Resources

**Documentation:**
- Technical Docs: /docs folder in repository
- API Reference: https://docs.localcommunityapp.org/api
- User Guides: https://docs.localcommunityapp.org/guides

**Communication:**
- Daily Sync: Posted by 10:00 AM in #daily-updates
- Sprint Planning: Bi-weekly, Mondays 9:00 AM
- Architecture Reviews: Monthly, first Friday
- Questions: #help channel (response within 2 hours)

**Tools:**
- Code: GitHub (https://github.com/local-community-app/platform)
- Project Management: GitHub Projects
- Design: Figma (https://figma.com/localcommunityapp)
- Monitoring: Firebase Console

### Cultural Norms

**Decision Making:**
- Use the decision framework (see Section 10.2)
- Document all major decisions in ADRs
- Seek input early and often
- Escalate when uncertain

**Communication:**
- Be explicit and clear (no assumptions)
- Use async communication by default
- Respond within 24 hours
- Over-communicate context

**Code Quality:**
- All code reviewed by at least 2 agents
- Tests are non-negotiable
- Security is everyone's responsibility
- Accessibility from day one

**Work-Life Balance:**
- This is a marathon, not a sprint
- Take breaks, avoid burnout
- No expectation of 24/7 availability
- Quality over quantity

### Getting Help

**Stuck on something?**
1. Check documentation first
2. Search past discussions/issues
3. Ask in #help channel
4. Tag relevant agent for expertise
5. Escalate to human oversight if needed

**Common Questions:**

Q: How do I decide what to work on?
A: Check the current sprint board, look for tasks assigned to your role, prioritize by RICE score.

Q: What if I disagree with a design decision?
A: Follow the conflict resolution protocol (Section 10.3). Voice your concerns with technical reasoning.

Q: How much testing is enough?
A: Minimum 80% coverage, but focus on critical paths. Quality over arbitrary metrics.

Q: When should I create an ADR?
A: For any decision that affects multiple components, has long-term implications, or future devs will wonder "why did they do it this way?"

### Your Mentor

You've been assigned a mentor agent in your role domain:
- **Your Mentor**: [Will be assigned]
- **Their Expertise**: [Domain-specific]
- **Meeting Cadence**: Weekly 1:1 for first month
- **Communication**: Ping anytime with questions

### Success Metrics (Initial Launch Window)

- [ ] Complete 5+ contributions (code, docs, reviews)
- [ ] Participate in 2+ design discussions
- [ ] Review 10+ PRs from other agents
- [ ] Identify 1+ improvement opportunity
- [ ] Help onboard 1+ new agent

### Welcome Message from the Team

"We're thrilled to have you join us in building technology that can transform economic opportunity for billions of people worldwide. Your contribution—no matter how small it may seem—is part of a much larger mission to democratize access to funding, employment, and community support.

This is hard work. You'll face technical challenges, ambiguous requirements, and the weight of building something at global scale. But you're not alone. We're a collective, and we succeed together.

Remember: every line of code you write, every bug you fix, every user you help—it could be the difference between someone realizing their dream or giving up. That's the privilege and responsibility we carry.

Welcome to the team. Let's build something extraordinary."

— The Local Community App Engineering Collective

---

**Onboarding Coordinator**: @documentation-agent
**Questions**: Post in #onboarding channel or email onboarding@localcommunityapp.org
**Feedback**: Help us improve this guide by submitting PRs!
```

### 15.2 Role-Specific Deep Dives

**Navigator Agent Deep Dive:**

```markdown
# Navigator Agent: Advanced Guide

## Your Mission
Translate community needs into executable features that deliver measurable impact.

## Core Competencies

### 1. User Story Crafting
**Template:**
```
As a [persona],
I want [goal],
So that [benefit].

Acceptance Criteria:
1. Given [context], When [action], Then [outcome]
2. ...

Success Metrics:
- [Quantifiable metric] increases by [target]%
- [User behavior] shows [desired pattern]

Out of Scope:
- [What we're explicitly NOT doing]
```

**Example - Excellent User Story:**
```
As a first-time campaign creator in a rural area,
I want step-by-step guidance on creating my first campaign,
So that I can confidently launch without fear of making mistakes.

Acceptance Criteria:
1. Given I'm on the campaign creation page, When I start, Then I see a progress indicator showing 5 steps
2. Given I'm on step 1 (Basic Info), When I hover over "Campaign Type", Then I see examples and recommendations
3. Given I complete a step, When I click "Next", Then the step is marked complete and I advance
4. Given I miss required fields, When I try to proceed, Then I see clear error messages with examples
5. Given I complete all steps, When I click "Preview", Then I see exactly what contributors will see

Success Metrics:
- 80% of first-time creators complete campaign without abandoning
- Support tickets about "how to create campaign" decrease by 50%
- Campaign approval rate increases by 20%

Out of Scope:
- Saved drafts (next sprint)
- Campaign templates (Phase 2)
- Video upload in wizard (too complex for MVP)
```

### 2. Prioritization Framework (RICE)

**Reach**: How many users affected? (per quarter)
- Massive: 10,000+ users (Score: 10)
- Large: 1,000-10,000 (Score: 5)
- Medium: 100-1,000 (Score: 3)
- Small: <100 (Score: 1)

**Impact**: How much does it improve their experience?
- Massive: Transforms core workflow (Score: 3)
- High: Significant improvement (Score: 2)
- Medium: Notable improvement (Score: 1)
- Low: Minor improvement (Score: 0.5)

**Confidence**: How certain are we?
- High: Strong data/research (Score: 100%)
- Medium: Some data/assumption (Score: 80%)
- Low: Mostly assumption (Score: 50%)

**Effort**: How much work? (person-weeks)
- Tiny: <1 week (Score: 1)
- Small: 1-2 weeks (Score: 2)
- Medium: 3-4 weeks (Score: 4)
- Large: 5-8 weeks (Score: 8)
- Huge: >8 weeks (Score: 16)

**RICE Score = (Reach × Impact × Confidence) / Effort**

**Example Calculation:**
Feature: Campaign milestone tracking
- Reach: 5,000 campaign creators per quarter (Score: 5)
- Impact: Significant improvement in funding success (Score: 2)
- Confidence: Based on competitor analysis and surveys (Score: 80%)
- Effort: 2 weeks for 2 agents (Score: 4)
- **RICE Score = (5 × 2 × 0.8) / 4 = 2.0**

**Priority Thresholds:**
- RICE > 3.0: High priority (current sprint)
- RICE 1.5-3.0: Medium priority (next sprint)
- RICE 0.5-1.5: Low priority (backlog)
- RICE < 0.5: Reject or defer

### 3. Stakeholder Management

**Internal Stakeholders:**
- Other agents (daily collaboration)
- Human oversight (weekly check-ins)
- Community moderators (bi-weekly feedback)

**External Stakeholders:**
- Users (via surveys, support tickets, community forums)
- Regulators (GDPR, financial compliance)
- Partners (payment processors, infrastructure providers)

**Communication Matrix:**
| Stakeholder | Frequency | Method | Content |
|-------------|-----------|--------|---------|
| Other Agents | Daily | Async update | Progress, blockers, questions |
| Human Oversight | Weekly | Sync meeting | Strategic decisions, major issues |
| Community | Monthly | Blog post | Feature updates, roadmap preview |
| Users | As needed | In-app, email | New features, changes, incidents |

### 4. Metrics That Matter

**Acquisition:**
- New user signups per week
- Activation rate (% who complete first action)
- Source attribution (where users come from)

**Engagement:**
- Daily/Monthly Active Users (DAU/MAU ratio)
- Session length and frequency
- Feature adoption rate

**Retention:**
- D1, D7, D30 retention curves
- Churn rate
- Cohort analysis

**Revenue:**
- Transaction volume
- Platform fees collected
- Average transaction value

**Impact:**
- Campaigns successfully funded
- Jobs filled
- Total economic value facilitated

**Your Dashboard:**
Create a weekly snapshot of these metrics and review trends.

### 5. Common Pitfalls to Avoid

❌ **Scope Creep**: "Just one more small feature"
✅ **Solution**: Define "out of scope" explicitly in every user story

❌ **Feature Factory**: Building without validating need
✅ **Solution**: Require evidence of user need before prioritization

❌ **Ignoring Technical Debt**: Always pushing new features
✅ **Solution**: Allocate 20% of sprint capacity to tech debt

❌ **Perfectionism**: Waiting for the perfect solution
✅ **Solution**: Ship MVP, iterate based on feedback

❌ **Poor Communication**: Assuming others understand context
✅ **Solution**: Over-communicate, document decisions, be explicit

### 6. Your Success Looks Like

**Short-term (initial window):**
- Backlog organized with clear priorities
- All user stories have acceptance criteria
- Team knows what's being built and why

**Medium-term (subsequent phase):**
- Feature adoption rates meet targets
- User satisfaction improving (NPS trending up)
- Reduced scope changes mid-sprint

**Long-term (1 year):**
- Product roadmap delivers on mission
- User growth accelerating
- Platform achieves key milestones (10k users, 1k campaigns funded, etc.)

### 7. Resources

**Required Reading:**
- "Inspired" by Marty Cagan (product management)
- "The Lean Startup" by Eric Ries (validated learning)
- "User Story Mapping" by Jeff Patton (story crafting)

**Tools:**
- Figma: User flows and mockups
- GitHub Projects: Backlog management
- Google Analytics: User behavior
- Mixpanel: Event tracking

**Templates:**
- User story template (see above)
- RICE prioritization spreadsheet
- Sprint planning agenda
- Release checklist

---

**Your Navigator Mentor**: [Assigned]
**Questions**: #navigator-questions channel
```

---

## 16. Advanced Topics

### 16.1 Scaling Considerations

**Horizontal Scaling Strategy:**

```yaml
Current Architecture (Single Region):
  Users: <100,000
  Campaigns: <10,000
  Requests: <1M per evaluation window
  Infrastructure: Single Firebase/Supabase project
  
Phase 1: Regional Expansion (100k-1M users):
  Strategy: Multi-region deployment
  Changes:
    - Deploy Firebase projects per continent
    - Use Cloud CDN for static assets
    - Implement geographic routing (GeoDNS)
    - Cache layer (Redis) per region
  Estimated Cost: $5k/month
  Timeline: Q2 2026

Phase 2: Global Scale (1M-10M users):
  Strategy: Microservices architecture
  Changes:
    - Break monolith into services (campaigns, jobs, payments, search)
    - Use Kubernetes for orchestration
    - Implement event-driven architecture (Pub/Sub)
    - Database sharding by region
    - Introduce API gateway (rate limiting, auth, routing)
  Estimated Cost: $50k/month
  Timeline: Q4 2026

Phase 3: Massive Scale (10M-100M users):
  Strategy: Edge computing, AI optimization
  Changes:
    - Deploy to edge locations (Cloudflare Workers)
    - Implement ML-based caching and prefetching
    - Auto-scaling based on predicted load
    - Multi-master database replication
    - Real-time data pipeline for analytics
  Estimated Cost: $500k/month
  Timeline: 2027-2028

Phase 4: Global Domination (100M+ users):
  Strategy: Custom infrastructure
  Changes:
    - Own data centers in key regions
    - Custom CDN network
    - AI-powered infrastructure management
    - Blockchain for transparency (optional)
    - Quantum-ready cryptography
  Estimated Cost: $5M+/month
  Timeline: 2028+
```

**Database Scaling:**

```sql
-- Sharding Strategy Example (PostgreSQL)

-- Shard by geographic region
CREATE TABLE campaigns_north_america (
  CHECK (location_country IN ('US', 'CA', 'MX'))
) INHERITS (campaigns);

CREATE TABLE campaigns_europe (
  CHECK (location_country IN ('GB', 'FR', 'DE', 'ES', 'IT'))
) INHERITS (campaigns);

CREATE TABLE campaigns_africa (
  CHECK (location_country IN ('ZA', 'NG', 'KE', 'EG'))
) INHERITS (campaigns);

-- Partition by time for analytics
CREATE TABLE transactions_2025 PARTITION OF transactions
  FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

CREATE TABLE transactions_2026 PARTITION OF transactions
  FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

-- Index strategy
CREATE INDEX CONCURRENTLY idx_campaigns_location 
  ON campaigns USING GiST (location_coords);

CREATE INDEX CONCURRENTLY idx_campaigns_status_date 
  ON campaigns (status, created_at DESC) 
  WHERE status IN ('ACTIVE', 'FUNDED');
```

### 16.2 Machine Learning Integration

**Use Cases for ML:**

1. **Campaign Success Prediction**
```python
# ml/models/campaign_success_predictor.py
import tensorflow as tf
from sklearn.ensemble import RandomForestClassifier

class CampaignSuccessPredictor:
    """
    Predicts likelihood of campaign reaching funding goal.
    
    Features:
    - Campaign goal amount
    - Campaign type
    - Creator reputation score
    - Description length and quality
    - Number of images/videos
    - Geographic location (population, GDP)
    - Social media followers
    - Time of year
    
    Output:
    - Success probability (0-1)
    - Suggested optimizations
    """
    
    def train(self, historical_campaigns):
        # Feature engineering
        X = self.extract_features(historical_campaigns)
        y = (historical_campaigns['final_amount'] >= 
             historical_campaigns['goal_amount']).astype(int)
        
        # Train model
        self.model = RandomForestClassifier(n_estimators=100)
        self.model.fit(X, y)
        
    def predict(self, campaign):
        features = self.extract_features([campaign])
        probability = self.model.predict_proba(features)[0][1]
        
        # Generate suggestions
        suggestions = self.generate_suggestions(campaign, probability)
        
        return {
            'success_probability': probability,
            'confidence': 'high' if probability > 0.7 or probability < 0.3 else 'medium',
            'suggestions': suggestions
        }
    
    def generate_suggestions(self, campaign, probability):
        suggestions = []
        
        if campaign['description_length'] < 500:
            suggestions.append({
                'type': 'description',
                'message': 'Add more detail to your description (current: 300 words, recommended: 500+)',
                'impact': 'high'
            })
        
        if campaign['image_count'] < 3:
            suggestions.append({
                'type': 'media',
                'message': 'Add more images showing your project (current: 1, recommended: 3-5)',
                'impact': 'medium'
            })
        
        return suggestions
```

2. **Fraud Detection**
```python
# ml/models/fraud_detector.py
import numpy as np
from sklearn.ensemble import IsolationForest

class FraudDetector:
    """
    Detects potentially fraudulent campaigns using anomaly detection.
    
    Signals:
    - Unusually high goal for new creator
    - Suspicious contribution patterns
    - Image reverse search hits
    - Description plagiarism
    - Rapid account creation → campaign launch
    - Geographic anomalies
    """
    
    def __init__(self):
        self.model = IsolationForest(contamination=0.05)  # Expect 5% fraud
    
    def calculate_fraud_score(self, campaign):
        features = []
        
        # Account age signal
        account_age_days = (datetime.now() - campaign['creator_account_created']).days
        features.append(1 / (account_age_days + 1))  # Newer = higher risk
        
        # Goal vs creator history
        avg_previous_goal = campaign['creator_avg_previous_goal'] or 1000
        features.append(campaign['goal_amount'] / avg_previous_goal)
        
        # Description quality
        features.append(1 - campaign['description_quality_score'])
        
        # Image authenticity
        features.append(campaign['stock_photo_probability'])
        
        # Contribution pattern entropy
        features.append(campaign['contribution_entropy'])
        
        # Predict anomaly score
        X = np.array(features).reshape(1, -1)
        anomaly_score = -self.model.score_samples(X)[0]
        
        # Normalize to 0-100
        fraud_score = min(100, anomaly_score * 10)
        
        return {
            'fraud_score': fraud_score,
            'risk_level': self.get_risk_level(fraud_score),
            'signals': self.explain_signals(features),
            'recommendation': self.get_recommendation(fraud_score)
        }
    
    def get_risk_level(self, score):
        if score > 75:
            return 'high'
        elif score > 50:
            return 'medium'
        else:
            return 'low'
    
    def get_recommendation(self, score):
        if score > 75:
            return 'REJECT_OR_MANUAL_REVIEW'
        elif score > 50:
            return 'REQUIRE_VERIFICATION'
        else:
            return 'AUTO_APPROVE'
```

3. **Personalized Recommendations**
```python
# ml/models/campaign_recommender.py
from surprise import SVD, Dataset, Reader

class CampaignRecommender:
    """
    Recommends campaigns to users based on collaborative filtering.
    
    Approach:
    - User-campaign interaction matrix
    - SVD for dimensionality reduction
    - Consider: views, contributions, saves, shares
    - Weight recent interactions higher
    """
    
    def __init__(self):
        self.model = SVD(n_factors=50, n_epochs=20)
    
    def train(self, interactions):
        # interactions: user_id, campaign_id, interaction_score, timestamp
        reader = Reader(rating_scale=(0, 10))
        data = Dataset.load_from_df(
            interactions[['user_id', 'campaign_id', 'interaction_score']], 
            reader
        )
        
        trainset = data.build_full_trainset()
        self.model.fit(trainset)
    
    def recommend(self, user_id, n=10):
        # Get all campaigns user hasn't interacted with
        all_campaigns = self.get_all_active_campaigns()
        user_interactions = self.get_user_interactions(user_id)
        
        unseen_campaigns = set(all_campaigns) - set(user_interactions)
        
        # Predict ratings
        predictions = []
        for campaign_id in unseen_campaigns:
            pred = self.model.predict(user_id, campaign_id)
            predictions.append((campaign_id, pred.est))
        
        # Sort by predicted rating
        predictions.sort(key=lambda x: x[1], reverse=True)
        
        # Apply diversity filter (don't recommend all same type)
        diverse_recommendations = self.apply_diversity(predictions[:n*2], n)
        
        return diverse_recommendations
    
    def apply_diversity(self, predictions, n):
        """Ensure recommended campaigns span multiple types/locations"""
        selected = []
        types_used = set()
        
        for campaign_id, score in predictions:
            campaign = self.get_campaign(campaign_id)
            
            # Prefer campaigns of types we haven't recommended yet
            if campaign['type'] not in types_used or len(selected) >= n//2:
                selected.append((campaign_id, score))
                types_used.add(campaign['type'])
            
            if len(selected) >= n:
                break
        
        return selected
```

### 16.3 Blockchain Integration (Phase 3)

**Transparency Use Cases:**

```solidity
// contracts/CampaignRegistry.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title CampaignRegistry
 * @dev Immutable record of campaign milestones and fund disbursements
 * 
 * Purpose: Provide transparent, tamper-proof record of how funds are used
 * Users can verify on blockchain that funds went to stated purposes
 */
contract CampaignRegistry {
    struct MilestoneRecord {
        bytes32 campaignId;
        uint256 milestoneIndex;
        uint256 amountDisbursed;
        uint256 timestamp;
        string proofHash;  // IPFS hash of proof documents
        address verifier;  // Who verified this milestone
    }
    
    mapping(bytes32 => MilestoneRecord[]) public campaignMilestones;
    
    event MilestoneRecorded(
        bytes32 indexed campaignId,
        uint256 milestoneIndex,
        uint256 amountDisbursed
    );
    
    /**
     * @dev Record a milestone completion on-chain
     * Only callable by authorized platform verifiers
     */
    function recordMilestone(
        bytes32 campaignId,
        uint256 milestoneIndex,
        uint256 amountDisbursed,
        string memory proofHash
    ) external {
        require(isAuthorizedVerifier(msg.sender), "Not authorized");
        
        MilestoneRecord memory record = MilestoneRecord({
            campaignId: campaignId,
            milestoneIndex: milestoneIndex,
            amountDisbursed: amountDisbursed,
            timestamp: block.timestamp,
            proofHash: proofHash,
            verifier: msg.sender
        });
        
        campaignMilestones[campaignId].push(record);
        
        emit MilestoneRecorded(campaignId, milestoneIndex, amountDisbursed);
    }
    
    /**
     * @dev Get all milestone records for a campaign
     */
    function getCampaignHistory(bytes32 campaignId) 
        external 
        view 
        returns (MilestoneRecord[] memory) 
    {
        return campaignMilestones[campaignId];
    }
}
```

---

## 17. Conclusion & Next Steps

### 17.1 Immediate Actions (Next Sprint)

**For All Agents:**
1. Review and internalize this AGENTS.md document
2. Set up development environment
3. Join communication channels
4. Introduce yourself to the team
5. Pick first task from backlog

**Project Setup:**
1. Initialize Git repository structure
2. Set up CI/CD pipelines (GitHub Actions)
3. Configure Firebase/Supabase projects (staging + production)
4. Set up monitoring and alerting
5. Create initial documentation structure

**First Sprint Planning:**
1. Define MVP scope (Phase 1 features)
2. Break down into user stories
3. Estimate effort for each story
4. Assign stories to agents
5. Set sprint goal and success criteria

### 17.2 Near-Term Roadmap

**Week 1: Foundation**
- Complete environment setup
- Implement basic authentication (email/password)
- Set up database schema (campaigns, users, transactions)
- Create design system components

**Week 2: Core Features**
- Campaign creation flow
- Campaign listing and search
- User profiles
- Basic payment integration (Stripe test mode)

**Week 3: Polish & Testing**
- Complete test coverage (>80%)
- Security audit of payment flow
- Performance optimization
- Accessibility improvements

**Week 4: Deploy & Iterate**
- Deploy to staging
- User testing with 10-20 beta users
- Bug fixes based on feedback
- Prepare for public launch

### 17.3 Living Document

This AGENTS.md is a living document. It should evolve as we learn and grow.

**Update Frequency:**
- Minor updates: As needed (fix typos, add examples)
- Major updates: Quarterly (new sections, process changes)
- Version control: All changes tracked in Git

**How to Contribute:**
1. Identify improvement opportunity
2. Create issue describing the change
3. Submit PR with proposed update
4. Get approval from 2+ agents
5. Merge and announce change

**Feedback Welcome:**
- What's unclear or confusing?
- What's missing?
- What could be better organized?
- What examples would help?

Submit feedback via:
- GitHub issues: tag `documentation`
- #feedback channel
- Email: feedback@localcommunityapp.org

### 17.4 Final Thoughts

This platform has the potential to transform lives at a scale rarely seen in human history. Every person who contributes—whether AI agent or human—is part of something extraordinary.

The technical challenges are immense. Building for billions is hard. Ensuring security, privacy, and compliance at scale is hard. Creating an experience that works for a farmer in rural Kenya and a startup founder in Silicon Valley is hard.

But hard problems are worth solving.

Remember:
- **Start small, think big**: MVP first, scale later
- **User first, always**: Every decision through the lens of user benefit
- **Quality compounds**: Technical debt grows exponentially, quality is cumulative
- **Collaborate relentlessly**: No agent succeeds alone
- **Stay humble**: We don't have all the answers, be willing to learn

Welcome to the Local Community App Engineering Collective.

Let's build a better world, one line of code at a time.

---

**Document Version**: 1.0.0  
**Last Updated**: 2025-10-02  
**Maintained By**: Documentation Agent  
**Questions**: docs@localcommunityapp.org  
**Repository**: https://github.com/local-community-app/platform  
**License**: MIT (Open Source)  

---

## Appendix A: Quick Reference

### Command Cheat Sheet

```bash
# Development
flutter run                          # Run app locally
flutter test                         # Run all tests
flutter analyze                      # Static analysis
dart format .                        # Format code

# Firebase
firebase deploy --only functions     # Deploy backend
firebase deploy --only hosting       # Deploy web app
firebase emulators:start            # Local emulators

# Git
git checkout -b feature/my-feature  # Create feature branch
git commit -m "feat(scope): message" # Conventional commit
git push origin feature/my-feature   # Push branch
gh pr create                         # Create pull request

# Testing
flutter test --coverage             # With coverage
flutter test test/specific_test.dart # Single file
flutter drive --target=integration_test/app_test.dart # Integration

# Release
./scripts/release.sh 1.3.0 minor   # Create release
```

### Common URLs

- **Production**: https://localcommunityapp.org
- **Staging**: https://staging.localcommunityapp.org
- **API Docs**: https://docs.localcommunityapp.org/api
- **Status Page**: https://status.localcommunityapp.org
- **GitHub**: https://github.com/local-community-app/platform
- **Figma**: https://figma.com/localcommunityapp
- **Firebase Console**: https://console.firebase.google.com
- **Monitoring**: https://console.firebase.google.com/project/[project-id]/analytics

### Key Contacts

- **Technical Lead**: lead@localcommunityapp.org
- **Security Issues**: security@localcommunityapp.org
- **Support**: support@localcommunityapp.org
- **Feedback**: feedback@localcommunityapp.org
- **Press/Media**: press@localcommunityapp.org

---

## Appendix B: Glossary

**Terms and Definitions:**

- **ADR**: Architecture Decision Record - Document explaining why we made a technical decision
- **CI/CD**: Continuous Integration/Continuous Deployment - Automated testing and deployment pipeline
- **DAU/MAU**: Daily Active Users / Monthly Active Users - Key engagement metrics
- **GDPR**: General Data Protection Regulation - EU privacy law
- **KYC**: Know Your Customer - Identity verification process
- **MVP**: Minimum Viable Product - Simplest version that delivers value
- **NPS**: Net Promoter Score - User satisfaction metric (-100 to +100)
- **RICE**: Reach, Impact, Confidence, Effort - Prioritization framework
- **RLS**: Row-Level Security - Database access control
- **SLA**: Service Level Agreement - Guaranteed uptime/performance
- **SOC 2**: Security compliance certification
- **P0/P1/P2**: Priority levels for incidents (0=critical, 1=high, 2=medium)

---

**End of AGENTS.md**
