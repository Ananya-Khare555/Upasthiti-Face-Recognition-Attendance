// import 'package:flutter/material.dart';
// import 'package:face_recog/Api/apiIntegration.dart';
// import 'package:face_recog/Custom_Widget/custom_dropdown.dart';
// import 'package:face_recog/Custom_Widget/custom_button.dart';

// class AcademicSelection {
//   final String? courseId;
//   final String? courseName;
//   final String? yearId;
//   final String? yearName;
//   final String? sectionId;
//   final String? sectionName;

//   AcademicSelection({
//     this.courseId,
//     this.courseName,
//     this.yearId,
//     this.yearName,
//     this.sectionId,
//     this.sectionName,
//   });

//   bool get isComplete => courseId != null && yearId != null && sectionId != null;

//   AcademicSelection copyWith({
//     String? courseId,
//     String? courseName,
//     String? yearId,
//     String? yearName,
//     String? sectionId,
//     String? sectionName,
//   }) {
//     return AcademicSelection(
//       courseId: courseId ?? this.courseId,
//       courseName: courseName ?? this.courseName,
//       yearId: yearId ?? this.yearId,
//       yearName: yearName ?? this.yearName,
//       sectionId: sectionId ?? this.sectionId,
//       sectionName: sectionName ?? this.sectionName,
//     );
//   }
// }

// class AcademicSelectionWidget extends StatefulWidget {
//   final String schoolId;
//   final String buttonText;
//   final Function(AcademicSelection) onSelectionComplete;
//   final bool autoLoadInitialData;

//   const AcademicSelectionWidget({
//     required this.onSelectionComplete,
//     this.schoolId = "1",
//     this.buttonText = "Continue",
//     this.autoLoadInitialData = true,
//     Key? key,
//   }) : super(key: key);

//   @override
//   _AcademicSelectionWidgetState createState() => _AcademicSelectionWidgetState();
// }

// class _AcademicSelectionWidgetState extends State<AcademicSelectionWidget> {
//   late AcademicSelection _selection;
//   List<Map<String, dynamic>> _courses = [];
//   List<Map<String, dynamic>> _years = [];
//   List<Map<String, dynamic>> _sections = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _selection = AcademicSelection();
//     if (widget.autoLoadInitialData) {
//       _loadInitialData();
//     } else {
//       _isLoading = false;
//     }
//   }

//   Future<void> _loadInitialData() async {
//     setState(() => _isLoading = true);
//     await _loadCourses();
//     setState(() => _isLoading = false);
//   }

//   Future<void> _loadCourses() async {
//     _courses = await ApiService.getCoursesBySchool(widget.schoolId);
//     _years = [];
//     _sections = [];
//     _selection = AcademicSelection();
//   }

//   Future<void> _loadYears(String courseId) async {
//     setState(() => _isLoading = true);
//     _years = await ApiService.getYearsByCourse(courseId);
//     _sections = [];
//     _selection = _selection.copyWith(
//       yearId: null,
//       yearName: null,
//       sectionId: null,
//       sectionName: null,
//     );
//     setState(() => _isLoading = false);
//   }

//   Future<void> _loadSections(String yearId) async {
//     setState(() => _isLoading = true);
//     _sections = await ApiService.getSectionsByYear(yearId);
//     _selection = _selection.copyWith(
//       sectionId: null,
//       sectionName: null,
//     );
//     setState(() => _isLoading = false);
//   }

//   // Helper to find matching item in list
//   Map<String, dynamic>? _findMatch(List<Map<String, dynamic>> items, String? id, String? name) {
//     if (id == null || name == null) return null;
//     return items.firstWhere(
//       (item) => item['id'].toString() == id && item['name'].toString() == name,
//       orElse: () => {'id': null, 'name': null},
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 6,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           if (_isLoading)
//             Center(child: CircularProgressIndicator())
//           else ...[
//             // Course Dropdown
//             CustomDropdown(
//               value: _findMatch(_courses, _selection.courseId, _selection.courseName),
//               items: _courses,
//               label: 'Course',
//               hint: 'Select Course',
//               onChanged: (value) async {
//                 if (value != null) {
//                   await _loadYears(value['id'].toString());
//                   setState(() {
//                     _selection = _selection.copyWith(
//                       courseId: value['id'].toString(),
//                       courseName: value['name'].toString(),
//                       yearId: null,
//                       yearName: null,
//                       sectionId: null,
//                       sectionName: null,
//                     );
//                   });
//                 }
//               },
//             ),
//             SizedBox(height: 16),

//             // Year Dropdown
//             CustomDropdown(
//               value: _findMatch(_years, _selection.yearId, _selection.yearName),
//               items: _years,
//               label: 'Year',
//               hint: 'Select Year',
//               onChanged: (value) async {
//                 if (value != null) {
//                   await _loadSections(value['id'].toString());
//                   setState(() {
//                     _selection = _selection.copyWith(
//                       yearId: value['id'].toString(),
//                       yearName: value['name'].toString(),
//                       sectionId: null,
//                       sectionName: null,
//                     );
//                   });
//                 }
//               },
//             ),
//             SizedBox(height: 16),

//             // Section Dropdown
//             CustomDropdown(
//               value: _findMatch(_sections, _selection.sectionId, _selection.sectionName),
//               items: _sections,
//               label: 'Section',
//               hint: 'Select Section',
//               onChanged: (value) {
//                 if (value != null) {
//                   setState(() {
//                     _selection = _selection.copyWith(
//                       sectionId: value['id'].toString(),
//                       sectionName: value['name'].toString(),
//                     );
//                   });
//                 }
//               },
//             ),
//             SizedBox(height: 24),

//             // Submit Button
//             CustomButton(
//               text: widget.buttonText,
//               onPressed: _selection.isComplete
//                   ? () => widget.onSelectionComplete(_selection)
//                   : null,
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }









// import 'package:flutter/material.dart';
// import 'package:face_recog/Api/apiIntegration.dart';
// import 'package:face_recog/Custom_Widget/custom_dropdown.dart';
// import 'package:face_recog/Custom_Widget/custom_button.dart';

// class AcademicSelection {
//   final String? courseId;
//   final String? courseName;
//   final String? yearId;
//   final String? yearName;
//   final String? sectionId;
//   final String? sectionName;

//   AcademicSelection({
//     this.courseId,
//     this.courseName,
//     this.yearId,
//     this.yearName,
//     this.sectionId,
//     this.sectionName,
//   });

//   bool get isComplete => courseId != null && yearId != null && sectionId != null;

//   AcademicSelection copyWith({
//     String? courseId,
//     String? courseName,
//     String? yearId,
//     String? yearName,
//     String? sectionId,
//     String? sectionName,
//   }) {
//     return AcademicSelection(
//       courseId: courseId ?? this.courseId,
//       courseName: courseName ?? this.courseName,
//       yearId: yearId ?? this.yearId,
//       yearName: yearName ?? this.yearName,
//       sectionId: sectionId ?? this.sectionId,
//       sectionName: sectionName ?? this.sectionName,
//     );
//   }
// }

// class AcademicSelectionWidget extends StatefulWidget {
//   final String schoolId;
//   final String buttonText;
//   final Function(AcademicSelection) onSelectionComplete;
//   final bool autoLoadInitialData;

//   const AcademicSelectionWidget({
//     required this.onSelectionComplete,
//     this.schoolId = "1",
//     this.buttonText = "Continue",
//     this.autoLoadInitialData = true,
//     Key? key,
//   }) : super(key: key);

//   @override
//   _AcademicSelectionWidgetState createState() => _AcademicSelectionWidgetState();
// }

// class _AcademicSelectionWidgetState extends State<AcademicSelectionWidget> {
//   late AcademicSelection _selection;
//   List<Map<String, dynamic>> _courses = [];
//   List<Map<String, dynamic>> _years = [];
//   List<Map<String, dynamic>> _sections = [];

//   @override
//   void initState() {
//     super.initState();
//     _selection = AcademicSelection();
//     if (widget.autoLoadInitialData) {
//       _loadCourses();
//     }
//   }

//   Future<void> _loadCourses() async {
//     _courses = await ApiService.getCoursesBySchool(widget.schoolId);
//     _years = [];
//     _sections = [];
//     _selection = AcademicSelection();
//     if (mounted) setState(() {});
//   }

//   Future<void> _loadYears(String courseId) async {
//     _years = await ApiService.getYearsByCourse(courseId);
//     _sections = [];
//     _selection = _selection.copyWith(
//       yearId: null,
//       yearName: null,
//       sectionId: null,
//       sectionName: null,
//     );
//     if (mounted) setState(() {});
//   }

//   Future<void> _loadSections(String yearId) async {
//     _sections = await ApiService.getSectionsByYear(yearId);
//     _selection = _selection.copyWith(
//       sectionId: null,
//       sectionName: null,
//     );
//     if (mounted) setState(() {});
//   }

//   Map<String, dynamic>? _findMatch(List<Map<String, dynamic>> items, String? id, String? name) {
//     if (id == null || name == null) return null;
//     return items.firstWhere(
//       (item) => item['id'].toString() == id && item['name'].toString() == name,
//       orElse: () => {'id': null, 'name': null},
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 6,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Course Dropdown
//           CustomDropdown(
//             value: _findMatch(_courses, _selection.courseId, _selection.courseName),
//             items: _courses,
//             label: 'Course',
//             hint: 'Select Course',
//             onChanged: (value) async {
//               if (value != null) {
//                 await _loadYears(value['id'].toString());
//                 if (mounted) {
//                   setState(() {
//                     _selection = _selection.copyWith(
//                       courseId: value['id'].toString(),
//                       courseName: value['name'].toString(),
//                       yearId: null,
//                       yearName: null,
//                       sectionId: null,
//                       sectionName: null,
//                     );
//                   });
//                 }
//               }
//             },
//           ),
//           SizedBox(height: 16),

//           // Year Dropdown
//           CustomDropdown(
//             value: _findMatch(_years, _selection.yearId, _selection.yearName),
//             items: _years,
//             label: 'Year',
//             hint: 'Select Year',
//             onChanged: (value) async {
//               if (value != null) {
//                 await _loadSections(value['id'].toString());
//                 if (mounted) {
//                   setState(() {
//                     _selection = _selection.copyWith(
//                       yearId: value['id'].toString(),
//                       yearName: value['name'].toString(),
//                       sectionId: null,
//                       sectionName: null,
//                     );
//                   });
//                 }
//               }
//             },
//           ),
//           SizedBox(height: 16),

//           // Section Dropdown
//           CustomDropdown(
//             value: _findMatch(_sections, _selection.sectionId, _selection.sectionName),
//             items: _sections,
//             label: 'Section',
//             hint: 'Select Section',
//             onChanged: (value) {
//               if (value != null && mounted) {
//                 setState(() {
//                   _selection = _selection.copyWith(
//                     sectionId: value['id'].toString(),
//                     sectionName: value['name'].toString(),
//                   );
//                 });
//               }
//             },
//           ),
//           SizedBox(height: 24),

//           // Submit Button
//           CustomButton(
//             text: widget.buttonText,
//             onPressed: _selection.isComplete
//                 ? () => widget.onSelectionComplete(_selection)
//                 : null,
//           ),
//         ],
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:face_recog/Api/apiIntegration.dart';
import 'package:face_recog/Custom_Widget/custom_dropdown.dart';
import 'package:face_recog/Custom_Widget/custom_button.dart';

class AcademicSelection {
  final String? courseId;
  final String? courseName;
  final String? yearId;
  final String? yearName;
  final String? sectionId;
  final String? sectionName;

  AcademicSelection({
    this.courseId,
    this.courseName,
    this.yearId,
    this.yearName,
    this.sectionId,
    this.sectionName,
  });

  bool get isComplete => courseId != null && yearId != null && sectionId != null;

  AcademicSelection copyWith({
    String? courseId,
    String? courseName,
    String? yearId,
    String? yearName,
    String? sectionId,
    String? sectionName,
  }) {
    return AcademicSelection(
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      yearId: yearId ?? this.yearId,
      yearName: yearName ?? this.yearName,
      sectionId: sectionId ?? this.sectionId,
      sectionName: sectionName ?? this.sectionName,
    );
  }
}

class AcademicSelectionWidget extends StatefulWidget {
  final String schoolId;
  final String buttonText;
  final Function(AcademicSelection) onSelectionComplete;
  final bool autoLoadInitialData;

  const AcademicSelectionWidget({
    required this.onSelectionComplete,
    this.schoolId = "1",
    this.buttonText = "Continue",
    this.autoLoadInitialData = true,
    Key? key,
  }) : super(key: key);

  @override
  _AcademicSelectionWidgetState createState() => _AcademicSelectionWidgetState();
}

class _AcademicSelectionWidgetState extends State<AcademicSelectionWidget> {
  late AcademicSelection _selection;
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _years = [];
  List<Map<String, dynamic>> _sections = [];

  @override
  void initState() {
    super.initState();
    _selection = AcademicSelection();
    if (widget.autoLoadInitialData) {
      _loadCourses();
    }
  }

  Future<void> _loadCourses() async {
    _courses = await ApiService.getCoursesBySchool(widget.schoolId);
    _years = [];
    _sections = [];
    if (mounted) setState(() {});
  }

  Future<void> _loadYears(String courseId) async {
    _years = await ApiService.getYearsByCourse(courseId);
    _sections = [];
    if (mounted) setState(() {});
  }

  Future<void> _loadSections(String yearId) async {
    _sections = await ApiService.getSectionsByYear(yearId);
    if (mounted) setState(() {});
  }

  Map<String, dynamic>? _findMatch(List<Map<String, dynamic>> items, String? id, String? name) {
    if (id == null || name == null) return null;
    return items.firstWhere(
      (item) => item['id'].toString() == id && item['name'].toString() == name,
      orElse: () => {'id': null, 'name': null},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Course Dropdown
          CustomDropdown(
            value: _findMatch(_courses, _selection.courseId, _selection.courseName),
            items: _courses,
            label: 'Course',
            hint: 'Select Course',
            onChanged: (value) async {
              if (value != null) {
                await _loadYears(value['id'].toString());
                if (mounted) {
                  setState(() {
                    _selection = AcademicSelection(
                      courseId: value['id'].toString(),
                      courseName: value['name'].toString(),
                    );
                  });
                }
              }
            },
          ),

          // Year Dropdown
          CustomDropdown(
            value: _findMatch(_years, _selection.yearId, _selection.yearName),
            items: _years,
            label: 'Year',
            hint: 'Select Year',
            onChanged: (value) async {
              if (value != null) {
                await _loadSections(value['id'].toString());
                if (mounted) {
                  setState(() {
                    _selection = _selection.copyWith(
                      yearId: value['id'].toString(),
                      yearName: value['name'].toString(),
                      sectionId: null,
                      sectionName: null,
                    );
                  });
                }
              }
            },
          ),

          // Section Dropdown
          CustomDropdown(
            value: _findMatch(_sections, _selection.sectionId, _selection.sectionName),
            items: _sections,
            label: 'Section',
            hint: 'Select Section',
            onChanged: (value) {
              if (value != null && mounted) {
                setState(() {
                  _selection = _selection.copyWith(
                    sectionId: value['id'].toString(),
                    sectionName: value['name'].toString(),
                  );
                });
              }
            },
          ),

          // Submit Button
          SizedBox(height:15),
          CustomButton(
            text: widget.buttonText,
            onPressed: _selection.isComplete
                ? () => widget.onSelectionComplete(_selection)
                : null,
          ),
        ],
      ),
    );
  }
}