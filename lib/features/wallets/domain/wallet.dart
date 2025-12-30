class Wallet {
  final String id;
  final String name;
  final int balance;
  final int iconCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  Wallet({
    required this.id,
    required this.name,
    required this.balance,
    required this.iconCode,
    required this.createdAt,
    required this.updatedAt,
  });
}
