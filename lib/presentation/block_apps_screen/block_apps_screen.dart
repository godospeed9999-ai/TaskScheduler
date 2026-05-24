import 'package:flutter/material.dart';

import '../../models/blocked_app_model.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/empty_state_widget.dart';
import './widgets/app_block_card_widget.dart';
import './widgets/block_apps_header_widget.dart';

// Mock installed apps for Android — in production, use device_apps package
// to fetch real installed apps via platform channel
final List<Map<String, dynamic>> _mockInstalledApps = [
  {
    'packageName': 'com.instagram.android',
    'appName': 'Instagram',
    'iconColor': 0xFFE1306C,
  },
  {
    'packageName': 'com.facebook.katana',
    'appName': 'Facebook',
    'iconColor': 0xFF1877F2,
  },
  {
    'packageName': 'com.twitter.android',
    'appName': 'X (Twitter)',
    'iconColor': 0xFF000000,
  },
  {
    'packageName': 'com.snapchat.android',
    'appName': 'Snapchat',
    'iconColor': 0xFFFFFC00,
  },
  {
    'packageName': 'com.google.android.youtube',
    'appName': 'YouTube',
    'iconColor': 0xFFFF0000,
  },
  {
    'packageName': 'com.netflix.mediaclient',
    'appName': 'Netflix',
    'iconColor': 0xFFE50914,
  },
  {
    'packageName': 'com.spotify.music',
    'appName': 'Spotify',
    'iconColor': 0xFF1DB954,
  },
  {
    'packageName': 'com.whatsapp',
    'appName': 'WhatsApp',
    'iconColor': 0xFF25D366,
  },
  {
    'packageName': 'com.reddit.frontpage',
    'appName': 'Reddit',
    'iconColor': 0xFFFF4500,
  },
  {'packageName': 'com.discord', 'appName': 'Discord', 'iconColor': 0xFF5865F2},
  {
    'packageName': 'com.tiktok.android',
    'appName': 'TikTok',
    'iconColor': 0xFF010101,
  },
  {
    'packageName': 'com.google.android.gm',
    'appName': 'Gmail',
    'iconColor': 0xFFEA4335,
  },
];

class BlockAppsScreen extends StatefulWidget {
  const BlockAppsScreen({super.key});

  @override
  State<BlockAppsScreen> createState() => _BlockAppsScreenState();
}

class _BlockAppsScreenState extends State<BlockAppsScreen> {
  // TODO: Replace with Riverpod/Bloc for production
  final DatabaseService _db = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  List<BlockedAppModel> _apps = [];
  List<BlockedAppModel> _filteredApps = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int get _blockedCount => _apps.where((a) => a.isBlocked).length;

  @override
  void initState() {
    super.initState();
    _loadApps();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filteredApps = _apps
          .where((a) => a.appName.toLowerCase().contains(_searchQuery))
          .toList();
    });
  }

  Future<void> _loadApps() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Load saved blocked states from DB
      final savedApps = await _db.getAllSavedApps();
      final savedMap = {for (final a in savedApps) a.packageName: a};

      // Merge mock installed apps with saved DB state
      final merged = _mockInstalledApps.map((appMap) {
        final pkg = appMap['packageName'] as String;
        final saved = savedMap[pkg];
        return BlockedAppModel(
          id: saved?.id,
          packageName: pkg,
          appName: appMap['appName'] as String,
          isBlocked: saved?.isBlocked ?? false,
        );
      }).toList();

      // Persist any new apps to DB
      for (final app in merged) {
        if (!savedMap.containsKey(app.packageName)) {
          await _db.upsertBlockedApp(app);
        }
      }

      if (mounted) {
        setState(() {
          _apps = merged;
          _filteredApps = merged;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleBlock(BlockedAppModel app, bool isBlocked) async {
    // Optimistic update
    setState(() {
      final idx = _apps.indexWhere((a) => a.packageName == app.packageName);
      if (idx >= 0) {
        _apps[idx] = _apps[idx].copyWith(isBlocked: isBlocked);
      }
      final fidx = _filteredApps.indexWhere(
        (a) => a.packageName == app.packageName,
      );
      if (fidx >= 0) {
        _filteredApps[fidx] = _filteredApps[fidx].copyWith(
          isBlocked: isBlocked,
        );
      }
    });

    try {
      if (app.id != null) {
        await _db.updateBlockedStatus(app.packageName, isBlocked);
      } else {
        await _db.upsertBlockedApp(app.copyWith(isBlocked: isBlocked));
      }
    } catch (e) {
      // Revert on failure
      if (mounted) {
        setState(() {
          final idx = _apps.indexWhere((a) => a.packageName == app.packageName);
          if (idx >= 0) {
            _apps[idx] = _apps[idx].copyWith(isBlocked: !isBlocked);
          }
          final fidx = _filteredApps.indexWhere(
            (a) => a.packageName == app.packageName,
          );
          if (fidx >= 0) {
            _filteredApps[fidx] = _filteredApps[fidx].copyWith(
              isBlocked: !isBlocked,
            );
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update. Please try again.')),
        );
      }
    }
  }

  void _unblockAll() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Unblock All Apps?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'All apps will be unblocked. You can re-block them anytime.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              for (final app in _apps.where((a) => a.isBlocked)) {
                await _db.updateBlockedStatus(app.packageName, false);
              }
              await _loadApps();
            },
            child: const Text(
              'Unblock All',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Color _appIconColor(String packageName) {
    final match = _mockInstalledApps.firstWhere(
      (m) => m['packageName'] == packageName,
      orElse: () => {'iconColor': 0xFF7C3AED},
    );
    return Color(match['iconColor'] as int);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header section (fixed)
            BlockAppsHeaderWidget(
              blockedCount: _blockedCount,
              totalCount: _apps.length,
              onUnblockAll: _blockedCount > 0 ? _unblockAll : null,
            ),
            // Search bar (fixed)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search apps...',
                    hintStyle: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: CustomIconWidget(
                        iconName: 'search_rounded',
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              FocusScope.of(context).unfocus();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: CustomIconWidget(
                                iconName: 'close_rounded',
                                color: AppTheme.textSecondary,
                                size: 18,
                              ),
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            // Notice banner
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withAlpha(20),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.warning.withAlpha(51)),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info_outline_rounded',
                      color: AppTheme.warning,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Blocked apps will show a warning during focus sessions',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // App list (scrollable)
            Expanded(
              child: _isLoading
                  ? _buildSkeletonList()
                  : _filteredApps.isEmpty
                  ? EmptyStateWidget(
                      iconName: 'search_off_rounded',
                      title: 'No apps found',
                      subtitle: 'Try a different search term.',
                    )
                  : isTablet
                  ? _buildTabletGrid()
                  : _buildPhoneList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: _filteredApps.length,
      itemBuilder: (_, i) {
        final app = _filteredApps[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppBlockCardWidget(
            app: app,
            iconColor: _appIconColor(app.packageName),
            onToggle: (val) => _toggleBlock(app, val),
          ),
        );
      },
    );
  }

  Widget _buildTabletGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 10,
        childAspectRatio: 3.5,
      ),
      itemCount: _filteredApps.length,
      itemBuilder: (_, i) {
        final app = _filteredApps[i];
        return AppBlockCardWidget(
          app: app,
          iconColor: _appIconColor(app.packageName),
          onToggle: (val) => _toggleBlock(app, val),
        );
      },
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: 8,
      itemBuilder: (_, __) => Container(
        height: 68,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.glassBorder),
        ),
      ),
    );
  }
}
