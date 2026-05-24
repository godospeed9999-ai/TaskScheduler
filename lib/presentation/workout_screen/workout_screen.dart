import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  static const List<Map<String, String>> _workouts = [
    {
      'videoId': 'UItWltVZZmE',
      'title': '10 Min Morning Workout - No Equipment',
      'channel': 'MadFit',
      'thumbnail': 'https://img.rocket.new/generatedImages/rocket_gen_img_15a81d7d2-1779614211000.png',
      'duration': '10 min',
      'level': 'Beginner',
    },
    {
      'videoId': 'gC_L9qAHVJ8',
      'title': 'Full Body Workout at Home - Beginner Friendly',
      'channel': 'Chloe Ting',
      'thumbnail': 'https://img.rocket.new/generatedImages/rocket_gen_img_1528faa6a-1773171484322.png',
      'duration': '20 min',
      'level': 'Beginner',
    },
    {
      'videoId': 'ml6cT4AZdqI',
      'title': '7 Minute Workout - Science-Based',
      'channel': 'Fitness Blender',
      'thumbnail': 'https://img.rocket.new/generatedImages/rocket_gen_img_146534319-1779614210717.png',
      'duration': '7 min',
      'level': 'Beginner',
    },
    {
      'videoId': 'oAPCPjnU1wA',
      'title': '30 Min Full Body HIIT Workout - No Equipment',
      'channel': 'SELF',
      'thumbnail': 'https://img.rocket.new/generatedImages/rocket_gen_img_1634caa36-1774239841073.png',
      'duration': '30 min',
      'level': 'Intermediate',
    },
    {
      'videoId': 'vc1E5CfRfos',
      'title': 'Home Workout - No Equipment Full Body',
      'channel': 'Heather Robertson',
      'thumbnail': 'https://img.rocket.new/generatedImages/rocket_gen_img_1634caa36-1774239841073.png',
      'duration': '25 min',
      'level': 'Intermediate',
    },
    {
      'videoId': 'cbKkB3POqaY',
      'title': 'Yoga for Beginners - Morning Routine',
      'channel': 'Yoga With Adriene',
      'thumbnail': 'https://img.rocket.new/generatedImages/rocket_gen_img_1a1a8af83-1774423547472.png',
      'duration': '15 min',
      'level': 'Beginner',
    },
  ];

  Future<void> _openVideo(String videoId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Workout',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Stay active, stay focused',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: CustomIconWidget(
                          iconName: 'fitness_center_rounded',
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Section label
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text(
                  'Home Workouts',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
            // Workout list
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final w = _workouts[index];
                  return _WorkoutCard(
                    videoId: w['videoId']!,
                    title: w['title']!,
                    channel: w['channel']!,
                    thumbnailUrl: w['thumbnail']!,
                    duration: w['duration']!,
                    level: w['level']!,
                    onTap: () => _openVideo(w['videoId']!),
                  );
                }, childCount: _workouts.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final String videoId;
  final String title;
  final String channel;
  final String thumbnailUrl;
  final String duration;
  final String level;
  final VoidCallback onTap;

  const _WorkoutCard({
    required this.videoId,
    required this.title,
    required this.channel,
    required this.thumbnailUrl,
    required this.duration,
    required this.level,
    required this.onTap,
  });

  Color get _levelColor {
    switch (level) {
      case 'Beginner':
        return AppTheme.success;
      case 'Intermediate':
        return AppTheme.warning;
      default:
        return AppTheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: Row(
          children: [
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: thumbnailUrl,
                    width: 120,
                    height: 88,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 120,
                      height: 88,
                      color: AppTheme.surfaceVariantDark,
                      child: const Center(
                        child: CustomIconWidget(
                          iconName: 'fitness_center_rounded',
                          color: AppTheme.textMuted,
                          size: 28,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 120,
                      height: 88,
                      color: AppTheme.surfaceVariantDark,
                      child: const Center(
                        child: CustomIconWidget(
                          iconName: 'broken_image_rounded',
                          color: AppTheme.textMuted,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
                // Duration badge
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(179),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      duration,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      channel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _levelColor.withAlpha(38),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            level,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _levelColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(38),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CustomIconWidget(
                                iconName: 'play_arrow_rounded',
                                color: AppTheme.primaryLight,
                                size: 10,
                              ),
                              SizedBox(width: 2),
                              Text(
                                'Watch',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
