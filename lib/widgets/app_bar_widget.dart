import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import './custom_icon_widget.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? leading;

  const AppBarWidget({
    super.key,
    required this.title,
    this.actions,
    this.showBack = false,
    this.onBack,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 64 + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: AppTheme.backgroundDark.withAlpha(179),
            border: Border(
              bottom: BorderSide(color: AppTheme.glassBorder, width: 1),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              if (showBack)
                GestureDetector(
                  onTap: onBack ?? () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.glassSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.glassBorder),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'arrow_back_ios_new_rounded',
                        color: AppTheme.textPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                )
              else if (leading != null)
                leading!,
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              if (actions != null) ...actions!,
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}
