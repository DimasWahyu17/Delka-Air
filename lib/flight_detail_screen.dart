import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'booking_form_screen.dart';

class FlightDetailScreen extends StatelessWidget {
  final Map<String, dynamic> flight;

  const FlightDetailScreen({Key? key, required this.flight}) : super(key: key);

  String formatDateTime(String dateTime) {
    try {
      return DateFormat('dd MMM yyyy • HH:mm').format(DateTime.parse(dateTime));
    } catch (_) {
      return dateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final origin = flight['origin'] ?? '-';
    final originCity = flight['origin_city'] ?? '-';
    final originAirport = flight['origin_airport'] ?? '-';

    final destination = flight['destination'] ?? '-';
    final destinationCity = flight['destination_city'] ?? '-';
    final destinationAirport = flight['destination_airport'] ?? '-';

    final departureTime = formatDateTime(flight['departure_time'] ?? '');
    final arrivalTime = formatDateTime(flight['arrival_time'] ?? '');
    final flightNumber = flight['flight_number'] ?? '-';
    final flightClass = flight['class'] ?? '-';
    final price = flight['price'] ?? 0;
    final seats = flight['seats_available'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Penerbangan'),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        // Tambahkan Scroll
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lokasi asal → tujuan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLocationInfo(origin, originCity, originAirport),
                      const Icon(
                        Icons.flight_takeoff,
                        size: 32,
                        color: Colors.blue,
                      ),
                      _buildLocationInfo(
                        destination,
                        destinationCity,
                        destinationAirport,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  detailRow('✈️  Nomor Penerbangan', flightNumber),
                  detailRow('🪑  Kelas', flightClass),
                  detailRow('🕓  Waktu Berangkat', departureTime),
                  detailRow('🛬  Waktu Tiba', arrivalTime),
                  detailRow('🧍  Kursi Tersedia', '$seats'),

                  const Divider(height: 30, thickness: 1),

                  Text(
                    '💰 Harga Tiket:',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  Text(
                    'Rp ${NumberFormat.decimalPattern('id_ID').format(price)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => BookingFormScreen(flight: flight),
                          ),
                        );
                      },
                      icon: const Icon(Icons.airplane_ticket),
                      label: const Text('Pesan Tiket'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(String code, String city, String airport) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            code,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            city,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Text(
            airport,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black38),
          ),
        ],
      ),
    );
  }
}
