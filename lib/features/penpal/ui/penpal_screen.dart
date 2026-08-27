import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:totoki_extract/theme/app_theme.dart';

import 'widgets/letter_view.dart';
import 'widgets/letter_reply_input.dart';
import 'widgets/typing_indicator.dart';
import 'widgets/result_overlay.dart';
import '../notifier/penpal_notifier.dart';
import '../data/penpal_data.dart';
import '../models/penpal_friend.dart';

class PenpalScreen extends StatefulWidget {
  const PenpalScreen({super.key});

  @override
  State<PenpalScreen> createState() => _PenpalScreenState();
}

class _PenpalScreenState extends State<PenpalScreen> {
  final ScrollController _scrollController = ScrollController();
  PenpalNotifier? _notifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifier = context.read<PenpalNotifier>();
      _notifier!.addListener(_onGameUpdate);
    });
  }

  @override
  void dispose() {
    _notifier?.removeListener(_onGameUpdate);
    _scrollController.dispose();
    super.dispose();
  }

  void _onGameUpdate() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PenpalNotifier>(
      builder: (context, notifier, _) {
        final friend = notifier.selectedFriend;
        if (friend == null) {
          return _buildSelectionScreen(context);
        }
        return _buildCorrespondenceScreen(context, notifier, friend);
      },
    );
  }

  Widget _buildSelectionScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Mailbox',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'Select a Penpal',
                style: AppTheme.heroStyle.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 6),
              Text(
                'Commence a letters exchange about deep knowledge with a friend from afar.',
                style: AppTheme.bodyMediumStyle.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: PenpalData.friends.map((friend) {
                    IconData icon;
                    Color color;
                    if (friend.id == 'history') {
                      icon = Icons.menu_book;
                      color = AppTheme.yellowPrimary;
                    } else if (friend.id == 'physics') {
                      icon = Icons.science;
                      color = AppTheme.bluePrimary;
                    } else {
                      icon = Icons.terminal;
                      color = AppTheme.greenPrimary;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.darkBorder),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () {
                              context.read<PenpalNotifier>().selectFriend(friend);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: color.withValues(alpha: 0.15),
                                        child: Icon(icon, color: color),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              friend.name,
                                              style: AppTheme.bodyLargeStyle.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${friend.subject} • ${friend.location}',
                                              style: AppTheme.captionStyle.copyWith(
                                                color: Colors.white60,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    friend.description,
                                    style: AppTheme.bodyMediumStyle.copyWith(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Start Writing',
                                          style: TextStyle(
                                            color: AppTheme.sciSpark,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 14,
                                          color: AppTheme.sciSpark,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorrespondenceScreen(
      BuildContext context, PenpalNotifier notifier, PenpalFriend friend) {
    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => notifier.goBackToSelection(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              friend.name,
              style: AppTheme.bodyMediumStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${friend.subject} correspondence',
              style: AppTheme.captionStyle.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: notifier.friendshipLevel / 100,
            backgroundColor: AppTheme.darkBorder,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.sciSpark),
            minHeight: 3,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  itemCount: notifier.messages.length + (notifier.isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == notifier.messages.length) {
                      return TypingIndicator(senderName: friend.name);
                    }
                    final msg = notifier.messages[index];
                    return LetterView(
                      message: msg,
                      senderName: msg.isUser ? 'You' : friend.name,
                    );
                  },
                ),
              ),
              if (notifier.gameStatus == GameStatus.playing && !notifier.isTyping)
                LetterReplyInput(
                  key: ValueKey('${friend.id}_${notifier.currentStageIndex}'),
                  keywords: notifier.currentStage.requiredKeywords,
                  onSubmit: notifier.submitReply,
                  attemptsRemaining: notifier.attemptsRemaining,
                  maxAttempts: notifier.maxAttempts,
                ),
            ],
          ),
          if (notifier.gameStatus != GameStatus.playing)
            ResultOverlay(
              status: notifier.gameStatus,
              friendship: notifier.friendshipLevel,
              onRestart: () {
                notifier.selectFriend(friend);
              },
              onBackToMenu: () {
                notifier.goBackToSelection();
              },
            ),
        ],
      ),
    );
  }
}