import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'registration_screen.dart';
import 'beranda_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? email;
  final String? password;

  LoginScreen({this.email, this.password});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true; // 👈 untuk toggle tampil/sembunyi password

  @override
  void initState() {
    super.initState();
    if (widget.email != null) _emailController.text = widget.email!;
    if (widget.password != null) _passwordController.text = widget.password!;
  }

  Future<void> _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Email dan password harus diisi')));
      return;
    }

    setState(() => _isLoading = true);

    final encodedEmail = Uri.encodeComponent(email);
    final encodedPassword = Uri.encodeComponent(password);
    final url = Uri.parse(
      'http://10.0.2.2:3000/api/users?_where=(email,eq,$encodedEmail)~and(password,eq,$encodedPassword)',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List && data.isNotEmpty) {
          final user = data[0];
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          await prefs.setInt('user_id', user['id']);
          await prefs.setString('user_name', user['name']);
          await prefs.setString('user_email', user['email']);

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Login berhasil')));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => BerandaScreen()),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Email atau password salah')));
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghubungi server')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Color(0xFF1565C0),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => RegistrationScreen()),
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: EdgeInsets.all(20),
                constraints: BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 30, 33, 36),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 25),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                          onPressed: _loginUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 122, 179, 245),
                            minimumSize: Size(double.infinity, 45),
                          ),
                          child: Text(
                            'Masuk',
                            style: TextStyle(
                              color: Color.fromARGB(255, 31, 33, 36),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    SizedBox(height: 15),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegistrationScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Belum punya akun? Daftar',
                        style: TextStyle(
                          color: Color.fromARGB(255, 31, 33, 36),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
