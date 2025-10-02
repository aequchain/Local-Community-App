# 🚀 Quick Start Guide

## Development Setup (5 minutes)

### 1. Prerequisites
```bash
# Check Flutter version
flutter --version  # Should be >= 3.35.0

# Check Dart version  
dart --version     # Should be >= 3.9.0
```

### 2. Install Dependencies
```bash
cd local_community_app
flutter pub get
```

### 3. Run the App
```bash
# Run on Chrome (recommended for development)
flutter run -d chrome

# Or run on any connected device
flutter devices
flutter run -d <device-id>
```

---

## 📱 Testing the App

### Authentication Flow
1. App starts on **Landing Page**
2. Tap **"Get started"** or **"Roadmap"** → Opens bottom sheet
3. Tap **"Get started"** in sheet → Navigates to **Sign In**
4. Enter any email/password (e.g., `test@example.com` / `password123`)
5. Tap **"Sign in"** → Mock auth succeeds after 233-610ms
6. App navigates to **Campaign Feed**

### Campaign Discovery
1. Browse the **Campaign Feed** with 5 sample campaigns
2. **Hover over cards** (desktop) → See scale/elevation animation
3. **Pull down** to refresh → Simulates data reload
4. **Tap a campaign card** → Opens **Campaign Detail**
5. **Scroll the detail page** → Watch app bar transition
6. **Tap FAB "Contribute"** → Opens contribution bottom sheet
7. Select quick amount or enter custom → Tap confirm
8. **Tap back** → Returns to feed

### Profile Management
1. Tap **Profile** icon in bottom nav bar
2. View user stats and settings
3. Tap **Sign out** → Confirmation dialog appears
4. Confirm → Returns to landing page

---

## 🎨 Design Token Examples

### Spacing in Code
```dart
// Use Fibonacci spacing
Padding(
  padding: EdgeInsets.all(AequusDesignTokens.spacing.s21), // F8
  child: Column(
    children: [
      Text('Title'),
      SizedBox(height: AequusDesignTokens.spacing.s13), // F7
      Text('Subtitle'),
    ],
  ),
)
```

### Animation Timing
```dart
// Use prime-number durations
AnimationController(
  vsync: this,
  duration: AequusDesignTokens.durations.moderate, // 233ms (P3)
)
```

### Border Radius
```dart
// Use Fibonacci radii
Container(
  decoration: BoxDecoration(
    borderRadius: AequusDesignTokens.radii.s13, // F7
  ),
)
```

### Responsive Layout
```dart
final width = MediaQuery.of(context).size.width;
final isMobile = width < 610;  // P4
final isTablet = width >= 610 && width < 987; // P4-P5
final isDesktop = width >= 987; // P5+
```

---

## 🏗️ Adding a New Feature

### Step 1: Create Feature Folder
```bash
mkdir -p lib/src/features/my_feature/{domain,data,application,presentation}
```

### Step 2: Define Domain Model
```dart
// lib/src/features/my_feature/domain/my_model.dart
class MyModel {
  final String id;
  final String name;
  
  const MyModel({
    required this.id,
    required this.name,
  });
}
```

### Step 3: Create Repository Interface
```dart
// lib/src/features/my_feature/domain/my_repository.dart
abstract class MyRepository {
  Stream<List<MyModel>> watchAll();
  Future<MyModel?> getById(String id);
}
```

### Step 4: Implement Mock Repository
```dart
// lib/src/features/my_feature/data/mock_my_repository.dart
class MockMyRepository implements MyRepository {
  final _controller = StreamController<List<MyModel>>.broadcast();
  
  @override
  Stream<List<MyModel>> watchAll() => _controller.stream;
  
  @override
  Future<MyModel?> getById(String id) async {
    await Future.delayed(AequusDesignTokens.durations.moderate);
    return MyModel(id: id, name: 'Sample');
  }
}
```

### Step 5: Create Riverpod Provider
```dart
// lib/src/features/my_feature/application/my_service.dart
final myRepositoryProvider = Provider<MyRepository>((ref) {
  return MockMyRepository();
});

final myModelsProvider = StreamProvider<List<MyModel>>((ref) {
  final repository = ref.watch(myRepositoryProvider);
  return repository.watchAll();
});
```

### Step 6: Build UI Screen
```dart
// lib/src/features/my_feature/presentation/my_screen.dart
class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});
  
  static const routeName = 'my-screen';
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelsAsync = ref.watch(myModelsProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('My Feature')),
      body: modelsAsync.when(
        data: (models) => ListView.builder(
          itemCount: models.length,
          itemBuilder: (context, index) {
            final model = models[index];
            return ListTile(title: Text(model.name));
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

### Step 7: Add Route
```dart
// lib/src/routing/app_router.dart
import '../features/my_feature/presentation/my_screen.dart';

// Inside routes array:
GoRoute(
  path: '/my-feature',
  name: MyScreen.routeName,
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: const MyScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  ),
),
```

---

## 🐛 Common Issues & Solutions

### Issue: Hot reload not working
```bash
# Solution: Stop and restart with hot reload enabled
flutter run --hot
```

### Issue: "Provider not found" error
```dart
// Solution: Ensure ProviderScope wraps MaterialApp
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### Issue: Navigation not working
```dart
// Solution: Use context.goNamed() instead of Navigator.push()
context.goNamed(MyScreen.routeName);

// For routes with parameters:
context.goNamed(
  CampaignDetailScreen.routeName,
  pathParameters: {'id': campaignId},
);
```

### Issue: Animations not smooth
```dart
// Solution: Ensure vsync is provided
class _MyScreenState extends State<MyScreen> 
    with SingleTickerProviderStateMixin { // Add this mixin
  late final AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, // Now available from mixin
      duration: AequusDesignTokens.durations.moderate,
    );
  }
}
```

---

## 📊 Performance Optimization Tips

### 1. Use const Constructors
```dart
// Good ✅
const Text('Hello');
const SizedBox(height: 10);
const Icon(Icons.person);

// Avoid ❌
Text('Hello');
SizedBox(height: 10);
Icon(Icons.person);
```

### 2. Lazy Load Images
```dart
// Campaign cards already implement this
Image.network(
  campaign.imageUrl,
  fit: BoxFit.cover,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return const Center(child: CircularProgressIndicator());
  },
);
```

### 3. Dispose Controllers
```dart
@override
void dispose() {
  _controller.dispose(); // Always dispose animation controllers
  _scrollController.dispose();
  super.dispose();
}
```

### 4. Use StreamProvider for Real-time Data
```dart
// Automatically manages subscription lifecycle
final campaignsProvider = StreamProvider<List<Campaign>>((ref) {
  final repository = ref.watch(campaignRepositoryProvider);
  return repository.watchActiveCampaigns();
});
```

---

## 🧪 Testing (Future Implementation)

### Unit Test Example
```dart
// test/features/campaigns/domain/campaign_test.dart
void main() {
  group('Campaign', () {
    test('percentageFunded calculates correctly', () {
      final campaign = Campaign(
        fundingGoal: FundingGoal(
          targetAmount: 10000,
          currentAmount: 7500,
        ),
        // ... other fields
      );
      
      expect(campaign.percentageFunded, equals(75.0));
    });
  });
}
```

### Widget Test Example
```dart
// test/features/campaigns/presentation/widgets/campaign_card_test.dart
void main() {
  testWidgets('CampaignCard displays campaign info', (tester) async {
    final campaign = Campaign(/* ... */);
    
    await tester.pumpWidget(
      MaterialApp(
        home: CampaignCard(campaign: campaign),
      ),
    );
    
    expect(find.text(campaign.title), findsOneWidget);
    expect(find.text(campaign.location.city), findsOneWidget);
  });
}
```

---

## 🔄 Migrating from Mock to Firebase

### Step 1: Add Firebase Dependencies
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
```

### Step 2: Initialize Firebase
```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}
```

### Step 3: Create Firebase Repository
```dart
// lib/src/features/auth/data/firebase_auth_repository.dart
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  @override
  Stream<AuthUser?> authStateChanges() {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return AuthUser(
        uid: user.uid,
        email: user.email!,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        isEmailVerified: user.emailVerified,
      );
    });
  }
  
  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }
  
  // ... implement other methods
}
```

### Step 4: Swap Repository in Provider
```dart
// lib/src/features/auth/application/auth_service.dart

// Before (Mock):
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

// After (Firebase):
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});
```

**That's it!** The rest of your app remains unchanged thanks to the repository pattern.

---

## 📚 Additional Resources

### Flutter Documentation
- [Widget Catalog](https://docs.flutter.dev/ui/widgets)
- [Animations Tutorial](https://docs.flutter.dev/ui/animations)
- [State Management](https://docs.flutter.dev/data-and-backend/state-mgmt/intro)

### Riverpod
- [Official Docs](https://riverpod.dev/)
- [Provider Types](https://riverpod.dev/docs/concepts/providers)
- [Reading Providers](https://riverpod.dev/docs/concepts/reading)

### GoRouter
- [Navigation Guide](https://pub.dev/packages/go_router)
- [Declarative Routing](https://docs.flutter.dev/ui/navigation)

### Material 3
- [Design System](https://m3.material.io/)
- [Flutter Implementation](https://docs.flutter.dev/ui/design/material)

---

## 💬 Support

### Common Questions

**Q: Why use mock repositories?**  
A: Enables rapid development without backend setup, easy to test, and real implementation can be swapped in later.

**Q: Why Fibonacci/prime numbers?**  
A: Creates mathematical harmony and consistency. All timing feels natural because it follows patterns found in nature.

**Q: How do I add Firebase?**  
A: See "Migrating from Mock to Firebase" section above. Just swap the repository implementation in the provider.

**Q: Can I use a different state management solution?**  
A: Yes, but Riverpod is recommended for its compile-time safety and excellent DevTools integration.

---

**Happy coding! 🎉**
