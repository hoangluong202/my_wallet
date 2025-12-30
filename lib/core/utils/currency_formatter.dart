class CurrencyFormatter {
  static String formatVND(int amount) {
    final s = amount.toString();
    final re = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(re, (m) => '.');
  }

  static String formatVNDWithSymbol(int amount) {
    return '${formatVND(amount)} đ';
  }
}
