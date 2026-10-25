import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kavach/app/app.dart';
import 'package:kavach/app/app_providers.dart';
import 'package:kavach/app/firebase_startup_error_screen.dart';
import 'package:kavach/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp();
}

Future<void> _initializeApp() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    runApp(
      ProviderScope(overrides: appProviderOverrides, child: const KavachApp()),
    );
  } on Object {
    runApp(
      const ProviderScope(
        child: FirebaseStartupErrorScreen(onRetry: _initializeApp),
      ),
    );
  }
}
