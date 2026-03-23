import 'package:flutter/material.dart';
import '../model/category_view_data.dart';
import 'category_type_badge.dart';

class CategoryDetailHeader extends StatelessWidget {
  final CategoryViewData category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CategoryDetailHeader({
    super.key,
    required this.category,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            category.color.withOpacity(0.25),
            category.color.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: category.color.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: category.color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _BackButton(),
              const SizedBox(width: 14),
              _CategoryIcon(category: category),
              const SizedBox(width: 14),
              Expanded(child: _CategoryInfo(category: category)),
              // Action buttons (edit / delete) on the right in header
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(width: 12),
                Row(
                  children: [
                    if (onEdit != null)
                      _HeaderActionButton(
                        icon: Icons.edit,
                        color: Colors.blueGrey.shade800,
                        onTap: onEdit!,
                        tooltip: 'Edit',
                      ),
                    if (onDelete != null) const SizedBox(width: 8),
                    if (onDelete != null)
                      _HeaderActionButton(
                        icon: Icons.delete_outline,
                        color: Colors.red.shade600,
                        onTap: onDelete!,
                        tooltip: 'Delete',
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? tooltip;

  const _HeaderActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final CategoryViewData category;

  const _CategoryIcon({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            category.color.withOpacity(0.25),
            category.color.withOpacity(0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: category.color.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: category.color.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(category.icon, color: category.color, size: 28),
    );
  }
}

class _CategoryInfo extends StatelessWidget {
  final CategoryViewData category;

  const _CategoryInfo({required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          category.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: 0.3,
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
