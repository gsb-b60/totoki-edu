import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/widget/reviewScreen.dart' as shared;
import 'package:totoki_extract/ui/screens/studymode/speechword/speechwordNoti.dart';
import 'package:provider/provider.dart';

class Speechword extends StatefulWidget {
  final int deck_id;
  Speechword({super.key, required this.deck_id});
  @override
  State<Speechword> createState() => _SpeechwordState();
}

class _SpeechwordState extends State<Speechword> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SpeechWordNoti()..getFlashcardList(widget.deck_id),
      child: Consumer<SpeechWordNoti>(
        builder: (context, value, child) {
          if (value.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const SpeechWordUI();
        },
      ),
    );
  }
}

class SpeechWordUI extends StatefulWidget {
  const SpeechWordUI({super.key});

  @override
  State<SpeechWordUI> createState() => _SpeechWordUIState();
}

class _SpeechWordUIState extends State<SpeechWordUI> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SpeechWordNoti>();
    final reader = context.read<SpeechWordNoti>();
    provider.initSTT();

    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.lightText,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: LinearProgressIndicator(
          value: provider.value,
          backgroundColor: AppTheme.darkCard,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.greenPrimary),
          minHeight: 12,
          borderRadius: BorderRadius.circular(6),
        ),
        backgroundColor: AppTheme.darkBase,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    "Speak this word",
                    style: AppTheme.sectionHeaderStyle.copyWith(
                      color: AppTheme.lightText,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  // Word Area
                  Column(
                    children: [
                      Text(
                        provider.word,
                        style: AppTheme.heroStyle.copyWith(
                          fontSize: 48,
                          color: AppTheme.bluePrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        provider.ipa,
                        style: AppTheme.bodyLargeStyle.copyWith(
                          fontSize: 24,
                          color: AppTheme.lightText.withOpacity(0.7),

                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Microphone Button Area
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48.0),
                    child: GestureDetector(
                      onTap: () => reader.startListening(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: provider.stt.isListening 
                                ? AppTheme.greenPrimary 
                                : AppTheme.bluePrimary,
                            width: 2,
                          ),
                          boxShadow: [
                            if (provider.stt.isListening)
                              BoxShadow(
                                color: AppTheme.greenPrimary.withOpacity(0.3),
                                blurRadius: 16,
                                spreadRadius: 4,
                              ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              provider.stt.isListening ? Icons.graphic_eq : Icons.mic,
                              color: provider.stt.isListening 
                                  ? AppTheme.greenPrimary 
                                  : AppTheme.bluePrimary,
                              size: 40,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              provider.stt.isListening ? "LISTENING..." : "TAP TO SPEAK",
                              style: AppTheme.sectionHeaderStyle.copyWith(
                                color: provider.stt.isListening 
                                    ? AppTheme.greenPrimary 
                                    : AppTheme.bluePrimary,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (provider.answered)
              shared.ReviewScreen(
                right: provider.right,
                answer: provider.word,
                onPressed: () => reader.SetNext(),
              ),
          ],
        ),
      ),
    );
  }
}



