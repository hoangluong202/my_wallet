import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/categories/domain/category.dart';
import 'package:my_wallet/features/categories/presentation/list/category_tree_card.dart';
import 'package:my_wallet/features/categories/presentation/model/category_view_data.dart';

void main() {
  testWidgets('supports inline edit and swipe-left delete actions', (
    tester,
  ) async {
    final now = DateTime(2026);
    final category = CategoryViewData(
      id: 'food',
      name: 'Food',
      type: CategoryType.expense,
      icon: Icons.restaurant,
      color: Colors.orange,
      createdAt: now,
      updatedAt: now,
    );
    CategoryViewData? edited;
    CategoryViewData? deleted;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryTreeCard(
            parent: category,
            children: const [],
            onEdit: (value) => edited = value,
            onDelete: (value) async => deleted = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edit'), warnIfMissed: false);
    expect(edited, isNull);

    final categoryLeftBeforeSwipe = tester.getTopLeft(find.text(category.name));
    await tester.drag(find.text(category.name), const Offset(-200, 0));
    await tester.pumpAndSettle();
    final categoryLeftAfterSwipe = tester.getTopLeft(find.text(category.name));

    expect(categoryLeftAfterSwipe.dx, categoryLeftBeforeSwipe.dx);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(edited?.id, category.id);

    await tester.drag(find.text(category.name), const Offset(-200, 0));
    await tester.pumpAndSettle();

    expect(find.text('Delete'), findsOneWidget);
    expect(deleted, isNull);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(deleted?.id, category.id);
  });
}
