import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'search_screen.dart';
import 'booking_history_screen.dart';
import 'account_screen.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({Key? key}) : super(key: key);

  @override
  _BerandaScreenState createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  int _currentIndex = 0;

  Widget _buildResponsiveImageCard(
    String imagePath,
    double width,
    double height, {
    String? label,
  }) {
    return Container(
      width: width,
      height: height + (label != null ? 30 : 0),
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              width: width,
              height: height,
              fit: BoxFit.cover,
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, const Color.fromARGB(255, 94, 181, 235)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double totalWidth = constraints.maxWidth;

            double promoItemWidth = totalWidth * 0.8;
            if (promoItemWidth > 300) promoItemWidth = 300;
            double promoItemHeight = 160;

            double destItemWidth = totalWidth * 0.6;
            if (destItemWidth > 280) destItemWidth = 280;
            double destItemHeight = 140;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<SharedPreferences>(
                  future: SharedPreferences.getInstance(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    final prefs = snapshot.data!;
                    final name = prefs.getString('user_name') ?? 'Pengguna';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Center(
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: const Color(0xFFE1F5FE),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.waving_hand,
                                  color: Color.fromARGB(255, 19, 35, 116),
                                  size: 28,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Hai, $name!',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF01579B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const Text(
                  'Penawaran Terbaik untuk Perjalananmu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildResponsiveImageCard(
                        'assets/bca.jpg',
                        promoItemWidth,
                        promoItemHeight,
                      ),
                      _buildResponsiveImageCard(
                        'assets/bali.png',
                        promoItemWidth,
                        promoItemHeight,
                      ),
                      _buildResponsiveImageCard(
                        'assets/bagasi.png',
                        promoItemWidth,
                        promoItemHeight,
                      ),
                      _buildResponsiveImageCard(
                        'assets/gold.png',
                        promoItemWidth,
                        promoItemHeight,
                      ),
                      _buildResponsiveImageCard(
                        'assets/delpay.jpg',
                        promoItemWidth,
                        promoItemHeight,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Destinasi Favorit yang Sering Dikunjungi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  ' Klik gambar untuk melihat deskripsi kota.',
                  style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _InteractiveImageCard(
                        imagePath: 'assets/jogja.jpg',
                        width: destItemWidth,
                        height: destItemHeight,
                        label: 'Yogyakarta',
                        description:
                            'Kota budaya dan sejarah yang kaya, terkenal dengan kawasan Malioboro, keraton, serta candi-candi seperti Prambanan dan Borobudur.',
                      ),
                      _InteractiveImageCard(
                        imagePath: 'assets/bandung.jpg',
                        width: destItemWidth,
                        height: destItemHeight,
                        label: 'Bandung',
                        description:
                            'Kota di dataran tinggi dengan udara sejuk, terkenal dengan wisata alam, kuliner, dan pusat belanja yang kreatif.',
                      ),
                      _InteractiveImageCard(
                        imagePath: 'assets/makassar.jpg',
                        width: destItemWidth,
                        height: destItemHeight,
                        label: 'Makassar',
                        description:
                            'Kota pelabuhan dengan wisata bahari menarik, seperti Pantai Losari dan Pulau Samalona.',
                      ),
                      _InteractiveImageCard(
                        imagePath: 'assets/bali1.jpg',
                        width: destItemWidth,
                        height: destItemHeight,
                        label: 'Bali',
                        description:
                            'Pantai-pantai eksotis, pura, dan budaya Bali menjadikannya destinasi utama di Indonesia.',
                      ),
                      _InteractiveImageCard(
                        imagePath: 'assets/jakarta.jpg',
                        width: destItemWidth,
                        height: destItemHeight,
                        label: 'Jakarta',
                        description:
                            'Ibu kota Indonesia dengan banyak atraksi seperti Monas, pusat perbelanjaan, dan museum.',
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _getBodyContent() {
    switch (_currentIndex) {
      case 3:
        return const AccountScreen(memberPoints: 12000);
      case 0:
      default:
        return _buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color emerald = const Color.fromARGB(255, 113, 205, 239);

    return Theme(
      data: Theme.of(context).copyWith(primaryColor: emerald),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Delka Air'),
          backgroundColor: emerald,
        ),
        body: SafeArea(child: _getBodyContent()),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookingHistoryScreen(),
                ),
              );
            } else {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          selectedItemColor: emerald,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Cari Penerbangan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Riwayat Pemesanan',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class _InteractiveImageCard extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;
  final String label;
  final String description;

  const _InteractiveImageCard({
    Key? key,
    required this.imagePath,
    required this.width,
    required this.height,
    required this.label,
    required this.description,
  }) : super(key: key);

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(label),
          content: Text(description),
          actions: [
            TextButton(
              child: const Text('Tutup'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showInfoDialog(context),
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: width,
                height: height,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
