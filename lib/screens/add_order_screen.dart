import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../providers/laundry_provider.dart';
import '../models/laundry_order.dart';
import '../models/customer.dart';
import 'receipt_screen.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  
  List<OrderItem> _orderItems = [];
  DateTime? _pickupDate;
  OrderPriority _priority = OrderPriority.biasa;
  Customer? _selectedCustomer;

  @override
  void initState() {
    super.initState();
    _addNewOrderItem();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addNewOrderItem() {
    setState(() {
      _orderItems.add(OrderItem(
        serviceName: 'Cuci Setrika',
        weight: 1.0,
        pricePerKg: 10000,
        subtotal: 10000,
      ));
    });
  }

  void _removeOrderItem(int index) {
    if (_orderItems.length > 1) {
      setState(() {
        _orderItems.removeAt(index);
      });
    }
  }

  void _updateOrderItem(int index, OrderItem item) {
    setState(() {
      _orderItems[index] = item;
    });
  }

  double _calculateTotal() {
    return _orderItems.fold(0, (sum, item) => sum + item.subtotal);
  }

  DateTime _calculateEstimatedCompletion() {
    final now = DateTime.now();
    if (_priority == OrderPriority.express) {
      return now.add(const Duration(hours: 6)); // Express 6 jam
    } else {
      return now.add(const Duration(days: 1)); // Biasa 1 hari
    }
  }

  void _searchCustomer(String phoneNumber) {
    final provider = Provider.of<LaundryProvider>(context, listen: false);
    final customer = provider.getCustomerByPhone(phoneNumber);
    
    if (customer != null) {
      setState(() {
        _selectedCustomer = customer;
        _customerNameController.text = customer.name;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pelanggan ditemukan: ${customer.name}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        _selectedCustomer = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Pesanan Baru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Section
              _buildCustomerSection(),
              const SizedBox(height: 24),
              
              // Services Section
              _buildServicesSection(),
              const SizedBox(height: 24),
              
              // Additional Details Section
              _buildAdditionalDetailsSection(),
              const SizedBox(height: 24),
              
              // Price Summary
              _buildPriceSummary(),
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Simpan Pesanan & Cetak Nota',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Pelanggan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Phone Number with Search
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Nomor HP',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.phone_outlined),
              suffixIcon: IconButton(
                onPressed: () => _searchCustomer(_phoneController.text),
                icon: const Icon(Icons.search),
              ),
            ),
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              if (value.length >= 10) {
                _searchCustomer(value);
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nomor HP harus diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Customer Name
          TextFormField(
            controller: _customerNameController,
            decoration: InputDecoration(
              labelText: 'Nama Lengkap',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.person_outline),
              suffixIcon: _selectedCustomer != null 
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama harus diisi';
              }
              return null;
            },
          ),
          
          if (_selectedCustomer != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pelanggan lama • ${_selectedCustomer!.totalOrders} pesanan sebelumnya',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Layanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _addNewOrderItem,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Layanan'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _orderItems.length,
            itemBuilder: (context, index) {
              return _buildOrderItemCard(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(int index) {
    final item = _orderItems[index];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Layanan ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_orderItems.length > 1)
                  IconButton(
                    onPressed: () => _removeOrderItem(index),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Service Selection
            Consumer<LaundryProvider>(
              builder: (context, provider, child) {
                return DropdownButtonFormField<String>(
                  value: item.serviceName,
                  decoration: const InputDecoration(
                    labelText: 'Jenis Layanan',
                    border: OutlineInputBorder(),
                  ),
                  items: provider.services.map((service) {
                    return DropdownMenuItem(
                      value: service.name,
                      child: Text('${service.name} - Rp ${NumberFormat('#,###').format(service.pricePerKg)}/kg'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final service = provider.getServiceByName(value!);
                    if (service != null) {
                      final updatedItem = item.copyWith(
                        serviceName: service.name,
                        pricePerKg: service.pricePerKg,
                        subtotal: service.pricePerKg * item.weight,
                      );
                      _updateOrderItem(index, updatedItem);
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            
            // Weight Input
            Row(
              children: [
                const Expanded(
                  child: Text('Berat (kg)'),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: item.weight > 0.5 ? () {
                          final updatedItem = item.copyWith(
                            weight: item.weight - 0.5,
                            subtotal: item.pricePerKg * (item.weight - 0.5),
                          );
                          _updateOrderItem(index, updatedItem);
                        } : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          item.weight.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final updatedItem = item.copyWith(
                            weight: item.weight + 0.5,
                            subtotal: item.pricePerKg * (item.weight + 0.5),
                          );
                          _updateOrderItem(index, updatedItem);
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:'),
                Text(
                  'Rp ${NumberFormat('#,###').format(item.subtotal)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Tambahan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Priority Selection
          const Text('Prioritas:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<OrderPriority>(
                  title: const Text('Biasa (1 hari)'),
                  value: OrderPriority.biasa,
                  groupValue: _priority,
                  onChanged: (value) {
                    setState(() {
                      _priority = value!;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<OrderPriority>(
                  title: const Text('Express (6 jam)'),
                  value: OrderPriority.express,
                  groupValue: _priority,
                  onChanged: (value) {
                    setState(() {
                      _priority = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Pickup Date
          InkWell(
            onTap: _selectPickupDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _pickupDate != null
                          ? 'Jadwal Pickup: ${DateFormat('dd/MM/yyyy').format(_pickupDate!)}'
                          : 'Pilih Jadwal Pickup (Opsional)',
                      style: TextStyle(
                        fontSize: 16,
                        color: _pickupDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Notes
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Catatan Khusus (Opsional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note_outlined),
              hintText: 'Contoh: ada pakaian sensitif, lipat khusus, dll',
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    final total = _calculateTotal();
    final estimatedCompletion = _calculateEstimatedCompletion();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Pesanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Items Summary
          ..._orderItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${item.serviceName} (${item.weight} kg)'),
                  Text('Rp ${NumberFormat('#,###').format(item.subtotal)}'),
                ],
              ),
            );
          }).toList(),
          
          const Divider(),
          
          // Priority Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Prioritas:'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _priority.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _priority.displayName,
                  style: TextStyle(
                    color: _priority.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Estimated Completion
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimasi Selesai:'),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(estimatedCompletion),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          
          const Divider(),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Harga',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Rp ${NumberFormat('#,###').format(total)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectPickupDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _pickupDate = picked;
      });
    }
  }

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<LaundryProvider>(context, listen: false);
      
      // Create or get customer
      String customerId;
      if (_selectedCustomer != null) {
        customerId = _selectedCustomer!.id;
      } else {
        customerId = const Uuid().v4();
        final newCustomer = Customer(
          id: customerId,
          name: _customerNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          address: '', // Address not required for now
          createdAt: DateTime.now(),
        );
        provider.addCustomer(newCustomer);
      }
      
      final newOrder = LaundryOrder(
        id: provider.generateOrderId(),
        customerId: customerId,
        customerName: _customerNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        items: _orderItems,
        totalPrice: _calculateTotal(),
        status: OrderStatus.menunggu,
        createdAt: DateTime.now(),
        pickupDate: _pickupDate,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        priority: _priority,
        estimatedCompletion: _calculateEstimatedCompletion(),
      );
      
      provider.addOrder(newOrder).then((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptScreen(order: newOrder),
          ),
        );
      });
    }
  }
}
