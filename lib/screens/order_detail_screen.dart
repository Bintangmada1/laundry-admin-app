import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/laundry_order.dart';
import '../providers/laundry_provider.dart';

class OrderDetailScreen extends StatelessWidget {
  final LaundryOrder order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pesanan ${order.id}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'print') {
                _printLabel(context);
              } else if (value == 'delete') {
                _showDeleteDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(Icons.print),
                    SizedBox(width: 8),
                    Text('Cetak Label'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus Pesanan', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: order.status.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: order.status.color.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    _getStatusIcon(order.status),
                    size: 48,
                    color: order.status.color,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order.status.displayName,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: order.status.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Customer Information
            _buildSection(
              'Informasi Pelanggan',
              [
                _buildInfoRow('Nama', order.customerName),
                _buildInfoRow('Telepon', order.phoneNumber),
                _buildInfoRow('Alamat', order.address),
              ],
            ),
            const SizedBox(height: 24),

            // Order Information
            _buildSection(
              'Detail Pesanan',
              [
                _buildInfoRow('ID Pesanan', order.id),
                _buildInfoRow('Layanan', order.service),
                _buildInfoRow('Berat', '${order.weight} kg'),
                _buildInfoRow('Harga', 'Rp ${NumberFormat('#,###').format(order.price)}'),
                _buildInfoRow('Tanggal Masuk', DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)),
                if (order.pickupDate != null)
                  _buildInfoRow('Tanggal Ambil', DateFormat('dd/MM/yyyy').format(order.pickupDate!)),
                if (order.completedDate != null)
                  _buildInfoRow('Tanggal Selesai', DateFormat('dd/MM/yyyy HH:mm').format(order.completedDate!)),
                if (order.notes != null && order.notes!.isNotEmpty)
                  _buildInfoRow('Catatan', order.notes!),
                _buildInfoRow('Label Tercetak', order.labelPrinted ? 'Ya' : 'Belum'),
              ],
            ),
            const SizedBox(height: 32),

            // Status Update Buttons
            if (order.status != OrderStatus.diambil) ...[
              Text(
                'Ubah Status',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatusButtons(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButtons(BuildContext context) {
    final nextStatuses = _getNextStatuses(order.status);
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: nextStatuses.map((status) {
        return ElevatedButton(
          onPressed: () => _updateStatus(context, status),
          style: ElevatedButton.styleFrom(
            backgroundColor: status.color,
            foregroundColor: Colors.white,
          ),
          child: Text(status.displayName),
        );
      }).toList(),
    );
  }

  List<OrderStatus> _getNextStatuses(OrderStatus currentStatus) {
    switch (currentStatus) {
      case OrderStatus.baru:
        return [OrderStatus.diproses];
      case OrderStatus.diproses:
        return [OrderStatus.selesai];
      case OrderStatus.selesai:
        return [OrderStatus.diambil];
      case OrderStatus.diambil:
        return [];
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.baru:
        return Icons.fiber_new;
      case OrderStatus.diproses:
        return Icons.hourglass_empty;
      case OrderStatus.selesai:
        return Icons.check_circle;
      case OrderStatus.diambil:
        return Icons.done_all;
    }
  }

  void _updateStatus(BuildContext context, OrderStatus newStatus) {
    final provider = Provider.of<LaundryProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Status'),
        content: Text('Ubah status pesanan ke ${newStatus.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateOrderStatus(order.id, newStatus);
              Navigator.pop(context);
              Navigator.pop(context); // Go back to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Status berhasil diubah ke ${newStatus.displayName}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Ubah'),
          ),
        ],
      ),
    );
  }

  void _printLabel(BuildContext context) {
    final provider = Provider.of<LaundryProvider>(context, listen: false);
    
    // Simulate printing
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cetak Label'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Label akan dicetak dengan informasi:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Nama: ${order.customerName}'),
                  Text('Layanan: ${order.service}'),
                  Text('Berat: ${order.weight} kg'),
                  Text('Tanggal: ${DateFormat('dd/MM/yyyy').format(order.createdAt)}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.markLabelPrinted(order.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Label berhasil dicetak!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Cetak'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pesanan'),
        content: const Text('Apakah Anda yakin ingin menghapus pesanan ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<LaundryProvider>(context, listen: false);
              provider.deleteOrder(order.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pesanan berhasil dihapus'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
