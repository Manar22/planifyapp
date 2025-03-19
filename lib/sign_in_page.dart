import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'dart:math';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _loadingAnimation = CurvedAnimation(
      parent: _loadingController,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _loadingController.repeat();
    });

    try {
      bool success;
      if (_isSignUp) {
        success = await AuthService.signUp(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        success = await AuthService.signIn(
          _emailController.text,
          _passwordController.text,
        );
      }

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/planner');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isSignUp
                ? 'Email already exists'
                : 'Invalid email or password'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingController.stop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          CustomPaint(
            size: Size.infinite,
            painter: FlowerPatternPainter(),
          ),
          Center(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isMobile ? 400 : 900,
                        maxHeight: isMobile ? 600 : 500,
                      ),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: isMobile
                              ? _buildSignInForm()
                              : IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: _buildSignInForm(),
                                      ),
                                      const SizedBox(width: 32),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: const Color(0xFFA13F89),
                                          ),
                                          child: Container(
                                            width: 300,
                                            height: 300,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.3),
                                                width: 2,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.asset(
                                                'images/calender_icon.jpg',
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.calendar_today,
            size: 64,
            color: Color(0xFFA13F89),
          ),
          const SizedBox(height: 24),
          Text(
            _isSignUp ? 'Create Account' : 'Planify',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFA13F89),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Color(0xFFA13F89),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFA13F89),
                ),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              labelStyle: const TextStyle(
                color: Color(0xFFA13F89),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFA13F89),
                ),
              ),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA13F89),
              foregroundColor: const Color(0xFFF5F5DC),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? RotationTransition(
                    turns: _loadingAnimation,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFF5F5DC),
                      ),
                    ),
                  )
                : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() => _isSignUp = !_isSignUp);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFA13F89),
            ),
            child: Text(_isSignUp
                ? 'Already have an account? Sign In'
                : 'Don\'t have an account? Sign Up'),
          ),
        ],
      ),
    );
  }
}

class FlowerPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final flowerSize = size.width * 0.1;
    for (double x = 0; x < size.width; x += flowerSize * 2) {
      for (double y = 0; y < size.height; y += flowerSize * 2) {
        // Draw flower petals
        for (int i = 0; i < 5; i++) {
          final angle = (i * 72) * 3.14159 / 180;
          final centerX = x + flowerSize;
          final centerY = y + flowerSize;
          final petalPath = Path()
            ..moveTo(centerX, centerY)
            ..quadraticBezierTo(
              centerX + cos(angle) * flowerSize * 0.8,
              centerY + sin(angle) * flowerSize * 0.8,
              centerX + cos(angle) * flowerSize * 0.6,
              centerY + sin(angle) * flowerSize * 0.6,
            )
            ..quadraticBezierTo(
              centerX + cos(angle + 0.5) * flowerSize * 0.4,
              centerY + sin(angle + 0.5) * flowerSize * 0.4,
              centerX,
              centerY,
            );
          canvas.drawPath(petalPath, paint);
        }

        // Draw flower center
        canvas.drawCircle(
          Offset(x + flowerSize, y + flowerSize),
          flowerSize * 0.15,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
