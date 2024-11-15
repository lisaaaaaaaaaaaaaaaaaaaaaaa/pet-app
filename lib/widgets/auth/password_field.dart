import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/auth/auth_validators.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool isConfirmPassword;
  final String? originalPassword;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final Function(String)? onSubmitted;
  final bool showStrengthIndicator;
  final bool showRequirements;

  const PasswordField({
    Key? key,
    required this.controller,
    this.label = 'Password',
    this.hint,
    this.isConfirmPassword = false,
    this.originalPassword,
    this.enabled = true,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.showStrengthIndicator = true,
    this.showRequirements = true,
  }) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;
  double _strength = 0;
  String _displayText = '';
  Color _strengthColor = Colors.grey;
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_checkPassword);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_checkPassword);
    super.dispose();
  }

  void _checkPassword() {
    String password = widget.controller.text;
    _hasMinLength = password.length >= 8;
    _hasUppercase = password.contains(RegExp(r'[A-Z]'));
    _hasLowercase = password.contains(RegExp(r'[a-z]'));
    _hasNumber = password.contains(RegExp(r'[0-9]'));
    _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (password.isEmpty) {
      _strength = 0;
      _displayText = '';
      _strengthColor = Colors.grey;
    } else if (password.length < 6) {
      _strength = 0.2;
      _displayText = 'Weak';
      _strengthColor = AppTheme.errorColor;
    } else if (password.length < 8) {
      _strength = 0.4;
      _displayText = 'Fair';
      _strengthColor = Colors.orange;
    } else {
      if (_hasUppercase && _hasLowercase && _hasNumber && _hasSpecialChar) {
        _strength = 1.0;
        _displayText = 'Strong';
        _strengthColor = AppTheme.successColor;
      } else if (_hasUppercase && _hasLowercase && _hasNumber) {
        _strength = 0.8;
        _displayText = 'Good';
        _strengthColor = Colors.blue;
      } else {
        _strength = 0.6;
        _displayText = 'Moderate';
        _strengthColor = Colors.yellow;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          enabled: widget.enabled,
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.isConfirmPassword
              ? (value) => AuthValidators.validateConfirmPassword(
                    value,
                    widget.originalPassword ?? '',
                  )
              : AuthValidators.validatePassword,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint ?? 'Enter your password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppTheme.textSecondaryColor,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        if (widget.showStrengthIndicator && !widget.isConfirmPassword && widget.controller.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: _strength,
                  backgroundColor: Colors.grey[300],
                  color: _strengthColor,
                  minHeight: 4,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _displayText,
                style: TextStyle(
                  color: _strengthColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],

        if (widget.showRequirements && !widget.isConfirmPassword) ...[
          const SizedBox(height: 12),
          _buildRequirement('At least 8 characters', _hasMinLength),
          _buildRequirement('At least one uppercase letter', _hasUppercase),
          _buildRequirement('At least one lowercase letter', _hasLowercase),
          _buildRequirement('At least one number', _hasNumber),
          _buildRequirement('At least one special character', _hasSpecialChar),
        ],
      ],
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_outline : Icons.circle_outlined,
            size: 16,
            color: isMet ? AppTheme.successColor : AppTheme.textSecondaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? AppTheme.successColor : AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}