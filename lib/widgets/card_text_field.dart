import 'package:flutter/cupertino.dart';

class CardTextField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final int maxLines;
  final bool enabled;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;

  const CardTextField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.maxLines = 1,
    this.enabled = true,
    this.suffixIcon,
    this.onTap,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CupertinoColors.systemGrey4,
              width: 1,
            ),
          ),
          child: CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            maxLines: maxLines,
            enabled: enabled,
            onTap: onTap,
            keyboardType: keyboardType,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(),
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.label,
            ),
            placeholderStyle: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.placeholderText,
            ),
            suffix: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: suffixIcon,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class CardSelectField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final Widget? trailing;

  const CardSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CupertinoColors.systemGrey4,
              width: 1,
            ),
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.label,
                      ),
                    ),
                  ),
                  trailing ??
                      const Icon(
                        CupertinoIcons.chevron_right,
                        color: CupertinoColors.systemGrey2,
                        size: 16,
                      ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CardSection extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? margin;

  const CardSection({
    super.key,
    required this.children,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.systemGrey5,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey6.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
} 