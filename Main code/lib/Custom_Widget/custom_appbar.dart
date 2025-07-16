import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Color> gradientColors;
  final List<Widget>? actions;
  final bool centerTitle;
  final double elevation;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.gradientColors = const [
      Color.fromARGB(255, 52, 152, 104),
      Color.fromARGB(255, 43, 209, 129),
      Color.fromARGB(255, 18, 136, 79),
    ],
    this.actions,
    this.centerTitle = true,
    this.elevation = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      centerTitle: centerTitle,
      elevation: elevation,
      actions: actions,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white), // For back button color
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
