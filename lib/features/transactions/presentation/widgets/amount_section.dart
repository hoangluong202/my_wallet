import 'package:flutter/material.dart';
import '../../../../core/utils/thousand_separator_input_formatter.dart';

class AmountSection extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const AmountSection({super.key, required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: false,
      keyboardType: TextInputType.number,
      inputFormatters: [ThousandSeparatorInputFormatter()],
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: '0',
        hintStyle: TextStyle(fontSize: 24, color: Colors.grey.shade300),
        suffixText: ' ₫',
        suffixStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        final amount = int.tryParse(value.replaceAll('.', '')) ?? 0;

        if (amount <= 0) {
          return 'Amount must be greater than 0';
        }
        return null;
      },
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      onChanged: onChanged,
    );
  }
}
