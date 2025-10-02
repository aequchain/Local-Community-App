import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:local_community_app/src/app.dart';

void main() {
  testWidgets('Unauthenticated users see landing screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: App(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify landing screen is shown
    expect(
      find.text('Mobilize funding. Unlock jobs. Grow local prosperity.'),
      findsOneWidget,
    );
  });
}
