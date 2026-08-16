import 'package:flutter/material.dart';

import '../model/category_view_data.dart';

class HierarchicalCategoryPicker extends StatefulWidget {
  const HierarchicalCategoryPicker({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
    this.emptyMessage = 'No categories available',
    this.showTrigger = true,
    this.leading,
    this.emptySelectionLabel = 'Select a category',
    this.clearSelectionLabel,
    this.onCleared,
    this.showChildren = true,
  });

  final List<CategoryViewData> categories;
  final String? selectedCategoryId;
  final ValueChanged<CategoryViewData> onSelected;
  final String emptyMessage;
  final bool showTrigger;
  final Widget? leading;
  final String emptySelectionLabel;
  final String? clearSelectionLabel;
  final VoidCallback? onCleared;
  final bool showChildren;

  @override
  State<HierarchicalCategoryPicker> createState() =>
      _HierarchicalCategoryPickerState();
}

class _HierarchicalCategoryPickerState
    extends State<HierarchicalCategoryPicker> {
  String? _expandedParentId;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _expandedParentId = _parentIdForSelection();
  }

  @override
  void didUpdateWidget(covariant HierarchicalCategoryPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategoryId != widget.selectedCategoryId ||
        oldWidget.categories != widget.categories) {
      _expandedParentId = _parentIdForSelection() ?? _expandedParentId;
    }
  }

  String? _parentIdForSelection() {
    for (final category in widget.categories) {
      if (category.id == widget.selectedCategoryId) {
        return category.parentCategoryId ?? category.id;
      }
    }
    return null;
  }

  void _toggleOpen() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isOpen = !_isOpen);
  }

  @override
  Widget build(BuildContext context) {
    final visibleCategories = widget.showChildren
        ? widget.categories
        : widget.categories
              .where((category) => category.parentCategoryId == null)
              .toList();

    if (visibleCategories.isEmpty && widget.clearSelectionLabel == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          widget.emptyMessage,
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    final parents = visibleCategories
        .where((category) => category.parentCategoryId == null)
        .toList();
    final parentIds = parents.map((category) => category.id).toSet();
    final rootOptions = [
      ...parents,
      ...visibleCategories.where(
        (category) =>
            category.parentCategoryId != null &&
            !parentIds.contains(category.parentCategoryId),
      ),
    ];
    final children = _expandedParentId == null
        ? <CategoryViewData>[]
        : visibleCategories
              .where(
                (category) => category.parentCategoryId == _expandedParentId,
              )
              .toList();
    final selectedCategory = visibleCategories
        .where((category) => category.id == widget.selectedCategoryId)
        .firstOrNull;

    final options = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (widget.clearSelectionLabel != null)
              _ClearCategoryButton(
                label: widget.clearSelectionLabel!,
                selected: widget.selectedCategoryId == null,
                onTap: () {
                  widget.onCleared?.call();
                  setState(() {
                    _expandedParentId = null;
                    _isOpen = false;
                  });
                },
              ),
            ...rootOptions.map((category) {
              final hasChildren = visibleCategories.any(
                (child) => child.parentCategoryId == category.id,
              );
              final isActive = _expandedParentId == category.id;
              final isSelected = widget.selectedCategoryId == category.id;
              return _CategoryButton(
                category: category,
                selected: isSelected,
                active: isActive,
                hasChildren: hasChildren,
                onTap: () {
                  setState(() {
                    _expandedParentId = hasChildren ? category.id : null;
                    if (!hasChildren) _isOpen = false;
                  });
                  if (!hasChildren) widget.onSelected(category);
                },
              );
            }),
          ],
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          reverseDuration: const Duration(milliseconds: 120),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: children.isEmpty
              ? const SizedBox.shrink(key: ValueKey('no-category-children'))
              : Container(
                  key: ValueKey(_expandedParentId),
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: children.map((category) {
                      return _CategoryButton(
                        category: category,
                        selected: widget.selectedCategoryId == category.id,
                        onTap: () {
                          widget.onSelected(category);
                          setState(() => _isOpen = false);
                        },
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );

    if (!widget.showTrigger) return options;

    return TapRegion(
      onTapOutside: (_) {
        if (_isOpen) setState(() => _isOpen = false);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.leading == null)
            _CategorySelectorButton(
              category: selectedCategory,
              emptyLabel: widget.emptySelectionLabel,
              isOpen: _isOpen,
              onTap: _toggleOpen,
            )
          else
            Row(
              children: [
                widget.leading!,
                const SizedBox(width: 12),
                Expanded(
                  child: _CategorySelectorButton(
                    category: selectedCategory,
                    emptyLabel: widget.emptySelectionLabel,
                    isOpen: _isOpen,
                    onTap: _toggleOpen,
                  ),
                ),
              ],
            ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: _isOpen
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: options,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CategorySelectorButton extends StatelessWidget {
  const _CategorySelectorButton({
    required this.category,
    required this.emptyLabel,
    required this.isOpen,
    required this.onTap,
  });

  final CategoryViewData? category;
  final String emptyLabel;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: category?.color.withValues(alpha: 0.08) ?? Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOpen
                    ? (category?.color ?? colors.primary)
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category?.icon ?? Icons.category_outlined,
                  size: 19,
                  color: category?.color ?? Colors.grey.shade500,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    category?.name ?? emptyLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: category == null
                          ? FontWeight.w500
                          : FontWeight.w600,
                      color: category?.color ?? Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.category,
    required this.selected,
    required this.onTap,
    this.active = false,
    this.hasChildren = false,
  });

  final CategoryViewData category;
  final bool selected;
  final bool active;
  final bool hasChildren;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final highlighted = selected || active;
    return Material(
      color: highlighted
          ? category.color.withValues(alpha: 0.12)
          : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: highlighted
                  ? category.color.withValues(alpha: 0.65)
                  : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(category.icon, size: 17, color: category.color),
              const SizedBox(width: 6),
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
                  color: highlighted ? category.color : Colors.grey.shade800,
                ),
              ),
              if (hasChildren) ...[
                const SizedBox(width: 4),
                Icon(
                  active ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 16,
                  color: highlighted ? category.color : Colors.grey.shade500,
                ),
              ] else if (selected) ...[
                const SizedBox(width: 5),
                Icon(Icons.check, size: 15, color: category.color),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ClearCategoryButton extends StatelessWidget {
  const _ClearCategoryButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? colors.primary.withValues(alpha: 0.1)
          : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? colors.primary : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_tree_outlined,
                size: 17,
                color: colors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? colors.primary : Colors.grey.shade800,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 5),
                Icon(Icons.check, size: 15, color: colors.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
