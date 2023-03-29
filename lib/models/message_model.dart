class MessageModel {
  String? messageid;
  String? sender;
  String? text;
  DateTime? createdon;
  bool? seen;

  MessageModel(
      {this.messageid, this.sender, this.text, this.createdon, this.seen});

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageid = map["messageid"];
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createdon = map["createdon"].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "messageid": messageid,
      "sender": sender,
      "text": text,
      "seen": seen,
      "createdon": createdon
    };
  }
}
