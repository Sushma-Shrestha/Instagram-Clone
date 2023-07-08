import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String message;
  final DateTime messagedTime;
  final String type;
  final String messageId;

  Message(
      {required this.message,
      required this.messagedTime,
      required this.type,
      required this.messageId});

  static Message fromSnap(DocumentSnapshot snap) {
    var snapshot = (snap.data() as Map<String, dynamic>);
    return Message(
        message: snapshot['message'],
        messagedTime: snapshot['messagedTime'],
        type: snapshot['type'],
        messageId: snapshot['messageId']);
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'messagedTime': messagedTime,
        'type': type,
        'messageId': messageId
      };
}
