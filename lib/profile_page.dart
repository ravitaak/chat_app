import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_app/home_page.dart';

import 'models/user_model.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfile(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  CompleteProfileState createState() => CompleteProfileState();
}

class CompleteProfileState extends State<CompleteProfile> {
  File? imageFile;
  TextEditingController ageController = TextEditingController();
  TextEditingController aboutController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 20);
    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Upload Profile Picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: const Icon(Icons.photo_album),
                  title: const Text("Select from Gallery"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Take a photo"),
                ),
              ],
            ),
          );
        });
  }

  void checkValues() {
    String age = aboutController.text.trim();
    String about = ageController.text.trim();

    if (age == "" || about == "" || imageFile == null) {
      debugPrint("Please fill all the fields");
      debugPrint(
          "Incomplete Data Please fill all the fields and upload a profile picture");
    } else {
      log("Uploading data..");
      uploadData(age, about);
    }
  }

  void uploadData(String age, String about) async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;

    String? imageUrl = await snapshot.ref.getDownloadURL();
    widget.userModel.profilepic = imageUrl;
    widget.userModel.about = about;
    widget.userModel.age = age;

    await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      log("Data uploaded!");
      Navigator.popUntil(context, (route) => route.isFirst);
      Get.offAll(
          () => HomePage(
              firebaseUser: widget.firebaseUser, userModel: widget.userModel),
          duration: const Duration(milliseconds: 500),
          transition: Transition.downToUp);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text("Complete Profile"),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ListView(
            children: [
              const SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: () {
                  showPhotoOptions();
                },
                padding: const EdgeInsets.all(0),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      (imageFile != null) ? FileImage(imageFile!) : null,
                  child: (imageFile == null)
                      ? const Icon(
                          Icons.person,
                          size: 60,
                        )
                      : null,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                maxLength: 3,
                decoration: const InputDecoration(
                  labelText: "Age",
                ),
              ),
              TextField(
                controller: aboutController,
                decoration: const InputDecoration(
                  labelText: "About",
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: () {
                  checkValues();
                },
                color: Theme.of(context).colorScheme.secondary,
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
