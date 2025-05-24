import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'constants.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final int? maxLength;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.maxLength,
    this.enabled = true,
    this.inputFormatters,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          obscureText: _isObscured,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          inputFormatters: widget.inputFormatters,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
            prefixIcon:
                widget.prefixIcon != null
                    ? Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.md,
                        right: AppSpacing.sm,
                      ),
                      child: widget.prefixIcon,
                    )
                    : null,
            suffixIcon:
                widget.obscureText
                    ? IconButton(
                      icon: Icon(
                        _isObscured ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                    )
                    : widget.suffixIcon,
            counterText: '',
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: const BorderSide(
                color: AppColors.borderActive,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}

class CustomPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textHint,
        ),
        child:
            isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(text, style: AppTextStyles.button),
                  ],
                ),
      ),
    );
  }
}

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
      height: 56,
      child: OutlinedButton(
        style: AppButtonStyles.secondaryButton,
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}

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

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepLabels;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
    this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Step ${currentStep + 1} of $totalSteps',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.xs),

        Row(
          children: List.generate(totalSteps, (index) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: index < totalSteps - 1 ? AppSpacing.xs : 0,
                ),
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color:
                      index <= currentStep
                          ? AppColors.primary
                          : AppColors.border,
                ),
              ),
            );
          }),
        ),

        if (stepLabels != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
                stepLabels!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  return Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color:
                          index <= currentStep
                              ? AppColors.primary
                              : AppColors.textHint,
                      fontWeight:
                          index == currentStep
                              ? FontWeight.w600
                              : FontWeight.normal,
                    ),
                  );
                }).toList(),
          ),
        ],
      ],
    );
  }
}

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

class SuccessMessage extends StatelessWidget {
  final String message;
  final IconData icon;

  const SuccessMessage({
    super.key,
    required this.message,
    this.icon = Icons.check_circle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.success, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final strength = _calculatePasswordStrength(password);
    final strengthText = _getStrengthText(strength);
    final strengthColor = _getStrengthColor(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength / 4,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                minHeight: 4,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              strengthText,
              style: AppTextStyles.caption.copyWith(
                color: strengthColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (password.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Password must contain at least 8 characters',
            style: AppTextStyles.caption,
          ),
        ],
      ],
    );
  }

  int _calculatePasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    return strength;
  }

  String _getStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return 'Weak';
    }
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.primary;
      case 4:
        return AppColors.success;
      default:
        return AppColors.error;
    }
  }
}
