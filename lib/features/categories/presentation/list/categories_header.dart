import 'package:flutter/material.dart';
import '../../../../core/widgets/page_header.dart';

class CategoriesHeader extends StatelessWidget {
  const CategoriesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageHeader(
      title: 'Categories',
      subtitle: 'Manage your categories',
      icon: Icons.category_outlined,
    );
  }
}
