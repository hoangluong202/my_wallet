class CurrencyFormatter {
  static String formatVND(double amount) {
    final intAmount = amount.toInt();
    final s = intAmount.toString();
    final re = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(re, (m) => '.');
  }

  static String formatVNDWithSymbol(double amount) {
    return '${formatVND(amount)} đ';
  }
}
