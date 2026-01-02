import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';
import 'transactions_header.dart';
import 'transactions_tab_content.dart';
import '../model/transaction_view_data.dart';
import '../viewmodel/transaction_viewmodel.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getIt<TransactionViewmodel>();

    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        body: Column(
          children: [
            const TransactionsHeader(),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: TabBar(
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

            Expanded(
              child: StreamBuilder<List<TransactionViewData>>(
                stream: viewModel.watchAllTransactions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Stream tự động retry khi có thay đổi
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final transactions = snapshot.data ?? [];

                  return TabBarView(
                    children: [
                      TransactionsTabContent(
                        tabType: TabType.past,
                        transactions: transactions,
                      ),
                      TransactionsTabContent(
                        tabType: TabType.today,
                        transactions: transactions,
                      ),
                      TransactionsTabContent(
                        tabType: TabType.future,
                        transactions: transactions,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
