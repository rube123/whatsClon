import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'profile_setup_screen.dart';
import '../../services/auth_service.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  String? _verificationId;
  bool _codeSent = false;
  bool _loading = false;

  Future<void> _sendCode() async {
    setState(() => _loading = true);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneCtrl.text.trim(),
      verificationCompleted: (credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
      },
      codeSent: (verificationId, _) {
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
        });
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
    setState(() => _loading = false);
  }

  Future<void> _verifyCode() async {
    if (_verificationId == null) return;
    setState(() => _loading = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _codeCtrl.text.trim(),
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      final appUser = await AuthService.getCurrentAppUser();
      if (!mounted) return;
      if (appUser == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Código inválido')));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tec Chat – Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!_codeSent) ...[
              TextField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Número de teléfono',
                  hintText: '+52 4xx xxx xxxx',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _sendCode,
                child: Text(_loading ? 'Enviando...' : 'Enviar código por SMS'),
              ),
            ] else ...[
              TextField(
                controller: _codeCtrl,
                decoration: const InputDecoration(labelText: 'Código SMS'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _verifyCode,
                child: Text(_loading ? 'Verificando...' : 'Verificar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
