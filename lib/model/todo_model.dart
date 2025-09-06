import 'dart:ffi';

class TodoModel {
  String email;
  final String title;
  final int id;
  TodoModel({required this.title, required this.id,required this.email});
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(id: json['id'], title: json['title'],email:json["email"]);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title,"email":email};
  }
}
