import 'package:flutter/material.dart';

Future<DateTime?> showMonthPickerBottomSheet({
  required BuildContext context,
  required DateTime initialMonth,
  DateTime? firstMonth,
  DateTime? lastMonth,
}) {
  final first = firstMonth ?? DateTime(2000);
  final last = lastMonth ?? DateTime(2100, 12);
  final now = DateTime.now();
  final currentMonth = DateTime(now.year, now.month);
  var displayedYear = initialMonth.year;

  return showModalBottomSheet<DateTime>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final colors = Theme.of(context).colorScheme;
        const monthLabels = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        final canSelectCurrentMonth =
            !currentMonth.isBefore(DateTime(first.year, first.month)) &&
            !currentMonth.isAfter(DateTime(last.year, last.month));

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Select month',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: displayedYear > first.year
                          ? () => setState(() => displayedYear--)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      '$displayedYear',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: displayedYear < last.year
                          ? () => setState(() => displayedYear++)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final month = index + 1;
                    final value = DateTime(displayedYear, month);
                    final isSelected =
                        displayedYear == initialMonth.year &&
                        month == initialMonth.month;
                    final isEnabled =
                        !value.isBefore(DateTime(first.year, first.month)) &&
                        !value.isAfter(DateTime(last.year, last.month));

                    return InkWell(
                      onTap: isEnabled
                          ? () => Navigator.pop(context, value)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary
                              : colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          monthLabels[index],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: !isEnabled
                                ? colors.onSurface.withValues(alpha: 0.35)
                                : isSelected
                                ? colors.onPrimary
                                : colors.onSurface,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: canSelectCurrentMonth
                        ? () => Navigator.pop(context, currentMonth)
                        : null,
                    icon: const Icon(Icons.today_outlined, size: 18),
                    label: const Text('Current month'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
