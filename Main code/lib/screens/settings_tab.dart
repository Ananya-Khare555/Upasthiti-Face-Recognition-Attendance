
import 'package:flutter/material.dart';

class SettingsTab extends StatelessWidget {
  
  const SettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('System Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.timer, color: Colors.blue),
                    title: const Text('Attendance Interval'),
                    subtitle: const Text('Set duration for attendance sessions'),
                    trailing: const Text('1 minute'),
                    onTap: () {
                      // Change interval
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.backup, color: Colors.blue),
                    title: const Text('Backup & Restore'),
                    subtitle: const Text('Manage data backups'),
                    onTap: () {
                      // Backup settings
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.security, color: Colors.blue),
                    title: const Text('Privacy Settings'),
                    subtitle: const Text('Configure data privacy options'),
                    onTap: () {
                      // Privacy settings
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Model Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.update, color: Colors.blue),
                    title: const Text('Update Face Model'),
                    subtitle: const Text('Download latest face recognition model'),
                    onTap: () {
                      // Update model
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.import_export, color: Colors.blue),
                    title: const Text('Import/Export Model'),
                    subtitle: const Text('Transfer model to another device'),
                    onTap: () {
                      // Import/export
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                // Connect to security camera
              },
              icon: const Icon(Icons.video_camera_back),
              label: const Text('Connect Security Camera'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}