import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:user_app/models/user_model.dart';
import 'package:user_app/profile_page.dart';

import 'login_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: RegisterWidget(),
    );
  }
}

class RegisterWidget extends StatelessWidget {
  const RegisterWidget({
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
        width: double.infinity,
        height: size,
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
                            "Register",
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
                            "Create Your\nAccount!",
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
                        'assets/images/bg2.svg',
                        colorFilter: const ColorFilter.mode(
                            Colors.black, BlendMode.srcIn),
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
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(60),
                    )),
                child: const RegisterForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool registerBtnClicked = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();

  createUserAccount() async {
    registerBtnClicked = true;
    setState(() {});
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String fullName = userNameController.text.trim();
    String mobileNumber = mobileNumberController.text;
    UserCredential credential;
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = credential.user!.uid;
      UserModel userModel = UserModel(
          uid: uid,
          age: null,
          email: email,
          fullname: fullName,
          mobileNumber: mobileNumber,
          profilepic: "",
          friends: [],
          active: true,
          about: "");
      FirebaseFirestore.instance
          .collection("Users")
          .doc(uid)
          .set(userModel.toMap());
      // Go to HomePage
      if (credential.user != null) {
        Get.offAll(
            () => CompleteProfile(
                firebaseUser: credential.user!, userModel: userModel),
            duration: const Duration(milliseconds: 500),
            transition: Transition.downToUp);
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("error", e.toString(), duration: const Duration(seconds: 1));
    }
    registerBtnClicked = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
            controller: userNameController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: Colors.red,
            decoration: const InputDecoration(
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: "Full Name",
              prefixIcon: Icon(Icons.person, color: Colors.red),
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
            controller: emailController,
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
            controller: mobileNumberController,
            textInputAction: TextInputAction.next,
            cursorColor: Colors.red,
            decoration: const InputDecoration(
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: "Enter Mobile Number",
              prefixIcon: Icon(Icons.phone, color: Colors.red),
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
        InkWell(
          onTap: createUserAccount,
          child: Container(
            margin: const EdgeInsets.only(top: 50, right: 20, left: 20),
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
            child: registerBtnClicked
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : const Text(
                    "Register",
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
                const Text("Already have an account? "),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ));
                  },
                  child: const Text(
                    "Login Now!",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )),
      ],
    );
  }
}
