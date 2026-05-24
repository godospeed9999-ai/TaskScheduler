import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../models/blocked_app_model.dart';
import '../../../theme/app_theme.dart';

class AppBlockCardWidget extends StatelessWidget {
  final BlockedAppModel app;
  final Color iconColor;
  final ValueChanged<bool> onToggle;

  const AppBlockCardWidget({
    super.key,
    required this.app,
    required this.iconColor,
    required this.onToggle,
  });

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: app.isBlocked
                ? AppTheme.error.withAlpha(15)
                : AppTheme.cardDark,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: app.isBlocked
                  ? AppTheme.error.withAlpha(51)
                  : AppTheme.glassBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // App icon (colored circle with initials)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(38),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: iconColor.withAlpha(51)),
                ),
                child: Center(
                  child: Text(
                    _initials(app.appName),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // App info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.appName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (app.isBlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withAlpha(38),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'BLOCKED',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.error,
                                letterSpacing: 0.5,
                              ),
                            ),
                          )
                        else
                          Text(
                            app.packageName.length > 28
                                ? '${app.packageName.substring(0, 28)}...'
                                : app.packageName,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Block toggle
              Switch(
                value: app.isBlocked,
                onChanged: onToggle,
                activeThumbColor: AppTheme.error,
                activeTrackColor: AppTheme.error.withAlpha(77),
                inactiveThumbColor: AppTheme.textMuted,
                inactiveTrackColor: AppTheme.surfaceVariantDark,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
