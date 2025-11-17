import 'package:flutter/material.dart';

import 'add_category_page.dart';
import 'edit_category_page.dart';
import 'category_history_page.dart';

enum CategoryType { expense, income, debt, loan }

String categoryTypeLabel(CategoryType t) {
  switch (t) {
    case CategoryType.expense:
      return 'Expense';
    case CategoryType.income:
      return 'Income';
    case CategoryType.debt:
      return 'Debt';
    case CategoryType.loan:
      return 'Loan';
  }
}

class CategoryItem {
  final int id;
  final String name;
  final IconData icon;
  final Color color;
  final int transactionCount;
  final double amount;
  final CategoryType type;

  CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.transactionCount,
    required this.amount,
    required this.type,
  });

  CategoryItem copyWith({
    int? id,
    String? name,
    IconData? icon,
    Color? color,
    int? transactionCount,
    double? amount,
    CategoryType? type,
  }) {
    return CategoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      transactionCount: transactionCount ?? this.transactionCount,
      amount: amount ?? this.amount,
      type: type ?? this.type,
    );
  }
}

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final Map<CategoryType, List<CategoryItem>> _categories = {};
  int _nextId = 100;

  @override
  void initState() {
    super.initState();
    _initMockData();
  }

  void _initMockData() {
    _categories[CategoryType.expense] = [
      CategoryItem(
        id: 1,
        name: 'Food',
        icon: Icons.restaurant,
        color: Colors.orange,
        transactionCount: 12,
        amount: 245.50,
        type: CategoryType.expense,
      ),
      CategoryItem(
        id: 2,
        name: 'Transport',
        icon: Icons.directions_car,
        color: Colors.blue,
        transactionCount: 8,
        amount: 180.00,
        type: CategoryType.expense,
      ),
    ];

    _categories[CategoryType.income] = [
      CategoryItem(
        id: 3,
        name: 'Salary',
        icon: Icons.account_balance,
        color: Colors.green,
        transactionCount: 1,
        amount: 3500.00,
        type: CategoryType.income,
      ),
    ];

    _categories[CategoryType.debt] = [
      CategoryItem(
        id: 4,
        name: 'Credit Card',
        icon: Icons.credit_card,
        color: Colors.red,
        transactionCount: 15,
        amount: 2500.00,
        type: CategoryType.debt,
      ),
    ];

    _categories[CategoryType.loan] = [
      CategoryItem(
        id: 5,
        name: 'Home Loan',
        icon: Icons.home,
        color: Colors.brown,
        transactionCount: 60,
        amount: 150000.00,
        type: CategoryType.loan,
      ),
    ];

    _nextId = 10;
  }

  Future<void> _onAddCategory(CategoryType type) async {
    final result = await Navigator.push<CategoryItem?>(
      context,
      MaterialPageRoute(
        builder: (context) => AddCategoryPage(preselectedType: type),
      ),
    );

    if (result != null) {
      setState(() {
        final newCategory = result.copyWith(id: _nextId++);
        final list = _categories[type] ?? [];
        _categories[type] = [...list, newCategory];
      });
    }
  }

  Future<void> _onEditCategory(CategoryItem category) async {
    final result = await Navigator.push<CategoryItem?>(
      context,
      MaterialPageRoute(
        builder: (context) => EditCategoryPage(category: category),
      ),
    );

    if (result != null) {
      setState(() {
        final list = _categories[category.type]!;
        final idx = list.indexWhere((c) => c.id == category.id);
        if (idx != -1) list[idx] = result;
      });
    }
  }

  void _onViewHistory(CategoryItem category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryHistoryPage(category: category),
      ),
    );
  }

  void _onDeleteCategory(CategoryItem category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: const Text(
          'Are you sure you want to delete this category? '
          'All transactions related to this category will also be deleted. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final list = _categories[category.type]!;
                list.removeWhere((c) => c.id == category.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Category "${category.name}" deleted'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          children: [
            // Modern Header
            _buildHeader(context),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: const TabBar(
                isScrollable: false,
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(text: 'Expense'),
                  Tab(text: 'Income'),
                  Tab(text: 'Debt'),
                  Tab(text: 'Loan'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildTabContent(CategoryType.expense),
                  _buildTabContent(CategoryType.income),
                  _buildTabContent(CategoryType.debt),
                  _buildTabContent(CategoryType.loan),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categories',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Organize your finances',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(CategoryType type) {
    final items = _categories[type] ?? [];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${categoryTypeLabel(type)} Categories',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _onAddCategory(type),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      'No ${categoryTypeLabel(type).toLowerCase()} categories yet',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final category = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                color: category.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(category.icon, color: category.color),
                            ),
                            title: Text(
                              category.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${category.transactionCount} transactions • \$${category.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'view') _onViewHistory(category);
                                if (value == 'edit') _onEditCategory(category);
                                if (value == 'delete')
                                  _onDeleteCategory(category);
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'view',
                                  child: Row(
                                    children: [
                                      Icon(Icons.history, size: 18),
                                      SizedBox(width: 8),
                                      Text('View History'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 18),
                                      SizedBox(width: 8),
                                      Text('Edit Category'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Delete Category',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
