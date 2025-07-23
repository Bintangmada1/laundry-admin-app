import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 1)
class Customer extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phoneNumber;

  @HiveField(3)
  String address;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? lastOrderDate;

  @HiveField(6)
  int totalOrders;

  Customer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.createdAt,
    this.lastOrderDate,
    this.totalOrders = 0,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? address,
    DateTime? createdAt,
    DateTime? lastOrderDate,
    int? totalOrders,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      totalOrders: totalOrders ?? this.totalOrders,
    );
  }
}
