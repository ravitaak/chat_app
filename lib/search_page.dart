import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chatroom_page.dart';
import 'main.dart';
import 'models/chatroom_model.dart';
import 'models/user_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);
  final UserModel userModel;
  final User firebaseUser;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      //return existing
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existingChatroom;
    } else {
      //create a new
      ChatRoomModel newChatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: ["", "", ""],
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
        createdon: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());

      widget.userModel.friends?.add(targetUser.uid!);
      FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.userModel.uid)
          .set(widget.userModel.toMap());

      targetUser.friends?.add(widget.userModel.uid);
      FirebaseFirestore.instance
          .collection("Users")
          .doc(targetUser.uid)
          .set(targetUser.toMap());

      chatRoom = newChatroom;
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Page"),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: const InputDecoration(labelText: "Email Address"),
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                onPressed: () {
                  setState(() {});
                },
                color: Theme.of(context).colorScheme.secondary,
                child: const Text("Search"),
              ),
              const SizedBox(height: 20),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Users")
                    .where("email", isEqualTo: searchController.text.trim())
                    .where("email", isNotEqualTo: widget.userModel.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;
                      if (dataSnapshot.docs.isNotEmpty) {
                        Map<String, dynamic> userMap =
                            dataSnapshot.docs[0].data() as Map<String, dynamic>;
                        UserModel searchedUser = UserModel.fromMap(userMap);
                        return ListTile(
                          onTap: () async {
                            ChatRoomModel? chatRoom =
                                await getChatroomModel(searchedUser);
                            if (chatRoom != null) {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                              Get.to(() => ChatRoomPage(
                                    chatroom: chatRoom,
                                    firebaseUser: widget.firebaseUser,
                                    targetUser: searchedUser,
                                    userModel: widget.userModel,
                                  ));
                            }
                          },
                          leading: CircleAvatar(
                            backgroundImage: (searchedUser.profilepic != "")
                                ? NetworkImage(searchedUser.profilepic!)
                                : null,
                            child: (searchedUser.profilepic == "")
                                ? const Icon(
                                    Icons.person,
                                  )
                                : null,
                          ),
                          title: Text(searchedUser.fullname!),
                          subtitle: Text(searchedUser.email!),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                        );
                      } else {
                        return const Center(child: Text("No Results Found!"));
                      }
                    } else if (snapshot.hasError) {
                      return const Center(child: Text("An Error Occured!"));
                    } else {
                      return const Center(child: Text("No Results Found!"));
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
