import 'package:flutter/material.dart';

class CategoryNameField extends StatelessWidget {
  const CategoryNameField({
    super.key,
    required this.controller,
    required this.icon,
    required this.color,
    required this.typeLabel,
    required this.validator,
    required this.autofocus,
  });

  final TextEditingController controller;
  final IconData icon;
  final Color color;
  final String typeLabel;
  final FormFieldValidator<String> validator;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Name', style: Theme.of(context).textTheme.labelLarge),
            Text(
              typeLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          autofocus: autofocus,
          textCapitalization: TextCapitalization.sentences,
          validator: validator,
          decoration: InputDecoration(
            hintText: 'Category name',
            prefixIcon: Icon(icon, color: color),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: border,
            enabledBorder: border,
          ),
        ),
      ],
    );
  }
}
