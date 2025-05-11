import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'constants.dart';

// Custom Primary Button
class CustomPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double width;

  const CustomPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: AppButtonStyles.primaryButton,
        onPressed: isLoading ? null : onPressed,
        child:
            isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
                : Text(text, style: AppTextStyles.button),
      ),
    );
  }
}

// Custom Secondary Button
class CustomSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;

  const CustomSecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: OutlinedButton(
        style: AppButtonStyles.secondaryButton,
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}

// Custom Text Field
class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.autofocus = false,
    this.focusNode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: AppDurations.fast,
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
        autofocus: autofocus,
        focusNode: focusNode,
        onChanged: onChanged,
        decoration: AppInputDecorations.textFieldDecoration(
          label: label,
          hint: hint,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

// Custom OTP TextField
class CustomOtpField extends StatelessWidget {
  final ValueChanged<String> onCompleted;
  final int length;

  const CustomOtpField({super.key, required this.onCompleted, this.length = 6});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: AppDurations.fast,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            // We're not actually implementing this with pin_code_fields here
            // as we're using a simpler TextField in the actual screens
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(fontSize: 24, letterSpacing: 10),
              onChanged: (value) {
                if (value.length == length) {
                  onCompleted(value);
                }
              },
              decoration: InputDecoration(
                hintText: '------',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  borderSide: const BorderSide(color: AppColors.lightGrey),
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
        ),
      ),
    );
  }
}

// Header with back button
class HeaderWithBackButton extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;

  const HeaderWithBackButton({
    super.key,
    required this.title,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.headline),
      ],
    );
  }
}

// Progress Indicator for multi-step forms
class StepProgressIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const StepProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        final isActive = index == currentStep;

        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color:
                  isCompleted || isActive
                      ? AppColors.googleBlue
                      : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
          ),
        );
      }),
    );
  }
}

// Animated Container for transitions
class AnimatedSlideTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final bool isForward;

  const AnimatedSlideTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.isForward = true,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInRight(
      duration: duration,
      from: isForward ? 30 : -30,
      child: child,
    );
  }
}
