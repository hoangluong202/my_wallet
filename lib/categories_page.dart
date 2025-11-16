import 'package:flutter/material.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          elevation: 0,
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Expense'),
              Tab(text: 'Income'),
              Tab(text: 'Debt'),
              Tab(text: 'Loan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent(
              context,
              categories: _getExpenseCategories(),
              tabType: 'Expense',
            ),
            _buildTabContent(
              context,
              categories: _getIncomeCategories(),
              tabType: 'Income',
            ),
            _buildTabContent(
              context,
              categories: _getDebtCategories(),
              tabType: 'Debt',
            ),
            _buildTabContent(
              context,
              categories: _getLoanCategories(),
              tabType: 'Loan',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context, {
    required List<CategoryItem> categories,
    required String tabType,
  }) {
    return Stack(
      children: [
        // Category list
        ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildCategoryCard(context, category),
            );
          },
        ),
        // Floating Add Button
        Positioned(
          bottom: 24,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _handleAddCategory(context, tabType),
            icon: const Icon(Icons.add),
            label: const Text('Add'),
            tooltip: 'Add $tabType category',
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryItem category) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
            color: category.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(category.icon, color: category.color, size: 24),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${category.transactionCount} transactions • \$${category.amount.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Icon(Icons.more_vert, color: Colors.grey.shade400),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tapped ${category.name}'),
              duration: const Duration(milliseconds: 500),
            ),
          );
        },
      ),
    );
  }

  void _handleAddCategory(BuildContext context, String categoryType) {
    debugPrint('Create new $categoryType category');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Create new $categoryType category'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Dummy data methods
  List<CategoryItem> _getExpenseCategories() {
    return [
      CategoryItem(
        name: 'Food',
        icon: Icons.restaurant,
        color: Colors.orange,
        transactionCount: 12,
        amount: 245.50,
      ),
      CategoryItem(
        name: 'Transport',
        icon: Icons.directions_car,
        color: Colors.blue,
        transactionCount: 8,
        amount: 180.00,
      ),
      CategoryItem(
        name: 'Shopping',
        icon: Icons.shopping_cart,
        color: Colors.pink,
        transactionCount: 5,
        amount: 320.75,
      ),
      CategoryItem(
        name: 'Entertainment',
        icon: Icons.movie,
        color: Colors.purple,
        transactionCount: 6,
        amount: 120.00,
      ),
      CategoryItem(
        name: 'Utilities',
        icon: Icons.electric_bolt,
        color: Colors.amber,
        transactionCount: 3,
        amount: 150.50,
      ),
    ];
  }

  List<CategoryItem> _getIncomeCategories() {
    return [
      CategoryItem(
        name: 'Salary',
        icon: Icons.account_balance,
        color: Colors.green,
        transactionCount: 1,
        amount: 3500.00,
      ),
      CategoryItem(
        name: 'Freelance',
        icon: Icons.work,
        color: Colors.teal,
        transactionCount: 4,
        amount: 750.00,
      ),
      CategoryItem(
        name: 'Bonus',
        icon: Icons.card_giftcard,
        color: Colors.indigo,
        transactionCount: 1,
        amount: 500.00,
      ),
      CategoryItem(
        name: 'Interest',
        icon: Icons.trending_up,
        color: Colors.lightGreen,
        transactionCount: 12,
        amount: 45.30,
      ),
    ];
  }

  List<CategoryItem> _getDebtCategories() {
    return [
      CategoryItem(
        name: 'Credit Card',
        icon: Icons.credit_card,
        color: Colors.red,
        transactionCount: 15,
        amount: 2500.00,
      ),
      CategoryItem(
        name: 'Personal Loan',
        icon: Icons.money,
        color: Colors.deepOrange,
        transactionCount: 24,
        amount: 5000.00,
      ),
      CategoryItem(
        name: 'Owed to Friends',
        icon: Icons.people,
        color: Colors.orange,
        transactionCount: 2,
        amount: 150.00,
      ),
    ];
  }

  List<CategoryItem> _getLoanCategories() {
    return [
      CategoryItem(
        name: 'Home Loan',
        icon: Icons.home,
        color: Colors.brown,
        transactionCount: 60,
        amount: 150000.00,
      ),
      CategoryItem(
        name: 'Auto Loan',
        icon: Icons.directions_car,
        color: Colors.grey,
        transactionCount: 48,
        amount: 25000.00,
      ),
      CategoryItem(
        name: 'Education Loan',
        icon: Icons.school,
        color: Colors.blueGrey,
        transactionCount: 36,
        amount: 35000.00,
      ),
    ];
  }
}

class CategoryItem {
  final String name;
  final IconData icon;
  final Color color;
  final int transactionCount;
  final double amount;

  CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.transactionCount,
    required this.amount,
  });
}
