import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import 'constants.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import 'widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;
  final _otpController = TextEditingController();
  String? _otpError;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(_clearOtpError);
  }

  void _clearOtpError() {
    if (_otpError != null) {
      setState(() {
        _otpError = null;
      });
    }
  }

  void _handleSendOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(AppDurations.medium, () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _otpSent = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully!'),
            backgroundColor: AppColors.googleGreen,
          ),
        );
      });
    }
  }

  void _handleLogin() {
    if (_otpController.text.length == 6) {
      setState(() {
        _isLoading = true;
        _otpError = null;
      });
      Future.delayed(AppDurations.medium, () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: AppColors.googleGreen,
          ),
        );
      });
    } else {
      setState(() {
        _otpError = 'Please enter a valid 6-digit OTP';
      });
    }
  }

  void _goBackToMobileEntry() {
    setState(() {
      _otpSent = false;
      _otpController.clear();
      _otpError = null;
    });
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    }
    if (value.length != 10 || int.tryParse(value) == null) {
      return 'Please enter a valid 10-digit mobile number';
    }
    return null;
  }

  VoidCallback? getLoginButtonCallback() {
    if (_otpController.text.length == 6) {
      return _handleLogin;
    }
    return null;
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          // Wrap with Center widget to center vertically
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ), // Reduced from 40 to balance vertical centering

                FadeInDown(
                  duration: AppDurations.medium,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Welcome back!',
                        style: AppTextStyles.headline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _otpSent
                            ? 'Please enter the OTP sent to +91 ${_mobileController.text}'
                            : 'Login with your mobile number',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!_otpSent) ...[
                        CustomTextField(
                          label: 'Mobile Number',
                          hint: 'Enter your 10-digit mobile number',
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          validator: _validateMobile,
                          onChanged: (_) => setState(() {}),
                          prefixIcon: const Icon(
                            Icons.phone_android,
                            color: AppColors.googleBlue,
                          ),
                        ),

                        const SizedBox(height: 24),

                        FadeInUp(
                          duration: AppDurations.fast,
                          child: CustomPrimaryButton(
                            text: 'Send OTP',
                            onPressed:
                                _mobileController.text.length == 10
                                    ? _handleSendOtp
                                    : null,
                            isLoading: _isLoading,
                          ),
                        ),
                      ] else ...[
                        FadeInUp(
                          duration: AppDurations.fast,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                ),
                                child: TextField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    letterSpacing: 10,
                                  ),
                                  onChanged: (text) {
                                    setState(() {});
                                  },
                                  decoration: InputDecoration(
                                    hintText: '------',
                                    counterText: '',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.medium,
                                      ),
                                      borderSide: const BorderSide(
                                        color: AppColors.lightGrey,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.medium,
                                      ),
                                      borderSide: const BorderSide(
                                        color: AppColors.googleBlue,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_otpError != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                  ),
                                  child: Text(
                                    _otpError!,
                                    style: const TextStyle(
                                      color: AppColors.googleRed,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Didn't receive OTP? ",
                                    style: AppTextStyles.caption,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _otpSent = false;
                                      });
                                    },
                                    child: const Text(
                                      "Resend",
                                      style: TextStyle(
                                        color: AppColors.googleBlue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Add back button option
                              GestureDetector(
                                onTap: _goBackToMobileEntry,
                                child: const Text(
                                  "Change mobile number",
                                  style: TextStyle(
                                    color: AppColors.googleBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              CustomPrimaryButton(
                                text: 'Login',
                                onPressed: getLoginButtonCallback(),
                                isLoading: _isLoading,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                if (!_otpSent)
                  FadeInUp(
                    duration: AppDurations.slow,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: AppTextStyles.caption,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: AppColors.googleBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
