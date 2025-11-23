import 'package:get_it/get_it.dart';
import '../../core/local/database/app_database.dart';
import '../../features/wallets/data/datasources/wallet_local_datasource.dart';
import '../../features/wallets/data/repositories/wallet_repository_impl.dart';
import '../../features/wallets/domain/repositories/wallet_repository.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core - Database
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Data Sources
  getIt.registerLazySingleton<WalletLocalDataSource>(
    () => WalletLocalDataSourceImpl(getIt<AppDatabase>()),
  );

  // Repositories
  getIt.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(getIt<WalletLocalDataSource>()),
  );
}
