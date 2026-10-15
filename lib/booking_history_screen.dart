import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'e_ticket_detail_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _futureBookings;

  Future<int?> getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  Future<List<Map<String, dynamic>>> fetchBookings() async {
    final userId = await getUserIdFromPrefs();
    if (userId == null) throw Exception('User belum login.');

    final url = Uri.parse(
      'http://10.0.2.2:3000/api/xjoin'
      '?_join=b.bookings,_j,f.flights'
      '&_on1=(b.flight_id,eq,f.id)'
      '&_where=(b.user_id,eq,$userId)'
      '&_fields=b.id,b.passenger_name,b.contact_info,b.payment_code,'
      'b.payment_method,b.status,b.flight_id,'
      'f.id,f.origin,f.destination,f.flight_number,'
      'f.departure_time,f.arrival_time,f.price,f.seats_available',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      // Filter duplikat berdasarkan kombinasi booking_id dan flight_id
      final Set<String> seenIds = {};
      final List<Map<String, dynamic>> uniqueBookings = [];

      for (var booking in data) {
        final id = '${booking['b_id']}_${booking['f_id']}';
        if (!seenIds.contains(id)) {
          seenIds.add(id);
          uniqueBookings.add(booking);
        }
      }

      // ✅ Filter hanya booking yang punya payment_code
      final List<Map<String, dynamic>> filteredBookings =
          uniqueBookings
              .where((b) => (b['b_payment_code'] ?? '').toString().isNotEmpty)
              .toList();

      return filteredBookings;
    } else {
      throw Exception(
        'Gagal mengambil data riwayat\nStatus: ${response.statusCode}\nBody: ${response.body}',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _futureBookings = fetchBookings();
  }

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

  String formatTime(String? isoTime) {
    if (isoTime == null) return '-';
    final dt = DateTime.tryParse(isoTime);
    if (dt == null) return '-';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} (${dt.day}/${dt.month}/${dt.year})';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Booking'),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE3F2FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureBookings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Terjadi kesalahan: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'Tidak ada riwayat booking.',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            final bookings = snapshot.data!;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final status = booking['b_status'] ?? '-';

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        booking['b_passenger_name'] ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Kontak: ${booking['b_contact_info'] ?? '-'}'),
                          Text(
                            'Kode Pembayaran: ${booking['b_payment_code'] ?? '-'}',
                          ),
                          Text('Metode: ${booking['b_payment_method'] ?? '-'}'),
                          Text(
                            'Rute: ${booking['f_origin'] ?? '?'} → ${booking['f_destination'] ?? '?'}',
                          ),
                          Text(
                            'Penerbangan: ${booking['f_flight_number'] ?? '-'}',
                          ),
                          Text('Harga: Rp${booking['f_price']?.toInt() ?? 0}'),
                          Text(
                            'Keberangkatan: ${formatTime(booking['f_departure_time'])}',
                          ),
                          Text(
                            'Tiba: ${formatTime(booking['f_arrival_time'])}',
                          ),
                          Row(
                            children: [
                              const Text('Status: '),
                              Text(
                                status,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: getStatusColor(status),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.qr_code_2, color: Colors.blue),
                        tooltip: 'Lihat Tiket',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ETicketDetailScreen(booking: booking),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
