import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'constants.dart';
import 'widgets.dart';
import 'color_utils.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int _currentStep = 0;
  final int _totalSteps = 3;

  final _businessNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  final _panController = TextEditingController();
  final _captchaController = TextEditingController();

  final _gstinController = TextEditingController();
  final _gstCaptchaController = TextEditingController();

  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  bool _isLoading = false;
  bool _otpSent = false;
  bool _otpVerified = false;
  String? _captchaImage;
  String? _gstCaptchaImage;

  @override
  void dispose() {
    _businessNameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _panController.dispose();
    _captchaController.dispose();
    _gstinController.dispose();
    _gstCaptchaController.dispose();
    super.dispose();
  }

  void _handleSendOtp() {
    if (_formKeys[0].currentState?.validate() ?? false) {
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

  void _handleVerifyOtp() {
    if (_otpController.text.length == 6) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(AppDurations.medium, () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _otpVerified = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP verified successfully!'),
            backgroundColor: AppColors.googleGreen,
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid OTP'),
          backgroundColor: AppColors.googleRed,
        ),
      );
    }
  }

  void _handleContinue() {
    if (_currentStep == 0) {
      if (_otpVerified) {
        _goToNextStep();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please verify your mobile number first'),
            backgroundColor: AppColors.googleRed,
          ),
        );
      }
    } else if (_currentStep == 1) {
      if (_formKeys[1].currentState?.validate() ?? false) {
        setState(() {
          _isLoading = true;
        });

        Future.delayed(AppDurations.medium, () {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          _goToNextStep();
        });
      }
    } else if (_currentStep == 2) {
      if (_formKeys[2].currentState?.validate() ?? false) {
        setState(() {
          _isLoading = true;
        });

        Future.delayed(AppDurations.medium, () {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration completed successfully!'),
              backgroundColor: AppColors.googleGreen,
            ),
          );

          Navigator.of(context).pop();
        });
      }
    }
  }

  void _goToNextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  String? _validateBusinessName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your business name';
    }
    return null;
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validatePAN(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your PAN number';
    }

    final RegExp panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(value)) {
      return 'Please enter a valid PAN number';
    }
    return null;
  }

  String? _validateCaptcha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the captcha';
    }
    return null;
  }

  String? _validateGSTIN(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your GSTIN';
    }

    if (value.length != 15) {
      return 'GSTIN must be 15 characters';
    }
    return null;
  }

  void _generateCaptcha() {
    setState(() {
      _captchaImage = 'Simulated Captcha Image';
    });
  }

  void _generateGSTCaptcha() {
    setState(() {
      _gstCaptchaImage = 'Simulated GST Captcha Image';
    });
  }

  String _getPageTitle() {
    switch (_currentStep) {
      case 0:
        return 'Create Account';
      case 1:
        return 'Verify PAN';
      case 2:
        return 'Verify GSTIN';
      default:
        return 'Sign Up';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _goToPreviousStep,
        ),
        title: Text(
          _getPageTitle(),
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: StepProgressIndicator(
                totalSteps: _totalSteps,
                currentStep: _currentStep,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: AnimatedSwitcher(
                  duration: AppDurations.medium,
                  child: _buildCurrentStep(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return _buildStep1();
    }
  }

  Widget _buildStep1() {
    return Form(
      key: _formKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FadeInDown(
            duration: AppDurations.fast,
            child: const Text(
              'Let\'s get started with your business details',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'Business Name',
            hint: 'Enter your business name',
            controller: _businessNameController,
            validator: _validateBusinessName,
            onChanged: (_) => setState(() {}),
            prefixIcon: const Icon(Icons.business, color: AppColors.googleBlue),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Password',
            hint: 'Create a password (min. 8 characters)',
            controller: _passwordController,
            obscureText: true,
            validator: _validatePassword,
            onChanged: (_) => setState(() {}),
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.googleBlue,
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Confirm Password',
            hint: 'Re-enter your password',
            controller: _confirmPasswordController,
            obscureText: true,
            validator: _validateConfirmPassword,
            onChanged: (_) => setState(() {}),
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.googleBlue,
            ),
          ),
          const SizedBox(height: 24),

          if (!_otpSent) ...[
            CustomPrimaryButton(
              text: 'Get OTP',
              onPressed:
                  _mobileController.text.length == 10 &&
                          _passwordController.text.length >= 8 &&
                          _passwordController.text ==
                              _confirmPasswordController.text
                      ? _handleSendOtp
                      : null,
              isLoading: _isLoading,
            ),
          ] else if (!_otpVerified) ...[
            FadeInUp(
              duration: AppDurations.fast,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, letterSpacing: 10),
                      onChanged: (text) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: '------',
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                          borderSide: const BorderSide(
                            color: AppColors.lightGrey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                          borderSide: const BorderSide(
                            color: AppColors.googleBlue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Didn't receive OTP? ",
                        style: AppTextStyles.caption,
                      ),
                      GestureDetector(
                        onTap: _handleSendOtp,
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
                  const SizedBox(height: 24),
                  CustomPrimaryButton(
                    text: 'Verify OTP',
                    onPressed:
                        _otpController.text.length == 6
                            ? _handleVerifyOtp
                            : null,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ] else ...[
            FadeInUp(
              duration: AppDurations.fast,
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.googleGreen,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Mobile verified successfully',
                        style: TextStyle(
                          color: AppColors.googleGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomPrimaryButton(
                    text: 'Continue',
                    onPressed: _otpVerified ? _handleContinue : null,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep2() {
    if (_captchaImage == null) {
      _generateCaptcha();
    }

    return FadeInRight(
      duration: AppDurations.medium,
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Verify your PAN details',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'PAN Number',
              hint: 'Enter your PAN number',
              controller: _panController,
              validator: _validatePAN,
              onChanged: (_) => setState(() {}),
              keyboardType: TextInputType.text,
              prefixIcon: const Icon(
                Icons.credit_card,
                color: AppColors.googleBlue,
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Captcha Verification',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withAlpha(77),
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              _captchaImage ?? 'Loading captcha...',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: AppColors.googleBlue,
                          ),
                          onPressed: _generateCaptcha,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Enter Captcha',
                    hint: 'Type the captcha shown above',
                    controller: _captchaController,
                    validator: _validateCaptcha,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            CustomPrimaryButton(
              text: 'Verify & Continue',
              onPressed:
                  _panController.text.length == 10 &&
                          _captchaController.text.isNotEmpty
                      ? _handleContinue
                      : null,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    if (_gstCaptchaImage == null) {
      _generateGSTCaptcha();
    }

    return FadeInRight(
      duration: AppDurations.medium,
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Verify your GSTIN details',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'GSTIN',
              hint: 'Enter your 15-digit GSTIN',
              controller: _gstinController,
              validator: _validateGSTIN,
              onChanged: (_) => setState(() {}),
              keyboardType: TextInputType.text,
              prefixIcon: const Icon(
                Icons.receipt_long,
                color: AppColors.googleBlue,
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Captcha Verification',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withAlpha(77),
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              _gstCaptchaImage ?? 'Loading captcha...',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: AppColors.googleBlue,
                          ),
                          onPressed: _generateGSTCaptcha,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Enter Captcha',
                    hint: 'Type the captcha shown above',
                    controller: _gstCaptchaController,
                    validator: _validateCaptcha,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            CustomPrimaryButton(
              text: 'Complete Registration',
              onPressed:
                  _gstinController.text.length == 15 &&
                          _gstCaptchaController.text.isNotEmpty
                      ? _handleContinue
                      : null,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
