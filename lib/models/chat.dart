class Chat {
  final String id;
  final List<String> members; // uids
  final bool isGroup;
  final String? groupName;
  final bool hidePhones; // si el profe oculta teléfonos
  final String lastMessage;
  final DateTime updatedAt;
  final String? pinnedMessageId;

  Chat({
    required this.id,
    required this.members,
    required this.isGroup,
    this.groupName,
    this.hidePhones = false,
    this.lastMessage = '',
    required this.updatedAt,
    this.pinnedMessageId,
  });

  Map<String, dynamic> toMap() => {
    'members': members,
    'isGroup': isGroup,
    'groupName': groupName,
    'hidePhones': hidePhones,
    'lastMessage': lastMessage,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
    'pinnedMessageId': pinnedMessageId,
  };

  factory Chat.fromMap(String id, Map<String, dynamic> map) => Chat(
    id: id,
    members: List<String>.from(map['members'] ?? []),
    isGroup: map['isGroup'] ?? false,
    groupName: map['groupName'],
    hidePhones: map['hidePhones'] ?? false,
    lastMessage: map['lastMessage'] ?? '',
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch,
    ),
    pinnedMessageId: map['pinnedMessageId'],
  );
}
