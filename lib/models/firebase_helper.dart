import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/models/user_model.dart';

class FirebaseHelper {
  static Future<UserModel?> getUserModelById(String uid) async {
    UserModel? userModel;
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection("Users").doc(uid).get();

    if (snapshot.data() != null) {
      userModel = UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
    }
    return userModel;
  }
}
