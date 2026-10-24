import 'package:flutter/material.dart';

import 'package:kavach/app/app_router.dart';
import 'package:kavach/core/design_system/theme/app_theme.dart';

class KavachApp extends StatelessWidget {
  const KavachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kavach',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
