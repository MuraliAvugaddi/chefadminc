import 'package:get/get.dart';

class AppUser {
  final String id;
  final String name;
  final String enrollmentNo;
  final String phonenumber;
  final String course;
  final String year;
  final String room;
  RxBool isApproved;

  AppUser({
    required this.id,
    required this.name,
    required this.enrollmentNo,
    required this.phonenumber,
    required this.course,
    required this.year,
    required this.room,
    required bool approved,
  }) : isApproved = approved.obs;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['_id'] ?? 'N/A',
      name: json['name'] ?? 'N/A',
      enrollmentNo: json['enrollmentNo']?.toString() ?? 'N/A',
      phonenumber: json['phonenumber']?.toString() ?? 'N/A',
      course: json['course'] ?? 'N/A',
      year: json['year']?.toString() ?? 'N/A',
      room: json['room']?.toString() ?? 'N/A',
      approved: json['isApproved'] ?? false,
    );
  }
}
