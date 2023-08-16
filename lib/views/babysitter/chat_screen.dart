import 'dart:io';

import 'package:babysitter/config/constants.dart';
import 'package:babysitter/models/message.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  String bookingID;
  String attenderEmail;
  String attenderName;

  ChatScreen({
    required this.bookingID,
    required this.attenderEmail,
    required this.attenderName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();

  selectImageType(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.white,
          child: Wrap(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  getImage(false);
                },
                child: ListTile(
                  leading: Icon(
                    CupertinoIcons.photo,
                    color: Colors.black,
                  ),
                  title: Text(
                    "Gallery",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  getImage(true);
                },
                child: ListTile(
                  leading: Icon(
                    CupertinoIcons.camera,
                    color: Colors.black,
                  ),
                  title: Text(
                    "Camera",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  getImage(bool isCamera) async {
    var image = await ImagePicker().pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 40);
    File imageF = File(image!.path);
    final bytes = imageF.readAsBytesSync().lengthInBytes;
    final kb = bytes / 1024;
    final mb = kb / 1024;
    if (mb > 10) {
      Fluttertoast.showToast(
        msg: "Image is larger than 5 mb, please upload a smaller image",
      );
    } else {
      Fluttertoast.showToast(
          msg: "Uploading image, message will be sent shortly...");
      uploadImageToFirebase(context, image.path);
    }
  }

  uploadImageToFirebase(BuildContext context, imagePath) async {
    File imageFile = File(imagePath);
    await FirebaseStorage.instance
        .ref()
        .child('chats/${widget.bookingID}/')
        .putFile(imageFile)
        .then((fileUpload) async {
      String downloadURL = await fileUpload.ref.getDownloadURL();
      ChatMessage message = ChatMessage(
        sender: widget.attenderName,
        email: widget.attenderEmail,
        content: downloadURL,
        isPicture: true,
        isMe: true,
        timestamp: Timestamp.fromDate(
          DateTime.now(),
        ),
      );
      FirebaseFirestore.instance
          .collection("bookings")
          .doc(widget.bookingID)
          .collection("chats")
          .doc()
          .set(
            message.toJson(),
          );
    }).onError((error, stackTrace) {
      Fluttertoast.showToast(msg: "Your image could not be uploaded");
    });
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    ChatMessage message = ChatMessage(
      sender: widget.attenderName,
      email: widget.attenderEmail,
      content: text,
      isPicture: false,
      isMe: true,
      timestamp: Timestamp.fromDate(
        DateTime.now(),
      ),
    );
    FirebaseFirestore.instance
        .collection("bookings")
        .doc(widget.bookingID)
        .collection("chats")
        .doc()
        .set(
          message.toJson(),
        );
    // var docRef = collection.doc(widget.bookingID).update({"chats": FieldValue.arrayUnion(message.toJson())})
  }

  Widget _buildChatList() {
    return Flexible(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("bookings")
            .doc(widget.bookingID)
            .collection("chats")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          List<ChatMessage> _messages = [];

          if (snapshot.hasData) {
            snapshot.data!.docs.forEach((element) {
              print(element.data());
              ChatMessage newMess = ChatMessage.fromJson(
                element.data(),
              );
              newMess.isMe = newMess.email == widget.attenderEmail;
              _messages.add(newMess);
            });
          }

          return !snapshot.hasData
              ? Container()
              : ListView.builder(
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ChatMessage message = _messages[index];
                    return _buildChatMessage(message);
                  },
                );
        },
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    final AlignmentGeometry alignment =
        message.isMe ? Alignment.centerRight : Alignment.centerLeft;

    final BorderRadiusGeometry borderRadius = message.isMe
        ? BorderRadius.only(
            topLeft: Radius.circular(16.0),
            bottomLeft: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
          )
        : BorderRadius.only(
            topRight: Radius.circular(16.0),
            bottomLeft: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
          );

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      alignment: alignment,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey[600],
            ),
          ),
          if (message.isPicture)
            Container(
              margin: EdgeInsets.only(top: 4.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: message.isMe ? Colors.deepPurple[300] : Colors.grey[200],
                borderRadius: borderRadius,
              ),
              child: Image.network(message.content),
            ),
          if (!message.isPicture)
            Container(
              margin: EdgeInsets.only(top: 4.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: message.isMe ? Colors.deepPurple[300] : Colors.grey[200],
                borderRadius: borderRadius,
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 16.0,
                  color: message.isMe ? Colors.white : Colors.deepPurple,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      margin: EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 5,
              ),
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration(
                  suffixIcon: GestureDetector(
                    onTap: () {
                      selectImageType(
                        context,
                      );
                    },
                    child: Icon(
                      Icons.photo,
                      color: kMainColor,
                    ),
                  ),
                  hintText: "Type a message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () => _handleSubmitted(_textController.text),
            color: Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Row(
          children: [
            Text(
              "Chat",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
              onTap: () {
                launch("tel:03353269262");
              },
              child: Icon(
                Icons.call,
                color: Colors.white,
              )),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildChatList(),
          Divider(
            height: 1.0,
            color: Colors.grey[300],
          ),
          _buildMessageInput(),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
