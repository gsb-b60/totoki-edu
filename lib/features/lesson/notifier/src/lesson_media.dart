part of 'package:totoki_extract/features/lesson/notifier/lesson_noti.dart';

mixin LessonMedia on LessonNotiBase {
  String media = "";
  Map<int, String> mediaMap = {};

  String getImagePath() {
    if (File(
      PathService.getFilePath(media, _cards[cardIdx].img ?? ""),
    ).existsSync()) {
      return PathService.getFilePath(media, _cards[cardIdx].img ?? "");
    }
    return "";
  }

  String getSynonymPath() {
    if (File(
      PathService.getFilePath(media, _cards[cardIdx].synonyms ?? ""),
    ).existsSync()) {
      return PathService.getFilePath(media, _cards[cardIdx].synonyms ?? "");
    }
    if (File(
      PathService.getFilePath(media, _cards[cardIdx].img ?? ""),
    ).existsSync()) {
      return PathService.getFilePath(media, _cards[cardIdx].img ?? "");
    }
    return "";
  }

  final AudioPlayer audioPlayer = AudioPlayer();

  Future<void> playSound() async {
    if (media != "") {
      try {
        await audioPlayer.play(
          DeviceFileSource(
            PathService.getFilePath(media, _cards[cardIdx].sound ?? ""),
          ),
        );
      } catch (e) {
        debugPrint('$e');
      }
    }
  }

  //function
  Future<String> fetchMedia() async {
    try {
      int deckId = _cards[cardIdx].deckId;
      if (mediaMap.containsKey(deckId)) {
        media = mediaMap[deckId] ?? "";
        return mediaMap[deckId]!;
      } else {
        String md = await LessonNotiBase._dbhelper.getMediaFile(deckId) ?? "";
        mediaMap[deckId] = md;
        media = mediaMap[deckId] ?? "";
        return md;
      }
    } catch (e) {
      debugPrint('$e');
      return "";
    }
  }
}