// import 'dart:io';
// import 'package:face_recog/Custom_Widget/custom_academic_info_widget.dart';
// import 'package:face_recog/Custom_Widget/custom_appbar.dart';
// import 'package:face_recog/Custom_Widget/custom_button.dart';
// import 'package:face_recog/constants/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';

// class AddStudentScreen extends StatefulWidget {
//   final List<CameraDescription> cameras;

//   const AddStudentScreen({
//     Key? key,
//     required this.cameras,
//   }) : super(key: key);

//   @override
//   State<AddStudentScreen> createState() => _AddStudentScreenState();
// }

// class _AddStudentScreenState extends State<AddStudentScreen> {
//   late CameraController _controller;
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _rollNoController = TextEditingController();
//   bool _isCapturing = false;
//   File? _capturedImage;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     _controller = CameraController(
//       widget.cameras[0],
//       ResolutionPreset.high,
//     );
//     await _controller.initialize();
//     if (mounted) setState(() {});
//   }

//   Future<void> _captureImage() async {
//     if (!_controller.value.isInitialized || _isCapturing) return;

//     setState(() => _isCapturing = true);

//     try {
//       final image = await _controller.takePicture();
//       setState(() => _capturedImage = File(image.path));
//     } catch (e) {
//       print('Error capturing image: $e');
//     } finally {
//       setState(() => _isCapturing = false);
//     }
//   }

//   // Future<void> _registerStudent() async {
//   //   if (_nameController.text.isEmpty || _rollNoController.text.isEmpty) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(content: Text('Please enter student name and roll number')),
//   //     );
//   //     return;
//   //   }

//   //   if (_capturedImage == null) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(content: Text('Please capture a photo of the student')),
//   //     );
//   //     return;
//   //   }

//   //   try {
//   //     final response = await ApiService.registerStudent(
//   //       schoolName: widget.schoolName,
//   //       courseName: widget.courseName,
//   //       yearNumber: widget.yearNumber,
//   //       sectionName: widget.sectionName,
//   //       rollNo: _rollNoController.text,
//   //       name: _nameController.text,
//   //       imageFile: _capturedImage!,
//   //     );

//   //     if (response['status'] == 'success') {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(content: Text(response['message'])),
//   //       );
//   //       Navigator.pop(context, true); // Return success
//   //     } else {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(content: Text(response['message'])),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Error registering student: ${e.toString()}')),
//   //     );
//   //   }
//   // }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _nameController.dispose();
//     _rollNoController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(title: "Add New Student"),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: GestureDetector(
//           onTap: () {
//             FocusScope.of(context).unfocus();
//           },
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Text(
//               //   '${widget.schoolName} > ${widget.courseName} > Year ${widget.yearNumber} > ${widget.sectionName}',
//               //   style: const TextStyle(fontSize: 16, color: Colors.grey),
//               //   textAlign: TextAlign.center,
//               // ),
//               // const SizedBox(height: 20),
//               const Text(
//                 'Register New Student',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//               Container(
//                 height:550,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(15),
//                   border: Border.all(color: Colors.grey[300]!),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: _capturedImage != null
//                       ? Image.file(_capturedImage!, fit: BoxFit.cover)
//                       : _controller.value.isInitialized
//                           ? CameraPreview(_controller)
//                           : const Center(child: CircularProgressIndicator()),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Center(
//                 child: CustomButton(text: "Capture Photo",onPressed: _captureImage,)
//               ),
//               const SizedBox(height: 30),
//               // const SizedBox(height: 30),
//               TextField(
//                 controller: _rollNoController,
//                 decoration:InputDecoration(
//                   labelText: 'Roll Number',
//                   labelStyle: TextStyle(color: Colors.green),
//                   fillColor: Colors.white,
//                   filled: true,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20)
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20),
//                     borderSide: BorderSide(
//                       color: Colors.green,
//                       width: 2
//                     )
//                   ),
//                   prefixIcon: Icon(Icons.confirmation_number,color: kPrimaryColor,),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(height: 15),
//               TextField(
//                 cursorColor: Colors.green,
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   fillColor: Colors.white,
//                   filled: true,
//                   labelText: 'Student Name',
//                   labelStyle: TextStyle(color: Colors.green),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20)
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20),
//                     borderSide: BorderSide(
//                       color: Colors.green,
//                       width: 2
//                     )
//                   ),
//                   prefixIcon: Icon(Icons.person,color: kPrimaryColor,),
//                 ),
//               ),
//               const SizedBox(height: 15),
//               // dropdowns
//               AcademicSelectionWidget(
//                 buttonText: "Register Student",
//                 onSelectionComplete:(selection) {
//                   print("${selection.sectionId}");
//                   print("${selection.courseId}");
//                   print("${selection.yearId}");
//               },),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:io';
// import 'package:face_recog/Custom_Widget/custom_academic_info_widget.dart';
// import 'package:face_recog/Custom_Widget/custom_appbar.dart';
// import 'package:face_recog/Custom_Widget/custom_button.dart';
// import 'package:face_recog/Custom_Widget/custom_toast.dart';
// import 'package:face_recog/constants/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:face_recog/Api/apiIntegration.dart';

// class AddStudentScreen extends StatefulWidget {
//   final List<CameraDescription> cameras;

//   const AddStudentScreen({
//     Key? key,
//     required this.cameras,
//   }) : super(key: key);

//   @override
//   State<AddStudentScreen> createState() => _AddStudentScreenState();
// }

// class _AddStudentScreenState extends State<AddStudentScreen> {
//   late CameraController _controller;
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _rollNoController = TextEditingController();
//   final TextEditingController _dobController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();

//   bool _isCapturing = false;
//   bool _isRegistering = false;
//   File? _capturedImage;
//   String? _sectionId;
//   String? _courseId;
//   String? _yearId;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     _controller = CameraController(
//       widget.cameras[0],
//       ResolutionPreset.high,
//     );
//     await _controller.initialize();
//     if (mounted) setState(() {});
//   }

//   Future<void> _captureImage() async {
//     if (!_controller.value.isInitialized || _isCapturing) return;

//     setState(() => _isCapturing = true);

//     try {
//       final image = await _controller.takePicture();
//       setState(() => _capturedImage = File(image.path));
//     } catch (e) {
//       showCustomToast(context, message: 'Error capturing image: $e');
//     } finally {
//       setState(() => _isCapturing = false);
//     }
//   }

//   Future<void> _registerStudent() async {
//     if (_nameController.text.isEmpty ||
//         _rollNoController.text.isEmpty ||
//         _dobController.text.isEmpty) {
//       showCustomToast(context, message: 'Please fill all required fields');
//       return;
//     }

//     if (_capturedImage == null) {
//       showCustomToast(context, message: 'Please capture a photo of the student');
//       return;
//     }

//     if (_sectionId == null) {
//       showCustomToast(context, message:  'Please select academic details');
//       return;
//     }

//     setState(() => _isRegistering = true);

//     try {
//       final response = await ApiService.registerStudent(
//         sectionId: _sectionId!,
//         fullName: _nameController.text,
//         rollNumber: _rollNoController.text,
//         dateOfBirth: _dobController.text,
//         imageFile: _capturedImage!,
//         email: _emailController.text.isNotEmpty ? _emailController.text : null,
//         phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
//         address: _addressController.text.isNotEmpty ? _addressController.text : null,
//       );

//       if (mounted) {
//         showCustomToast(context, message: 'Student registered successfully');
//         Navigator.pop(context, true);
//       }
//     } catch (e) {
//       if (mounted) {
//         showCustomToast(context, message: 'Failed to register student: $e');
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isRegistering = false);
//       }
//     }
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null && mounted) {
//       setState(() {
//         _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
//       });
//     }
//   }

//   void _onAcademicSelectionComplete(AcademicSelection selection) {
//     setState(() {
//       _sectionId = selection.sectionId;
//       _courseId = selection.courseId;
//       _yearId = selection.yearId;
//       _registerStudent;
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _nameController.dispose();
//     _rollNoController.dispose();
//     _dobController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(title: "Add New Student"),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: GestureDetector(
//           onTap: () => FocusScope.of(context).unfocus(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const Text(
//                 'Register New Student',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//               Container(
//                 height: 300,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(15),
//                   border: Border.all(color: Colors.grey[300]!),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: _capturedImage != null
//                       ? Image.file(_capturedImage!, fit: BoxFit.cover)
//                       : _controller.value.isInitialized
//                           ? CameraPreview(_controller)
//                           : const Center(child: CircularProgressIndicator()),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Center(
//                 child: CustomButton(
//                   text: "Capture Photo",
//                   onPressed: _captureImage,
//                   isLoading: _isCapturing,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               _buildTextField(
//                 controller: _rollNoController,
//                 label: 'Roll Number',
//                 icon: Icons.confirmation_number,
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(height: 15),
//               _buildTextField(
//                 controller: _nameController,
//                 label: 'Full Name',
//                 icon: Icons.person,
//               ),
//               const SizedBox(height: 15),
//               _buildDateField(),
//               const SizedBox(height: 15),
//               _buildTextField(
//                 controller: _emailController,
//                 label: 'Email (Optional)',
//                 icon: Icons.email,
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 15),
//               _buildTextField(
//                 controller: _phoneController,
//                 label: 'Phone (Optional)',
//                 icon: Icons.phone,
//                 keyboardType: TextInputType.phone,
//               ),
//               const SizedBox(height: 15),
//               _buildTextField(
//                 controller: _addressController,
//                 label: 'Address (Optional)',
//                 icon: Icons.location_on,
//                 maxLines: 2,
//               ),
//               const SizedBox(height: 30),
//               AcademicSelectionWidget(
//                 buttonText: "Register Student",
//                 onSelectionComplete: _onAcademicSelectionComplete,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     TextInputType? keyboardType,
//     int maxLines = 1,
//   }) {
//     return TextField(
//       controller: controller,
//       cursorColor: kPrimaryColor,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: kPrimaryColor),
//         fillColor: Colors.white,
//         filled: true,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(20),
//           borderSide: BorderSide(color: kPrimaryColor, width: 2),
//         ),
//         prefixIcon: Icon(icon, color: kPrimaryColor),
//       ),
//       keyboardType: keyboardType,
//       maxLines: maxLines,
//     );
//   }

//   Widget _buildDateField() {
//     return TextField(
//       controller: _dobController,
//       cursorColor: kPrimaryColor,
//       readOnly: true,
//       onTap: () => _selectDate(context),
//       decoration: InputDecoration(
//         labelText: 'Date of Birth',
//         labelStyle: TextStyle(color: kPrimaryColor),
//         fillColor: Colors.white,
//         filled: true,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(20),
//           borderSide: BorderSide(color: kPrimaryColor, width: 2),
//         ),
//         prefixIcon: Icon(Icons.calendar_today, color: kPrimaryColor),
//         suffixIcon: IconButton(
//           icon: Icon(Icons.calendar_month, color: kPrimaryColor),
//           onPressed: () => _selectDate(context),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:io';
import 'package:face_recog/Custom_Widget/custom_academic_info_widget.dart';
import 'package:face_recog/Custom_Widget/custom_appbar.dart';
import 'package:face_recog/Custom_Widget/custom_button.dart';
import 'package:face_recog/Custom_Widget/custom_toast.dart';
import 'package:face_recog/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:face_recog/Api/apiIntegration.dart';

class AddStudentScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const AddStudentScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  late CameraController _controller;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollNoController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isCapturing = false;
  bool _isRegistering = false;
  File? _capturedImage;
  String? _sectionId;
  String? _courseId;
  String? _yearId;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.medium,
      );
      await _controller.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      showCustomToast(context, message: 'Failed to initialize camera: $e');
    }
  }

  Future<void> _captureImage() async {
    if (!_controller.value.isInitialized || _isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      final image = await _controller.takePicture();
      setState(() => _capturedImage = File(image.path));
    } catch (e) {
      showCustomToast(context, message: 'Error capturing image: $e');
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  Future<void> _registerStudent() async {
    // Validate inputs first
    if (_nameController.text.isEmpty ||
        _rollNoController.text.isEmpty ||
        _dobController.text.isEmpty) {
      showCustomToast(context, message: 'Please fill all required fields');
      return;
    }

    if (_capturedImage == null) {
      showCustomToast(
        context,
        message: 'Please capture a photo of the student',
      );
      return;
    }

    if (_sectionId == null) {
      showCustomToast(context, message: 'Please select academic details');
      return;
    }

    setState(() => _isRegistering = true);

    try {
      final response = await ApiService.registerStudent(
        sectionId: _sectionId!,
        fullName: _nameController.text,
        rollNumber: _rollNoController.text,
        dateOfBirth: _dobController.text,
        imageFile: _capturedImage!,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        address:
            _addressController.text.isNotEmpty ? _addressController.text : null,
      );

      if (mounted) {
        showCustomToast(context, message: 'Student registered successfully!');
        Navigator.pop(context, true);
      }
    } on SocketException {
      if (mounted) {
        showCustomToast(context, message: 'No internet connection');
      }
    } on TimeoutException {
      if (mounted) {
        showCustomToast(
          context,
          message: 'Request timed out. Please try again',
        );
      }
    } on HttpException catch (e) {
      if (mounted) {
        showCustomToast(
          context,
          message: 'Server error (${e.statusCode}): ${e.message}',
        );
      }
    } catch (e) {
      if (mounted) {
        showCustomToast(
          context,
          message: 'Error: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _onAcademicSelectionComplete(AcademicSelection selection) {
    setState(() {
      _sectionId = selection.sectionId;
      _courseId = selection.courseId;
      _yearId = selection.yearId;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _rollNoController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Add New Student"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Register New Student',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child:
                    _capturedImage != null
                        ? Image.file(_capturedImage!, fit: BoxFit.cover)
                        : _controller.value.isInitialized
                        ? CameraPreview(_controller)
                        : const Center(child: CircularProgressIndicator()),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: CustomButton(
                text: "Capture Photo",
                onPressed: _captureImage,
                isLoading: _isCapturing,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _rollNoController,
              label: 'Roll Number',
              icon: Icons.confirmation_number,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 15),
            _buildDateField(),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _emailController,
              label: 'Email (Optional)',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone (Optional)',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _addressController,
              label: 'Address (Optional)',
              icon: Icons.location_on,
              maxLines: 2,
            ),
            const SizedBox(height: 30),
            AcademicSelectionWidget(
              buttonText: "Register Student",
              onSelectionComplete: _onAcademicSelectionComplete,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: "Submit Registration",
              onPressed: _registerStudent,
              isLoading: _isRegistering,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: kPrimaryColor),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: kPrimaryColor, width: 2),
        ),
        prefixIcon: Icon(icon, color: kPrimaryColor),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  Widget _buildDateField() {
    return TextField(
      controller: _dobController,
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        labelText: 'Date of Birth',
        labelStyle: TextStyle(color: kPrimaryColor),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: kPrimaryColor, width: 2),
        ),
        prefixIcon: Icon(Icons.calendar_today, color: kPrimaryColor),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_month, color: kPrimaryColor),
          onPressed: () => _selectDate(context),
        ),
      ),
    );
  }
}
