import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    this.showAdmin = false,
    this.fontSize = 28,
    this.compact = false,
    super.key,
  });

  final bool showAdmin;
  final double fontSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontSize: fontSize,
      height: 1,
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
    );

    if (compact) {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
      );
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: style,
        children: [
          const TextSpan(
            text: 'Tá',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          const TextSpan(
            text: 'Feito',
            style: TextStyle(color: AppColors.primary),
          ),
          if (showAdmin)
            TextSpan(
              text: ' Admin',
              style: TextStyle(color: AppColors.textPrimary),
            ),
        ],
      ),
    );
  }
}
