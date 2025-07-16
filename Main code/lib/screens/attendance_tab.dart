import 'package:face_recog/Api/apiIntegration.dart';
import 'package:face_recog/constants/constants.dart';
import 'package:face_recog/screens/face_recognition_screen.dart';
import 'package:flutter/material.dart';

class AttendanceTab extends StatefulWidget {
  const AttendanceTab({Key? key}) : super(key: key);

  @override
  _AttendanceTabState createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  List<dynamic> _attendanceRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // _loadAttendance();
  }

  // Future<void> _loadAttendance() async {
  //   try {
  //     final records = await ApiService.getAttendanceRecords();
  //     setState(() {
  //       _attendanceRecords = records;
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() => _isLoading = false);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Failed to load attendance records')));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green,))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _attendanceRecords.length,
              itemBuilder: (context, index) {
                final record = _attendanceRecords[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                  child: ExpansionTile(
                    leading: const Icon(Icons.calendar_today, color: kPrimaryColor),
                    title: Text(record['date']),
                    subtitle: Text('Present: ${record['present'].length}, Absent: ${record['absent'].length}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Present:', style: TextStyle(fontWeight: FontWeight.bold)),
                            ...(record['present'] as List).map((name) => Text('• $name')).toList(),
                            const SizedBox(height: 10),
                            const Text('Absent:', style: TextStyle(fontWeight: FontWeight.bold)),
                            ...(record['absent'] as List).map((name) => Text('• $name')).toList(),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Export attendance
                                  },
                                  child: const Text('Export'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FaceRecognitionScreen(cameras: []),
            ),
          );
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add,color: Colors.white,),
      ),
    );
  }
}

