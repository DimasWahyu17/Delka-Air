import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final ValueChanged<String>? onEmailChanged; // Optional callback

  const SettingsScreen({Key? key, this.onEmailChanged}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotificationOn = true;
  String _email = 'nan@example.com'; // Default email
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: _email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notifikasi'),
            subtitle: Text(_isNotificationOn ? 'Aktif' : 'Nonaktif'),
            secondary: const Icon(Icons.notifications),
            value: _isNotificationOn,
            onChanged: (value) {
              setState(() => _isNotificationOn = value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value ? 'Notifikasi diaktifkan' : 'Notifikasi dimatikan',
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Edit Email'),
            subtitle: Text(_email),
            onTap: _showEditEmailDialog,
          ),
        ],
      ),
    );
  }

  void _showEditEmailDialog() {
    _emailController.text = _email;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Email'),
            content: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email baru'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newEmail = _emailController.text.trim();
                  if (newEmail.isNotEmpty) {
                    setState(() => _email = newEmail);
                    widget.onEmailChanged?.call(newEmail);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email berhasil diubah')),
                    );
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
  }
}
