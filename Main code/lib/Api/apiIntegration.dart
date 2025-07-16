import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpException implements Exception {
  final String message;
  final int statusCode;

  HttpException(this.message, {this.statusCode = 500});

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = "http://192.168.63.151:8000";

  // Helper method for headers
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
    };
  }

//   // ======================
//   // School Endpoints
//   // ======================

//   static Future<Map<String, dynamic>> createSchool({
//     required String name,
//     required String address,
//     required String contact,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/schools/'),
//         headers: _getHeaders(),
//         body: json.encode({
//           'name': name,
//           'address': address,
//           'contact': contact,
//         }),
//       );
//       return json.decode(response.body);
//     } catch (e) {
//       throw Exception('Failed to create school: $e');
//     }
//   }

//   static Future<List<dynamic>> listSchools() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/schools/'),
//         headers: _getHeaders(),
//       );
//       return json.decode(response.body)['schools'];
//     } catch (e) {
//       throw Exception('Failed to list schools: $e');
//     }
//   }

//   // ======================
//   // Course Endpoints
//   // ======================

  static Future<Map<String, dynamic>> createCourse({
    required String schoolId,
    required String name,
    required int durationYears,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/courses/'),
        headers: _getHeaders(),
        body: json.encode({
          'school_id': schoolId,
          'name': name,
          'duration_years': durationYears,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to create course: $e');
    }
  }

 static Future<List<Map<String, dynamic>>> getCoursesBySchool(String schoolId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/schools/$schoolId/courses'),
      headers: _getHeaders(),
    );

    final data = json.decode(response.body);
    final courses = data['courses'] as List<dynamic>;

    // Return list of maps: [{'name': ..., 'id': ...}, ...]
    return courses
        .map<Map<String, dynamic>>(
          (course) => {
            'name': course['name'],
            'id': course['id'],
          },
        )
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch course names and IDs: $e');
  }
}



//   // ======================
//   // Year Endpoints
//   // ======================

  static Future<Map<String, dynamic>> createYear({
    required String courseId,
    required int yearNumber,
    List<String> subjects = const [],
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/years/'),
        headers: _getHeaders(),
        body: json.encode({
          'course_id': courseId,
          'year_number': yearNumber,
          'subjects': subjects,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to create year: $e');
    }
  }

 static Future<List<Map<String, dynamic>>> getYearsByCourse(String courseId) async {
  try {
    final url = '$baseUrl/courses/$courseId/years';
    final response = await http.get(
      Uri.parse(url),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> years = data['years'];

      final mappedList = years.map<Map<String, dynamic>>((year) {
        return {
          'name': year['year_number'].toString(),  // ISS POINT PARR YEAR_NUMBER MEY ERROR AA SAKTI HAI
          'id': year['id'].toString(),
        };
      }).toList();

      return mappedList;
    } else {
      throw Exception('Failed with status: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to get years: $e');
  }
}




//   // ======================
//   // Section Endpoints
//   // ======================

//   static Future<Map<String, dynamic>> createSection({
//     required String yearId,
//     required String name,
//     required String classTeacher,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/sections/'),
//         headers: _getHeaders(),
//         body: json.encode({
//           'year_id': yearId,
//           'name': name,
//           'class_teacher': classTeacher,
//         }),
//       );
//       return json.decode(response.body);
//     } catch (e) {
//       throw Exception('Failed to create section: $e');
//     }
//   }

  static Future<List<Map<String, dynamic>>> getSectionsByYear(String yearId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/years/$yearId/sections'),
      headers: _getHeaders(),
    );

    final data = json.decode(response.body);
    final sections = data['sections'] as List;

    // Map each section into the desired format
    return sections.map<Map<String, dynamic>>((section) {
      return {
        'name': section['name'],
        'id': section['id'],
      };
    }).toList();
  } catch (e) {
    throw Exception('Failed to get sections: $e');
  }
}

//   // ======================
//   // Student Endpoints
//   // ======================


static const int timeoutSeconds = 30;

  static Future<Map<String, dynamic>> registerStudent({
    required String sectionId,
    required String fullName,
    required String rollNumber,
    required String dateOfBirth,
    required File imageFile,
    String? email,
    String? phone,
    String? address,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/sections/$sectionId/students'),
      )..fields.addAll({
          'full_name': fullName,
          'roll_number': rollNumber,
          'date_of_birth': dateOfBirth,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
          if (address != null) 'address': address,
        });

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: 'student_$rollNumber.jpg',
      ));

      final response = await request.send().timeout(
        const Duration(seconds: timeoutSeconds),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );

      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonResponse;
      } else {
        throw HttpException(
          jsonResponse['message'] ?? 'Failed to register student',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on TimeoutException {
      throw Exception('Request timed out');
    } on FormatException {
      throw Exception('Invalid server response');
    } catch (e) {
      throw Exception('Failed to register student: ${e.toString()}');
    }
  }

//   static Future<Map<String, dynamic>> deleteStudentById(String studentId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/students/$studentId'),
//         headers: _getHeaders(),
//       );
//       return json.decode(response.body);
//     } catch (e) {
//       throw Exception('Failed to delete student: $e');
//     }
//   }

//   // ======================
//   // Attendance Endpoints
//   // ======================

  static Future<Map<String, dynamic>> markAttendance({
    required String sectionId,
    required String subject,
    required File imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/attendance/'),
      );
      
      request.headers.addAll(_getHeaders());
      request.fields['section_id'] = sectionId;
      request.fields['subject'] = subject;
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));
      
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      return json.decode(responseBody);
    } catch (e) {
      throw Exception('Failed to mark attendance: $e');
    }
  }

//   static Future<List<dynamic>> getAttendanceBySection(String sectionId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/sections/$sectionId/attendance'),
//         headers: _getHeaders(),
//       );
//       return json.decode(response.body)['attendance_records'];
//     } catch (e) {
//       throw Exception('Failed to get attendance records: $e');
//     }
//   }

//   // ======================
//   // Face Recognition
//   // ======================

//   static Future<Map<String, dynamic>> recognizeFace(File imageFile) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/recognize'),
//       );
      
//       request.files.add(await http.MultipartFile.fromPath(
//         'image',
//         imageFile.path,
//       ));

//       var response = await request.send();
//       final responseBody = await response.stream.bytesToString();
//       return json.decode(responseBody);
//     } catch (e) {
//       throw Exception('Failed to recognize face: $e');
//     }
//   }

//   // ======================
//   // System Management
//   // ======================

//   static Future<Map<String, dynamic>> resetAllData() async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/reset-all'),
//         headers: _getHeaders(),
//       );
//       return json.decode(response.body);
//     } catch (e) {
//       throw Exception('Failed to reset data: $e');
//     }
//   }
}






































// // api_service.dart
// import 'dart:io';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ApiService {

//   static const String baseUrl = "http://192.100.35.140:8000";

//   static Future<Map<String, dynamic>> registerFace(String name, File imageFile) async {
//   try {
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$baseUrl/register'),
//     );

//     request.fields['name'] = name;
//     request.files.add(await http.MultipartFile.fromPath(
//       'image',
//       imageFile.path,
//     ));

//     print('Sending request to: ${request.url}');

//     var response = await request.send();
//     final responseBody = await response.stream.bytesToString();

//     print('Response status: ${response.statusCode}');
//     print('Response body: $responseBody');

//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       return json.decode(responseBody);
//     } else {
//       throw Exception('Failed to register: ${response.statusCode}');
//     }
//   } on SocketException catch (e) {
//     print('Connection error: $e');
//     throw Exception('Could not connect to server. Please check your internet connection and try again.');
//   } catch (e) {
//     print('Error in registerFace: $e');
//     throw Exception('Failed to register face: $e');
//   }
// }

//   static Future<Map<String, dynamic>> recognizeFace(File imageFile) async {
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$baseUrl/recognize'),
//     );

//     request.files.add(await http.MultipartFile.fromPath(
//       'image',
//       imageFile.path,
//     ));

//     var response = await request.send();
//     return json.decode(await response.stream.bytesToString());
//   }

//   static Future<Map<String, dynamic>> markAttendance(String name, DateTime sessionTime) async {
//   final response = await http.post(
//     Uri.parse('$baseUrl/mark_attendance'),
//     headers: {'Content-Type': 'application/json'},
//     body: json.encode({
//       'name': name,
//       'session_time': sessionTime.toIso8601String(),
//     }),
//   );
//   return json.decode(response.body);
// }

//   static Future<List<dynamic>> getAttendanceRecords() async {
//     final response = await http.get(Uri.parse('$baseUrl/attendance'));
//     return json.decode(response.body)['data'];
//   }

//   static Future<List<dynamic>> getRegisteredStudents() async {
//     final response = await http.get(Uri.parse('$baseUrl/students'));
//     return json.decode(response.body)['data'];
//   }

//   static Future<Map<String, dynamic>> deleteStudent(String name) async {
//   try {
//     final response = await http.delete(
//       Uri.parse('$baseUrl/students/$name'),
//       headers: {'Content-Type': 'application/json'},
//     );

//     final responseData = json.decode(response.body);

//     // Force refresh students list after deletion
//     if (responseData['status'] == 'success') {
//       await getRegisteredStudents(); // Refresh the list
//     }

//     return responseData;
//   } catch (e) {
//     throw Exception('Failed to connect to server: $e');
//   }
// }

//   static Future<Map<String, dynamic>> resetAllData() async {
//   try {
//     final response = await http.delete(
//       Uri.parse('$baseUrl/reset-all'),
//       headers: {'Content-Type': 'application/json'},
//     );
//     return json.decode(response.body);
//   } catch (e) {
//     throw Exception('Failed to reset data: $e');
//   }
// }

//   static Future<Map<String, dynamic>> importStudents(String filePath) async {
//   try {
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$baseUrl/import-students'),
//     );

//     request.files.add(await http.MultipartFile.fromPath(
//       'excel_file',
//       filePath,
//     ));

//     var response = await request.send();
//     final responseData = await response.stream.bytesToString();

//     if (response.statusCode == 200) {
//       return json.decode(responseData);
//     } else {
//       throw Exception('Failed to import students: ${response.reasonPhrase}');
//     }
//   } catch (e) {
//     throw Exception('Error importing students: $e');
//   }
// }

// }







// import 'dart:io';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ApiService {
//   static const String baseUrl = "http://192.168.63.151:8000";

//   // Helper method for headers
  // static Map<String, String> _getHeaders() {
  //   return {'Content-Type': 'application/json'};
  // }

//   // Original endpoints (maintained for backward compatibility)
//   static Future<Map<String, dynamic>> registerFace(
//     String name,
//     File imageFile,
//   ) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/register'),
//       );

//       request.fields['name'] = name;
//       request.files.add(
//         await http.MultipartFile.fromPath('image', imageFile.path),
//       );

//       var response = await request.send();
//       final responseBody = await response.stream.bytesToString();

//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         return json.decode(responseBody);
//       } else {
//         throw Exception('Failed to register: ${response.statusCode}');
//       }
//     } on SocketException catch (e) {
//       throw Exception('Connection error: $e');
//     } catch (e) {
//       throw Exception('Failed to register face: $e');
//     }
//   }

//   static Future<Map<String, dynamic>> recognizeFace(File imageFile) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/recognize'),
//       );

//       request.files.add(
//         await http.MultipartFile.fromPath('image', imageFile.path),
//       );

//       var response = await request.send();
//       final responseBody = await response.stream.bytesToString();
//       return json.decode(responseBody);
//     } catch (e) {
//       throw Exception('Failed to recognize face: $e');
//     }
//   }

//   static Future<Map<String, dynamic>> markAttendance(
//     String name,
//     DateTime sessionTime,
//   ) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/mark_attendance'),
//         headers: _getHeaders(),
//         body: json.encode({
//           'name': name,
//           'session_time': sessionTime.toIso8601String(),
//         }),
//       );
//       return json.decode(response.body);
//     } catch (e) {
//       throw Exception('Failed to mark attendance: $e');
//     }
//   }

//   static Future<List<dynamic>> getAttendanceRecords() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/attendance'),
//         headers: _getHeaders(),
//       );
//       return json.decode(response.body)['data'];
//     } catch (e) {
//       throw Exception('Failed to get attendance records: $e');
//     }
//   }

//   static Future<List<dynamic>> getRegisteredStudents() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/students'),
//         headers: _getHeaders(),
//       );
//       return json.decode(response.body)['data'];
//     } catch (e) {
//       throw Exception('Failed to get registered students: $e');
//     }
//   }

//   static Future<Map<String, dynamic>> deleteStudent(String name) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/students/$name'),
//         headers: _getHeaders(),
//       );
//       final responseData = json.decode(response.body);
//       if (responseData['status'] == 'success') {
//         await getRegisteredStudents(); // Refresh the list
//       }
//       return responseData;
//     } catch (e) {
//       throw Exception('Failed to delete student: $e');
//     }
//   }

//   static Future<Map<String, dynamic>> resetAllData() async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/reset-all'),
//         headers: _getHeaders(),
//       );
//       return json.decode(response.body);
//     } catch (e) {
//       throw Exception('Failed to reset data: $e');
//     }
//   }

//   // New hierarchical endpoints
//   static Future<Map<String, dynamic>> createSchool(
//     String name,
//     String address,
//     String contact,
//   ) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/schools/'),
//         headers: _getHeaders(),
//         body: json.encode({
//           'name': name,
//           'address': address,
//           'contact': contact,
//         }),
//       );
//       return json.decode(response.body);
//     } catch (e) {
//       throw Exception('Failed to create school: $e');
//     }
//   }

//   static Future<List<dynamic>> listSchools() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/schools/'),
//         headers: _getHeaders(),
//       );
//       return json.decode(response.body)['schools'];
//     } catch (e) {
//       throw Exception('Failed to list schools: $e');
//     }
//   }

//   static Future<Map<String, dynamic>> addCourse(
//     String schoolName,
//     String courseName,
//     int durationYears,
//   ) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/$schoolName/courses/'),
//         headers: _getHeaders(),
//         body: json.encode({
//           'name': courseName,
//           'duration_years': durationYears,
//         }),
//       );
//       return json.decode(response.body);
//     } catch (e) {
//       throw Exception('Failed to add course: $e');
//     }
//   }

//   static Future<List<dynamic>> listCourses(String schoolName) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/$schoolName/courses/'),
//         headers: _getHeaders(),
//       );
//       return json.decode(response.body)['courses'];
//     } catch (e) {
//       throw Exception('Failed to list courses: $e');
//     }
//   }

//   static Future<Map<String, dynamic>> registerStudent({
//     required String schoolName,
//     required String courseName,
//     required int yearNumber,
//     required String sectionName,
//     required String rollNo,
//     required String name,
//     String? email,
//     String? phone,
//     String? address,
//     required File imageFile,
//   }) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse(
//           '$baseUrl/$schoolName/$courseName/$yearNumber/$sectionName/students/',
//         ),
//       );

//       request.headers.addAll(_getHeaders());

//       request.fields['roll_no'] = rollNo;
//       request.fields['name'] = name;
//       if (email != null) request.fields['email'] = email;
//       if (phone != null) request.fields['phone'] = phone;
//       if (address != null) request.fields['address'] = address;

//       request.files.add(
//         await http.MultipartFile.fromPath('image', imageFile.path),
//       );

//       var response = await request.send();
//       final responseBody = await response.stream.bytesToString();

//       return json.decode(responseBody);
//     } catch (e) {
//       throw Exception('Failed to register student: $e');
//     }
//   }

//   static Future<Map<String, dynamic>> takeAttendance({
//     required String schoolName,
//     required String courseName,
//     required int yearNumber,
//     required String sectionName,
//     required String subject,
//     required File imageFile,
//   }) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse(
//           '$baseUrl/$schoolName/$courseName/$yearNumber/$sectionName/take-attendance',
//         ),
//       );

//       request.headers.addAll(_getHeaders());
//       request.fields['subject'] = subject;
//       request.files.add(
//         await http.MultipartFile.fromPath('image', imageFile.path),
//       );

//       var response = await request.send();
//       final responseBody = await response.stream.bytesToString();

//       return json.decode(responseBody);
//     } catch (e) {
//       throw Exception('Failed to take attendance: $e');
//     }
//   }

//   static Future<List<dynamic>> getHierarchicalAttendance({
//     required String schoolName,
//     String? courseName,
//     int? yearNumber,
//     String? sectionName,
//     String? date,
//     String? subject,
//   }) async {
//     try {
//       String url = '$baseUrl/$schoolName/attendance?';
//       if (courseName != null) url += 'course_name=$courseName&';
//       if (yearNumber != null) url += 'year_number=$yearNumber&';
//       if (sectionName != null) url += 'section_name=$sectionName&';
//       if (date != null) url += 'date=$date&';
//       if (subject != null) url += 'subject=$subject';

//       final response = await http.get(Uri.parse(url), headers: _getHeaders());
//       return json.decode(response.body)['records'];
//     } catch (e) {
//       throw Exception('Failed to get hierarchical attendance: $e');
//     }
//   }

//   static Future<List<dynamic>> listStudentsInSection({
//     required String schoolName,
//     required String courseName,
//     required int yearNumber,
//     required String sectionName,
//   }) async {
//     try {
//       final response = await http.get(
//         Uri.parse(
//           '$baseUrl/$schoolName/$courseName/$yearNumber/$sectionName/students/',
//         ),
//         headers: _getHeaders(),
//       );
//       return json.decode(response.body)['students'];
//     } catch (e) {
//       throw Exception('Failed to list students: $e');
//     }
//   }

//   Future<Map<String, dynamic>> getStudentsForAttendance(
//     String courseId,
//     String yearId,
//     String sectionId,
//   ) async {
//     final url = Uri.parse(
//       '$baseUrl/get_student_for_attendance',
//     );
//     final response = await http.get(
//       url.replace(
//         queryParameters: {
//           'course_id': courseId,
//           'year_id': yearId,
//           'section_id': sectionId,
//         },
//       ),
//       headers: {'Content-Type': 'application/json'},
//     );

//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to load students for attendance');
//     }
//   }

//   // // Usage example:
//   // void fetchStudents() async {
//   //   try {
//   //     final data = await getStudentsForAttendance(
//   //       'your-course-id',
//   //       'your-year-id',
//   //       'your-section-id',
//   //     );
//   //     print(data['students']); // List of students
//   //   } catch (e) {
//   //     print('Error: $e');
//   //   }
//   // }
// }
