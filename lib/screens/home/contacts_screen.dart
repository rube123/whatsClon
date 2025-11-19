import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/chat_service.dart';
import '../chat/chat_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _searchCtrl = TextEditingController();
  bool _searching = false;
  List<DocumentSnapshot> _results = [];

  Future<void> _searchUser() async {
    final text = _searchCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _searching = true;
      _results = [];
    });

    final db = FirebaseFirestore.instance;
    QuerySnapshot query;

    if (text.contains('@')) {
      // buscar por correo
      query =
          await db
              .collection('users')
              .where('email', isEqualTo: text)
              .limit(10)
              .get();
    } else {
      // buscar por telefono
      query =
          await db
              .collection('users')
              .where('phoneNumber', isEqualTo: text)
              .limit(10)
              .get();
    }

    setState(() {
      _searching = false;
      _results = query.docs;
    });
  }

  Future<void> _openChatWith(DocumentSnapshot userDoc) async {
    final otherUid = userDoc.id;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    if (otherUid == uid) return;

    final chatId = await ChatService.createOrGetPrivateChat(otherUid);
    if (!mounted) return;

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ChatScreen(chatId: chatId)));
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Contactos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por teléfono o correo',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searching ? null : _searchUser,
                ),
              ],
            ),
          ),
          if (_searching)
            const CircularProgressIndicator()
          else if (_results.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (_, index) {
                  final doc = _results[index];
                  final data = doc.data() as Map<String, dynamic>;
                  if (doc.id == uid) {
                    return const SizedBox.shrink();
                  }
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(data['displayName'] ?? ''),
                    subtitle: Text(data['email'] ?? ''),
                    trailing: const Icon(Icons.chat),
                    onTap: () => _openChatWith(doc),
                  );
                },
              ),
            )
          else
            const Text('Busca un usuario para agregarlo.'),
        ],
      ),
    );
  }
}
