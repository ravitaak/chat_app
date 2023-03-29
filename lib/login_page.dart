import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:user_app/register_page.dart';

import 'home_page.dart';
import 'models/user_model.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LoginWidget(),
    );
  }
}

class LoginWidget extends StatelessWidget {
  const LoginWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double size;
    double wSize;
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    if (currentOrientation == Orientation.portrait) {
      size = MediaQuery.of(context).size.height;
      wSize = MediaQuery.of(context).size.width;
    } else {
      size = MediaQuery.of(context).size.width;
      wSize = MediaQuery.of(context).size.height;
    }

    return SingleChildScrollView(
        child: Container(
      height: size,
      width: double.infinity,
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [Colors.red, Colors.orange, Colors.pink])),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 60,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: wSize * 0.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      FittedBox(
                        fit: BoxFit.cover,
                        child: Text(
                          overflow: TextOverflow.ellipsis,
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 46,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.cover,
                        child: Text(
                          "Welcome Back!",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Opacity(
                    opacity: 0.2,
                    child: SvgPicture.asset(
                      'assets/images/bg1.svg',
                      colorFilter:
                          const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                      width: 200,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: size * 0.06,
          ),
          const LoginForm(),
        ],
      ),
    ));
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool loginBtnClicked = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  void loginUserAccount() async {
    loginBtnClicked = true;
    setState(() {});
    UserCredential credential;
    UserModel userModel;
    try {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      String uid = credential.user!.uid;
      debugPrint(uid);
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      debugPrint(userData.data().toString());
      // Go to HomePage
      debugPrint("Log In Successful!");
      userModel = UserModel.fromMap(userData.data() as Map<String, dynamic>);
      Get.offAll(
          () => HomePage(userModel: userModel, firebaseUser: credential.user!),
          duration: const Duration(milliseconds: 500),
          transition: Transition.downToUp);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Get.snackbar("error", 'No user found for that email.',
            duration: const Duration(seconds: 1));
      } else if (e.code == 'wrong-password') {
        Get.snackbar("error", 'Wrong password provided for that user.');
      } else {
        Get.snackbar("error", "Unkown error.");
      }
    }
    loginBtnClicked = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(60),
            )),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 20, left: 20, top: 70),
              padding: const EdgeInsets.only(left: 10, right: 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.grey[200],
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xffEEEEEE),
                        blurRadius: 50,
                        offset: Offset(0, 0))
                  ]),
              child: TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                cursorColor: Colors.red,
                decoration: const InputDecoration(
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: "Enter Email",
                  prefixIcon: Icon(Icons.email, color: Colors.red),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 20, left: 20, top: 20),
              padding: const EdgeInsets.only(left: 10, right: 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.grey[200],
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xffEEEEEE),
                        blurRadius: 50,
                        offset: Offset(0, 10))
                  ]),
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                cursorColor: Colors.red,
                decoration: const InputDecoration(
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: "Enter Password",
                  prefixIcon: Icon(Icons.vpn_key, color: Colors.red),
                ),
              ),
            ),
            Container(
                margin: const EdgeInsets.only(top: 5, right: 20),
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Forget Password?",
                    style: TextStyle(color: Colors.black54),
                  ),
                )),
            InkWell(
              onTap: loginUserAccount,
              child: Container(
                margin: const EdgeInsets.only(top: 60, right: 20, left: 20),
                height: 50,
                padding: const EdgeInsets.only(left: 20, right: 20),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.red, Colors.pink]),
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xfffEEEEE),
                      blurRadius: 50,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: loginBtnClicked
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
              ),
            ),
            Container(
                margin: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have account? "),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ));
                      },
                      child: const Text(
                        "Register Now!",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
