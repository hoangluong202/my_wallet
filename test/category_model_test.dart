import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/categories/data/models/category_model.dart';
import 'package:my_wallet/features/categories/domain/category.dart';

void main() {
  test('toCompanion explicitly clears a removed parent category', () {
    final now = DateTime(2026);
    final category = Category(
      id: 'child',
      name: 'Child category',
      type: CategoryType.expense,
      iconCode: 1,
      parentCategoryId: null,
      createdAt: now,
      updatedAt: now,
    );

    final companion = CategoryModel.toCompanion(category);

    expect(companion.parentCategoryId.present, isTrue);
    expect(companion.parentCategoryId.value, isNull);
  });
}
