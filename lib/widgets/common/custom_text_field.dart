import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.textInputAction,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      enabled: enabled,
      style: const TextStyle(color: AppTheme.textDark),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: AppTheme.secondaryGreen) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: AppTheme.secondaryGreen),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.error, width: 2),
        ),
        errorStyle: TextStyle(color: AppTheme.error),
      ),
    );
  }
}