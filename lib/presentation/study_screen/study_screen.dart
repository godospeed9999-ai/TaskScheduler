import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/youtube_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final YoutubeService _youtubeService = YoutubeService();
  final TextEditingController _searchController = TextEditingController();

  List<YoutubeVideoModel> _videos = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentQuery = '';

  static const List<Map<String, String>> _preloadedVideos = [
    {
      'videoId': 'aircAruvnKk',
      'title': 'But what is a neural network? | Deep learning, chapter 1',
      'channel': '3Blue1Brown',
      'thumbnail': 'https://img.rocket.new/generatedImages/rocket_gen_img_11c0400a2-1772827301108.png',
    },
    {
      'videoId': 'rfscVS0vtbw',
      'title': 'Learn Python - Full Course for Beginners',
      'channel': 'freeCodeCamp.org',
      'thumbnail': 'https://img.rocket.new/generatedImages/rocket_gen_img_1d5cdeb9e-1773227311717.png',
    },
    {
      'videoId': 'HXV3zeQKqGY',
      'title': 'SQL Tutorial - Full Database Course for Beginners',
      'channel': 'freeCodeCamp.org',
      'thumbnail': 'https://img.rocket.new/generatedImages/rocket_gen_img_11ca769bc-1767787715001.png',
    },
    {
      'videoId': 'NWuyBaAl7Zg',
      'title': 'Algebra Basics: What Is Algebra? - Math Antics',
      'channel': 'mathantics',
      'thumbnail': 'https://img.rocket.new/generatedImages/rocket_gen_img_1606c9a75-1767751467290.png',
    },
    {
      'videoId': 'OAx_6-wdslM',
      'title': 'Physics - Basic Introduction',
      'channel': 'The Organic Chemistry Tutor',
      'thumbnail': 'https://img.rocket.new/generatedImages/rocket_gen_img_1501aa542-1767141247036.png',
    },
    {
      'videoId': 'eI4an8aSsgw',
      'title': 'Introduction to Chemistry - Basic Overview',
      'channel': 'The Organic Chemistry Tutor',
      'thumbnail': 'https://img.rocket.new/generatedImages/rocket_gen_img_11b914ddc-1773236018671.png',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchVideos(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentQuery = query.trim();
    });
    try {
      final results = await _youtubeService.searchVideos(
        query.trim(),
        maxResults: 10,
      );
      if (mounted) {
        setState(() {
          _videos = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load videos. Check your connection.';
          _isLoading = false;
        });
      }
    }
  }

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Study',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Learn something new today',
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
                        colors: [AppTheme.primary, AppTheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: CustomIconWidget(
                        iconName: 'menu_book_rounded',
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 14),
                      child: CustomIconWidget(
                        iconName: 'search_rounded',
                        color: AppTheme.textMuted,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search study videos...',
                          hintStyle: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: _searchVideos,
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _videos = [];
                            _currentQuery = '';
                            _errorMessage = null;
                          });
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: CustomIconWidget(
                            iconName: 'close_rounded',
                            color: AppTheme.textMuted,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Section label
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                _currentQuery.isNotEmpty
                    ? 'Results for "$_currentQuery"'
                    : 'Featured Study Videos',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                        strokeWidth: 2,
                      ),
                    )
                  : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CustomIconWidget(
                              iconName: 'wifi_off_rounded',
                              color: AppTheme.textMuted,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _buildVideoList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoList() {
    final isSearchResult = _currentQuery.isNotEmpty && _videos.isNotEmpty;

    if (isSearchResult) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final video = _videos[index];
          return _VideoCard(
            videoId: video.videoId,
            title: video.title,
            channel: video.channelTitle,
            thumbnailUrl: video.thumbnailUrl,
            onTap: () => _openVideo(video.videoId),
          );
        },
      );
    }

    // Preloaded videos
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      itemCount: _preloadedVideos.length,
      itemBuilder: (context, index) {
        final v = _preloadedVideos[index];
        return _VideoCard(
          videoId: v['videoId']!,
          title: v['title']!,
          channel: v['channel']!,
          thumbnailUrl: v['thumbnail']!,
          onTap: () => _openVideo(v['videoId']!),
        );
      },
    );
  }
}

class _VideoCard extends StatelessWidget {
  final String videoId;
  final String title;
  final String channel;
  final String thumbnailUrl;
  final VoidCallback onTap;

  const _VideoCard({
    required this.videoId,
    required this.title,
    required this.channel,
    required this.thumbnailUrl,
    required this.onTap,
  });

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
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: thumbnailUrl,
                width: 120,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 120,
                  height: 80,
                  color: AppTheme.surfaceVariantDark,
                  child: const Center(
                    child: CustomIconWidget(
                      iconName: 'play_circle_outline_rounded',
                      color: AppTheme.textMuted,
                      size: 28,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 120,
                  height: 80,
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
                    const SizedBox(height: 6),
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
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(38),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CustomIconWidget(
                                iconName: 'play_arrow_rounded',
                                color: AppTheme.primaryLight,
                                size: 12,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Open YouTube',
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
