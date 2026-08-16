import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/categories/domain/category.dart';
import 'package:my_wallet/features/categories/presentation/model/category_view_data.dart';
import 'package:my_wallet/features/categories/presentation/widgets/hierarchical_category_picker.dart';

void main() {
  testWidgets('can hide child categories without changing the default picker', (
    tester,
  ) async {
    final now = DateTime(2026);
    final categories = [
      CategoryViewData(
        id: 'parent',
        name: 'Parent',
        type: CategoryType.expense,
        icon: Icons.category,
        color: Colors.blue,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryViewData(
        id: 'child',
        name: 'Child',
        type: CategoryType.expense,
        icon: Icons.category,
        color: Colors.blue,
        parentCategoryId: 'parent',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HierarchicalCategoryPicker(
            categories: categories,
            selectedCategoryId: null,
            showTrigger: false,
            showChildren: false,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Parent'), findsOneWidget);
    expect(find.text('Child'), findsNothing);

    await tester.tap(find.text('Parent'));
    await tester.pumpAndSettle();

    expect(find.text('Child'), findsNothing);
  });
}
