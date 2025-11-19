import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _carreraCtrl = TextEditingController();
  final _semestreCtrl = TextEditingController(text: '1');
  String _role = 'alumno';
  bool _saving = false;

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _saving = true);

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'phoneNumber': user.phoneNumber,
      'email': _emailCtrl.text.trim(),
      'displayName': _nameCtrl.text.trim(),
      'role': _role,
      'carrera': _carreraCtrl.text.trim(),
      'semestre': int.tryParse(_semestreCtrl.text.trim()) ?? 1,
      'avatarUrl': '',
      'isOnline': true,
    });

    setState(() => _saving = false);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completar perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
            ),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Correo institucional',
                hintText: 'nombre@itcelaya.edu.mx',
              ),
            ),
            TextField(
              controller: _carreraCtrl,
              decoration: const InputDecoration(labelText: 'Carrera'),
            ),
            TextField(
              controller: _semestreCtrl,
              decoration: const InputDecoration(labelText: 'Semestre'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _role,
              items: const [
                DropdownMenuItem(value: 'alumno', child: Text('Alumno')),
                DropdownMenuItem(value: 'profesor', child: Text('Profesor')),
              ],
              onChanged: (v) => setState(() => _role = v ?? 'alumno'),
              decoration: const InputDecoration(labelText: 'Rol'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saving ? null : _saveProfile,
              child: Text(_saving ? 'Guardando...' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
