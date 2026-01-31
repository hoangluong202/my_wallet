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

  Wallet copyWith({
    String? id,
    String? name,
    int? balance,
    int? iconCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      iconCode: iconCode ?? this.iconCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
