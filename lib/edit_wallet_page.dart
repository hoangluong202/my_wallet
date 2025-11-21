import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'notification_widget.dart';

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
      final walletData = {
        'name': _walletNameController.text,
        'balance': int.parse(
          _balanceController.text.replaceAll('.', ''),
        ).toDouble(),
        'icon': _selectedIcon,
        'iconColor': _selectedIconColor,
      };

      debugPrint('Wallet updated: $walletData');

      SuccessNotification.show(
        context: context,
        message: 'Changes saved successfully!',
        duration: const Duration(seconds: 2),
      );

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          Navigator.pop(context, true);
        }
      });
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Text(
            'Edit Wallet',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Select Wallet Icon'),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _selectedIconColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _selectedIcon,
                                size: 32,
                                color: _selectedIconColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _walletIcons
                                    .map(
                                      (iconData) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 6),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedIcon =
                                                  iconData['icon'];
                                              _selectedIconColor =
                                                  iconData['color'];
                                            });
                                          },
                                          child: Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              color: _selectedIcon ==
                                                          iconData['icon'] &&
                                                      _selectedIconColor ==
                                                          iconData['color']
                                                  ? iconData['color']
                                                      .withOpacity(0.25)
                                                  : Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: _selectedIcon ==
                                                            iconData['icon'] &&
                                                        _selectedIconColor ==
                                                            iconData['color']
                                                    ? iconData['color']
                                                    : Colors.transparent,
                                                width: 2,
                                              ),
                                            ),
                                            child: Icon(
                                              iconData['icon'],
                                              size: 20,
                                              color: iconData['color'],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
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
              ),
            ),
            // Fixed Save Button at bottom
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submitForm,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
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
