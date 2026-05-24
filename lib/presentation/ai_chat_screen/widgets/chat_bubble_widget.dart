import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../models/chat_message_model.dart';
import '../../../theme/app_theme.dart';
import './ai_orb_widget.dart';

class ChatBubbleWidget extends StatelessWidget {
  final ChatMessageModel message;

  const ChatBubbleWidget({super.key, required this.message});

  bool get _isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: _isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!_isUser) ...[
          AiOrbWidget(size: 28, isAnimating: message.isStreaming),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(_isUser ? 20 : 4),
                bottomRight: Radius.circular(_isUser ? 4 : 20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: _isUser
                        ? LinearGradient(
                            colors: [
                              AppTheme.primary,
                              AppTheme.primary.withAlpha(204),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: _isUser ? null : AppTheme.cardDark,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(_isUser ? 20 : 4),
                      bottomRight: Radius.circular(_isUser ? 4 : 20),
                    ),
                    border: _isUser
                        ? null
                        : Border.all(color: AppTheme.glassBorder),
                    boxShadow: _isUser
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withAlpha(51),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.content.isEmpty && message.isStreaming)
                        const _CursorBlink()
                      else
                        Text(
                          message.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: _isUser
                                ? Colors.white
                                : AppTheme.textPrimary,
                            height: 1.55,
                          ),
                        ),
                      if (message.isStreaming && message.content.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: _CursorBlink(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isUser) const SizedBox(width: 8),
      ],
    );
  }
}

class _CursorBlink extends StatefulWidget {
  const _CursorBlink();

  @override
  State<_CursorBlink> createState() => _CursorBlinkState();
}

class _CursorBlinkState extends State<_CursorBlink>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(width: 2, height: 16, color: AppTheme.primaryLight),
    );
  }
}
