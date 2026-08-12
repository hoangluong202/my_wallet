part of 'budget_form.dart';

class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.month,
    required this.onPrevious,
    required this.onNext,
    required this.onTap,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _FormCard(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    child: Row(
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  Text(
                    MaterialLocalizations.of(context).formatMonthYear(month),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormatter.formatDate(month)} - '
                    '${DateFormatter.formatDate(DateTime(month.year, month.month + 1, 0))}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    ),
  );
}

class _DateRangeCard extends StatelessWidget {
  const _DateRangeCard({
    required this.startDate,
    required this.endDate,
    required this.onStartDateTap,
    required this.onEndDateTap,
  });

  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;

  @override
  Widget build(BuildContext context) => _FormCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CardLabel(Icons.date_range_outlined, 'Date Range'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DateField(
                label: 'Start',
                date: startDate,
                onTap: onStartDateTap,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.arrow_forward,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ),
            Expanded(
              child: _DateField(
                label: 'End',
                date: endDate,
                onTap: onEndDateTap,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
