import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class BlockAppsHeaderWidget extends StatelessWidget {
  final int blockedCount;
  final int totalCount;
  final VoidCallback? onUnblockAll;

  const BlockAppsHeaderWidget({
    super.key,
    required this.blockedCount,
    required this.totalCount,
    this.onUnblockAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Block Apps',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Blocked during focus sessions',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onUnblockAll != null)
                GestureDetector(
                  onTap: onUnblockAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.error.withAlpha(64)),
                    ),
                    child: const Text(
                      'Unblock All',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.error,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          // Stats row
          Row(
            children: [
              _StatChip(
                label: 'Blocked',
                value: '$blockedCount',
                color: AppTheme.error,
                iconName: 'block_rounded',
              ),
              const SizedBox(width: 10),
              _StatChip(
                label: 'Allowed',
                value: '${totalCount - blockedCount}',
                color: AppTheme.success,
                iconName: 'check_circle_outline_rounded',
              ),
              const SizedBox(width: 10),
              _StatChip(
                label: 'Total',
                value: '$totalCount',
                color: AppTheme.textSecondary,
                iconName: 'apps_rounded',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String iconName;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.iconName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(iconName: iconName, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
