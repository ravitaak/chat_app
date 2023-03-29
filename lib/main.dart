import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:user_app/login_page.dart';
import 'package:user_app/models/firebase_helper.dart';
import 'package:uuid/uuid.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'models/user_model.dart';

var uuid = const Uuid();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    UserModel? newUserModel =
        await FirebaseHelper.getUserModelById(currentUser.uid);
    if (newUserModel != null) {
      runApp(MyAppLoggedIn(
        userModel: newUserModel,
        firebaseUser: currentUser,
      ));
    } else {
      runApp(const MyApp());
    }
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'poppins',
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  const MyAppLoggedIn(
      {super.key, required this.userModel, required this.firebaseUser});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'poppins',
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}
