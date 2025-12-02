import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/app_initializer.dart';

/// Main entry point for SUB-GUARD application.
///
/// This file is kept minimal, delegating initialization to AppInitializer
/// and app configuration to MyApp widget.
void main() async {
  // Initialize all required services and dependencies
  await AppInitializer.initialize();

  // Run the app with Riverpod state management
  runApp(const ProviderScope(child: MyApp()));
}
