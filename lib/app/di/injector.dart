import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/local/database/app_database.dart';
import '../../features/wallets/data/datasources/wallet_local_datasource.dart';
import '../../features/wallets/data/datasources/firebase_service.dart';
import '../../features/wallets/data/repositories/wallet_repository_impl.dart';
import '../../features/wallets/domain/repositories/wallet_repository.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/users/data/repositories/user_repository_impl.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import '../../features/users/domain/services/user_service.dart';
import '../../features/users/presentation/viewmodels/user_viewmodel.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core - Database
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Firebase
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Auth Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(firebaseAuth: getIt<FirebaseAuth>()),
  );

  // User Repository
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt<AppDatabase>().userDao),
  );

  // User Service
  getIt.registerLazySingleton<UserService>(
    () => UserService(getIt<UserRepository>()),
  );

  // Auth ViewModel
  getIt.registerSingleton<AuthViewModel>(
    AuthViewModel(getIt<AuthRepository>(), getIt<UserService>()),
  );

  // User ViewModel
  getIt.registerLazySingleton<UserViewModel>(
    () => UserViewModel(getIt<UserRepository>()),
  );

  // Data Sources
  getIt.registerLazySingleton<WalletLocalDataSource>(
    () => WalletLocalDataSourceImpl(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<FirebaseService>(
    () => FirebaseServiceImpl(
      getIt<FirebaseFirestore>(),
      getIt<AppDatabase>().walletDao,
    ),
  );

  // Repositories
  getIt.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(
      getIt<WalletLocalDataSource>(),
      getIt<FirebaseService>(),
    ),
  );
}
