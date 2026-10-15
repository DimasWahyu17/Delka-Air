import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:po/screens/help_screen.dart';
import 'package:po/screens/settings_screen.dart';
import 'login_screen.dart';

class AccountScreen extends StatefulWidget {
  final int memberPoints;

  const AccountScreen({Key? key, this.memberPoints = 0}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String username = '';
  String email = '';
  String profileImageUrl =
      'https://tse3.mm.bing.net/th?id=OIP.kEXBJMLiahYU_7vmOq-4fwHaHa&pid=Api&P=0&h=180';
  int _currentPoints = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentPoints = widget.memberPoints;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId == null) {
      setState(() {
        username = 'User belum login';
        email = '-';
        _isLoading = false;
      });
      return;
    }

    try {
      final url = Uri.parse('http://10.0.2.2:3000/api/users?id=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);
        final user = users.firstWhere(
          (u) => u['id'] == userId,
          orElse: () => null,
        );

        if (user != null) {
          setState(() {
            username = user['name'] ?? 'Pengguna';
            email = user['email'] ?? 'email@example.com';
            profileImageUrl = user['profile_image'] ?? profileImageUrl;
            _currentPoints = user['points'] ?? 0;
            _isLoading = false;
          });
        } else {
          setState(() {
            username = 'User tidak ditemukan';
            email = '-';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          username = 'Gagal memuat data user';
          email = '-';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        username = 'Kesalahan jaringan';
        email = '-';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUsername(String newUsername) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId == null) return;

    final url = Uri.parse('http://10.0.2.2:3000/api/users/$userId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': newUsername}),
    );

    if (response.statusCode == 200) {
      setState(() => username = newUsername);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username berhasil diperbarui')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui username')),
      );
    }
  }

  void _showEditUsernameDialog() {
    final controller = TextEditingController(text: username);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Edit Username'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Masukkan username baru',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newUsername = controller.text.trim();
                  if (newUsername.isNotEmpty) {
                    await _updateUsername(newUsername);
                  }
                  Navigator.pop(context);
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }

  void _changeProfilePhoto() {
    setState(() {
      profileImageUrl =
          'https://deorchids.com/wp-content/uploads/2023/02/Warna-Bunga-Lily-dan-Maknanya.jpg';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Foto profil berhasil diubah')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akun Saya')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileSection(),
            const SizedBox(height: 20),
            _buildMemberCard(),
            const SizedBox(height: 20),
            _buildMenuOptions(context),
            const SizedBox(height: 30),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(profileImageUrl),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isLoading ? 'Memuat...' : username,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.edit, size: 18, color: Colors.blueAccent),
              onSelected: (value) {
                if (value == 'foto') {
                  _changeProfilePhoto();
                } else if (value == 'username') {
                  _showEditUsernameDialog();
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'foto',
                      child: Row(
                        children: [
                          Icon(
                            Icons.photo_camera,
                            size: 18,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Ganti Foto Profil',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'username',
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 18, color: Colors.blue),
                          SizedBox(width: 10),
                          Text('Edit Username', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
        Text(email, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildMemberCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: const Icon(Icons.card_membership, color: Colors.orange),
        title: const Text('Membership Points'),
        subtitle: Text('$_currentPoints poin'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur Member Points belum tersedia')),
          );
        },
      ),
    );
  }

  Widget _buildMenuOptions(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Bantuan'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Pengaturan'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SettingsScreen(), // Tidak pakai tema
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const Icon(Icons.logout),
      label: const Text('Keluar'),
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      },
    );
  }
}
