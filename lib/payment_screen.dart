import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'beranda_screen.dart'; // Pastikan ini sesuai path kamu

class PaymentScreen extends StatelessWidget {
  final Map<String, dynamic> bookingDetails;

  const PaymentScreen({Key? key, required this.bookingDetails})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final flight = bookingDetails['flight'] ?? {};
    final passenger = bookingDetails['passenger'] ?? {};
    final paymentMethod = bookingDetails['payment_method'] ?? '-';

    final route =
        "${flight['origin'] ?? '-'} → ${flight['destination'] ?? '-'}";
    final price = flight['price'] ?? 0;

    final formattedPrice = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
    ).format(price);

    final paymentCode = generatePaymentCode(paymentMethod);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail Pemesanan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 20),
                _infoRow("Nama Penumpang", passenger['full_name'] ?? '-'),
                _infoRow("Kontak", passenger['contact_info'] ?? '-'),
                _infoRow("Rute", route),
                _infoRow("Harga Tiket", formattedPrice),
                const Divider(height: 30),
                const Text(
                  'Detail Pembayaran',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 20),
                _infoRow("Metode Pembayaran", paymentMethod),
                _infoRow("Kode Pembayaran", paymentCode),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '✅ Pembayaran berhasil! Silakan cek tiket di Riwayat Pemesanan.',
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );

                      // Delay sebentar agar user bisa baca snackbar
                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const BerandaScreen(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 127, 169, 218),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Bayar"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              "$title:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String generatePaymentCode(String method) {
    final random = Random();
    final uniqueNumber = random.nextInt(900000) + 100000;
    switch (method.toLowerCase()) {
      case 'bca':
        return 'BCA-$uniqueNumber';
      case 'bri':
        return 'BRI-$uniqueNumber';
      case 'mandiri':
        return 'MANDIRI-$uniqueNumber';
      default:
        return 'PAY-$uniqueNumber';
    }
  }
}
