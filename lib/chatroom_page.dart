import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:user_app/models/message_model.dart';

import 'main.dart';
import 'models/chatroom_model.dart';
import 'models/user_model.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage(
      {super.key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendMsg() async {
    String msg = messageController.text.trim();
    messageController.clear();
    if (msg != "") {
      MessageModel newMessage = MessageModel(
        createdon: DateTime.now(),
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        text: msg,
        seen: false,
      );

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.chatroom.lastMessage = [
        widget.userModel.uid,
        msg,
        DateTime.now(),
        false
      ];

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage:
                      const AssetImage('assets/images/loading.gif'),
                  child: (widget.targetUser.profilepic == "")
                      ? const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person),
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage:
                              NetworkImage(widget.targetUser.profilepic!),
                        ),
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: (widget.targetUser.active == null)
                          ? null
                          : BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: (widget.targetUser.active!)
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                    ))
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Text(widget.targetUser.fullname.toString()),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                opacity: 0.5,
                image: NetworkImage(
                    "https://i.pinimg.com/736x/8c/98/99/8c98994518b575bfd8c949e91d20548b.jpg"))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("chatrooms")
                  .doc(widget.chatroom.chatroomid)
                  .collection("messages")
                  .orderBy("createdon", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                    return ListView.builder(
                      reverse: true,
                      itemCount: dataSnapshot.docs.length,
                      itemBuilder: (context, index) {
                        MessageModel currentMsg = MessageModel.fromMap(
                            dataSnapshot.docs[index].data()
                                as Map<String, dynamic>);
                        if (currentMsg.sender != widget.userModel.uid &&
                            currentMsg.seen != true) {
                          currentMsg.seen = true;
                          FirebaseFirestore.instance
                              .collection("chatrooms")
                              .doc(widget.chatroom.chatroomid)
                              .collection("messages")
                              .doc(currentMsg.messageid)
                              .set(currentMsg.toMap());
                        }
                        return Row(
                          mainAxisAlignment:
                              (currentMsg.sender == widget.userModel.uid)
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment:
                                  (currentMsg.sender == widget.userModel.uid)
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              .5),
                                  margin: const EdgeInsets.only(
                                      left: 7, bottom: 2, right: 7, top: 5),
                                  padding: const EdgeInsets.only(
                                      left: 10, bottom: 5, right: 10, top: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: (currentMsg.sender ==
                                            widget.userModel.uid)
                                        ? Colors.red
                                        : Colors.black54,
                                  ),
                                  child: Text(
                                    currentMsg.text!,
                                    softWrap: true,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.only(left: 7, right: 7),
                                  child: (currentMsg.sender ==
                                          widget.userModel.uid)
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              (currentMsg.sender ==
                                                      widget.userModel.uid)
                                                  ? MainAxisAlignment.end
                                                  : MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              DateFormat('hh:mm a')
                                                  .format(DateTime.now()),
                                              style:
                                                  const TextStyle(fontSize: 10),
                                            ),
                                            Icon(
                                              (currentMsg.seen!)
                                                  ? Icons.done_all
                                                  : Icons.check,
                                              size: 14,
                                            ),
                                          ],
                                        )
                                      : Text(
                                          DateFormat(' hh:mm a')
                                              .format(DateTime.now()),
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                )
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text(
                            "An Error Occured! Please check your internet connection"));
                  } else {
                    return const Center(
                        child: Text("Say hi to your new friend!"));
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),

          Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(50),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 5,
                          spreadRadius: 0.1,
                          blurStyle: BlurStyle.outer,
                        ),
                      ],
                      color: Colors.grey[200]),
                  child: TextFormField(
                    textInputAction: TextInputAction.send,
                    onFieldSubmitted: (value) => sendMsg(),
                    maxLines: null,
                    controller: messageController,
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: "Enter Message"),
                  ),
                ),
              ),
              FloatingActionButton.small(
                backgroundColor: Colors.red,
                onPressed: sendMsg,
                child: const Icon(
                  Icons.send,
                  size: 18,
                ),
              ),
              const SizedBox(
                width: 10,
              )
            ],
          ),

          // end of msg bar
        ]),
      ),
    );
  }
}
