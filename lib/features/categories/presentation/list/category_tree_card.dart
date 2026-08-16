import 'package:flutter/material.dart';

import '../model/category_view_data.dart';

class CategoryTreeCard extends StatelessWidget {
  const CategoryTreeCard({
    super.key,
    required this.parent,
    required this.children,
    required this.onTap,
  });

  final CategoryViewData parent;
  final List<CategoryViewData> children;
  final ValueChanged<CategoryViewData> onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CategoryRow(
              category: parent,
              childCount: children.length,
              onTap: () => onTap(parent),
            ),
            if (children.isNotEmpty)
              Container(
                color: parent.color.withValues(alpha: 0.025),
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  children: children.indexed.map((entry) {
                    final (index, category) = entry;
                    return Column(
                      children: [
                        Divider(height: 1, color: Colors.grey.shade200),
                        _CategoryRow(
                          category: category,
                          isChild: true,
                          showGuide: index < children.length - 1,
                          onTap: () => onTap(category),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.onTap,
    this.childCount = 0,
    this.isChild = false,
    this.showGuide = false,
  });

  final CategoryViewData category;
  final VoidCallback onTap;
  final int childCount;
  final bool isChild;
  final bool showGuide;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(isChild ? 4 : 12, 9, 10, 9),
        child: Row(
          children: [
            if (isChild) _buildBranch(),
            Container(
              width: isChild ? 32 : 38,
              height: isChild ? 32 : 38,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(isChild ? 9 : 11),
              ),
              child: Icon(
                category.icon,
                size: isChild ? 17 : 20,
                color: category.color,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isChild ? 13 : 14,
                  fontWeight: isChild ? FontWeight.w500 : FontWeight.w700,
                ),
              ),
            ),
            if (childCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$childCount',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 19,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranch() {
    return SizedBox(
      width: 20,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Icon(
          showGuide ? Icons.subdirectory_arrow_right : Icons.turn_right_rounded,
          size: 15,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
