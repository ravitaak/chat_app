class UserModel {
  String? uid;
  String? fullname;
  String? email;
  String? profilepic;
  String? mobileNumber;
  String? about;
  String? age;
  List<dynamic>? friends;
  bool? active;
  UserModel({
    required this.uid,
    required this.fullname,
    required this.email,
    required this.profilepic,
    required this.mobileNumber,
    required this.about,
    required this.age,
    required this.friends,
    required this.active,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'fullname': fullname,
      'email': email,
      'profilepic': profilepic,
      'mobileNumber': mobileNumber,
      'about': about,
      'age': age,
      'friends': friends,
      'active': active,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      fullname: map['fullname'],
      email: map['email'],
      profilepic: map['profilepic'],
      mobileNumber: map['mobileNumber'],
      about: map['about'],
      age: map['age'],
      friends: map['friends'],
      active: map['active'],
    );
  }
}
