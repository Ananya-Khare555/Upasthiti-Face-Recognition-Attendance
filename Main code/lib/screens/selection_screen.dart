import 'package:camera/camera.dart';
import 'package:face_recog/Api/apiIntegration.dart';
import 'package:face_recog/Custom_Widget/custom_appbar.dart';
import 'package:face_recog/Custom_Widget/custom_button.dart';
import 'package:face_recog/Custom_Widget/custom_dropdown.dart';
import 'package:face_recog/Custom_Widget/custom_toast.dart';
import 'package:face_recog/screens/face_recognition_screen.dart';
import 'package:flutter/material.dart';

class SelectionScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const SelectionScreen({required this.cameras});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  Map<String, dynamic>? selectedCourse;
  Map<String, dynamic>? selectedYear;
  Map<String, dynamic>? selectedSection;
  int courseId = 0;

  List<Map<String, dynamic>> courseMapList = [];
  List<Map<String, dynamic>> yearMapList = [];
  List<Map<String, dynamic>> sectionMapList = [];

  bool get isFormComplete =>
      selectedCourse != null && selectedYear != null && selectedSection != null;

  @override
  void initState() {
    getCourse();
    super.initState();
  }

  void getCourse() async {
    // courses= getCoursesBySchool()
    courseMapList = await ApiService.getCoursesBySchool("1");
    selectedYear = null;
    selectedSection = null;
    yearMapList=[];
    sectionMapList=[];
    setState(() {});
  }

  void getYearList(String selectedCourseId) async {
    yearMapList = await ApiService.getYearsByCourse(selectedCourseId);
    selectedSection = null;
    sectionMapList=[];
    setState(() {});
  }

  void getSectionList(String selectedYearId) async {
    sectionMapList = await ApiService.getSectionsByYear(selectedYearId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      appBar: CustomAppBar(title: "Academic Information"),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg1.jpg'), // or NetworkImage
            fit: BoxFit.cover, // This ensures the image covers the whole screen
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Usage in UI
            CustomDropdown(
              value: selectedCourse,
              items: courseMapList,
              label: 'Course',
              hint: 'Select Course',
              onChanged: (value) {
                setState(() {
                  selectedCourse = value;
                  selectedYear = null; // Reset year
                  selectedSection = null; // Reset section

                  if (value != null && value.containsKey('id')) {
                    getYearList(value['id'].toString());
                  }
                });
              },
            ),
            // Year Dropdown
            CustomDropdown(
              value: selectedYear,
              items: yearMapList,
              label: 'Year',
              hint: 'Select Year',
              onChanged: (value) {
                setState(() {
                  selectedYear = value;
                  selectedSection = null; // Reset section

                  if (value != null && value.containsKey('id')) {
                    getSectionList(value['id'].toString());
                  }
                });
              },
            ),
            CustomDropdown(
              value: selectedSection,
              items: sectionMapList,
              hint: 'Select Section',
              label: 'Section',
              onChanged: (value) {
                setState(() {
                  selectedSection = value;

                  if (value != null && value.keys.length >= 2) {
                    final firstKey = value.keys.elementAt(0);
                    final secondKey = value.keys.elementAt(1);

                    final firstValue = value[firstKey];
                    final secondValue = value[secondKey];

                    print("First Value: $firstValue");
                    print("Second Value: $secondValue");
                  } else {
                    print("Value is null or doesn't have enough keys.");
                  }
                });
              },
            ),
            const SizedBox(height: 20),

            // Submit Button
            CustomButton(
              text: 'Continue',
              onPressed: () {
                if (selectedCourse == null ||
                    selectedSection == null ||
                    selectedYear == null) {
                  showCustomToast(context, message: "Please fill all the fields",backgroundColor: Colors.red);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              FaceRecognitionScreen(cameras: widget.cameras),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}