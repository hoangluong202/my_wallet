import 'package:flutter/material.dart';

import '../model/category_view_data.dart';
import '../list/categories_viewmodel.dart';
import 'category_type_badge.dart';

class CategoryChildrenSection extends StatelessWidget {
  final CategoryViewData category;
  final CategoriesViewModel viewModel;
  final ValueChanged<String> onChildTap;

  const CategoryChildrenSection({
    super.key,
    required this.category,
    required this.viewModel,
    required this.onChildTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CategoryViewData>>(
      stream: viewModel.categoriesStream,
      builder: (context, snapshot) {
        final children = (snapshot.data ?? [])
            .where((c) => c.parentCategoryId == category.id)
            .toList();

        if (children.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Sub-Categories (${children.length})',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: children.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) => _ChildCategoryCard(
                category: children[index],
                onTap: () => onChildTap(children[index].id),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChildCategoryCard extends StatelessWidget {
  final CategoryViewData category;
  final VoidCallback onTap;

  const _ChildCategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              _ChildIcon(category: category),
              const SizedBox(width: 14),
              Expanded(child: _ChildInfo(category: category)),
              const SizedBox(width: 8),
              _ForwardArrow(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildIcon extends StatelessWidget {
  final CategoryViewData category;

  const _ChildIcon({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            category.color.withOpacity(0.15),
            category.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: category.color.withOpacity(0.3)),
      ),
      child: Icon(category.icon, color: category.color, size: 24),
    );
  }
}

class _ChildInfo extends StatelessWidget {
  final CategoryViewData category;

  const _ChildInfo({required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: 0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        CategoryTypeBadge(type: category.type, color: category.color),
      ],
    );
  }
}

class _ForwardArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.blue.shade600,
      ),
    );
  }
}
