// import 'package:face_recog/Custom_Widget/custom_academic_info_widget.dart';
// import 'package:face_recog/constants/constants.dart';
// import 'package:flutter/material.dart';

// class StudentsTab extends StatefulWidget {
//   const StudentsTab({Key? key}) : super(key: key);

//   @override
//   _StudentsTabState createState() => _StudentsTabState();
// }

// class _StudentsTabState extends State<StudentsTab> {
//   List<String> _students = [];
//   List<String> _filteredStudents = [];
//   bool _isLoading = false;
//   bool _showPlaceholder = true;
//   final TextEditingController _searchController = TextEditingController();
//   Set<int> _expandedIndices = {};

//   // Dropdown values
//   String? _selectedSchool;
//   String? _selectedCourse;
//   String? _selectedYearSection;

//   // Dummy data for dropdowns
//   final List<String> _schools = ['School 1', 'School 2'];
//   final Map<String, List<String>> _courses = {
//     'School 1': ['Course A', 'Course B'],
//     'School 2': ['Course C', 'Course D'],
//   };
//   final Map<String, List<String>> _yearSections = {
//     'Course A': ['Year 1 - Section A', 'Year 1 - Section B'],
//     'Course B': ['Year 2 - Section A', 'Year 2 - Section B'],
//   };

//   @override
//   void initState() {
//     super.initState();
//     // Initialize without loading - we'll load after dropdown selections
//   }

//   Future<void> _loadStudents() async {
//     if (_selectedSchool == null ||
//         _selectedCourse == null ||
//         _selectedYearSection == null)
//       return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Simulate API call
//       await Future.delayed(Duration(seconds: 2));

//       final students = [
//         'John Doe',
//         'Jane Smith',
//         'Robert Johnson',
//         'Emily Davis',
//         'Michael Wilson',
//       ];

//       setState(() {
//         _students = List.from(students);
//         _filteredStudents = List.from(students);
//         _isLoading = false;
//         _showPlaceholder = false; // Hide the SVG after data loads
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to load students: $e')));
//     }
//   }

//   void _handleDropdownChange() {
//     if (_selectedSchool != null &&
//         _selectedCourse != null &&
//         _selectedYearSection != null) {
//       _loadStudents();
//     }
//   }

//   // ... keep your existing _filterStudents, _toggleExpand, _buildStudentDetails methods ...

//   void _filterStudents(String query) {
//     setState(() {
//       _filteredStudents =
//           _students
//               .where(
//                 (student) =>
//                     student.toLowerCase().startsWith(query.toLowerCase()),
//               )
//               .toList();
//     });
//   }

//   void _toggleExpand(int index) {
//     setState(() {
//       if (_expandedIndices.contains(index)) {
//         _expandedIndices.remove(index);
//       } else {
//         _expandedIndices.add(index);
//       }
//     });
//   }

//   Widget _buildStudentDetails(String student) {
//     // Simulated student data - replace with actual data from your API
//     final attendance = {
//       'Math': '85%',
//       'Science': '92%',
//       'English': '78%',
//       'History': '88%',
//     };

//     final testMarks = {
//       'Math': '92/100',
//       'Science': '88/100',
//       'English': '85/100',
//       'History': '90/100',
//     };

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Attendance', style: TextStyle(fontWeight: FontWeight.bold)),
//           SizedBox(height: 8),
//           ...attendance.entries
//               .map(
//                 (subject) => Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 4.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(subject.key),
//                       Text(
//                         subject.value,
//                         style: TextStyle(color: Colors.green),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//               .toList(),

//           // Divider(),

//           // Text('Test Marks', style: TextStyle(fontWeight: FontWeight.bold)),
//           // SizedBox(height: 8),
//           // ...testMarks.entries.map((subject) => Padding(
//           //   padding: const EdgeInsets.symmetric(vertical: 4.0),
//           //   child: Row(
//           //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           //     children: [
//           //       Text(subject.key),
//           //       Text(subject.value, style: TextStyle(color: Colors.blue)),
//           //     ],
//           //   ),
//           // )).toList(),
//           Divider(),

//           Text(
//             'Overall Performance',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 8),
//           LinearProgressIndicator(
//             value: 0.86, // Replace with actual value
//             backgroundColor: Colors.grey[200],
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
//           ),
//           SizedBox(height: 8),
//           Text('86% Overall', textAlign: TextAlign.center),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: Column(
//           children: [
//             // In any of your screens:
//             Container(
//               height: 400,
//               child: AcademicSelectionWidget(
//                 onSelectionComplete: (selection){
//                   print("${selection.courseName}");
//                   print("${selection.yearName}");
//                   print("${selection.sectionName}");
//                   print("${selection.courseId}");
//                   print("${selection.yearId}");
//                   print("${selection.sectionId}");
//                 },
//               ),
//             ),      
//             Expanded(
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   // SVG Placeholder (shown when dropdowns aren't fully selected or during initial load)
//                   if (_showPlaceholder)
//                     AnimatedOpacity(
//                       opacity:
//                           (_selectedSchool == null ||
//                                   _selectedCourse == null ||
//                                   _selectedYearSection == null)
//                               ? 1.0
//                               : 0.0,
//                       duration: Duration(milliseconds: 500),
//                       child: Image.asset(
//                         'assets/images/img4.png',
//                         width: MediaQuery.of(context).size.width * 2,
//                       ),
//                       onEnd: () {
//                         if (_selectedSchool != null &&
//                             _selectedCourse != null &&
//                             _selectedYearSection != null) {
//                           setState(() => _showPlaceholder = false);
//                         }
//                       },
//                     ),

//                   // Loading Indicator (shown on top of SVG when loading)
//                   if (_isLoading)
//                     Center(
//                       child: CircularProgressIndicator(color: kPrimaryColor),
//                     ),

//                   // Main Content (shown after data loads)
//                   if (!_showPlaceholder && !_isLoading)
//                     Column(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: TextField(
//                             controller: _searchController,
//                             decoration: InputDecoration(
//                               hintText: 'Search students...',
//                               prefixIcon: Icon(
//                                 Icons.search,
//                                 color: Colors.green[800],
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 borderSide: BorderSide(color: Colors.green),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 borderSide: BorderSide(color: Colors.green),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 borderSide: BorderSide(
//                                   color: Colors.green,
//                                   width: 2.0,
//                                 ),
//                               ),
//                             ),
//                             onChanged: _filterStudents,
//                           ),
//                         ),
//                         Expanded(
//                           child: ListView.builder(
//                             padding: const EdgeInsets.symmetric(horizontal: 16),
//                             itemCount: _filteredStudents.length,
//                             itemBuilder: (context, index) {
//                               final student = _filteredStudents[index];
//                               final isExpanded = _expandedIndices.contains(
//                                 index,
//                               );

//                               return Card(
//                                 color: const Color.fromARGB(228, 255, 255, 255),
//                                 margin: const EdgeInsets.only(bottom: 16),
//                                 elevation: 2,
//                                 child: Column(
//                                   children: [
//                                     ListTile(
//                                       onTap: () => _toggleExpand(index),
//                                       leading: CircleAvatar(
//                                         backgroundColor: Colors.green.shade100,
//                                         child: Text(
//                                           student[0],
//                                           style: TextStyle(
//                                             color: kPrimaryColor,
//                                           ),
//                                         ),
//                                       ),
//                                       title: Text(student),
//                                       trailing: Icon(
//                                         isExpanded
//                                             ? Icons.expand_less
//                                             : Icons.expand_more,
//                                         color: kPrimaryColor,
//                                       ),
//                                     ),
//                                     if (isExpanded)
//                                       _buildStudentDetails(student),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton:
//           !_showPlaceholder && !_isLoading
//               ? FloatingActionButton(
//                 onPressed: () {
//                   // Your FAB action
//                 },
//                 backgroundColor: kPrimaryColor,
//                 child: const Icon(Icons.person_add, color: Colors.white),
//               )
//               : null,
//     );
//   }
// }


import 'package:face_recog/Custom_Widget/custom_academic_info_widget.dart';
import 'package:face_recog/constants/constants.dart';
import 'package:flutter/material.dart';

class StudentsTab extends StatefulWidget {
  const StudentsTab({Key? key}) : super(key: key);

  @override
  _StudentsTabState createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  List<String> _students = [];
  List<String> _filteredStudents = [];
  bool _isLoading = false;
  bool _showPlaceholder = true;
  final TextEditingController _searchController = TextEditingController();
  Set<int> _expandedIndices = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      final students = [
        'John Doe',
        'Jane Smith',
        'Robert Johnson',
        'Emily Davis',
        'Michael Wilson',
      ];

      setState(() {
        _students = List.from(students);
        _filteredStudents = List.from(students);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load students: $e')),
      );
    }
  }

  void _filterStudents(String query) {
    setState(() {
      _filteredStudents = _students
          .where((student) =>
              student.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _toggleExpand(int index) {
    setState(() {
      if (_expandedIndices.contains(index)) {
        _expandedIndices.remove(index);
      } else {
        _expandedIndices.add(index);
      }
    });
  }

  Widget _buildStudentDetails(String student) {
    final attendance = {
      'Math': '85%',
      'Science': '92%',
      'English': '78%',
      'History': '88%',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Attendance', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          ...attendance.entries
              .map(
                (subject) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(subject.key),
                      Text(
                        subject.value,
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          Divider(),
          Text(
            'Overall Performance',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.86,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          SizedBox(height: 8),
          Text('86% Overall', textAlign: TextAlign.center),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Academic Selection Widget
              Container(
                padding: EdgeInsets.all(20),
                // height: 400,
                child: AcademicSelectionWidget(
                  onSelectionComplete: (selection) {
                    // When selection is complete, hide placeholder and load students
                    setState(() {
                      _showPlaceholder = false;
                    });
                    _loadStudents();
                  },
                ),
              ),
              
              // Main Content Area
              Container(
                // color: Colors.blue,
                height: 600, // Adjust height
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Loading Indicator (shown when loading)
                    if (_isLoading)
                      CircularProgressIndicator(color: kPrimaryColor),

                    // SVG Placeholder with fade animation
                    AnimatedOpacity(
                      opacity: _showPlaceholder ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 500),
                      child: Image.asset(
                        'assets/images/img4.png',
                        width: MediaQuery.of(context).size.width * 0.8,
                        fit: BoxFit.contain,
                      ),
                    ),

                   
                    // Main Content (shown after data loads)
                    if (!_showPlaceholder && !_isLoading)
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search students...',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.green[800],
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(color: Colors.green),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: Colors.green,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              onChanged: _filterStudents,
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filteredStudents.length,
                              itemBuilder: (context, index) {
                                final student = _filteredStudents[index];
                                final isExpanded = _expandedIndices.contains(index);

                                return Card(
                                  color: const Color.fromARGB(228, 255, 255, 255),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  elevation: 2,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        onTap: () => _toggleExpand(index),
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.green.shade100,
                                          child: Text(
                                            student[0],
                                            style: TextStyle(
                                              color: kPrimaryColor,
                                            ),
                                          ),
                                        ),
                                        title: Text(student),
                                        trailing: Icon(
                                          isExpanded
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                          color: kPrimaryColor,
                                        ),
                                      ),
                                      if (isExpanded) _buildStudentDetails(student),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: !_showPlaceholder && !_isLoading
          ? FloatingActionButton(
              onPressed: () {
                // Your FAB action
              },
              backgroundColor: kPrimaryColor,
              child: const Icon(Icons.person_add, color: Colors.white),
            )
          : null,
    );
  }
}