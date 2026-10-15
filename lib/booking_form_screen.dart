import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'payment_screen.dart';

class BookingFormScreen extends StatefulWidget {
  final Map<String, dynamic> flight;

  const BookingFormScreen({Key? key, required this.flight}) : super(key: key);

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  String? _gender;
  String _selectedPaymentMethod = 'DelkaPay';
  String? _selectedBank;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _idNumberController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      _showErrorDialog("User belum login.");
      setState(() => _isSubmitting = false);
      return;
    }

    final passengerData = {
      "full_name": _fullNameController.text,
      "no_ktp": _idNumberController.text,
      "gender": _gender,
      "contact_info": _contactController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/passengers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(passengerData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final getResponse = await http.get(
          Uri.parse(
            'http://10.0.2.2:3000/api/passengers?_where=(no_ktp,eq,${_idNumberController.text})',
          ),
        );

        if (getResponse.statusCode == 200) {
          final decoded = jsonDecode(getResponse.body);
          if (decoded is List && decoded.isNotEmpty) {
            final passenger = decoded[0];
            final passengerId = passenger['id'];
            final now = DateTime.now();
            final paymentCode = "DELKA-${now.millisecondsSinceEpoch}";

            final paymentMethod =
                _selectedPaymentMethod == 'Transfer Bank' &&
                        _selectedBank != null
                    ? 'Transfer Bank ($_selectedBank)'
                    : _selectedPaymentMethod;

            final bookingData = {
              "user_id": userId,
              "flight_id": widget.flight['id'],
              "passenger_id": passengerId,
              "passenger_name": passenger['full_name'],
              "contact_info": passenger['contact_info'],
              "booking_date": now.toIso8601String().substring(0, 19),
              "status": "Confirmed",
              "payment_method": paymentMethod,
              "payment_code": paymentCode,
              "created_at": now.toIso8601String().substring(0, 19),
            };

            final bookingResponse = await http.post(
              Uri.parse('http://10.0.2.2:3000/api/bookings'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(bookingData),
            );

            if (bookingResponse.statusCode == 200 ||
                bookingResponse.statusCode == 201) {
              _goToPayment(passenger);
            } else {
              final error = bookingResponse.body.toLowerCase();
              if (error.contains("duplicate entry")) {
                _goToPayment(passenger);
              } else {
                _showErrorDialog("Gagal menyimpan data booking:\n$error");
              }
            }
          } else {
            _showErrorDialog("Data penumpang tidak ditemukan.");
          }
        } else {
          _showErrorDialog("Gagal mengambil data penumpang.");
        }
      } else {
        _showErrorDialog("Gagal menyimpan data penumpang.");
      }
    } catch (e) {
      _showErrorDialog("Terjadi kesalahan koneksi: $e");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _goToPayment(Map<String, dynamic> passenger) {
    final flight = widget.flight;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PaymentScreen(
              bookingDetails: {
                'flight': {
                  'id': flight['id'],
                  'origin': flight['origin'],
                  'destination': flight['destination'],
                  'date': flight['date'],
                  'time': flight['time'],
                  'price': flight['price'], // tambahkan harga
                },

                'passenger': passenger,
                'payment_method':
                    _selectedPaymentMethod == 'Transfer Bank' &&
                            _selectedBank != null
                        ? 'Transfer Bank ($_selectedBank)'
                        : _selectedPaymentMethod,
              },
            ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Error"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flight = widget.flight;
    final route = '${flight['origin']} → ${flight['destination']}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulir Pemesanan'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Penerbangan: $route',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Divider(height: 30),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) => value!.isEmpty ? 'Nama harus diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _idNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Nomor KTP / Paspor',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Nomor identitas harus diisi'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    items:
                        ['Laki-laki', 'Perempuan']
                            .map(
                              (gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => setState(() => _gender = value),
                    decoration: const InputDecoration(
                      labelText: 'Jenis Kelamin',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) => value == null ? 'Pilih jenis kelamin' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contactController,
                    decoration: const InputDecoration(
                      labelText: 'Nomor HP / Email',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) => value!.isEmpty ? 'Kontak harus diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedPaymentMethod,
                    items:
                        ['DelkaPay', 'OVO', 'Gopay', 'Transfer Bank']
                            .map(
                              (method) => DropdownMenuItem(
                                value: method,
                                child: Text(method),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value!;
                        if (_selectedPaymentMethod != 'Transfer Bank') {
                          _selectedBank = null;
                        }
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Metode Pembayaran',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) =>
                            value == null ? 'Pilih metode pembayaran' : null,
                  ),
                  if (_selectedPaymentMethod == 'Transfer Bank') ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedBank,
                      isExpanded: true,
                      hint: const Text('Pilih Bank'),
                      items:
                          ['BCA', 'BRI', 'Mandiri']
                              .map(
                                (bank) => DropdownMenuItem(
                                  value: bank,
                                  child: Text(bank),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) => setState(() => _selectedBank = value),
                      decoration: const InputDecoration(
                        labelText: 'Bank Tujuan',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null ? 'Pilih bank' : null,
                    ),
                  ],
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child:
                          _isSubmitting
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text('Lanjut ke Pembayaran'),
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
}
