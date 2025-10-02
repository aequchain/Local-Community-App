import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

Future<void> bootstrap() async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      runApp(const ProviderScope(child: App()));
    },
    (error, stackTrace) {
      // TODO(rtd): wire up error reporting service once available.
      debugPrint('Uncaught error: $error\n$stackTrace');
    },
  );
}
