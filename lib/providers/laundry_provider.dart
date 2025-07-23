import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/laundry_order.dart';
import '../models/customer.dart';
import '../models/service.dart';
import '../services/database_service.dart';

class LaundryProvider extends ChangeNotifier {
  List<LaundryOrder> _orders = [];
  List<Customer> _customers = [];
  List<LaundryService> _services = [];

  LaundryProvider() {
    _loadData();
  }

  // Getters
  List<LaundryOrder> get orders => _orders;
  List<Customer> get customers => _customers;
  List<LaundryService> get services => _services;

  int get totalOrders => _orders.length;
  double get totalRevenue => _orders.fold(0, (sum, order) => sum + order.price);
  
  int get todayOrders => _orders
      .where((order) => 
          order.createdAt.day == DateTime.now().day &&
          order.createdAt.month == DateTime.now().month &&
          order.createdAt.year == DateTime.now().year)
      .length;

  double get todayRevenue => _orders
      .where((order) => 
          order.createdAt.day == DateTime.now().day &&
          order.createdAt.month == DateTime.now().month &&
          order.createdAt.year == DateTime.now().year)
      .fold(0, (sum, order) => sum + order.price);

  int get totalCustomers => _customers.length;

  // Load data from Hive
  void _loadData() {
    _orders = DatabaseService.getAllOrders();
    _customers = DatabaseService.getAllCustomers();
    _services = DatabaseService.getAllServices();
    notifyListeners();
  }

  // Orders
  Future<void> addOrder(LaundryOrder order) async {
    await DatabaseService.saveOrder(order);
    
    // Update customer info
    final customer = _customers.firstWhere(
      (c) => c.id == order.customerId,
      orElse: () => null as Customer,
    );
    
    if (customer != null) {
      customer.totalOrders++;
      customer.lastOrderDate = order.createdAt;
      await DatabaseService.saveCustomer(customer);
    }
    
    _loadData();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final order = DatabaseService.getOrder(orderId);
    if (order != null) {
      final updatedOrder = order.copyWith(
        status: newStatus,
        completedDate: newStatus == OrderStatus.selesai ? DateTime.now() : null,
      );
      await DatabaseService.saveOrder(updatedOrder);
      _loadData();
    }
  }

  Future<void> markLabelPrinted(String orderId) async {
    final order = DatabaseService.getOrder(orderId);
    if (order != null) {
      final updatedOrder = order.copyWith(labelPrinted: true);
      await DatabaseService.saveOrder(updatedOrder);
      _loadData();
    }
  }

  Future<void> deleteOrder(String orderId) async {
    final order = DatabaseService.getOrder(orderId);
    if (order != null) {
      // Update customer order count
      final customer = _customers.firstWhere(
        (c) => c.id == order.customerId,
        orElse: () => null as Customer,
      );
      
      if (customer != null && customer.totalOrders > 0) {
        customer.totalOrders--;
        await DatabaseService.saveCustomer(customer);
      }
      
      await DatabaseService.deleteOrder(orderId);
      _loadData();
    }
  }

  String generateOrderId() {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final todayOrders = _orders.where((order) => 
      order.createdAt.day == now.day &&
      order.createdAt.month == now.month &&
      order.createdAt.year == now.year
    ).length;
    
    return 'LD$dateStr${(todayOrders + 1).toString().padLeft(3, '0')}';
  }

  // Customers
  Future<void> addCustomer(Customer customer) async {
    await DatabaseService.saveCustomer(customer);
    _loadData();
  }

  Future<void> updateCustomer(Customer customer) async {
    await DatabaseService.saveCustomer(customer);
    _loadData();
  }

  Future<void> deleteCustomer(String customerId) async {
    // Delete all orders for this customer first
    final customerOrders = _orders.where((order) => order.customerId == customerId).toList();
    for (final order in customerOrders) {
      await DatabaseService.deleteOrder(order.id);
    }
    
    await DatabaseService.deleteCustomer(customerId);
    _loadData();
  }

  Customer? getCustomerByPhone(String phoneNumber) {
    return _customers.firstWhere(
      (customer) => customer.phoneNumber == phoneNumber,
      orElse: () => null as Customer,
    );
  }

  // Services
  Future<void> addService(LaundryService service) async {
    await DatabaseService.saveService(service);
    _loadData();
  }

  Future<void> updateService(LaundryService service) async {
    await DatabaseService.saveService(service);
    _loadData();
  }

  Future<void> deleteService(String serviceId) async {
    await DatabaseService.deleteService(serviceId);
    _loadData();
  }

  LaundryService? getServiceByName(String serviceName) {
    return _services.firstWhere(
      (service) => service.name == serviceName,
      orElse: () => null as LaundryService,
    );
  }

  // Settings
  Future<void> saveSetting(String key, dynamic value) async {
    await DatabaseService.saveSetting(key, value);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    return DatabaseService.getSetting<T>(key, defaultValue: defaultValue);
  }

  // Backup
  Future<Map<String, dynamic>> exportData() async {
    return await DatabaseService.exportData();
  }
}
