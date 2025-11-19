import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final bool isMe;
  final String type;
  final String content;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.isMe,
    required this.type,
    required this.content,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (type == 'image') {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          content,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    } else {
      child = Text(content);
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isMe ? Colors.green.shade200 : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ),
    );
  }
}
