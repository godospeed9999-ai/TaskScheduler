import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/chat_message_model.dart';
import '../../models/task_model.dart';
import '../../services/database_service.dart';
import '../../services/openrouter_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/ai_orb_widget.dart';
import './widgets/chat_bubble_widget.dart';
import './widgets/task_created_card_widget.dart';
import './widgets/typing_indicator_widget.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  // TODO: Replace with Riverpod/Bloc for production
  final OpenRouterService _aiService = OpenRouterService();
  final DatabaseService _db = DatabaseService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessageModel> _messages = [];
  List<TaskModel>? _generatedTasks;

  bool _isLoading = false;
  bool _isRequestLocked = false; // Prevents race conditions
  String _streamingBuffer = '';
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initSession());
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initSession() async {
    if (_hasInitialized || !mounted) return;
    _hasInitialized = true;
    await _sendToAi(isInitialMessage: true);
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animated) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 200,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        } else {
          _scrollController.jumpTo(
            _scrollController.position.maxScrollExtent + 200,
          );
        }
      }
    });
  }

  Future<void> _sendToAi({bool isInitialMessage = false}) async {
    if (_isRequestLocked || !mounted) return;

    String userText = '';
    if (!isInitialMessage) {
      userText = _inputController.text.trim();
      if (userText.isEmpty) return;
    }

    // Lock to prevent overlapping requests
    setState(() {
      _isRequestLocked = true;
      _isLoading = true;
      _streamingBuffer = '';
    });

    if (!isInitialMessage) {
      _inputController.clear();
      final userMsg = ChatMessageModel(
        role: 'user',
        content: userText,
        timestamp: DateTime.now(),
      );
      setState(() => _messages.add(userMsg));
      _scrollToBottom();
    }

    // Add streaming placeholder for assistant
    final streamingPlaceholder = ChatMessageModel(
      role: 'assistant',
      content: '',
      timestamp: DateTime.now(),
      isStreaming: true,
    );
    setState(() {
      _messages.add(streamingPlaceholder);
      _isLoading = false;
    });
    _scrollToBottom();

    await _aiService.streamCompletion(
      messages: _messages
          .where((m) => !m.isStreaming && m.role != 'system')
          .toList(),
      onChunk: (chunk) {
        if (!mounted) return;
        setState(() {
          _streamingBuffer += chunk;
          // Update the last message (streaming placeholder)
          if (_messages.isNotEmpty && _messages.last.isStreaming) {
            _messages[_messages.length - 1] = _messages.last.copyWith(
              content: _streamingBuffer,
            );
          }
        });
        _scrollToBottom(animated: false);
      },
      onDone: () {
        if (!mounted) return;
        final finalContent = _streamingBuffer;
        setState(() {
          if (_messages.isNotEmpty && _messages.last.isStreaming) {
            _messages[_messages.length - 1] = ChatMessageModel(
              role: 'assistant',
              content: finalContent,
              timestamp: DateTime.now(),
              isStreaming: false,
            );
          }
          _isRequestLocked = false;
          _streamingBuffer = '';
        });
        _tryParseAndSaveTimetable(finalContent);
        _scrollToBottom();
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          if (_messages.isNotEmpty && _messages.last.isStreaming) {
            _messages[_messages.length - 1] = ChatMessageModel(
              role: 'assistant',
              content:
                  "I'm having trouble connecting right now. Please check your internet connection and try again.",
              timestamp: DateTime.now(),
              isStreaming: false,
            );
          }
          _isRequestLocked = false;
          _isLoading = false;
          _streamingBuffer = '';
        });
        _scrollToBottom();
      },
    );
  }

  Future<void> _tryParseAndSaveTimetable(String response) async {
    final tasks = OpenRouterService.tryParseTaskJson(response);
    if (tasks == null || tasks.isEmpty || !mounted) return;

    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final taskModels = tasks.map((t) {
      return TaskModel(
        title: t['title'] as String? ?? 'Task',
        startTime: t['startTime'] as String? ?? '09:00',
        endTime: t['endTime'] as String? ?? '10:00',
        category: t['category'] as String? ?? 'Study',
        description: t['description'] as String?,
        date: todayStr,
      );
    }).toList();

    for (final task in taskModels) {
      await _db.insertTask(task);
    }

    if (mounted) {
      setState(() => _generatedTasks = taskModels);
      _scrollToBottom();
    }
  }

  void _sendMessage() {
    if (!_isRequestLocked) {
      _sendToAi();
    }
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
            // Custom AppBar
            _buildAppBar(context),
            // Chat area
            Expanded(
              child: isTablet
                  ? Center(child: SizedBox(width: 640, child: _buildChatArea()))
                  : _buildChatArea(),
            ),
            // Input bar
            _buildInputBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.glassBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                context.pop();
              }
            },
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
          ),
          const SizedBox(width: 12),
          AiOrbWidget(size: 36, isAnimating: _isLoading || _isRequestLocked),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Scheduler',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Powered by GPT-4o mini',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.success.withAlpha(38),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.success.withAlpha(77)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Live',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount:
          _messages.length +
          (_isLoading ? 1 : 0) +
          (_generatedTasks != null ? 1 : 0),
      itemBuilder: (context, index) {
        // Typing indicator
        if (_isLoading && index == _messages.length) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: TypingIndicatorWidget(),
          );
        }
        // Generated tasks card
        if (_generatedTasks != null &&
            index == _messages.length + (_isLoading ? 1 : 0)) {
          return TaskCreatedCardWidget(
            tasks: _generatedTasks!,
            onDismiss: () => setState(() => _generatedTasks = null),
          );
        }
        final msg = _messages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ChatBubbleWidget(message: msg),
        );
      },
    );
  }

  Widget _buildInputBar(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + bottomPadding + keyboardPadding,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(top: BorderSide(color: AppTheme.glassBorder, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.glassBorder),
              ),
              child: TextField(
                controller: _inputController,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  hintText: 'Message AI Scheduler...',
                  hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _isRequestLocked ? null : _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isRequestLocked ? AppTheme.textMuted : AppTheme.primary,
                shape: BoxShape.circle,
                boxShadow: _isRequestLocked
                    ? null
                    : [
                        BoxShadow(
                          color: AppTheme.primary.withAlpha(102),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: _isRequestLocked
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : CustomIconWidget(
                        iconName: 'send_rounded',
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
