import 'package:flutter/material.dart';

import 'add_category_page.dart';
import 'edit_category_page.dart';
import 'category_history_page.dart';
import 'notification_widget.dart';

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
              SuccessNotification.show(
                context: context,
                message: 'Category "${category.name}" deleted successfully!',
                duration: const Duration(seconds: 2),
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
            // Beautiful Header
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your transactions',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(Icons.category, color: Colors.white, size: 28),
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
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              FilledButton.icon(
                onPressed: () => _onAddCategory(type),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No ${categoryTypeLabel(type).toLowerCase()} categories yet',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final category = items[index];
                      return _buildCategoryCard(category);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(CategoryItem category) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(category.icon, color: category.color, size: 22),
          ),
          const SizedBox(width: 12),
          // Category info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${category.transactionCount} transactions',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 1,
                      height: 12,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_formatVND(category.amount.toInt())} đ',
                      style: TextStyle(
                        fontSize: 11,
                        color: category.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Menu
          PopupMenuButton<String>(
            offset: const Offset(0, 30),
            onSelected: (value) {
              if (value == 'view') _onViewHistory(category);
              if (value == 'edit') _onEditCategory(category);
              if (value == 'delete') _onDeleteCategory(category);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                height: 40,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 16),
                    SizedBox(width: 8),
                    Text('History', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                height: 40,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Edit', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                height: 40,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Delete',
                      style: TextStyle(fontSize: 13, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
            child: Icon(Icons.more_vert, size: 20, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  static String _formatVND(int amount) {
    final s = amount.toString();
    final re = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(re, (m) => '.');
  }
}
