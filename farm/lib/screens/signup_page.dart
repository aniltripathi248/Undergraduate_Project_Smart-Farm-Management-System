// ============================================
// SIGNUP PAGE - User Registration
// ============================================
// This screen allows new users to create an account.
// Users must fill in:
// - Full name (required)
// - Farm name (optional)
// - Email (required)
// - Phone number (required)
// - Password (required, min 8 characters)
// - Confirm password (must match)
// - Agree to Terms and Privacy Policy
// 
// After successful signup, user is redirected to LoginPage.
// ============================================

import 'package:farm/screens/login_page.dart';
import 'package:farm/services/api_client.dart';
import 'package:farm/services/auth_api.dart';
import 'package:flutter/material.dart';

/// SignupPage - Screen for new user registration
/// 
/// Flow:
/// 1. User fills in registration form
/// 2. User checks "Agree to Terms" checkbox
/// 3. User taps "Create account" button
/// 4. _handleSignup() validates input (fields not empty, passwords match)
/// 5. AuthApi.signup() sends data to backend
/// 6. Backend creates user account
/// 7. User redirected to LoginPage
/// 
/// Navigation:
/// - "Back" → Previous screen (usually LoginPage or Onboarding)
/// - "Log in" link → LoginPage
/// - After successful signup → LoginPage
class SignupPage extends StatefulWidget {
  static const routeName = '/signup';
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

/// State class for SignupPage
/// Manages form state, password visibility, and signup process
class _SignupPageState extends State<SignupPage> {
  // ============================================
  // STATE VARIABLES
  // ============================================
  // Whether user has agreed to Terms and Privacy Policy
  // Required before account creation
  bool _agreed = false;
  
  // Controls password field visibility (show/hide)
  bool _obscurePassword = true;
  
  // Controls confirm password field visibility (show/hide)
  bool _obscureConfirm = true;
  
  // Shows loading spinner on submit button while API call is in progress
  bool _isSubmitting = false;

  // ============================================
  // TEXT CONTROLLERS
  // ============================================
  // Controllers for all form input fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _farmNameController = TextEditingController(); // Optional
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // ============================================
  // API SERVICE
  // ============================================
  // Authentication API service for signup operation
  late final AuthApi _authApi = AuthApi(ApiClient());

  @override
  void dispose() {
    _fullNameController.dispose();
    _farmNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE4E7D6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TopBar(
                leadingLabel: 'Back',
                trailingLabel: 'Help',
                onLeadingTap: _goToLogin,
                onTrailingTap: () => _showComingSoon(context),
              ),
              const SizedBox(height: 16),
              const Text(
                'Create your farm account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2C1C),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set up your profile to start tracking animals, tasks, and health insights.',
                style: TextStyle(
                  color: Color(0xFF6A6F5B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              _buildForm(),
              const SizedBox(height: 16),
              _buildSocialLoginButtons(),
              const SizedBox(height: 20),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LabeledField(
          label: 'Full name',
          hint: 'e.g. bishal tamang',
          controller: _fullNameController,
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'Farm name (optional)',
          hint: 'Name of your farm',
          controller: _farmNameController,
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'Email',
          hint: 'name@gmail.com',
          keyboardType: TextInputType.emailAddress,
          controller: _emailController,
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'Phone number',
          hint: 'e.g. +977 9765.....',
          helperText: 'For alerts & WhatsApp tips',
          keyboardType: TextInputType.phone,
          controller: _phoneController,
        ),
        const SizedBox(height: 12),
        _PasswordField(
          label: 'Password',
          hint: 'Create a password',
          obscure: _obscurePassword,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
          controller: _passwordController,
        ),
        const SizedBox(height: 12),
        _PasswordField(
          label: 'Confirm password',
          hint: 'Re-enter your password',
          obscure: _obscureConfirm,
          onToggle: () =>
              setState(() => _obscureConfirm = !_obscureConfirm),
          controller: _confirmPasswordController,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: _agreed,
              activeColor: const Color(0xFF2F7D32),
              onChanged: (value) => setState(() => _agreed = value ?? false),
            ),
            const Expanded(
              child: Text(
                'I agree to the Terms and Privacy Policy',
                style: TextStyle(color: Color(0xFF6A6F5B)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F7D32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            onPressed: !_agreed || _isSubmitting ? null : _handleSignup,
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Create account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialIconButton(imageAsset: 'lib/resources/google.png', onTap: () => _showComingSoon(context)),
        const SizedBox(width: 20),
        _SocialIconButton(icon: Icons.phone_android_outlined, onTap: () => _showComingSoon(context)),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(color: Color(0xFF6A6F5B)),
        ),
        TextButton(
          onPressed: _goToLogin,
          child: const Text(
            'Log in',
            style: TextStyle(
              color: Color(0xFF2F7D32),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, LoginPage.routeName);
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This feature is coming soon!')),
    );
  }

  /// Handles the signup process when user taps "Create account" button
  /// 
  /// Flow:
  /// 1. Validates that all required fields are filled
  /// 2. Validates that passwords match
  /// 3. Shows loading spinner on button
  /// 4. Calls AuthApi.signup() with user data
  /// 5. Backend creates new user account
  /// 6. If successful: shows success message and navigates to LoginPage
  /// 7. If error: shows error message
  /// 
  /// Called by: "Create account" button onPressed
  Future<void> _handleSignup() async {
    final messenger = ScaffoldMessenger.of(context);

    // ============================================
    // STEP 1: Get user input
    // ============================================
    // Extract text from all form fields
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // ============================================
    // STEP 2: Validate required fields
    // ============================================
    // Check if all required fields are filled
    if (fullName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return; // Stop here if validation fails
    }

    // ============================================
    // STEP 3: Validate password match
    // ============================================
    // Ensure password and confirm password are the same
    if (password != confirmPassword) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return; // Stop here if passwords don't match
    }

    // ============================================
    // STEP 4: Show loading state
    // ============================================
    // Disable button and show spinner
    setState(() => _isSubmitting = true);
    
    try {
      // ============================================
      // STEP 5: Call signup API
      // ============================================
      // Send user data to backend to create account
      // Backend validates email uniqueness, phone format, etc.
      final result = await _authApi.signup(
        fullName: fullName,
        // Farm name is optional - send null if empty
        farmName: _farmNameController.text.trim().isEmpty
            ? null
            : _farmNameController.text.trim(),
        email: email,
        phoneNumber: phone,
        password: password,
        confirmPassword: confirmPassword,
      );

      // ============================================
      // STEP 6: Show success message
      // ============================================
      messenger.showSnackBar(
        SnackBar(
          content:
              Text(result['message'] ?? 'Account created successfully. Log in.'),
        ),
      );

      // ============================================
      // STEP 7: Navigate to login screen
      // ============================================
      // After successful signup, user must log in
      // pushReplacementNamed removes SignupPage from navigation stack
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    } catch (e) {
      // ============================================
      // ERROR HANDLING
      // ============================================
      // If signup fails (email exists, validation error, network error, etc.)
      // Show error message to user
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      // ============================================
      // CLEANUP
      // ============================================
      // Always hide loading spinner, even if error occurred
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _TopBar extends StatelessWidget {
  final String leadingLabel;
  final String trailingLabel;
  final VoidCallback? onLeadingTap;
  final VoidCallback? onTrailingTap;

  const _TopBar({
    required this.leadingLabel,
    required this.trailingLabel,
    this.onLeadingTap,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: onLeadingTap,
          icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF6A6F5B)),
          label: Text(
            leadingLabel,
            style: const TextStyle(color: Color(0xFF6A6F5B)),
          ),
        ),
        TextButton(
          onPressed: onTrailingTap,
          child: Text(
            trailingLabel,
            style: const TextStyle(color: Color(0xFF6A6F5B)),
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  const _LabeledField({
    required this.label,
    required this.hint,
    this.helperText,
    this.keyboardType,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F2F2F),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            helperStyle: const TextStyle(color: Color(0xFF9AA187)),
            filled: true,
            fillColor: const Color(0xFFFBF5EC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;
  final TextEditingController? controller;

  const _PasswordField({
    required this.label,
    required this.hint,
    required this.obscure,
    required this.onToggle,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2F2F2F),
              ),
            ),
            const Text(
              'Min. 8 characters',
              style: TextStyle(color: Color(0xFF9AA187), fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFFBF5EC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF9AA187),
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}


class _SocialIconButton extends StatelessWidget {
  final IconData? icon;
  final String? imageAsset;
  final VoidCallback onTap;

  const _SocialIconButton({this.icon, this.imageAsset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
        side: const BorderSide(color: Color(0xFFD1D7C4)),
      ),
      child: imageAsset != null
          ? Image.asset(imageAsset!, height: 28, width: 28)
          : Icon(icon, color: const Color(0xFF2F7D32), size: 28),
    );
  }
}
