import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/chat_service.dart';
import '../chat/chat_screen.dart';

class GroupCreateScreen extends StatefulWidget {
  const GroupCreateScreen({super.key});

  @override
  State<GroupCreateScreen> createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  final _nameCtrl = TextEditingController();
  bool _hidePhones = true;
  final Set<String> _selectedUserIds = {};
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear grupo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del grupo',
                  ),
                ),
                SwitchListTile(
                  title: const Text('Ocultar números telefónicos'),
                  subtitle: const Text(
                    'Solo se mostrarán nombres y correos institucionales',
                  ),
                  value: _hidePhones,
                  onChanged: (v) => setState(() => _hidePhones = v),
                ),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Selecciona integrantes'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (_, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    if (doc.id == uid) return const SizedBox.shrink();
                    final selected = _selectedUserIds.contains(doc.id);
                    return CheckboxListTile(
                      title: Text(data['displayName'] ?? ''),
                      subtitle: Text(data['email'] ?? ''),
                      value: selected,
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selectedUserIds.add(doc.id);
                          } else {
                            _selectedUserIds.remove(doc.id);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed:
                    _loading
                        ? null
                        : () async {
                          if (_nameCtrl.text.trim().isEmpty ||
                              _selectedUserIds.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Nombre de grupo y al menos un integrante',
                                ),
                              ),
                            );
                            return;
                          }

                          setState(() => _loading = true);
                          final members = [uid, ..._selectedUserIds];

                          final chatId = await ChatService.createGroupChat(
                            groupName: _nameCtrl.text.trim(),
                            members: members,
                            hidePhones: _hidePhones,
                          );

                          // 👇 justo después del await
                          if (!mounted) return;

                          setState(() => _loading = false);

                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(chatId: chatId),
                            ),
                          );
                        },

                child: Text(_loading ? 'Creando...' : 'Crear grupo'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
