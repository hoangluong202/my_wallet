import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';
import '../viewmodels/transactions_viewmodel.dart';
import '../../../categories/presentation/list/categories_viewmodel.dart';
import '../../../wallets/presentation/list/wallets_viewmodel.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../wallets/domain/entities/wallet.dart';
import '../../domain/transaction.dart';
import '../widgets/transactions_header.dart';
import '../widgets/transactions_tab_content.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late TransactionsViewModel _transactionsViewModel;
  late CategoriesViewModel _categoriesViewModel;
  late WalletsViewModel _walletsViewModel;

  // Cached data
  List<Transaction> _transactions = [];
  Map<String, Category> _categoriesCache = {};
  Map<String, Wallet> _walletsCache = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _transactionsViewModel = getIt<TransactionsViewModel>();
    _categoriesViewModel = getIt<CategoriesViewModel>();
    _walletsViewModel = getIt<WalletsViewModel>();

    // Add listener to transactions
    _transactionsViewModel.addListener(_onTransactionsChanged);

    // Add app lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Load all data
    _loadAllData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Reload data when app returns to foreground
    if (state == AppLifecycleState.resumed) {
      _loadAllData();
    }
  }

  void _onTransactionsChanged() {
    if (mounted) {
      setState(() {
        _transactions = _transactionsViewModel.transactions;
        _isLoading = _transactionsViewModel.isLoading;
        _error = _transactionsViewModel.error;

        // Rebuild caches to ensure consistency with updated transactions
        _categoriesCache = {
          for (var cat in _categoriesViewModel.categories) cat.id: cat,
        };
        _walletsCache = {
          for (var wallet in _walletsViewModel.wallets) wallet.id: wallet,
        };
      });
    }
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all data in parallel
      await Future.wait([
        _transactionsViewModel.loadTransactions(),
        _categoriesViewModel.loadCategories(),
        _walletsViewModel.loadWallets(),
      ]);

      // Build caches
      _categoriesCache = {
        for (var cat in _categoriesViewModel.categories) cat.id: cat,
      };
      _walletsCache = {
        for (var wallet in _walletsViewModel.wallets) wallet.id: wallet,
      };
      _transactions = _transactionsViewModel.transactions;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _onTransactionEditedOrDeleted() {
    // Reload all data when transaction is edited or deleted
    _loadAllData();
  }

  @override
  void dispose() {
    _transactionsViewModel.removeListener(_onTransactionsChanged);
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Modern Header
          const TransactionsHeader(),

          // Tab Bar - Enhanced
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey.shade500,
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Past'),
                Tab(text: 'Today'),
                Tab(text: 'Future'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                TransactionsTabContent(
                  tabType: TabType.past,
                  transactions: _transactions,
                  categoriesCache: _categoriesCache,
                  walletsCache: _walletsCache,
                  isLoading: _isLoading,
                  error: _error,
                  onRetry: _loadAllData,
                  onTransactionChanged: _onTransactionEditedOrDeleted,
                ),
                TransactionsTabContent(
                  tabType: TabType.today,
                  transactions: _transactions,
                  categoriesCache: _categoriesCache,
                  walletsCache: _walletsCache,
                  isLoading: _isLoading,
                  error: _error,
                  onRetry: _loadAllData,
                  onTransactionChanged: _onTransactionEditedOrDeleted,
                ),
                TransactionsTabContent(
                  tabType: TabType.future,
                  transactions: _transactions,
                  categoriesCache: _categoriesCache,
                  walletsCache: _walletsCache,
                  isLoading: _isLoading,
                  error: _error,
                  onRetry: _loadAllData,
                  onTransactionChanged: _onTransactionEditedOrDeleted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
