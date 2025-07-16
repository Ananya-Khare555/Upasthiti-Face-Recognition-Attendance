import 'package:camera/camera.dart';
import 'package:face_recog/constants/constants.dart';
import 'package:face_recog/screens/add_student_screen.dart';
import 'package:face_recog/screens/selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomeTab extends StatelessWidget {
  final List<CameraDescription> cameras;

  const HomeTab({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildFeatureCard(
            context,
            icon: Icons.face,
            title: "Face Recognition",
            subtitle: "Start attendance using face recognition",
            color: Colors.green,
            // color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SelectionScreen(cameras: cameras,),)
            ),
          ),
          const SizedBox(height: 20),
          _buildFeatureCard(
            context,
            icon: Icons.person_add,
            title: "Add Student",
            subtitle: "Register new student faces",
            color: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddStudentScreen(cameras: cameras)),
            ),
          ),
          const SizedBox(height: 20),
          // _buildStatsRow(context),
          Center(child: Lottie.asset("assets/lottie/RecogPersonLottie.json",height: 350)),
          // Container(
          //   child: Image.asset("assets/images/img2.png",height: 400,),
          // ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: kPrimaryColor,size: 30,),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildStatsRow(BuildContext context) {
  //   return FutureBuilder<List<dynamic>>(
  //     future: ApiService.getCoursesBySchool("1"),
  //     // future: ApiService.getRegisteredStudents(),
  //     builder: (context, snapshot) {
  //       int totalStudents = snapshot.hasData ? snapshot.data!.length : 0;
  //       int presentToday = 0; // You would need to get this from attendance records
        
  //       return Row(
  //         children: [
  //           Expanded(
  //             child: _buildStatCard(
  //               title: "Total Students",
  //               value: "$totalStudents",
  //               icon: Icons.people,
  //               color: Colors.purple,
  //             ),
  //           ),
  //           const SizedBox(width: 10),
  //           Expanded(
  //             child: _buildStatCard(
  //               title: "Present Today",
  //               value: "$presentToday",
  //               icon: Icons.check_circle,
  //               color: Colors.green,
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[600])),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
