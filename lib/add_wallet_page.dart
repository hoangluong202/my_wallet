import 'package:flutter/material.dart';

class AddWalletPage extends StatefulWidget {
  const AddWalletPage({super.key});

  @override
  State<AddWalletPage> createState() => _AddWalletPageState();
}

class _AddWalletPageState extends State<AddWalletPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late TextEditingController _walletNameController;
  late TextEditingController _initialBalanceController;

  // Selected currency
  String _selectedCurrency = 'VND (₫)';

  @override
  void initState() {
    super.initState();
    _walletNameController = TextEditingController();
    _initialBalanceController = TextEditingController();
  }

  @override
  void dispose() {
    _walletNameController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid
      final walletData = {
        'name': _walletNameController.text,
        'currency': _selectedCurrency,
        'balance': double.parse(_initialBalanceController.text),
      };

      debugPrint('Wallet verified: $walletData');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Wallet "${_walletNameController.text}" created successfully!',
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Pop back to previous page after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('+ Add New Wallet'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wallet Name
                _buildSectionTitle('Wallet Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _walletNameController,
                  keyboardType: TextInputType.text,
                  decoration: _buildInputDecoration(
                    'e.g., Savings, Momo, Main Account',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a wallet name';
                    }
                    if (value.length < 2) {
                      return 'Wallet name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Currency Selector
                _buildSectionTitle('Currency'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCurrency,
                  items: const [
                    DropdownMenuItem(value: 'VND (₫)', child: Text('VND (₫)')),
                    DropdownMenuItem(
                      value: 'USD (\$)',
                      child: Text('USD (\$)'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCurrency = value ?? 'VND (₫)';
                    });
                  },
                  decoration: _buildInputDecoration('Select a currency'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a currency';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Initial Balance
                _buildSectionTitle('Initial Balance'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _initialBalanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _buildInputDecoration(
                    'Enter the starting balance (e.g., 1000.50)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an initial balance';
                    }
                    final balance = double.tryParse(value);
                    if (balance == null) {
                      return 'Please enter a valid number';
                    }
                    if (balance < 0) {
                      return 'Balance cannot be negative';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Verify Button
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
                    child: const Text(
                      'Verify',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
