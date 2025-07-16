
// import 'dart:io';

// import 'package:camera/camera.dart';
// import 'package:face_recog/Api/apiIntegration.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class FaceRecognitionScreen extends StatefulWidget {
//   final List<CameraDescription> cameras;

//   const FaceRecognitionScreen({Key? key, required this.cameras}) : super(key: key);

//   @override
//   _FaceRecognitionScreenState createState() => _FaceRecognitionScreenState();
// }

// class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
//   late CameraController _controller;
//   bool _isRecognizing = false;
//   final List<String> _recognizedFaces = [];
//   bool _isAttendanceStarted = false;
//   DateTime? _sessionStartTime;
//   final int _attendanceInterval = 1; // minutes

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     _controller = CameraController(
//       widget.cameras[0],
//       ResolutionPreset.medium,
//     );
//     await _controller.initialize();
//     if (mounted) setState(() {});
//   }

//   Future<void> _startAttendance() async {
//     setState(() {
//       _isAttendanceStarted = true;
//       _sessionStartTime = DateTime.now();
//       _recognizedFaces.clear();
//     });
//   }

//   Future<void> _recognizeFaces() async {
//     if (!_controller.value.isInitialized || _isRecognizing) return;
    
//     setState(() => _isRecognizing = true);
    
//     try {
//       final image = await _controller.takePicture();
//       final response = await ApiService.recognizeFace(File(image.path));
      
//       if (response['status'] == 'success') {
//         for (var result in response['results']) {
//           if (result['status'] == 'recognized' && !_recognizedFaces.contains(result['name'])) {
//             setState(() => _recognizedFaces.add(result['name']));
//             await ApiService.markAttendance(result['name']);
//           }
//         }
//       }
//     } catch (e) {
//       print('Error recognizing faces: $e');
//     } finally {
//       setState(() => _isRecognizing = false);
//     }
//   }

//   void _stopAttendance() {
//     setState(() {
//       _isAttendanceStarted = false;
//       _isRecognizing = false;
//     });
//     _showAttendanceSummary();
//   }

//   void _showAttendanceSummary() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Attendance Summary'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Session Time: ${DateFormat('hh:mm a').format(_sessionStartTime!)}'),
//             const SizedBox(height: 10),
//             Text('Present: ${_recognizedFaces.length}'),
//             const SizedBox(height: 10),
//             const Text('Recognized Faces:', style: TextStyle(fontWeight: FontWeight.bold)),
//             ..._recognizedFaces.map((name) => Text('• $name')).toList(),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Face Recognition'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.info),
//             onPressed: () => showDialog(
//               context: context,
//               builder: (context) => const AlertDialog(
//                 title: Text('Instructions'),
//                 content: Text('Position your face in the frame and keep still for recognition.'),
//                 actions: [
//                   TextButton(
//                     onPressed: null,
//                     child: Text('OK'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: _controller.value.isInitialized
//                 ? Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       CameraPreview(_controller),
//                       if (_isRecognizing)
//                         const CircularProgressIndicator(),
//                     ],
//                   )
//                 : const Center(child: CircularProgressIndicator()),
//           ),
//           Container(
//             padding: const EdgeInsets.all(20),
//             color: Colors.grey[100],
//             child: Column(
//               children: [
//                 if (_isAttendanceStarted)
//                   Column(
//                     children: [
//                       LinearProgressIndicator(
//                         value: _sessionStartTime != null
//                             ? DateTime.now().difference(_sessionStartTime!).inSeconds / (_attendanceInterval * 60)
//                             : 0,
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         'Time remaining: ${_sessionStartTime != null ? (_attendanceInterval * 60 - DateTime.now().difference(_sessionStartTime!).inSeconds) : 0} seconds',
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 10),
//                       ElevatedButton(
//                         onPressed: _recognizeFaces,
//                         child: const Text('Capture & Recognize'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                         ),
//                       ),
//                     ],
//                   ),
//                 const SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: _isAttendanceStarted ? _stopAttendance : _startAttendance,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _isAttendanceStarted ? Colors.red : Colors.green,
//                     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                   ),
//                   child: Text(_isAttendanceStarted ? 'Stop Attendance' : 'Start Attendance'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:face_recog/Api/apiIntegration.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FaceRecognitionScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const FaceRecognitionScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _FaceRecognitionScreenState createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  late CameraController _controller;
  bool _isRecognizing = false;
  final Map<String, DateTime> _recognizedFaces = {}; // Track name and recognition time
  bool _isAttendanceStarted = false;
  DateTime? _sessionStartTime;
  final int _attendanceInterval = 1; // minutes
  List<Map<String, dynamic>> _currentFaces = []; // Current detected faces with positions
  Timer? _recognitionTimer;

  @override
void initState() {
  super.initState();
  _initializeCamera().then((_) {
    _startAttendance(); // Automatically start attendance after camera is initialized
  });
}


  Future<void> _initializeCamera() async {
    _controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.medium,
    );
    await _controller.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _startAttendance() async {
    setState(() {
      _isAttendanceStarted = true;
      _sessionStartTime = DateTime.now();
      _recognizedFaces.clear();
      _currentFaces.clear();
    });
    
    // Start periodic recognition every 2 seconds
    _recognitionTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_isAttendanceStarted) {
        // _recognizeFaces();
      }
    }
    );
  }

  // Future<void> _recognizeFaces() async {
  //   if (!_controller.value.isInitialized || _isRecognizing || !_isAttendanceStarted) return;
    
  //   setState(() => _isRecognizing = true);
    
  //   try {
  //     final image = await _controller.takePicture();
  //     final response = await ApiService.recognizeFace(File(image.path));
      
  //     if (response['status'] == 'success') {
  //       List<Map<String, dynamic>> currentFrameFaces = [];
        
  //       for (var result in response['results']) {
  //         if (result['status'] == 'recognized') {
  //           final name = result['name'];
  //           final now = DateTime.now();
            
  //           // Add face to current frame
  //           currentFrameFaces.add({
  //             'name': name,
  //             'position': result['position'], // Assuming API returns face position
  //             'isNew': !_recognizedFaces.containsKey(name),
  //           });
            
  //           // If new recognition or last recognition was more than 30 seconds ago
  //           if (!_recognizedFaces.containsKey(name) || 
  //               now.difference(_recognizedFaces[name]!) > Duration(seconds: 30)) {
              
  //             // Mark attendance
  //             final attendanceResponse = await ApiService.markAttendance(name, _sessionStartTime!);
  //             if (attendanceResponse['status'] == 'success') {
  //               _recognizedFaces[name] = now;
  //             }
  //           }
  //         }
  //       }
        
  //       setState(() {
  //         _currentFaces = currentFrameFaces;
  //       });
  //     }
  //   } catch (e) {
  //     print('Error recognizing faces: $e');
  //   } finally {
  //     setState(() => _isRecognizing = false);
  //   }
  // }

  void _stopAttendance() {
    _recognitionTimer?.cancel();
    setState(() {
      _isAttendanceStarted = false;
      _isRecognizing = false;
    });
    _showAttendanceSummary();
  }

  void _showAttendanceSummary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attendance Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session Time: ${DateFormat('hh:mm a').format(_sessionStartTime!)}'),
            const SizedBox(height: 10),
            Text('Present: ${_recognizedFaces.length}'),
            const SizedBox(height: 10),
            const Text('Recognized Faces:', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._recognizedFaces.keys.map((name) => 
              Text('• $name (${DateFormat('hh:mm a').format(_recognizedFaces[name]!)})')
            ).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _recognitionTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildFaceBoxes() {
    return Stack(
      children: _currentFaces.map((face) {
        final position = face['position'];
        final isNew = face['isNew'];
        
        return Positioned(
          left: position['left'] * MediaQuery.of(context).size.width,
          top: position['top'] * MediaQuery.of(context).size.height,
          width: position['width'] * MediaQuery.of(context).size.width,
          height: position['height'] * MediaQuery.of(context).size.height,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isNew ? Colors.green : Colors.blue,
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: isNew ? Colors.green.withOpacity(0.7) : Colors.blue.withOpacity(0.7),
                    padding: EdgeInsets.all(4),
                    child: Text(
                      face['name'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (isNew)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      color: Colors.green,
                      child: Text(
                        'MARKED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Recognition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const AlertDialog(
                title: Text('Instructions'),
                content: Text('The system will automatically detect and recognize faces. Position yourself clearly in front of the camera.'),
                actions: [
                  TextButton(
                    onPressed: null,
                    child: Text('OK'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _controller.value.isInitialized
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      CameraPreview(_controller),
                      _buildFaceBoxes(),
                      if (_isRecognizing)
                        const CircularProgressIndicator(),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.grey[100],
            child: Column(
              children: [
                if (_isAttendanceStarted)
                  Column(
                    children: [
                      LinearProgressIndicator(
                        value: _sessionStartTime != null
                            ? DateTime.now().difference(_sessionStartTime!).inSeconds / (_attendanceInterval * 60)
                            : 0,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Recognized: ${_recognizedFaces.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isAttendanceStarted ? _stopAttendance : _startAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAttendanceStarted ? Colors.red : Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: Text(_isAttendanceStarted ? 'Stop Attendance' : 'Start Attendance'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}