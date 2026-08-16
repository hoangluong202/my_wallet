import 'package:flutter/material.dart';

import '../model/category_view_data.dart';

class CategoryTreeCard extends StatelessWidget {
  const CategoryTreeCard({
    super.key,
    required this.parent,
    required this.children,
    required this.onEdit,
    required this.onDelete,
  });

  final CategoryViewData parent;
  final List<CategoryViewData> children;
  final ValueChanged<CategoryViewData> onEdit;
  final Future<void> Function(CategoryViewData) onDelete;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final childBackgroundColor = Color.alphaBlend(
      parent.color.withValues(alpha: 0.025),
      surfaceColor,
    );

    return Material(
      color: surfaceColor,
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
              backgroundColor: surfaceColor,
              childCount: children.length,
              onEdit: () => onEdit(parent),
              onDelete: () => onDelete(parent),
            ),
            if (children.isNotEmpty)
              Container(
                color: childBackgroundColor,
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  children: children.indexed.map((entry) {
                    final (index, category) = entry;
                    return Column(
                      children: [
                        Divider(height: 1, color: Colors.grey.shade200),
                        _CategoryRow(
                          category: category,
                          backgroundColor: childBackgroundColor,
                          isChild: true,
                          showGuide: index < children.length - 1,
                          onEdit: () => onEdit(category),
                          onDelete: () => onDelete(category),
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
    required this.backgroundColor,
    required this.onEdit,
    required this.onDelete,
    this.childCount = 0,
    this.isChild = false,
    this.showGuide = false,
  });

  final CategoryViewData category;
  final Color backgroundColor;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;
  final int childCount;
  final bool isChild;
  final bool showGuide;

  @override
  Widget build(BuildContext context) {
    return _SwipeDeleteAction(
      key: ValueKey(category.id),
      backgroundColor: backgroundColor,
      onEdit: onEdit,
      onDelete: onDelete,
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
            const SizedBox(width: 8),
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

class _SwipeDeleteAction extends StatefulWidget {
  const _SwipeDeleteAction({
    super.key,
    required this.child,
    required this.backgroundColor,
    required this.onEdit,
    required this.onDelete,
  });

  final Widget child;
  final Color backgroundColor;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  @override
  State<_SwipeDeleteAction> createState() => _SwipeDeleteActionState();
}

class _SwipeDeleteActionState extends State<_SwipeDeleteAction> {
  static const _actionWidth = 144.0;
  double _offset = 0;
  bool _dragging = false;

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragging = true;
      _offset = (_offset + details.delta.dx).clamp(-_actionWidth, 0.0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final shouldOpen =
        _offset.abs() > _actionWidth / 2 || details.primaryVelocity! < -300;
    setState(() {
      _dragging = false;
      _offset = shouldOpen ? -_actionWidth : 0;
    });
  }

  void _close() {
    if (_offset == 0) return;
    setState(() {
      _dragging = false;
      _offset = 0;
    });
  }

  Future<void> _delete() async {
    _close();
    await widget.onDelete();
  }

  void _edit() {
    _close();
    widget.onEdit();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: _actionWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SwipeActionButton(
                          icon: Icons.edit_outlined,
                          label: 'Edit',
                          color: Colors.blue.shade600,
                          onTap: _edit,
                        ),
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                      Expanded(
                        child: _SwipeActionButton(
                          icon: Icons.delete_outline,
                          label: 'Delete',
                          color: Colors.red.shade500,
                          onTap: _delete,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: _dragging
                ? Duration.zero
                : const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            margin: EdgeInsets.only(right: -_offset),
            color: widget.backgroundColor,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
              onHorizontalDragUpdate: _handleDragUpdate,
              onHorizontalDragEnd: _handleDragEnd,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeActionButton extends StatelessWidget {
  const _SwipeActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
