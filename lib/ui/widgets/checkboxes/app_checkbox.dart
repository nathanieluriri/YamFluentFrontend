import 'package:flutter/material.dart';

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.toggleOnLabelTap = true,
  });

  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Widget? label;
  final bool toggleOnLabelTap;

  @override
  Widget build(BuildContext context) {
    final labelWidget = label;

    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF02344C),
            checkColor: const Color(0XFFFFFFFF),
            side: const BorderSide(
              color: Color(0xFF02344C), 
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        if (labelWidget != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: toggleOnLabelTap
                ? InkWell(
                    onTap: onChanged == null ? null : () => onChanged?.call(!value),
                    child: labelWidget,
                  )
                : labelWidget,
          ),
        ],
      ],
    );
  }
}
