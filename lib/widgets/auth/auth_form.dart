import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/auth_styles.dart';
import '../../utils/auth/auth_validators.dart';
import 'auth_button.dart';

class AuthForm extends StatefulWidget {
  final bool isLogin;
  final bool isLoading;
  final Function(String email, String password) onSubmit;
  final VoidCallback onToggleAuthMode;
  final VoidCallback? onForgotPassword;

  const AuthForm({
    Key? key,
    this.isLogin = true,
    this.isLoading = false,
    required this.onSubmit,
    required this.onToggleAuthMode,
    this.onForgotPassword,
  }) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            decoration: AuthStyles.inputDecoration(
              hintText: 'Enter your email',
              labelText: 'Email',
              prefixIcon: Icons.email_outlined,
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: AuthValidators.validateEmail,
            enabled: !widget.isLoading,
          ),
          const SizedBox(height: 16),

          // Password Field
          TextFormField(
            controller: _passwordController,
            decoration: AuthStyles.inputDecoration(
              hintText: 'Enter your password',
              labelText: 'Password',
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppTheme.textSecondaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            obscureText: _obscurePassword,
            validator: AuthValidators.validatePassword,
            enabled: !widget.isLoading,
          ),
          const SizedBox(height: 16),

          // Confirm Password Field (only for register)
          if (!widget.isLogin) ...[
            TextFormField(
              controller: _confirmPasswordController,
              decoration: AuthStyles.inputDecoration(
                hintText: 'Confirm your password',
                labelText: 'Confirm Password',
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppTheme.textSecondaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              obscureText: _obscureConfirmPassword,
              validator: (value) => AuthValidators.validateConfirmPassword(
                value,
                _passwordController.text,
              ),
              enabled: !widget.isLoading,
            ),
            const SizedBox(height: 16),
          ],

          // Forgot Password Link (only for login)
          if (widget.isLogin && widget.onForgotPassword != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.isLoading ? null : widget.onForgotPassword,
                child: Text(
                  'Forgot Password?',
                  style: AuthStyles.linkStyle,
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Submit Button
          AuthButton(
            text: widget.isLogin ? 'Sign In' : 'Sign Up',
            onPressed: _submit,
            isLoading: widget.isLoading,
          ),

          const SizedBox(height: 16),

          // Toggle Auth Mode Button
          TextButton(
            onPressed: widget.isLoading ? null : widget.onToggleAuthMode,
            child: Text(
              widget.isLogin
                  ? 'Don\'t have an account? Sign Up'
                  : 'Already have an account? Sign In',
              style: AuthStyles.linkStyle,
            ),
          ),
        ],
      ),
    );
  }
}

// Optional: Social Auth Section
class SocialAuthSection extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onGooglePressed;
  final VoidCallback? onFacebookPressed;
  final VoidCallback? onApplePressed;

  const SocialAuthSection({
    Key? key,
    this.isLoading = false,
    this.onGooglePressed,
    this.onFacebookPressed,
    this.onApplePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        
        // Divider with text
        Row(
          children: const [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),

        const SizedBox(height: 24),

        // Social Buttons
        if (onGooglePressed != null)
          GoogleAuthButton(
            onPressed: isLoading ? () {} : onGooglePressed!,
            isLoading: isLoading,
          ),

        if (onFacebookPressed != null) ...[
          const SizedBox(height: 12),
          FacebookAuthButton(
            onPressed: isLoading ? () {} : onFacebookPressed!,
            isLoading: isLoading,
          ),
        ],

        if (onApplePressed != null) ...[
          const SizedBox(height: 12),
          AppleAuthButton(
            onPressed: isLoading ? () {} : onApplePressed!,
            isLoading: isLoading,
          ),
        ],
      ],
    );
  }
}