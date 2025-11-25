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
import '../../features/users/data/datasources/user_firebase_service.dart';
import '../../features/users/data/repositories/user_repository_impl.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import '../../features/users/domain/services/user_service.dart';
import '../../features/users/presentation/viewmodels/user_viewmodel.dart';
import '../../features/wallets/presentation/viewmodels/wallets_viewmodel.dart';
import '../../features/categories/data/datasources/categories_local_data_source.dart';
import '../../features/categories/data/repositories/categories_repository_impl.dart';
import '../../features/categories/domain/repositories/categories_repository.dart';
import '../../features/categories/domain/usecases/get_categories_usecase.dart';
import '../../features/categories/domain/usecases/get_categories_by_type_usecase.dart';
import '../../features/categories/domain/usecases/add_category_usecase.dart';
import '../../features/categories/domain/usecases/update_category_usecase.dart';
import '../../features/categories/domain/usecases/delete_category_usecase.dart';
import '../../features/categories/presentation/viewmodels/categories_viewmodel.dart';

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

  // User Firebase Service
  getIt.registerLazySingleton<UserFirebaseService>(
    () => UserFirebaseServiceImpl(
      getIt<FirebaseFirestore>(),
      getIt<AppDatabase>().userDao,
      getIt<FirebaseAuth>(),
    ),
  );

  // User Repository
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      getIt<AppDatabase>().userDao,
      getIt<UserFirebaseService>(),
    ),
  );

  // User Service
  getIt.registerLazySingleton<UserService>(
    () => UserService(getIt<UserRepository>()),
  );

  // Auth ViewModel
  getIt.registerSingleton<AuthViewModel>(
    AuthViewModel(
      getIt<AuthRepository>(),
      getIt<UserService>(),
      getIt<AppDatabase>(),
    ),
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
      getIt<FirebaseAuth>(),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(
      getIt<WalletLocalDataSource>(),
      getIt<FirebaseService>(),
    ),
  );

  // ViewModels
  getIt.registerFactory<WalletsViewModel>(
    () => WalletsViewModel(getIt<WalletRepository>()),
  );

  // Categories - Data Sources
  getIt.registerLazySingleton<CategoriesLocalDataSource>(
    () => CategoriesLocalDataSourceImpl(),
  );

  // Categories - Repositories
  getIt.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(getIt<CategoriesLocalDataSource>()),
  );

  // Categories - Use Cases
  getIt.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(getIt<CategoriesRepository>()),
  );
  getIt.registerLazySingleton<GetCategoriesByTypeUseCase>(
    () => GetCategoriesByTypeUseCase(getIt<CategoriesRepository>()),
  );
  getIt.registerLazySingleton<AddCategoryUseCase>(
    () => AddCategoryUseCase(getIt<CategoriesRepository>()),
  );
  getIt.registerLazySingleton<UpdateCategoryUseCase>(
    () => UpdateCategoryUseCase(getIt<CategoriesRepository>()),
  );
  getIt.registerLazySingleton<DeleteCategoryUseCase>(
    () => DeleteCategoryUseCase(getIt<CategoriesRepository>()),
  );

  // Categories - ViewModels
  getIt.registerFactory<CategoriesViewModel>(
    () => CategoriesViewModel(
      getIt<GetCategoriesUseCase>(),
      getIt<AddCategoryUseCase>(),
      getIt<UpdateCategoryUseCase>(),
      getIt<DeleteCategoryUseCase>(),
    ),
  );
}
