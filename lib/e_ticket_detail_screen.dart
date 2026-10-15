import 'package:flutter/material.dart';

class ETicketDetailScreen extends StatelessWidget {
  final Map<String, dynamic> booking;

  const ETicketDetailScreen({Key? key, required this.booking}) : super(key: key);

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = booking['b_status'] ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Ticket'),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE3F2FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Flight E-ticket',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    status.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: getStatusColor(status),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard([
              Text('Booking ID: #${booking['b_id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Payment Code: ${booking['b_payment_code'] ?? '-'}'),
              Text('Payment Method: ${booking['b_payment_method'] ?? '-'}'),
            ]),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.flight_takeoff, 'Rute: ${booking['f_origin']} → ${booking['f_destination']}'),
            _buildInfoRow(Icons.airplanemode_active, 'Flight: ${booking['f_flight_number'] ?? '-'}'),
            _buildInfoRow(Icons.access_time, 'Keberangkatan: ${_formatTime(booking['f_departure_time'])}'),
            _buildInfoRow(Icons.flight_land, 'Tiba: ${_formatTime(booking['f_arrival_time'])}'),
            const SizedBox(height: 20),
            _buildSectionCard([
              const Text(
                'Informasi Penumpang',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.person, 'Nama: ${booking['b_passenger_name'] ?? '-'}'),
              _buildInfoRow(Icons.phone, 'Kontak: ${booking['b_contact_info'] ?? '-'}'),
              _buildInfoRow(Icons.attach_money, 'Harga: Rp${booking['f_price']?.toInt() ?? 0}'),
            ]),
            const SizedBox(height: 20),
            _buildSectionCard([
              const Text('Catatan Penting', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.check, 'Perlihatkan e-ticket dan identitas diri saat check-in'),
              _buildInfoRow(Icons.schedule, 'Check-in minimal 90 menit sebelum keberangkatan'),
              _buildInfoRow(Icons.warning, 'Pastikan data Anda sudah benar'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2)),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null) return '-';
    final dt = DateTime.tryParse(isoTime);
    if (dt == null) return '-';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} - ${dt.day}/${dt.month}/${dt.year}';
  }
}
