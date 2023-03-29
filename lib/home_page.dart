import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:user_app/login_page.dart';
import 'package:user_app/models/chatroom_model.dart';
import 'package:user_app/models/firebase_helper.dart';
import 'package:user_app/search_page.dart';

import 'chatroom_page.dart';
import 'models/user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);
  final UserModel userModel;
  final User firebaseUser;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) {
      userStatusUpdate(false);
    } else if (state == AppLifecycleState.resumed) {
      userStatusUpdate(true);
    }
  }

  void userStatusUpdate(bool status) {
    widget.userModel.active = status;
    FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap());
  }

  Future<bool> onpopWillRun() {
    return Future<bool>.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onpopWillRun,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          actions: [
            IconButton(
                splashRadius: 24,
                onPressed: () async {
                  userStatusUpdate(false);
                  await FirebaseAuth.instance.signOut();
                  Get.to(() => const LoginPage());
                },
                icon: const Icon(Icons.exit_to_app))
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Get.to(() => SearchPage(
                    userModel: widget.userModel,
                    firebaseUser: widget.firebaseUser,
                  ));
            },
            child: const Icon(
              Icons.search,
              size: 30,
              color: Colors.white,
            )),
        body: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Users")
                  .doc(widget.userModel.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    UserModel thisUser;
                    DocumentSnapshot thisUserData =
                        snapshot.data as DocumentSnapshot;
                    thisUser = UserModel.fromMap(
                        thisUserData.data() as Map<String, dynamic>);
                    return ListView.builder(
                      itemCount: thisUser.friends?.length,
                      itemBuilder: (context, int index) {
                        //FRIEND
                        return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("Users")
                              .doc(thisUser.friends![index])
                              .snapshots(),
                          builder: (context, newUSer) {
                            if (newUSer.connectionState ==
                                ConnectionState.active) {
                              if (newUSer.hasData) {
                                UserModel targetUser;
                                DocumentSnapshot dataSnapshot =
                                    newUSer.data as DocumentSnapshot;
                                if (dataSnapshot.data() != null) {
                                  targetUser = UserModel.fromMap(dataSnapshot
                                      .data() as Map<String, dynamic>);

                                  //ChatROOM
                                  return StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection("chatrooms")
                                          .where("participants.${thisUser.uid}",
                                              isEqualTo: true)
                                          .where(
                                              "participants.${targetUser.uid}",
                                              isEqualTo: true)
                                          .snapshots(),
                                      builder: (context, chatSnapshot) {
                                        if (chatSnapshot.connectionState ==
                                            ConnectionState.active) {
                                          if (chatSnapshot.hasData) {
                                            ChatRoomModel? chatRoomModel;
                                            QuerySnapshot chatData =
                                                chatSnapshot.data
                                                    as QuerySnapshot;

                                            if (chatData.docs.isNotEmpty) {
                                              var docData =
                                                  chatData.docs[0].data();
                                              chatRoomModel =
                                                  ChatRoomModel.fromMap(docData
                                                      as Map<String, dynamic>);
                                            }
                                            return ListTile(
                                              onTap: () async {
                                                Get.to(() => ChatRoomPage(
                                                      chatroom: chatRoomModel!,
                                                      firebaseUser:
                                                          widget.firebaseUser,
                                                      targetUser: targetUser,
                                                      userModel:
                                                          widget.userModel,
                                                    ));
                                              },
                                              leading: Stack(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    backgroundImage:
                                                        const AssetImage(
                                                            'assets/images/loading.gif'),
                                                    child: (targetUser
                                                                .profilepic ==
                                                            "")
                                                        ? const CircleAvatar(
                                                            backgroundColor:
                                                                Colors.red,
                                                            child: Icon(
                                                                Icons.person,
                                                                color: Colors
                                                                    .white),
                                                          )
                                                        : CircleAvatar(
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            backgroundImage:
                                                                NetworkImage(
                                                                    targetUser
                                                                        .profilepic!),
                                                          ),
                                                  ),
                                                  Positioned(
                                                      bottom: 0,
                                                      right: 0,
                                                      child: Container(
                                                        width: 12,
                                                        height: 12,
                                                        decoration: (targetUser
                                                                    .active ==
                                                                null)
                                                            ? null
                                                            : BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            25),
                                                                color: (targetUser
                                                                        .active!)
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .grey,
                                                              ),
                                                      ))
                                                ],
                                              ),
                                              title: Text(targetUser.fullname!),
                                              subtitle: (chatRoomModel
                                                          ?.lastMessage![1]
                                                          .toString() !=
                                                      "")
                                                  ? Text(chatRoomModel
                                                      ?.lastMessage![1])
                                                  : Text(
                                                      "Say hi to your new friend",
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary),
                                                    ),
                                              trailing: const Icon(
                                                  Icons.keyboard_arrow_right),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        } else {
                                          return Container();
                                        }
                                      });
                                } else {
                                  return Container();
                                }
                              } else {
                                return Container();
                              }
                            } else {
                              return Container();
                            }
                          },
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("An Error Occured!"));
                  } else {
                    return const Center(child: Text("No Chat Found!"));
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
