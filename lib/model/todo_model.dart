import 'dart:ffi';

class TodoModel {
  final String email;
  final String title;
  final String deadLine;
  final String desc;
  final int id;

  TodoModel({
    required this.title,
    required this.id,
    required this.email,
    required this.desc,
    required this.deadLine,
  });
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      title: json['title'],
      email: json["email"],
      deadLine: json["createdAt"],
      desc: json["desc"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      "email": email,
      "createdAt": deadLine,
      "desc": desc,
    };
  }
}
