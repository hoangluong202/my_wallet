import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/di/injector.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AuthViewModel _authViewModel;

  @override
  void initState() {
    super.initState();
    _authViewModel = getIt<AuthViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _authViewModel,
      builder: (context, _) {
        final initialRoute = _authViewModel.isAuthenticated
            ? AppRouter.main
            : AppRouter.login;

        return MaterialApp(
          title: 'My Wallet',
          theme: AppTheme.lightTheme,
          initialRoute: initialRoute,
          onGenerateRoute: AppRouter.onGenerateRoute,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
