import 'package:flutter/material.dart';
import '../../domain/category.dart';

class CategoryIconData {
  final IconData icon;
  final Color color;

  const CategoryIconData({required this.icon, required this.color});
}

class CategoryIcons {
  static const List<CategoryIconData> expenseIcons = [
    // --- Ⅰ. GIAO LƯU & MỐI QUAN HỆ ---
    CategoryIconData(
      icon: Icons.people_outline, // Giao lưu & Bạn bè
      color: Color(0xFF009688), // Teal
    ),
    CategoryIconData(
      icon: Icons.card_giftcard, // Quà biếu
      color: Color(0xFFE91E63), // Pink
    ),
    CategoryIconData(
      icon: Icons.celebration, // Lì xì
      color: Color(0xFFFF5722), // Deep Orange
    ),
    CategoryIconData(
      icon:
          Icons.volunteer_activism, // Biếu bố mẹ (Biểu tượng trái tim trên tay)
      color: Color(0xFFF44336), // Red
    ),
    CategoryIconData(
      icon: Icons.holiday_village, // Về quê
      color: Color(0xFF4CAF50), // Green
    ),
    CategoryIconData(
      icon: Icons.groups, // Quỹ công ty
      color: Color(0xFF3F51B5), // Indigo
    ),

    // --- Ⅱ. PHÁT TRIỂN BẢN THÂN ---
    CategoryIconData(
      icon: Icons.psychology, // Học tập & Kỹ năng
      color: Color(0xFF9C27B0), // Purple
    ),
    CategoryIconData(
      icon: Icons.fitness_center, // Phòng gym
      color: Color(0xFF607D8B), // Blue Grey
    ),
    CategoryIconData(
      icon: Icons
          .sports_tennis, // Cầu lông (Icon vợt tennis/cầu lông gần giống nhau)
      color: Color(0xFF8BC34A), // Light Green
    ),
    CategoryIconData(
      icon: Icons.smart_toy, // Copilot (Icon AI / Robot)
      color: Color(0xFF00BCD4), // Cyan
    ),

    // --- Ⅲ. CHI PHÍ THIẾT YẾU ---
    CategoryIconData(
      icon: Icons.assignment_turned_in, // Khoản chi thiết yếu (Danh mục tổng)
      color: Color(0xFF4CAF50), // Green
    ),
    CategoryIconData(
      icon: Icons.signal_cellular_alt, // Internet & Data
      color: Color(0xFF03A9F4), // Light Blue
    ),
    CategoryIconData(
      icon: Icons.medical_services, // Y tế & Sức khỏe
      color: Color(0xFFF44336), // Red
    ),
    CategoryIconData(
      icon: Icons.home, // Tiền nhà & Điện nước
      color: Color(0xFF3F51B5), // Indigo
    ),
    CategoryIconData(
      icon: Icons.local_gas_station, // Xăng xe
      color: Color(0xFF607D8B), // Blue Grey
    ),
    CategoryIconData(
      icon: Icons.shopping_cart, // Đi chợ / Siêu thị
      color: Color(0xFFFF9800), // Orange
    ),
    CategoryIconData(
      icon: Icons.restaurant, // Ăn ngoài
      color: Color(0xFFFF5722), // Deep Orange
    ),
    CategoryIconData(
      icon: Icons.directions_car, // Xe công nghệ (GrabCar, Xanh SM...)
      color: Color(0xFF2196F3), // Blue
    ),

    // --- Ⅳ. SINH HOẠT CÁ NHÂN ---
    CategoryIconData(
      icon: Icons.person, // Chi tiêu cá nhân (Danh mục tổng)
      color: Color(0xFF009688), // Teal
    ),
    CategoryIconData(
      icon: Icons.clean_hands, // Đồ dùng sinh hoạt (Dầu gội, xà bông...)
      color: Color(0xFF00BCD4), // Cyan
    ),
    CategoryIconData(
      icon: Icons.checkroom, // Mua sắm (Quần áo...)
      color: Color(0xFF9C27B0), // Purple
    ),
    CategoryIconData(
      icon: Icons.content_cut, // Chăm sóc ngoại hình (Cắt tóc...)
      color: Color(0xFFE91E63), // Pink
    ),

    // --- Ⅴ. VUI CHƠI & GIẢI TRÍ ---
    CategoryIconData(
      icon: Icons.theater_comedy, // Giải trí & Vui chơi (Danh mục tổng)
      color: Color(0xFFE91E63), // Pink
    ),
    CategoryIconData(
      icon: Icons.games, // Bida (Icon các nút bấm/trò chơi tròn trịa)
      color: Color(0xFF795548), // Brown
    ),
    CategoryIconData(
      icon: Icons.local_cafe, // Cà phê & Hẹn hò
      color: Color(0xFF795548), // Brown
    ),
    CategoryIconData(
      icon: Icons.sports_soccer, // Bóng đá
      color: Color(0xFF4CAF50), // Green
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
