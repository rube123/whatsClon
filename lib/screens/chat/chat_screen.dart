import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/call_service.dart';
import '../../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sendingImage = false;

  Future<void> _sendText() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();

    final msgRef =
        FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatId)
            .collection('messages')
            .doc();

    await msgRef.set({
      'chatId': widget.chatId,
      'senderId': uid,
      'content': text,
      'type': 'text',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .update({
          'lastMessage': text,
          'updatedAt': FieldValue.serverTimestamp(),
        });

    _scrollBottom();
  }

  Future<void> _sendImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _sendingImage = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final file = File(picked.path);

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('chat_media')
        .child(widget.chatId)
        .child('${DateTime.now().millisecondsSinceEpoch}_$uid.jpg');

    await storageRef.putFile(file);
    final url = await storageRef.getDownloadURL();

    final msgRef =
        FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatId)
            .collection('messages')
            .doc();

    await msgRef.set({
      'chatId': widget.chatId,
      'senderId': uid,
      'content': url,
      'type': 'image',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .update({
          'lastMessage': '📷 Foto',
          'updatedAt': FieldValue.serverTimestamp(),
        });

    setState(() => _sendingImage = false);
    _scrollBottom();
  }

  void _scrollBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _startCall() async {
    await CallService.joinCall(roomName: 'teccelaya_${widget.chatId}');
  }

  Future<void> _togglePinMessage(String messageId) async {
    final chatDoc =
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatId)
            .get();
    final data = chatDoc.data() as Map<String, dynamic>?;

    if (data == null) return;
    final pinnedId = data['pinnedMessageId'];
    if (pinnedId == messageId) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({'pinnedMessageId': null});
    } else {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .update({'pinnedMessageId': messageId});
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: _startCall),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: StreamBuilder<DocumentSnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('chats')
                    .doc(widget.chatId)
                    .snapshots(),
            builder: (_, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
              final pinnedId = data['pinnedMessageId'];
              if (pinnedId == null) return const SizedBox.shrink();

              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('chats')
                        .doc(widget.chatId)
                        .collection('messages')
                        .doc(pinnedId)
                        .get(),
                builder: (_, msgSnap) {
                  if (!msgSnap.hasData || !msgSnap.data!.exists) {
                    return const SizedBox.shrink();
                  }
                  final raw = msgSnap.data!.data();
                  if (raw == null) {
                    return const SizedBox.shrink();
                  }
                  final msgData = raw as Map<String, dynamic>;
                  final content = msgData['content'] ?? '';

                  return Container(
                    width: double.infinity,
                    color: Colors.amber.shade100,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        const Icon(Icons.push_pin, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.chatId)
                      .collection('messages')
                      .orderBy('createdAt')
                      .snapshots(),
              builder: (_, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  controller: _scrollCtrl,
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == uid;
                    final type = data['type'] ?? 'text';
                    final content = data['content'] ?? '';

                    return MessageBubble(
                      isMe: isMe,
                      type: type,
                      content: content,
                      onLongPress: () => _togglePinMessage(doc.id),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions),
                  onPressed: () {
                    // aquí podrías abrir un picker de emojis / GIFs
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _sendingImage ? null : _sendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendText(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _sendText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
