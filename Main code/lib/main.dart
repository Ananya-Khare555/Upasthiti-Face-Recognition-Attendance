import 'package:face_recog/constants/constants.dart' as CupertinoContextMenu;
import 'package:face_recog/screens/attendance_tab.dart';
import 'package:face_recog/screens/home_tab.dart';
import 'package:face_recog/screens/settings_tab.dart';
import 'package:face_recog/screens/students_tab.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(AttendanceApp(cameras: cameras));
}

class AttendanceApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const AttendanceApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Upasthiti',
      theme: ThemeData(
        iconTheme: IconThemeData(color: Colors.white),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: CupertinoContextMenu.kPrimaryColor,
        ),
        scaffoldBackgroundColor: const Color.fromARGB(239, 255, 255, 255),
        // scaffoldBackgroundColor: const Color.fromARGB(248, 241, 248, 245),
        primaryColor: CupertinoContextMenu.kPrimaryColor,
        textTheme: Theme.of(
          context,
        ).textTheme.apply(bodyColor: CupertinoContextMenu.kTextColor),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(cameras: cameras),
    );
  }
}

class MainScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const MainScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeTab(cameras: widget.cameras),
      AttendanceTab(),
      StudentsTab(),
      SettingsTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upasthiti',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 1, 108, 4),
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.cyanAccent,
                offset: Offset(0, 0),
              ),
              Shadow(
                blurRadius: 20.0,
                color: Colors.cyanAccent,
                offset: Offset(0, 0),
              ),
              Shadow(
                blurRadius: 30.0,
                color: Colors.greenAccent,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 52, 152, 104),
                const Color.fromARGB(255, 43, 209, 129),
                const Color.fromARGB(255, 18, 136, 79),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 8, 163, 88),
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.lightGreenAccent,
        unselectedItemColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Students'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}