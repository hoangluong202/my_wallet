import 'package:flutter/material.dart';
import '../../domain/category.dart';

class CategoryIconData {
  final IconData icon;
  final Color color;

  const CategoryIconData({required this.icon, required this.color});
}

class CategoryIcons {
  static const List<CategoryIconData> expenseIcons = [
    // Ăn uống
    CategoryIconData(
      icon: Icons.restaurant,
      color: Color(0xFFFF5722), // Deep Orange
    ),
    CategoryIconData(
      icon: Icons.fastfood,
      color: Color(0xFFFF6F00), // Dark Orange
    ),
    CategoryIconData(
      icon: Icons.local_cafe,
      color: Color(0xFF795548), // Brown
    ),
    // Di chuyển
    CategoryIconData(
      icon: Icons.directions_car,
      color: Color(0xFF3F51B5), // Indigo
    ),
    CategoryIconData(
      icon: Icons.local_gas_station,
      color: Color(0xFF607D8B), // Blue Grey
    ),
    CategoryIconData(
      icon: Icons.directions_bus,
      color: Color(0xFF2196F3), // Blue
    ),
    // Nhà ở & Sinh hoạt
    CategoryIconData(
      icon: Icons.home,
      color: Color(0xFF4CAF50), // Green
    ),
    CategoryIconData(
      icon: Icons.electrical_services,
      color: Color(0xFFFFC107), // Amber
    ),
    CategoryIconData(
      icon: Icons.water_drop,
      color: Color(0xFF03A9F4), // Light Blue
    ),
    CategoryIconData(
      icon: Icons.wifi,
      color: Color(0xFF00BCD4), // Cyan
    ),
    // Mua sắm
    CategoryIconData(
      icon: Icons.shopping_cart,
      color: Color(0xFFE91E63), // Pink
    ),
    CategoryIconData(
      icon: Icons.checkroom,
      color: Color(0xFF9C27B0), // Purple
    ),
    CategoryIconData(
      icon: Icons.shopping_bag,
      color: Color(0xFFFF9800), // Orange
    ),
    // Giải trí & Thư giãn
    CategoryIconData(
      icon: Icons.movie,
      color: Color(0xFFE91E63), // Pink
    ),
    CategoryIconData(
      icon: Icons.sports_soccer,
      color: Color(0xFF4CAF50), // Green
    ),
    CategoryIconData(
      icon: Icons.music_note,
      color: Color(0xFF9C27B0), // Purple
    ),
    // Sức khỏe & Làm đẹp
    CategoryIconData(
      icon: Icons.medical_services,
      color: Color(0xFFF44336), // Red
    ),
    CategoryIconData(
      icon: Icons.face,
      color: Color(0xFFE91E63), // Pink
    ),
    // Giáo dục & Phát triển
    CategoryIconData(
      icon: Icons.school,
      color: Color(0xFF2196F3), // Blue
    ),
    CategoryIconData(
      icon: Icons.menu_book,
      color: Color(0xFF8BC34A), // Light Green
    ),
  ];

  static const List<CategoryIconData> incomeIcons = [
    // Lương & Thu nhập từ công việc
    CategoryIconData(
      icon: Icons.work,
      color: Color(0xFF4CAF50), // Green
    ),
    // Kinh doanh & Bán hàng
    CategoryIconData(
      icon: Icons.business_center,
      color: Color(0xFF2196F3), // Blue
    ),
    // Đầu tư & Lợi nhuận
    CategoryIconData(
      icon: Icons.trending_up,
      color: Color(0xFF8BC34A), // Light Green
    ),
    // Thưởng & Quà tặng
    CategoryIconData(
      icon: Icons.card_giftcard,
      color: Color(0xFFFF9800), // Orange
    ),
    // Thu nhập khác
    CategoryIconData(
      icon: Icons.monetization_on,
      color: Color(0xFFFFEB3B), // Yellow
    ),
  ];

  static const List<CategoryIconData> debtIcons = [
    // Vay ngân hàng
    CategoryIconData(
      icon: Icons.account_balance,
      color: Color(0xFFFF9800), // Orange
    ),
    // Vay bạn bè/người thân
    CategoryIconData(
      icon: Icons.people,
      color: Color(0xFFFF5722), // Deep Orange
    ),
    // Thẻ tín dụng
    CategoryIconData(
      icon: Icons.credit_card,
      color: Color(0xFFF44336), // Red
    ),
    // Trả góp
    CategoryIconData(
      icon: Icons.payment,
      color: Color(0xFFE91E63), // Pink
    ),
    // Nợ khác
    CategoryIconData(
      icon: Icons.request_quote,
      color: Color(0xFFFF6F00), // Dark Orange
    ),
  ];

  static const List<CategoryIconData> loanIcons = [
    // Cho vay cá nhân
    CategoryIconData(
      icon: Icons.person_add,
      color: Color(0xFF9C27B0), // Purple
    ),
    // Cho vay có lãi
    CategoryIconData(
      icon: Icons.account_balance_wallet,
      color: Color(0xFF673AB7), // Deep Purple
    ),
    // Ứng tiền
    CategoryIconData(
      icon: Icons.monetization_on,
      color: Color(0xFF7E57C2), // Medium Purple
    ),
    // Đầu tư cho người khác
    CategoryIconData(
      icon: Icons.handshake,
      color: Color(0xFFBA68C8), // Light Purple
    ),
    // Cho vay khác
    CategoryIconData(
      icon: Icons.attach_money,
      color: Color(0xFF8E24AA), // Purple Accent
    ),
  ];

  static List<CategoryIconData> get allIcons => [
    ...expenseIcons,
    ...incomeIcons,
    ...debtIcons,
    ...loanIcons,
  ];

  static CategoryIconData getIconByCodePoint(int codePoint) {
    final index = allIcons.indexWhere(
      (iconData) => iconData.icon.codePoint == codePoint,
    );
    return index != -1
        ? allIcons[index]
        : CategoryIconData(
            icon: Icons.error_outline,
            color: Color(0xFF9E9E9E), // Gray
          );
  }

  static List<CategoryIconData> getIconsByType(CategoryType type) {
    switch (type) {
      case CategoryType.expense:
        return expenseIcons;
      case CategoryType.income:
        return incomeIcons;
      case CategoryType.debt:
        return debtIcons;
      case CategoryType.loan:
        return loanIcons;
    }
  }
}

class CategoryTypeIcons {
  static const Map<CategoryType, CategoryIconData> typeIcons = {
    CategoryType.expense: CategoryIconData(
      icon: Icons.arrow_circle_down,
      color: Colors.red,
    ),
    CategoryType.income: CategoryIconData(
      icon: Icons.arrow_circle_up,
      color: Colors.green,
    ),
    CategoryType.debt: CategoryIconData(
      icon: Icons.money_off,
      color: Colors.orange,
    ),
    CategoryType.loan: CategoryIconData(
      icon: Icons.attach_money,
      color: Colors.purple,
    ),
  };

  static CategoryIconData getIconByType(CategoryType type) {
    return typeIcons[type]!;
  }
}
