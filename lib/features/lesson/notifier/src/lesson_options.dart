part of 'package:totoki_extract/features/lesson/notifier/lesson_noti.dart';

mixin LessonOptions on LessonNotiBase, LessonResult {
  //list
  List<String>? trueList;
  List<String>? list;
  List<String>? listWord;
  List<ButtonState>? states;
  List<bool>? statesBool;
  List<String>? options;

  List<String> get getOptionsShuffle {
    options ??= genOptionsShuffle();
    return options!;
  }

  List<String> genOptionsShuffle() {
    List<String> re = lessonNotiHelper.genOptionsShuffleHelp(_cards, cardIdx);
    statesBool = List.generate(re.length, (_) => false);
    return re;
  }

  void CheckAnswer(String letter, int index) {
    if (letter == trueList![currentWordIdx]) {
      states![index] = ButtonState.done;
      listWord![currentWordIdx] = trueList![currentWordIdx];
      notifyListeners();
      currentWordIdx++;
    } else {
      ResultHandler(false);
      inARow = 0;
      states![index] = ButtonState.wrong;
      notifyListeners();
      Future.delayed(Duration(milliseconds: 100), () {
        states![index] = ButtonState.normal;
        notifyListeners();
      });
    }
    if (currentWordIdx == list!.length) {
      answered = true;
      ResultHandler(true);
      notifyListeners();
    }
  }

  List<ButtonState> GetListState() {
    states ??= List.generate(list!.length, (_) => ButtonState.normal);
    return states!;
  }

  List<String> SetUpList() {
    if (list == null && _cards.isNotEmpty) {
      list = _cards[cardIdx].word?.split("");
      trueList = _cards[cardIdx].word!.split("");

      if (list!.length > 1) {
        do {
          list!.shuffle();
        } while (listEquals(list, trueList));
      }
    }
    return list!;
  }

  List<String> SetUpListWord() {
    listWord ??= List.filled(list!.length, "_");
    return listWord!;
  }

  void checkAnswerMC() {
    if (options?[selectedIndex!] == _cards[cardIdx].word) {
      answered = true;
      ResultHandler(true);
      notifyListeners();
    } else {
      answered = true;
      right = false;
      ResultHandler(false);
      inARow = 0;
      notifyListeners();
    }
  }

  void selectOption(int index) {
    if (selectedIndex == null) {
      selectedIndex = index;
      statesBool?[index] = true;
    } else {
      statesBool?[selectedIndex!] = false;
      selectedIndex = index;
      statesBool?[index] = true;
    }

    notifyListeners();
  }

  List<bool> getOptionStateBool() {
    statesBool ??= List<bool>.filled(3, false);
    return statesBool!;
  }

  List<String> genOptions() {
    final List<String> strs = [];
    String word = _cards[cardIdx].word!;
    final rand = Random();
    strs.add(word);

    const String alphabet = 'abcdefghijklmnopqrstuvwxyz';

    while (strs.length < 3) {
      String mixed;
      int attempts = 0;

      if (strs.length == 1) {
        do {
          mixed = generateVariant(word, rand);
          attempts++;
        } while ((mixed == word || strs.contains(mixed)) && attempts < 10);
      } else {
        // Second distractor: full shuffle
        final letters = word.split('');
        do {
          final shuffled = List.from(letters)..shuffle(rand);
          mixed = shuffled.join('');
          attempts++;
        } while ((mixed == word || strs.contains(mixed)) && attempts < 10);
      }

      // Fallback if max attempts reached and no unique variant found
      if (mixed == word || strs.contains(mixed)) {
        int fallbackAttempts = 0;
        do {
          if (word.isNotEmpty) {
            final chars = word.split('');
            int i = rand.nextInt(chars.length);
            chars[i] = alphabet[rand.nextInt(alphabet.length)];
            mixed = chars.join('');
          } else {
            mixed = alphabet[rand.nextInt(alphabet.length)];
          }
          fallbackAttempts++;
          if (fallbackAttempts > 50) {
            // Absolute last resort
            mixed = "${word}_${rand.nextInt(1000)}";
          }
        } while (mixed == word || strs.contains(mixed));
      }

      strs.add(mixed);
    }
    List<String> shuffle = List.from(strs)..shuffle(rand);
    statesBool = List.generate(shuffle.length, (_) => false);
    debugPrint('$shuffle');
    return shuffle;
  }

  String generateVariant(String word, Random rand) {
    if (word.length < 2) return word;

    final chars = word.split('');

    int i = rand.nextInt(chars.length);
    int j = rand.nextInt(chars.length);

    if (i == j) j = (j + 1) % chars.length;

    final temp = chars[i];
    chars[i] = chars[j];
    chars[j] = temp;

    return chars.join('');
  }

  List<String> get getOptionList {
    options ??= genOptions();
    return options!;
  }
}