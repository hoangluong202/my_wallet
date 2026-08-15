import 'package:flutter/material.dart';
import 'form_section_label.dart';

class FormCardSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const FormCardSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionLabel(title: title, icon: icon),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
