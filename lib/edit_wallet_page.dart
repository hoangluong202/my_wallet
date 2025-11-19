import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditWalletPage extends StatefulWidget {
  final String walletName;
  final double balance;
  final String currency;
  final IconData? icon;
  final Color? iconColor;

  const EditWalletPage({
    super.key,
    required this.walletName,
    required this.balance,
    required this.currency,
    this.icon,
    this.iconColor,
  });

  @override
  State<EditWalletPage> createState() => _EditWalletPageState();
}

class _EditWalletPageState extends State<EditWalletPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late TextEditingController _walletNameController;
  late TextEditingController _balanceController;

  // Selected icon and color
  late IconData _selectedIcon;
  late Color _selectedIconColor;

  // Available wallet icons
  final List<Map<String, dynamic>> _walletIcons = [
    {'icon': Icons.account_balance, 'color': Colors.blue, 'label': 'Bank'},
    {
      'icon': Icons.account_balance_wallet,
      'color': Colors.indigo,
      'label': 'Wallet',
    },
    {'icon': Icons.savings, 'color': Colors.green, 'label': 'Savings'},
    {'icon': Icons.mobile_friendly, 'color': Colors.pink, 'label': 'Mobile'},
    {'icon': Icons.currency_bitcoin, 'color': Colors.orange, 'label': 'Crypto'},
    {'icon': Icons.attach_money, 'color': Colors.amber, 'label': 'Cash'},
    {'icon': Icons.credit_card, 'color': Colors.purple, 'label': 'Card'},
    {'icon': Icons.card_giftcard, 'color': Colors.red, 'label': 'Gift'},
  ];

  @override
  void initState() {
    super.initState();
    _walletNameController = TextEditingController(text: widget.walletName);
    _balanceController = TextEditingController(
      text: _formatVND(widget.balance.toInt()),
    );
    _selectedIcon = widget.icon ?? Icons.account_balance_wallet;
    _selectedIconColor = widget.iconColor ?? Colors.blue;
  }

  @override
  void dispose() {
    _walletNameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid
      final walletData = {
        'name': _walletNameController.text,
        'balance': int.parse(
          _balanceController.text.replaceAll('.', ''),
        ).toDouble(),
        'icon': _selectedIcon,
        'iconColor': _selectedIconColor,
      };

      debugPrint('Wallet updated: $walletData');

      // Pop back to previous page immediately
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Wallet'),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Select Wallet Icon'),
                      const SizedBox(height: 12),
                      // Icon preview and selector (aligned with Add Wallet)
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: _selectedIconColor.withOpacity(
                              0.2,
                            ),
                            child: Icon(
                              _selectedIcon,
                              size: 40,
                              color: _selectedIconColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 70,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _walletIcons.length,
                              itemBuilder: (context, index) {
                                final iconData = _walletIcons[index];
                                final isSelected =
                                    iconData['icon'] == _selectedIcon &&
                                    iconData['color'] == _selectedIconColor;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedIcon = iconData['icon'];
                                      _selectedIconColor = iconData['color'];
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      border: isSelected
                                          ? Border.all(
                                              color: _selectedIconColor,
                                              width: 2,
                                            )
                                          : Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1,
                                            ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: CircleAvatar(
                                      radius: 24,
                                      backgroundColor: iconData['color']
                                          .withOpacity(0.2),
                                      child: Icon(
                                        iconData['icon'],
                                        size: 22,
                                        color: iconData['color'],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 16),
                      // Current Balance
                      _buildSectionTitle('Current Balance'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _balanceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            final cleanValue = int.tryParse(value) ?? 0;
                            _balanceController.value = TextEditingValue(
                              text: _formatVND(cleanValue),
                              selection: TextSelection.collapsed(
                                offset: _formatVND(cleanValue).length,
                              ),
                            );
                          }
                        },
                        decoration: _buildInputDecoration(
                          '1.000.000',
                          suffixText: 'đ',
                          suffixStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a balance';
                          }
                          final cleanValue = int.tryParse(
                            value.replaceAll('.', ''),
                          );
                          if (cleanValue == null) {
                            return 'Please enter a valid integer';
                          }
                          if (cleanValue < 0) {
                            return 'Balance cannot be negative';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      // Quick suggestion buttons
                      _buildSectionTitle('Quick Add'),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildQuickAddButton(10000, '10.000'),
                            const SizedBox(width: 8),
                            _buildQuickAddButton(35000, '35.000'),
                            const SizedBox(width: 8),
                            _buildQuickAddButton(50000, '50.000'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Fixed Save Button at bottom
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
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

  InputDecoration _buildInputDecoration(
    String hintText, {
    String? suffixText,
    TextStyle? suffixStyle,
  }) {
    return InputDecoration(
      hintText: hintText,
      suffixText: suffixText,
      suffixStyle: suffixStyle,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  Widget _buildQuickAddButton(int amount, String displayText) {
    return GestureDetector(
      onTap: () {
        setState(() {
          int currentBalance =
              int.tryParse(_balanceController.text.replaceAll('.', '')) ?? 0;
          int newBalance = currentBalance + amount;
          _balanceController.text = _formatVND(newBalance);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.shade300, width: 1),
          borderRadius: BorderRadius.circular(8),
          color: Colors.blue.shade50,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 18,
              color: Colors.blue.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              displayText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatVND(int amount) {
    final s = amount.toString();
    final re = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(re, (m) => '.');
  }
}
