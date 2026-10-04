import 'package:farm/screens/dashboard_page.dart';
import 'package:farm/screens/farm_companion_onboarding.dart';
import 'package:farm/screens/signup_page.dart';
import 'package:farm/services/api_client.dart';
import 'package:farm/services/auth_api.dart';
import 'package:farm/services/session_manager.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// Manages the state for the login page, including password visibility,
// loading state, and text field controllers.
class _LoginPageState extends State<LoginPage> {
  // Toggles the visibility of the password text.
  bool _obscurePassword = true;
  bool _rememberDevice = false;

  // Used to show a loading indicator on the login button while the API call is in progress.
  bool _isSubmitting = false;

  // Controllers to manage the text input for the email/phone and password fields.
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Instance of our authentication service to handle the login API call.
  late final AuthApi _authApi = AuthApi(ApiClient());

  @override
  void dispose() {
    // Always dispose of controllers to free up resources when the widget is removed.
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The main layout of the page.
    // Using a Center and SingleChildScrollView to keep the content centered and scrollable on smaller screens.
    return Scaffold(
      backgroundColor: const Color(0xFFE4E7D6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLogo(),
                const SizedBox(height: 40),
                _buildForm(),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Or log in with',
                    style: TextStyle(color: Color(0xFF6A6F5B)),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSocialLoginButtons(),
                const SizedBox(height: 32),
                _buildSignupPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Builds the top logo section with the app icon and name.
  Widget _buildLogo() {
    return Column(
      children: const [
        CircleAvatar(
          radius: 40,
          backgroundColor: Color(0xFFEFF2E2),
          child: Icon(Icons.eco_outlined, color: Color(0xFF4E7D44), size: 40),
        ),
        SizedBox(height: 16),
        Text(
          'Farm Companion',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2C1C),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Livestock Assistant',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF6A6F5B),
          ),
        ),
      ],
    );
  }

  // Builds the main login form with email/phone, password fields, and the login button.
  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email or phone',
          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F2F2F)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _identifierController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'name@gmail.com or +977 98...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD1D7C4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2F7D32), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Password',
          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F2F2F)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD1D7C4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2F7D32), width: 2),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: _rememberDevice,
              activeColor: const Color(0xFF2F7D32),
              onChanged: (value) => setState(() => _rememberDevice = value ?? false),
            ),
            const Text('Remember me', style: TextStyle(color: Color(0xFF6A6F5B))),
            const Spacer(), // Use a Spacer to push the 'Forgot password' button to the end.
            TextButton(
              onPressed: () => _showComingSoon(context),
              child: const Text(
                'Forgot password?',
                style: TextStyle(color: Color(0xFF2F7D32), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
            // Disable the button while a login request is in progress.
            onPressed: _isSubmitting ? null : _handleLogin,
            child: _isSubmitting
                ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                : const Text('Log in', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // Builds the social login buttons in a vertical column.
  Widget _buildSocialLoginButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SocialLoginButton(
          label: 'Log in with Google',
          imageAsset: 'lib/resources/google.png',
          onTap: () => _showComingSoon(context),
        ),
        const SizedBox(height: 12),
        _SocialLoginButton(
          label: 'Log in with phone number',
          icon: Icons.phone_android_outlined,
          onTap: () => _showComingSoon(context),
        ),
      ],
    );
  }

  // Builds the footer prompt to navigate to the signup page.
  Widget _buildSignupPrompt() {
    // Using a Wrap widget here to prevent horizontal overflow on smaller screen sizes.
    // It will automatically wrap the content to the next line if there isn't enough space.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text('New to Farm Companion?', style: TextStyle(color: Color(0xFF6A6F5B))),
        TextButton(
          onPressed: _goToSignup,
          child: const Text('Create an account', style: TextStyle(color: Color(0xFF2F7D32), fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  void _goToOnboarding() {
    Navigator.pushReplacementNamed(context, FarmCompanionOnboarding.routeName);
  }

  void _goToSignup() {
    Navigator.pushReplacementNamed(context, SignupPage.routeName);
  }

  /// Handles the entire login process when the user taps the 'Log in' button.
  Future<void> _handleLogin() async {
    final messenger = ScaffoldMessenger.of(context);
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    // First, do some basic validation to ensure fields are not empty.
    if (identifier.isEmpty || password.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Please enter email/phone and password')));
      return;
    }

    // Set loading state to true to show the progress indicator and prevent multiple taps.
    setState(() => _isSubmitting = true);

    // Call the login API endpoint. We wrap this in a try-catch-finally block
    // to handle network errors or invalid credentials gracefully.
    try {
      final result = await _authApi.login(identifier: identifier, password: password);

      messenger.showSnackBar(SnackBar(content: Text(result['message'] ?? 'Login successful')));

      // If login is successful, save the session token and user data.
      final token = result['token']?.toString();
      final user = result['user'] as Map<String, dynamic>?;
      if (token != null && user != null) {
        SessionManager.instance.setAuth(token, user);
      }

      // After a successful login, navigate to the main dashboard and remove all previous routes from the stack.
      Navigator.pushReplacementNamed(context, DashboardPage.routeName);
    } catch (e) {
      // If the API call fails, show the error message to the user.
      messenger.showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      // The `finally` block ensures we turn off the loading indicator, whether the login succeeded or failed.
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

/// A reusable widget for the full-width social login buttons.
class _SocialLoginButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final String? imageAsset;
  final IconData? icon;

  const _SocialLoginButton({
    required this.label,
    required this.onTap,
    this.imageAsset,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2F2F2F),
          side: const BorderSide(color: Color(0xFFE0E3D2)),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        onPressed: onTap,
        icon: imageAsset != null
            ? Image.asset(imageAsset!, height: 24)
            : Icon(icon, color: const Color(0xFF2F7D32)),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// A helper function to show a simple 'Coming soon' dialog.
void _showComingSoon(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Coming soon'),
      content: const Text('This option will be available shortly. Please continue with email for now.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Okay'),
        ),
      ],
    ),
  );
}
