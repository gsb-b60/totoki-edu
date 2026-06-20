import os
import re

lib_dir = 'd:/secobapCoop/totoki_seperate/totoki_extract/lib'
import_statement = "import 'package:flutter_screenutil/flutter_screenutil.dart';\n"

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find fontSize: <number>
    # We want to replace fontSize: 40 with fontSize: 40.sp
    pattern = r'fontSize:\s*(\d+(?:\.\d+)?)(?!\.sp)'
    
    if re.search(pattern, content):
        new_content = re.sub(pattern, r'fontSize: \1.sp', content)
        
        # Add import if not present
        if "package:flutter_screenutil" not in new_content:
            # Find the first import
            import_match = re.search(r'^import .*?;', new_content, re.MULTILINE)
            if import_match:
                insert_pos = import_match.end()
                new_content = new_content[:insert_pos] + '\n' + import_statement + new_content[insert_pos:]
            else:
                new_content = import_statement + new_content
                
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

print("Done.")
