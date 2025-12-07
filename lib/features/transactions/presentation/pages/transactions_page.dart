import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';
import '../viewmodels/transactions_viewmodel.dart';
import '../widgets/transactions_header.dart';
import '../widgets/transactions_tab_content.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TransactionsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _viewModel = getIt<TransactionsViewModel>();
  }

  @override
  void dispose() {
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
                  viewModel: _viewModel,
                ),
                TransactionsTabContent(
                  tabType: TabType.today,
                  viewModel: _viewModel,
                ),
                TransactionsTabContent(
                  tabType: TabType.future,
                  viewModel: _viewModel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
