import 'package:flutter/material.dart';
import '../../../../core/widgets/page_header.dart';

class TransactionsHeader extends StatelessWidget {
  const TransactionsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageHeader(
      title: 'Transactions',
      subtitle: 'Track your spending',
      icon: Icons.receipt_long_outlined,
    );
  }
}
