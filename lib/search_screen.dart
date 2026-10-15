import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'flight_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> flights = [];
  bool isLoading = false;
  bool hasError = false;

  String? selectedFromCity;
  String? selectedToCity;
  DateTime? selectedDate;
  String? selectedClass;

  final Map<String, String> citiesWithAirports = {
    'Jakarta': 'Soekarno-Hatta(CGK)',
    'Surabaya': 'Juanda(SUB)',
    'Bandung': 'Husein Sastranegara(BDO)',
    'Yogyakarta': 'YIA',
    'Denpasar': 'Ngurah Rai(DPS)',
    'Medan': 'Kualanamu (KNO)',
    'Makassar': 'Sultan Hasanuddin(UPG)',
    'Balikpapan': 'Sultan Aji Muhammad Sulaiman(BPN)',
    'Batam': 'Hang Nadim(BTH)',
    'Semarang': 'Ahmad Yani(SRG)',
    'Palembang': 'Sultan Mahmud Badaruddin II(PLM)',
    'Padang': 'Minangkabau(PDG)',
    'Pekanbaru': 'Sultan Syarif Kasim II(PKU)',
    'Pontianak': 'Supadio(PNK)',
    'Banjarmasin': 'Syamsudin Noor(BDJ)',
    'Manado': 'Sam Ratulangi(MDC)',
    'Ambon': 'Pattimura(AMQ)',
    'Kupang': 'El Tari(KOE)',
    'Jayapura': 'Sentani(DJJ)',
    'Ternate': 'Sultan Babullah(TTE)',
    'Mataram': 'Lombok Int\'l(LOP)',
    'Solo': 'Adi Soemarmo(SOC)',
    'Jambi': 'Sultan Thaha(DJB)',
    'Bengkulu': 'Fatmawati Soekarno(BKS)',
    'Tarakan': 'Juwata(TRK)',
    'Palangkaraya': 'Tjilik Riwut(PKY)',
    'Sorong': 'Domine Eduard Osok(SOQ)',
    'Labuan Bajo': 'Komodo(LBJ)',
    'Samarinda': 'APT Pranoto(AAP)',
    'Nabire': 'Douw Aturure(NBX)',
  };

  final List<String> flightClasses = ['Economy', 'Business'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> fetchFlights() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final baseUrl = 'http://10.0.2.2:3000/api/flights';
      List<String> conditions = [];

      if (selectedFromCity != null) {
        conditions.add('(origin,eq,${Uri.encodeComponent(selectedFromCity!)})');
      }
      if (selectedToCity != null) {
        conditions.add('(destination,eq,${Uri.encodeComponent(selectedToCity!)})');
      }
      if (selectedDate != null) {
        final dateString = DateFormat('yyyy-MM-dd').format(selectedDate!);
        conditions.add('(departure_time,like,${Uri.encodeComponent('$dateString%')})');
      }
      if (selectedClass != null) {
        conditions.add('(class,eq,${Uri.encodeComponent(selectedClass!)})');
      }

      final filter = conditions.join('~and');
      final uri = Uri.parse('$baseUrl?_where=$filter');

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> result = jsonDecode(response.body);
        setState(() {
          flights = result;
          isLoading = false;
        });
      } else {
        throw Exception("Gagal mengambil data penerbangan");
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  String formatDateTime(String dateTime) {
    try {
      return DateFormat('dd MMM yyyy – HH:mm').format(DateTime.parse(dateTime));
    } catch (_) {
      return dateTime;
    }
  }

  Widget _buildSearchForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedFromCity,
                isExpanded: true,
                items: citiesWithAirports.keys.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(
                      '$city - ${citiesWithAirports[city]}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedFromCity = value),
                decoration: const InputDecoration(
                  labelText: 'Kota Keberangkatan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flight_takeoff),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedToCity,
                isExpanded: true,
                items: citiesWithAirports.keys.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(
                      '$city - ${citiesWithAirports[city]}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedToCity = value),
                decoration: const InputDecoration(
                  labelText: 'Kota Tujuan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flight_land),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Keberangkatan',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate == null
                            ? 'Pilih tanggal'
                            : DateFormat('dd MMM yyyy').format(selectedDate!),
                        style: TextStyle(
                          color: selectedDate == null
                              ? Colors.grey[600]
                              : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedClass,
                isExpanded: true,
                items: flightClasses.map((cls) {
                  return DropdownMenuItem(
                    value: cls,
                    child: Text(cls),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedClass = value),
                decoration: const InputDecoration(
                  labelText: 'Kelas Penerbangan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.airline_seat_recline_normal),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: fetchFlights,
                  icon: const Icon(Icons.search),
                  label: const Text('Cari Tiket'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (hasError) {
      return const Center(
        child: Text('Terjadi kesalahan saat mengambil data.'),
      );
    }
    if (flights.isEmpty) {
      return const Center(child: Text('Tidak ada data penerbangan.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(15),
      itemCount: flights.length,
      itemBuilder: (context, index) {
        final flight = flights[index];
        final originCity = flight['origin'];
        final destinationCity = flight['destination'];
        final route =
            "$originCity (${citiesWithAirports[originCity]}) → $destinationCity (${citiesWithAirports[destinationCity]})";
        final departureTime = formatDateTime(flight['departure_time'] ?? '');
        final arrivalTime = formatDateTime(flight['arrival_time'] ?? '');
        final price = flight['price'] ?? 0;
        final seatsAvailable = flight['seats_available'] ?? 0;
        final flightClass = flight['class'] ?? '-';
        final flightNumber = flight['flight_number'] ?? '-';

        return Card(
          color: Colors.grey[100],
          margin: const EdgeInsets.only(bottom: 15),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flight_takeoff, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "$flightNumber | $route",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Berangkat: $departureTime"),
                Text("Tiba: $arrivalTime"),
                Text("Kelas: $flightClass"),
                Text("Kursi tersedia: $seatsAvailable"),
                Text("Harga: Rp $price"),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FlightDetailScreen(flight: flight),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Detail"),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Tiket Domestik'),
        backgroundColor: Colors.blue[800],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSearchForm(),
              const Divider(height: 1),
              _buildFlightList(),
            ],
          ),
        ),
      ),
    );
  }
}
