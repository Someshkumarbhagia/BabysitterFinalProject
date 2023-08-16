import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  String sender;
  String content;
  bool isMe;
  bool isPicture;
  String email;
  Timestamp timestamp;

  ChatMessage({
    required this.sender,
    required this.content,
    required this.isMe,
    required this.isPicture,
    required this.email,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: json['sender'],
      content: json['content'],
      isMe: json['isMe'],
      isPicture: json['isPicture'],
      email: json['email'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sender": this.sender,
      "content": this.content,
      "isMe": this.isMe,
      "isPicture": this.isPicture,
      "email": this.email,
      "timestamp": this.timestamp,
    };
  }
}
