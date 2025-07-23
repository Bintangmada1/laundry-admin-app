import 'package:hive/hive.dart';

part 'service.g.dart';

@HiveType(typeId: 3)
class LaundryService extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double pricePerKg;

  @HiveField(3)
  String description;

  @HiveField(4)
  bool isActive;

  @HiveField(5)
  DateTime createdAt;

  LaundryService({
    required this.id,
    required this.name,
    required this.pricePerKg,
    required this.description,
    this.isActive = true,
    required this.createdAt,
  });

  LaundryService copyWith({
    String? id,
    String? name,
    double? pricePerKg,
    String? description,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return LaundryService(
      id: id ?? this.id,
      name: name ?? this.name,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
