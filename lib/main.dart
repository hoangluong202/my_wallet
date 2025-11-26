import 'package:flutter/material.dart';
import 'core/di/injector.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Setup dependencies (including Drift database)
  await setupDependencies();

  runApp(const MyApp());
}
