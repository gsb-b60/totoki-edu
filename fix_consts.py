import os
import re

files_to_fix = [
    "lib/main.dart",
    "lib/ui/lesson/screen/endscreen.dart",
    "lib/ui/lesson/screen/startscreen.dart",
    "lib/ui/lesson/studymodeForLesson/mindfieldui.dart",
    "lib/ui/lesson/studymodeForLesson/phonemixUI.dart",
    "lib/ui/lesson/studymodeForLesson/reviewUI.dart",
    "lib/ui/lesson/studymodeForLesson/sound&sightUI.dart",
    "lib/ui/lesson/studymodeForLesson/wordsnapUI.dart",
    "lib/ui/screens/blankfill/blankwordscreen.dart",
    "lib/ui/screens/dashboard/dueDay.dart",
    "lib/ui/screens/decklist/cardlistscreen.dart",
    "lib/ui/screens/decklist/deckwelcome.dart",
    "lib/ui/screens/studymode/echospell/echospellUI.dart",
    "lib/ui/screens/studymode/flashcard/back.dart",
    "lib/ui/screens/studymode/flashcard/newwayreview.dart",
    "lib/ui/screens/studymode/meanfuse/meanfuse.dart",
    "lib/ui/screens/studymode/phonemix/phonemixUI.dart",
    "lib/ui/screens/studymode/sound&sight/sound&sightUI.dart",
    "lib/ui/screens/studymode/speechword/speechword.dart",
    "lib/widget/checkBtn.dart",
    "lib/widget/choiceBtn.dart",
    "lib/widget/choiceBtn4States.dart",
    "lib/widget/choiceBtnVertical.dart",
    "lib/widget/progessIndicator.dart"
]

base_dir = 'd:/secobapCoop/totoki_seperate/totoki_extract'

for file_path in files_to_fix:
    full_path = os.path.join(base_dir, file_path)
    if not os.path.exists(full_path):
        continue
        
    with open(full_path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    # Remove `const WidgetName(`
    content = re.sub(r'const\s+([A-Z]\w*\()', r'\1', content)
    # Remove `const [`
    content = re.sub(r'const\s*\[', r'[', content)
    # Remove `const {`
    content = re.sub(r'const\s*\{', r'{', content)
    
    with open(full_path, 'w', encoding='utf-8') as f:
        f.write(content)
        
print("Removed consts.")
