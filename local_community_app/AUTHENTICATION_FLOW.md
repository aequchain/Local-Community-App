# Authentication Flow

## Overview
The app uses **GoRouter** with automatic redirect logic to manage authentication state and navigation.

## Flow

### Unauthenticated Users
1. Land on **Landing Screen** (`/`)
2. Can tap "View build roadmap" to learn about the project
3. Roadmap modal has a "Get started" button that navigates to **Sign In Screen** (`/sign-in`)
4. After signing in, automatically redirected to **Campaign Feed** (`/campaigns`)

### Authenticated Users
1. Automatically redirected from `/` or `/sign-in` to `/campaigns`
2. Can navigate freely between:
   - Campaign Feed (`/campaigns`)
   - Campaign Detail (`/campaigns/:id`)
   - Profile (`/profile`)

## Router Redirect Logic

```dart
redirect: (context, state) {
  final isAuthenticated = authState.value != null;
  final isAuthRoute = state.matchedLocation == '/sign-in';
  final isLandingRoute = state.matchedLocation == '/';

  // If authenticated and on auth/landing screen, redirect to campaigns
  if (isAuthenticated && (isAuthRoute || isLandingRoute)) {
    return '/campaigns';
  }

  return null; // No redirect needed
}
```

## Mock Authentication

Currently uses `MockAuthRepository` for development:
- Any email with `@` symbol is accepted
- Password must be at least 8 characters
- Sign-in delay: 610ms (Fibonacci timing)
- User persists in memory during session

## Testing

Tests verify:
- ✅ Unauthenticated users see landing screen
- ✅ Campaign detail screen renders correctly
- ✅ Landing screen shows hero messaging

## Next Steps

When ready for production:
1. Replace `MockAuthRepository` with `FirebaseAuthRepository`
2. Add sign-up flow
3. Add password reset flow
4. Add email verification flow
5. Add protected route guards for campaigns/profile if needed
