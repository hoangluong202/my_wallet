import 'package:flutter/material.dart';
import 'app/di/injector.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependencies (including Drift database)
  await setupDependencies();

  runApp(const MyApp());
}
