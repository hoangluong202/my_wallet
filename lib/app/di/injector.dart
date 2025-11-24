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

  // Auth ViewModel
  getIt.registerSingleton<AuthViewModel>(
    AuthViewModel(getIt<AuthRepository>()),
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
