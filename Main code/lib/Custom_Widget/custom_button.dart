// import 'package:flutter/material.dart';

// class CustomButton extends StatelessWidget {
//   final String text;
//   final VoidCallback? onPressed;
//   final List<Color> gradientColors;
//   final double borderRadius;
//   final double height;
//   final double? width;
//   final TextStyle? textStyle;

//   const CustomButton({
//     Key? key,
//     required this.text,
//     this.onPressed,
//     this.gradientColors =const[const Color.fromARGB(255, 52, 152, 104), const Color.fromARGB(255, 43, 209, 129),const Color.fromARGB(255, 18, 136, 79)],
//     this.borderRadius = 10,
//     this.height = 50,
//     this.width,
//     this.textStyle,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: width ?? double.infinity,
//       height: height,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: gradientColors,
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//         borderRadius: BorderRadius.circular(borderRadius),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 4,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(borderRadius),
//           ),
//           padding: EdgeInsets.zero,
//         ),
//         child: Text(
//           text,
//           style: textStyle ?? TextStyle(
//             fontSize: 18,
//             color: Colors.white,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }
// }


// // Usage Example:
// /*
// GradientButton(
//   text: 'Continue',
//   onPressed: isFormComplete
//       ? () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ResultScreen(
//                 course: selectedCourse!,
//                 year: selectedYear!,
//                 section: selectedSection!,
//               ),
//             ),
//           );
//         }
//       : null,
//   // Optional customizations:
//   // gradientColors: [Colors.blue, Colors.purple],
//   // borderRadius: 20,
//   // height: 60,
//   // textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// )
// */


import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final List<Color> gradientColors;
  final double borderRadius;
  final double height;
  final double? width;
  final TextStyle? textStyle;
  final bool isLoading;
  final Color? loaderColor;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.gradientColors = const [
      Color.fromARGB(255, 52, 152, 104),
      Color.fromARGB(255, 43, 209, 129),
      Color.fromARGB(255, 18, 136, 79),
    ],
    this.borderRadius = 10,
    this.height = 50,
    this.width,
    this.textStyle,
    this.isLoading = false,
    this.loaderColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(loaderColor!),
                ),
              )
            : Text(
                text,
                style: textStyle ?? TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}

// Updated Usage Example:
/*
CustomButton(
  text: 'Register Student',
  onPressed: isFormValid ? _registerStudent : null,
  isLoading: isRegistering,
  // Optional customizations:
  // gradientColors: [Colors.blue, Colors.purple],
  // borderRadius: 20,
  // height: 60,
  // textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  // loaderColor: Colors.amber,
)
*/