import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../chat/chat_screen.dart';
import 'group_create_screen.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GroupCreateScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('chats')
                .where('members', arrayContains: uid)
                .orderBy('updatedAt', descending: true)
                .snapshots(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No hay conversaciones todavía'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final chatId = doc.id;
              final isGroup = data['isGroup'] ?? false;
              final groupName = data['groupName'] ?? 'Grupo';
              final lastMessage = data['lastMessage'] ?? '';

              return ListTile(
                leading: CircleAvatar(
                  child: Icon(isGroup ? Icons.group : Icons.person),
                ),
                title: Text(isGroup ? groupName : 'Chat individual'),
                subtitle: Text(lastMessage),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(chatId: chatId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
