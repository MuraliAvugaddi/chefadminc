import 'package:get/get.dart';

class AppUser {
  final String id;
  final String name;
  final String enrollmentNo;
  final String phonenumber;
  final String course;
  final String year;
  final String room;
  final String gender;
  final String fatherPhone;
  RxBool isApproved;
  final DateTime? accessExpiresAt;

  AppUser({
    required this.id,
    required this.name,
    required this.enrollmentNo,
    required this.phonenumber,
    required this.course,
    required this.year,
    required this.room,
    required this.gender,
    required this.fatherPhone,
    required bool isApproved,
    this.accessExpiresAt,
  }) : isApproved = RxBool(isApproved);

  factory AppUser.fromJson(Map<String, dynamic> json) {
    // Read both _id and id safely
    final rawId = json['_id'] ?? json['id'];
    final resolvedId = (rawId != null && rawId.toString().isNotEmpty)
        ? rawId.toString().trim()
        : '';

    // Handle boolean, string, or number conversions for approval
    final rawApproved = json['isApproved'];
    bool approved = false;
    if (rawApproved is bool) {
      approved = rawApproved;
    } else if (rawApproved is num) {
      approved = rawApproved == 1;
    } else if (rawApproved != null) {
      approved = rawApproved.toString().trim().toLowerCase() == 'true';
    }

    return AppUser(
      id: resolvedId,
      name: (json['name'] ?? 'Unnamed').toString().trim(),
      enrollmentNo: (json['enrollmentNo'] ?? json['enrollment'] ?? 'N/A').toString().trim(),
      phonenumber: (json['phonenumber'] ?? json['phone'] ?? '').toString().trim(),
      course: (json['course'] ?? 'N/A').toString().trim(),
      year: (json['year'] ?? '1').toString().trim(),
      room: (json['room'] ?? 'N/A').toString().trim(),
      gender: (json['gender'] ?? 'All').toString().trim(),
      fatherPhone: (json['fatherPhone'] ?? json['father_phone'] ?? '').toString().trim(),
      isApproved: approved,
      accessExpiresAt: json['accessExpiresAt'] != null
          ? DateTime.tryParse(json['accessExpiresAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'name': name,
      'enrollmentNo': enrollmentNo,
      'phonenumber': phonenumber,
      'course': course,
      'year': year,
      'room': room,
      'gender': gender,
      'fatherPhone': fatherPhone,
      'isApproved': isApproved.value,
      'accessExpiresAt': accessExpiresAt?.toIso8601String(),
    };
  }
}