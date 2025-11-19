import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get currentUid => _auth.currentUser!.uid;

  static Future<String> createOrGetPrivateChat(String otherUid) async {
    final query =
        await _db
            .collection('chats')
            .where('isGroup', isEqualTo: false)
            .where('members', arrayContains: currentUid)
            .get();

    for (final doc in query.docs) {
      final members = List<String>.from(doc['members'] ?? []);
      if (members.contains(otherUid)) {
        return doc.id;
      }
    }

    final ref = await _db.collection('chats').add({
      'members': [currentUid, otherUid],
      'isGroup': false,
      'groupName': null,
      'hidePhones': false,
      'lastMessage': '',
      'updatedAt': FieldValue.serverTimestamp(),
      'pinnedMessageId': null,
    });

    return ref.id;
  }

  static Future<String> createGroupChat({
    required String groupName,
    required List<String> members,
    required bool hidePhones,
  }) async {
    final ref = await _db.collection('chats').add({
      'members': members,
      'isGroup': true,
      'groupName': groupName,
      'hidePhones': hidePhones,
      'lastMessage': '',
      'updatedAt': FieldValue.serverTimestamp(),
      'pinnedMessageId': null,
    });
    return ref.id;
  }

  static Future<void> pinMessage(String chatId, String messageId) async {
    await _db.collection('chats').doc(chatId).update({
      'pinnedMessageId': messageId,
    });
  }

  static Future<void> unpinMessage(String chatId) async {
    await _db.collection('chats').doc(chatId).update({'pinnedMessageId': null});
  }
}
