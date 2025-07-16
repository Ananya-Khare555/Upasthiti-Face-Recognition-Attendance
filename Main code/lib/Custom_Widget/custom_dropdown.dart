import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final Map<String, dynamic>? value;
  final List<Map<String, dynamic>> items;
  final String hint;
  final String label;
  final Function(Map<String, dynamic>?) onChanged;
  final EdgeInsetsGeometry? padding;
  final String? errorText;
  final double? dropdownHeight;
  final Color? dropdownColor;
  final Color? buttonColor;
  final double? buttonHeight;
  final double? itemHeight;
  final BorderRadius? borderRadius;
  final bool showLabel;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    this.hint = '',
    this.label = '',
    required this.onChanged,
    this.padding,
    this.errorText,
    this.dropdownHeight = 200,
    this.dropdownColor,
    this.buttonColor = Colors.white,
    this.buttonHeight = 55,
    this.itemHeight = 50,
    this.borderRadius,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(12);

    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLabel && label.isNotEmpty) ...[
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
          ],
          DropdownButtonHideUnderline(
            child: DropdownButton2<Map<String, dynamic>>(
              isExpanded: true,
              hint: hint.isNotEmpty
                  ? Text(
                      hint,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              items: items.map((item) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: item,
                  child: Text(
                    item.values.first.toString(),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              value: value,
              onChanged: onChanged,
              buttonStyleData: ButtonStyleData(
                height: buttonHeight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: defaultBorderRadius,
                  border: Border.all(color: Colors.black54),
                  color: buttonColor,
                ),
                elevation: 2,
              ),
              iconStyleData: const IconStyleData(
                icon: Icon(
                  Icons.arrow_drop_down,
                  size: 25,
                  color: Colors.black54,
                ),
                openMenuIcon: Icon(
                  Icons.arrow_drop_up,
                  size: 25,
                  color: Colors.black54,
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: dropdownHeight!,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: dropdownColor ?? Colors.white,
                ),
                offset: const Offset(0, -5),
                scrollbarTheme: ScrollbarThemeData(
                  radius: const Radius.circular(40),
                  thickness: MaterialStateProperty.all(6),
                  thumbVisibility: MaterialStateProperty.all(true),
                ),
              ),
              menuItemStyleData: MenuItemStyleData(
                height: itemHeight!,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12),
              child: Text(
                errorText!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}