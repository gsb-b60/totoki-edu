part of 'package:totoki_extract/features/lesson/notifier/lesson_noti.dart';

mixin LessonSpeech on LessonNotiBase, LessonResult {
  String re = "";
  final SpeechToText stt = SpeechToText();

  bool hasFinal = false;
  Timer? timeoutTimer;

  Future<void> initSTT() async {
    try {
      bool available = await stt.initialize(
        onStatus: (status) => debugPrint('STT status: $status'),
        onError: (errorNotification) =>
            debugPrint('STT error: $errorNotification'),
      );
      if (!available) {
        debugPrint('STT not available or permission denied');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> startListening() async {
    re = "";
    hasFinal = false;

    await stt.listen(
      onResult: (result) {
        if (result.finalResult) {
          debugPrint("user said ${result.recognizedWords}");
          re = result.recognizedWords;
          hasFinal = true;

          timeoutTimer?.cancel();
          stt.stop();
          CheckAnswerSpeech(re);
        }
      },
      localeId: "en_US",
    );

    while (!stt.isListening) {
      await Future.delayed(Duration(milliseconds: 30));
    }

    timeoutTimer = Timer(Duration(seconds: 5), () {
      if (!hasFinal) {
        stt.stop();
        CheckAnswerSpeech(re);
      }
    });
  }

  void CheckAnswerSpeech(String re) {
    re = re.toLowerCase().trim();
    var wordtrim = answer.toLowerCase().trim();
    answered = true;
    if (normalize(re) == normalize(wordtrim)) {
      right = true;
      ResultHandler(true);
    } else {
      ResultHandler(false);
      right = false;
    }
    notifyListeners();
  }

  void stopListen() async {
    await stt.stop();
  }

  void callDone() {
    answered = true;
    debugPrint("answer up");
    notifyListeners();
  }

  String get correctspeak {
    String str = "right is: $answer";
    if (re != "") {
      str += "  you said: $re";
    }
    return str;
  }
}