import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'booking_form_screen.dart'; // pastikan file ini ada

class FlightScheduleScreen extends StatefulWidget {
  final int passengerCount;
  final int userId;

  const FlightScheduleScreen({
    Key? key,
    required this.passengerCount,
    required this.userId,
  }) : super(key: key);

  @override
  _FlightScheduleScreenState createState() => _FlightScheduleScreenState();
}

class _FlightScheduleScreenState extends State<FlightScheduleScreen> {
  List<dynamic> flights = [];

  @override
  void initState() {
    super.initState();
    fetchFlights();
  }

  Future<void> fetchFlights() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/flights'),
      headers: {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
    );

    if (response.statusCode == 200) {
      setState(() {
        flights = json.decode(response.body);
      });
    } else {
      throw Exception('Gagal memuat data penerbangan');
    }
  }

  Future<void> postBooking(
    int userId,
    int flightId,
    int jumlahPenumpang,
  ) async {
    final bookingUri = Uri.parse('http://10.0.2.2:3000/api/bookings');
    final updateUri = Uri.parse('http://10.0.2.2:3000/api/flights/$flightId');

    final response = await http.post(
      bookingUri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'flight_id': flightId,
        'booking_date': DateTime.now().toIso8601String(),
        'status': 'Diproses',
      }),
    );

    if (response.statusCode == 201) {
      print('Booking berhasil disimpan');

      final flightResponse = await http.get(updateUri);
      if (flightResponse.statusCode == 200) {
        final flightData = jsonDecode(flightResponse.body);
        final updatedSeats =
            (flightData['seats_available'] ?? 0) - jumlahPenumpang;

        final putResponse = await http.put(
          updateUri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'seats_available': updatedSeats}),
        );

        if (putResponse.statusCode == 200) {
          print('Kursi berhasil diperbarui');
        } else {
          print('Gagal update kursi: ${putResponse.body}');
        }
      }
    } else {
      print('Gagal booking: ${response.body}');
    }
  }

  Widget buildFlightCard(Map<String, dynamic> flight) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              flight['route'] ?? 'Rute tidak tersedia',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('🗓️ Tanggal: ${flight['date'] ?? '-'}'),
            Text('⏰ Jam: ${flight['time'] ?? '-'}'), // TAMBAHKAN JAM
            Text('💺 Kursi Tersedia: ${flight['seats_available'] ?? 0}'),
            Text('💰 Harga: Rp ${flight['price'] ?? 0}'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await postBooking(
                    widget.userId,
                    flight['id'],
                    widget.passengerCount,
                  );

                  // Navigasi ke BookingFormScreen dengan data lengkap
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BookingFormScreen(
                            flight: {
                              'id': flight['id'],
                              'route': flight['route'],
                              'origin': flight['origin'],
                              'destination': flight['destination'],
                              'date': flight['date'],
                              'time': flight['time'],
                              'price': flight['price'],
                            },
                          ),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Beli'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Penerbangan'),
        backgroundColor: Colors.blue[800],
      ),
      body:
          flights.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: flights.length,
                itemBuilder: (context, index) {
                  return buildFlightCard(flights[index]);
                },
              ),
    );
  }
}
