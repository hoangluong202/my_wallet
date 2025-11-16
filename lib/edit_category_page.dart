import 'package:flutter/material.dart';
import 'categories_page.dart';

class EditCategoryPage extends StatefulWidget {
  final CategoryItem category;

  const EditCategoryPage({super.key, required this.category});

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late IconData _selectedIcon;

  final List<IconData> _availableIcons = [
    Icons.restaurant,
    Icons.directions_car,
    Icons.shopping_cart,
    Icons.movie,
    Icons.account_balance,
    Icons.work,
    Icons.credit_card,
    Icons.money,
    Icons.home,
    Icons.electric_bolt,
    Icons.card_giftcard,
    Icons.trending_up,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedIcon = widget.category.icon;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updated = widget.category.copyWith(
        name: _nameController.text,
        icon: _selectedIcon,
      );

      debugPrint('Category updated: ${_nameController.text}');
      Navigator.pop(context, updated);
    }
  }

  Color _getColorForIcon(IconData icon) {
    final index = _availableIcons.indexOf(icon) % 5;
    final colors = [
      Colors.orange,
      Colors.blue,
      Colors.pink,
      Colors.purple,
      Colors.green,
    ];
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Category'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Picker
                _buildSectionTitle('Select Icon'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _getColorForIcon(
                            _selectedIcon,
                          ).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          _selectedIcon,
                          size: 40,
                          color: _getColorForIcon(_selectedIcon),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableIcons
                            .map(
                              (icon) => GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedIcon = icon),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _selectedIcon == icon
                                        ? Colors.blue.shade100
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _selectedIcon == icon
                                          ? Colors.blue
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(icon, size: 24),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Category Name
                _buildSectionTitle('Category Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration('Enter category name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Category Type (Read-only)
                _buildSectionTitle('Category Type (Read-only)'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade100,
                  ),
                  child: Text(
                    categoryTypeLabel(widget.category.type),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
