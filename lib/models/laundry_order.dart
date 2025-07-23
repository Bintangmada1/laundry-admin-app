import 'package:hive/hive.dart';

part 'laundry_order.g.dart';

@HiveType(typeId: 0)
class LaundryOrder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String customerId;

  @HiveField(2)
  String customerName;

  @HiveField(3)
  String phoneNumber;

  @HiveField(4)
  List<OrderItem> items;

  @HiveField(5)
  double totalPrice;

  @HiveField(6)
  OrderStatus status;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime? pickupDate;

  @HiveField(9)
  DateTime? completedDate;

  @HiveField(10)
  String? notes;

  @HiveField(11)
  bool receiptPrinted;

  @HiveField(12)
  OrderPriority priority;

  @HiveField(13)
  PaymentStatus paymentStatus;

  @HiveField(14)
  DateTime? estimatedCompletion;

  LaundryOrder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.phoneNumber,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.pickupDate,
    this.completedDate,
    this.notes,
    this.receiptPrinted = false,
    this.priority = OrderPriority.biasa,
    this.paymentStatus = PaymentStatus.belumBayar,
    this.estimatedCompletion,
  });

  LaundryOrder copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? phoneNumber,
    List<OrderItem>? items,
    double? totalPrice,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? pickupDate,
    DateTime? completedDate,
    String? notes,
    bool? receiptPrinted,
    OrderPriority? priority,
    PaymentStatus? paymentStatus,
    DateTime? estimatedCompletion,
  }) {
    return LaundryOrder(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      pickupDate: pickupDate ?? this.pickupDate,
      completedDate: completedDate ?? this.completedDate,
      notes: notes ?? this.notes,
      receiptPrinted: receiptPrinted ?? this.receiptPrinted,
      priority: priority ?? this.priority,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      estimatedCompletion: estimatedCompletion ?? this.estimatedCompletion,
    );
  }
}

@HiveType(typeId: 4)
class OrderItem extends HiveObject {
  @HiveField(0)
  String serviceName;

  @HiveField(1)
  double weight;

  @HiveField(2)
  double pricePerKg;

  @HiveField(3)
  double subtotal;

  OrderItem({
    required this.serviceName,
    required this.weight,
    required this.pricePerKg,
    required this.subtotal,
  });

  OrderItem copyWith({
    String? serviceName,
    double? weight,
    double? pricePerKg,
    double? subtotal,
  }) {
    return OrderItem(
      serviceName: serviceName ?? this.serviceName,
      weight: weight ?? this.weight,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}

@HiveType(typeId: 2)
enum OrderStatus {
  @HiveField(0)
  menunggu,
  @HiveField(1)
  dicuci,
  @HiveField(2)
  selesai,
  @HiveField(3)
  diambil,
}

@HiveType(typeId: 5)
enum OrderPriority {
  @HiveField(0)
  biasa,
  @HiveField(1)
  express,
}

@HiveType(typeId: 6)
enum PaymentStatus {
  @HiveField(0)
  belumBayar,
  @HiveField(1)
  lunas,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.menunggu:
        return 'Menunggu';
      case OrderStatus.dicuci:
        return 'Dicuci';
      case OrderStatus.selesai:
        return 'Selesai';
      case OrderStatus.diambil:
        return 'Diambil';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.menunggu:
        return Colors.blue;
      case OrderStatus.dicuci:
        return Colors.orange;
      case OrderStatus.selesai:
        return Colors.green;
      case OrderStatus.diambil:
        return Colors.grey;
    }
  }
}

extension OrderPriorityExtension on OrderPriority {
  String get displayName {
    switch (this) {
      case OrderPriority.biasa:
        return 'Biasa';
      case OrderPriority.express:
        return 'Express';
    }
  }

  Color get color {
    switch (this) {
      case OrderPriority.biasa:
        return Colors.blue;
      case OrderPriority.express:
        return Colors.red;
    }
  }
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.belumBayar:
        return 'Belum Bayar';
      case PaymentStatus.lunas:
        return 'Lunas';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.belumBayar:
        return Colors.red;
      case PaymentStatus.lunas:
        return Colors.green;
    }
  }
}
