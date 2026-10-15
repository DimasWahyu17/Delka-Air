import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  void _launchPhone(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint('Tidak dapat membuka telepon.');
    }
  }

  void _launchEmail(String email) async {
    final Uri url = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri.encodeQueryComponent(
        'subject=Permintaan Bantuan&body=Halo, saya membutuhkan bantuan.',
      ),
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint('Tidak dapat membuka email.');
    }
  }

  void _launchWhatsApp(String phoneNumber) async {
    final Uri url = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint('Tidak dapat membuka WhatsApp.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pusat Bantuan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Hubungi Kami',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Nomor layanan call center
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.green),
            title: const Text('Layanan Pelanggan'),
            subtitle: const Text('22890'),
            onTap: () => _launchPhone('22890'),
          ),
          const Divider(),

          // Email support
          ListTile(
            leading: const Icon(Icons.email, color: Colors.red),
            title: const Text('Email Support'),
            subtitle: const Text('DELKAAIR@example.com'),
            onTap: () => _launchEmail('support@example.com'),
          ),
          const Divider(),

          // WhatsApp support
          ListTile(
            leading: const Icon(Icons.chat, color: Colors.teal),
            title: const Text('WhatsApp'),
            subtitle: const Text('+62 812-3456-7890'),
            onTap: () => _launchWhatsApp('6281234567890'),
          ),
          const Divider(),

          const SizedBox(height: 30),

          const Text(
            ' Silakan hubungi kami melalui salah satu metode di atas.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
