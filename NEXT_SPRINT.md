# Next Sprint Plan: Create Campaign Flow

**Sprint Goal:** Enable users to create new campaigns through an intuitive multi-step form  
**Estimated Duration:** 2-3 development sessions  
**Priority:** HIGH

---

## User Story
```
As a community member,
I want to create a funding campaign,
So that I can raise money for local initiatives.

Acceptance Criteria:
✓ Form validates all required fields
✓ Image upload with preview
✓ Location autocomplete
✓ Funding goal with currency selector
✓ Draft save capability
✓ Review before submit
✓ Success confirmation
```

---

## Technical Tasks

### Task 1: Create Campaign Form Screen
**File:** `lib/src/features/campaigns/presentation/create_campaign_screen.dart`

**Components:**
- PageView/Stepper widget for multi-step flow
- Step 1: Basic Info (title, tagline, description, type)
- Step 2: Location (city, region, country + map preview)
- Step 3: Funding Goal (amount, currency, end date)
- Step 4: Media (image upload, optional video URL)
- Step 5: Review & Submit

**Design Tokens:**
- Use `AequusDesignTokens.durations.deliberate` for page transitions (610ms)
- Step progress indicator with Fibonacci spacing
- Form fields with `AequusDesignTokens.radii.s13`

### Task 2: Form Validation Layer
**File:** `lib/src/features/campaigns/domain/campaign_validators.dart`

**Validators:**
```dart
class CampaignValidators {
  static String? validateTitle(String? value);
  static String? validateDescription(String? value);
  static String? validateFundingGoal(double? value);
  static String? validateEndDate(DateTime? value);
  static bool isFormValid(CampaignFormState state);
}
```

### Task 3: Image Upload Widget
**File:** `lib/src/features/campaigns/presentation/widgets/campaign_image_picker.dart`

**Features:**
- File picker integration (`image_picker` package)
- Image crop/resize (maintain 1.618 aspect ratio)
- Upload progress indicator
- Error handling (size limits, format validation)

### Task 4: State Management
**File:** `lib/src/features/campaigns/application/create_campaign_service.dart`

**Provider:**
```dart
final createCampaignProvider = 
  AsyncNotifierProvider<CreateCampaignNotifier, CampaignFormState>(
    CreateCampaignNotifier.new,
  );

class CreateCampaignNotifier extends AsyncNotifier<CampaignFormState> {
  Future<void> updateField(String field, dynamic value);
  Future<void> saveDraft();
  Future<Campaign> submit();
}
```

### Task 5: Navigation Integration
**File:** `lib/src/routing/app_router.dart`

**Route Addition:**
```dart
GoRoute(
  path: '/campaigns/create',
  name: 'create-campaign',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: const CreateCampaignScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    },
  ),
),
```

### Task 6: FAB Integration
**File:** `lib/src/features/campaigns/presentation/campaign_feed_screen.dart`

**Add FloatingActionButton:**
```dart
floatingActionButton: FloatingActionButton.extended(
  onPressed: () => context.goNamed('create-campaign'),
  icon: const Icon(Icons.add_rounded),
  label: const Text('Create campaign'),
),
```

---

## Testing Requirements

### Unit Tests
- [ ] Validators return correct error messages
- [ ] Form state updates correctly
- [ ] Draft save/restore logic works

### Widget Tests
- [ ] Each step renders expected fields
- [ ] Navigation between steps works
- [ ] Form validation displays errors
- [ ] Review screen shows all entered data

### Integration Tests
- [ ] Full flow: start → enter data → submit → success
- [ ] Draft save → close → reopen → restore state
- [ ] Invalid data → error → fix → submit

---

## UI/UX Considerations

### Design Specs
- **Step Indicator**: Horizontal dots with active state (primary color)
- **Field Focus**: Subtle elevation + primary border on focus
- **Error Display**: Below field, red accent color, icon prefix
- **Success Animation**: Confetti + checkmark (similar to contribution modal)

### Accessibility
- Screen reader announces step transitions
- Form fields have semantic labels
- Error messages linked to fields via `aria-describedby` equivalent
- Skip navigation for keyboard users

### Responsive Behavior
- **Mobile**: Full-screen form, one step at a time
- **Tablet**: Side-by-side (form + preview)
- **Desktop**: Wide form with sticky preview panel

---

## Dependencies to Add

```yaml
dependencies:
  image_picker: ^1.0.7  # File picker
  image_cropper: ^5.0.0  # Crop to aspect ratio
  uuid: ^4.0.0  # Generate campaign IDs
  
dev_dependencies:
  mocktail: ^1.0.0  # Mock file picker in tests
```

---

## Acceptance Checklist

- [ ] User can navigate through all form steps
- [ ] All validation rules are enforced
- [ ] Image upload works (or shows placeholder)
- [ ] Location can be entered manually
- [ ] Funding goal accepts decimal values
- [ ] End date cannot be in the past
- [ ] Review screen shows all data correctly
- [ ] Submit creates campaign (mock for now)
- [ ] Success message redirects to campaign detail
- [ ] Draft save icon appears after first input
- [ ] Analyzer passes with 0 issues
- [ ] All tests pass

---

## Future Enhancements (Post-MVP)

1. **Location Autocomplete** (Google Places API)
2. **Rich Text Editor** (for description formatting)
3. **Video Upload** (in addition to image)
4. **Category Icons** (custom icon picker)
5. **Milestone Tracking** (multiple funding goals)
6. **Team Management** (co-creators)
7. **Preview Mode** (see campaign as users will see it)
8. **Template Library** (pre-filled forms for common campaign types)

---

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Image upload size limits | HIGH | Compress before upload, show size warning |
| Complex form state | MEDIUM | Use FormKey for validation, Riverpod for state |
| User drops off mid-form | MEDIUM | Auto-save draft every 30s |
| Invalid date selections | LOW | Use DatePicker with min/max constraints |

---

## Timeline Estimate

| Task | Estimated Time |
|------|----------------|
| Screen scaffolding | 1 hour |
| Form fields + validation | 2 hours |
| Image picker integration | 1.5 hours |
| State management | 1 hour |
| Review step + submit | 1 hour |
| Testing | 1.5 hours |
| **Total** | **~8 hours** |

---

## Success Metrics

**Technical:**
- 0 analyzer issues
- 100% test pass rate
- <500ms form field response time

**User Experience:**
- <5 minutes to complete form (avg.)
- <2% drop-off rate per step
- 80% success rate on first submit attempt

---

*This plan will be updated as implementation progresses. Check PROGRESS_REPORT.md for completed items.*
