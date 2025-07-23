import 'package:hive_flutter/hive_flutter.dart';
import '../models/laundry_order.dart';
import '../models/customer.dart';
import '../models/service.dart';

class DatabaseService {
  static const String ordersBoxName = 'orders';
  static const String customersBoxName = 'customers';
  static const String servicesBoxName = 'services';
  static const String settingsBoxName = 'settings';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(LaundryOrderAdapter());
    Hive.registerAdapter(CustomerAdapter());
    Hive.registerAdapter(LaundryServiceAdapter());
    Hive.registerAdapter(OrderStatusAdapter());
    Hive.registerAdapter(OrderItemAdapter());
    Hive.registerAdapter(OrderPriorityAdapter());
    Hive.registerAdapter(PaymentStatusAdapter());
    
    // Open boxes
    await Hive.openBox<LaundryOrder>(ordersBoxName);
    await Hive.openBox<Customer>(customersBoxName);
    await Hive.openBox<LaundryService>(servicesBoxName);
    await Hive.openBox(settingsBoxName);
    
    // Initialize default services if empty
    await _initializeDefaultServices();
  }

  static Future<void> _initializeDefaultServices() async {
    final servicesBox = Hive.box<LaundryService>(servicesBoxName);
    
    if (servicesBox.isEmpty) {
      final defaultServices = [
        LaundryService(
          id: '1',
          name: 'Cuci Setrika',
          pricePerKg: 10000,
          description: 'Cuci bersih dan setrika rapi',
          createdAt: DateTime.now(),
        ),
        LaundryService(
          id: '2',
          name: 'Cuci Kering',
          pricePerKg: 8000,
          description: 'Cuci bersih tanpa setrika',
          createdAt: DateTime.now(),
        ),
        LaundryService(
          id: '3',
          name: 'Dry Cleaning',
          pricePerKg: 15000,
          description: 'Pembersihan khusus untuk pakaian premium',
          createdAt: DateTime.now(),
        ),
        LaundryService(
          id: '4',
          name: 'Setrika Saja',
          pricePerKg: 5000,
          description: 'Hanya setrika tanpa cuci',
          createdAt: DateTime.now(),
        ),
      ];
      
      for (final service in defaultServices) {
        await servicesBox.put(service.id, service);
      }
    }
  }

  // Orders
  static Box<LaundryOrder> get ordersBox => Hive.box<LaundryOrder>(ordersBoxName);
  
  static Future<void> saveOrder(LaundryOrder order) async {
    await ordersBox.put(order.id, order);
  }
  
  static List<LaundryOrder> getAllOrders() {
    return ordersBox.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  static LaundryOrder? getOrder(String id) {
    return ordersBox.get(id);
  }
  
  static Future<void> deleteOrder(String id) async {
    await ordersBox.delete(id);
  }

  // Customers
  static Box<Customer> get customersBox => Hive.box<Customer>(customersBoxName);
  
  static Future<void> saveCustomer(Customer customer) async {
    await customersBox.put(customer.id, customer);
  }
  
  static List<Customer> getAllCustomers() {
    return customersBox.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }
  
  static Customer? getCustomer(String id) {
    return customersBox.get(id);
  }
  
  static Customer? getCustomerByPhone(String phoneNumber) {
    return customersBox.values.firstWhere(
      (customer) => customer.phoneNumber == phoneNumber,
      orElse: () => null as Customer,
    );
  }
  
  static Future<void> deleteCustomer(String id) async {
    await customersBox.delete(id);
  }

  // Services
  static Box<LaundryService> get servicesBox => Hive.box<LaundryService>(servicesBoxName);
  
  static Future<void> saveService(LaundryService service) async {
    await servicesBox.put(service.id, service);
  }
  
  static List<LaundryService> getAllServices() {
    return servicesBox.values.where((service) => service.isActive).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }
  
  static LaundryService? getService(String id) {
    return servicesBox.get(id);
  }
  
  static Future<void> deleteService(String id) async {
    await servicesBox.delete(id);
  }

  // Settings
  static Box get settingsBox => Hive.box(settingsBoxName);
  
  static Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }
  
  static T? getSetting<T>(String key, {T? defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  // Backup and Restore
  static Future<Map<String, dynamic>> exportData() async {
    return {
      'orders': ordersBox.values.map((order) => {
        'id': order.id,
        'customerId': order.customerId,
        'customerName': order.customerName,
        'phoneNumber': order.phoneNumber,
        'address': order.address,
        'service': order.service,
        'weight': order.weight,
        'price': order.price,
        'status': order.status.index,
        'createdAt': order.createdAt.millisecondsSinceEpoch,
        'pickupDate': order.pickupDate?.millisecondsSinceEpoch,
        'completedDate': order.completedDate?.millisecondsSinceEpoch,
        'notes': order.notes,
        'labelPrinted': order.labelPrinted,
      }).toList(),
      'customers': customersBox.values.map((customer) => {
        'id': customer.id,
        'name': customer.name,
        'phoneNumber': customer.phoneNumber,
        'address': customer.address,
        'createdAt': customer.createdAt.millisecondsSinceEpoch,
        'lastOrderDate': customer.lastOrderDate?.millisecondsSinceEpoch,
        'totalOrders': customer.totalOrders,
      }).toList(),
      'services': servicesBox.values.map((service) => {
        'id': service.id,
        'name': service.name,
        'pricePerKg': service.pricePerKg,
        'description': service.description,
        'isActive': service.isActive,
        'createdAt': service.createdAt.millisecondsSinceEpoch,
      }).toList(),
    };
  }

  static Future<void> closeBoxes() async {
    await Hive.close();
  }
}
